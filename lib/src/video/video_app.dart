import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Video {
  final String id;
  final String url;
  final String description;
  final String image;

  Video({
    required this.id,
    required this.url,
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
  bool _isPlaying = false;
  bool _isInitialized = false;
  Duration _videoDuration = Duration.zero;
  Duration _currentPosition = Duration.zero;

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

  void _initializeVideo() {
    _videoController =
        VideoPlayerController.networkUrl(Uri.parse(widget.video.url))
          ..initialize().then((_) {
            setState(() {
              _isInitialized = true;
              _videoDuration = _videoController.value.duration;
            });
          });

    _videoController.addListener(() {
      setState(() {
        _currentPosition = _videoController.value.position;
      });
    });
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

  void _skipForward() {
    Duration newPosition =
        _videoController.value.position + const Duration(seconds: 10);
    if (newPosition <= _videoDuration) {
      _videoController.seekTo(newPosition);
    }
  }

  void _skipBackward() {
    Duration newPosition =
        _videoController.value.position - const Duration(seconds: 10);
    if (newPosition >= Duration.zero) {
      _videoController.seekTo(newPosition);
    }
  }

  Widget _buildProgressBar() {
    double progress = _videoDuration != Duration.zero
        ? _currentPosition.inMilliseconds / _videoDuration.inMilliseconds
        : 0.0;
    return SizedBox(
      height: 4,
      child: LinearProgressIndicator(
        value: progress.isFinite ? progress : 0.0,
        backgroundColor: Colors.grey[300],
        valueColor: const AlwaysStoppedAnimation<Color>(Colors.blue),
      ),
    );
  }

  Widget _buildCountdown() {
    return Text(
      '${_currentPosition.inSeconds} / ${_videoDuration.inSeconds}',
      style: const TextStyle(fontSize: 16),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.video.description),
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AspectRatio(
              aspectRatio: 16 / 9,
              child: _isInitialized
                  ? VideoPlayer(_videoController)
                  : const CircularProgressIndicator(),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: Icon(_isPlaying ? Icons.pause : Icons.play_arrow),
                  onPressed: _toggleVideoPlayback,
                ),
                IconButton(
                  icon: const Icon(Icons.replay_10),
                  onPressed: _skipBackward,
                ),
                IconButton(
                  icon: const Icon(Icons.forward_10),
                  onPressed: _skipForward,
                ),
              ],
            ),
            _buildProgressBar(),
            _buildCountdown(),
          ],
        ),
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
                url: data['url'],
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
