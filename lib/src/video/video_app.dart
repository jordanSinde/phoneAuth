import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

class Video {
  final String id;
  final String storagePath;
  final String description;
  final String image;

  Video({
    required this.id,
    required this.storagePath,
    required this.description,
    required this.image,
  });
}

class VideoPlayerScreen extends StatefulWidget {
  final Video video;

  const VideoPlayerScreen({super.key, required this.video});

  @override
  State<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  late VideoPlayerController _videoController;
  late Future<void> _initializeVideoPlayerFuture;
  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();
    _initializeVideo();
  }

  @override
  void dispose() {
    _videoController.dispose();
    super.dispose();
  }

  void _initializeVideo() async {
    final storage = FirebaseStorage.instance.ref();
    final videoUrl =
        await storage.child(widget.video.storagePath).getDownloadURL();

    _videoController = VideoPlayerController.networkUrl(Uri.parse(videoUrl));

    _initializeVideoPlayerFuture = _videoController.initialize().then((_) {
      setState(() {});
    });

    _videoController.addListener(() {
      setState(() {});
    });

    _videoController.setLooping(true);
  }

  void _toggleVideoPlayback() {
    setState(() {
      _isPlaying = !_isPlaying;
      if (_isPlaying) {
        _videoController.play();
      } else {
        _videoController.pause();
      }
    });
  }

  Widget _buildVideoPlayer() {
    return AspectRatio(
      aspectRatio: _videoController.value.aspectRatio,
      child: VideoPlayer(_videoController),
    );
  }

  Widget _buildPlaybackControls() {
    return Column(
      children: [
        IconButton(
          icon: Icon(_isPlaying ? Icons.pause : Icons.play_arrow),
          onPressed: _toggleVideoPlayback,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.video.description),
      ),
      body: FutureBuilder(
        future: _initializeVideoPlayerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          } else {
            return Column(
              children: [
                _buildVideoPlayer(),
                _buildPlaybackControls(),
              ],
            );
          }
        },
      ),
    );
  }
}

class VideoListScreen extends StatelessWidget {
  const VideoListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Video List'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('videos').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          } else {
            final videos = snapshot.data!.docs.map((doc) {
              final data = doc.data() as Map<String, dynamic>;
              return Video(
                id: doc.id,
                storagePath: data['storagePath'],
                description: data['description'],
                image: data['image'],
              );
            }).toList();

            return ListView.builder(
              itemCount: videos.length,
              itemBuilder: (context, index) {
                final video = videos[index];
                return ListTile(
                  title: Text(video.description),
                  trailing: Image.network(video.image),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => VideoPlayerScreen(video: video),
                      ),
                    );
                  },
                );
              },
            );
          }
        },
      ),
    );
  }
}
