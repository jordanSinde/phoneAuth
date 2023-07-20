import 'package:flutter/material.dart';
import 'package:phone_auth/src/video/get_download_url.dart';
import 'package:video_player/video_player.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'type_def.dart';

class LessonPart {
  final PartLessonId partLessonId;
  final String storagePath;
  final String description;
  final String image;

  LessonPart({
    required this.partLessonId,
    required this.storagePath,
    required this.description,
    required this.image,
  });

  factory LessonPart.fromMap(Map<String, dynamic> map) {
    return LessonPart(
      partLessonId: map['partLessonId'] ?? "",
      storagePath: map['storagePath'] ?? "",
      description: map['description'] ?? "",
      image: map['image'] ?? "",
    );
  }
}

class VideoPlayerScreen extends StatefulWidget {
  final LessonPart video;

  const VideoPlayerScreen({super.key, required this.video});

  @override
  State<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  late VideoPlayerController _videoController;
  late Future<void> _initializeVideoPlayerFuture;
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
        VideoPlayerController.networkUrl(Uri.parse(widget.video.storagePath));

    _initializeVideoPlayerFuture = _videoController.initialize().then((_) {
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
    String formattedCurrentPosition = _formatDuration(_currentPosition);
    String formattedVideoDuration = _formatDuration(_videoDuration);

    return Text(
      '$formattedCurrentPosition / $formattedVideoDuration',
      style: const TextStyle(fontSize: 16),
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) {
      if (n >= 10) return "$n";
      return "0$n";
    }

    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    String twoDigitHours = twoDigits(duration.inHours);

    return "$twoDigitHours:$twoDigitMinutes:$twoDigitSeconds";
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
          if (snapshot.connectionState == ConnectionState.done) {
            // If the VideoPlayerController has finished initialization, use
            // the data it provides to limit the aspect ratio of the video.
            return videoView();
          } else {
            // If the VideoPlayerController is still initializing, show a
            // loading spinner.
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
        },
      ),
    );
  }

  SingleChildScrollView videoView() {
    return SingleChildScrollView(
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
    );
  }
}

class VideoListScreen extends StatelessWidget {
  const VideoListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
          appBar: AppBar(
            title: const Text('Video List'),
            bottom: const TabBar(
              tabs: [
                Tab(icon: Icon(Icons.video_collection)),
                Tab(icon: Icon(Icons.download)),
              ],
            ),
          ),
          body: const TabBarView(
            children: [
              LessonView(),
              UploadDownloadFileInStorage(),
            ],
          )),
    );
  }
}

class LessonView extends StatefulWidget {
  const LessonView({
    super.key,
  });

  @override
  State<LessonView> createState() => _LessonViewState();
}

class _LessonViewState extends State<LessonView> {
  final Stream<QuerySnapshot> _lessonPartStream =
      FirebaseFirestore.instance.collection('videos').snapshots();
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: _lessonPartStream,
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
            return LessonPart.fromMap(data);
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
                      fullscreenDialog: true,
                    ),
                  );
                },
              );
            },
          );
        }
      },
    );
  }
}
