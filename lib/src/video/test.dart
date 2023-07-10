/*

import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:phone_auth/src/video/video.dart';
import 'package:video_player/video_player.dart';

class VideoApp extends StatefulWidget {
  @override
  _VideoAppState createState() => _VideoAppState();
}

class _VideoAppState extends State<VideoApp> {
  late VideoPlayerController _controller;
  bool _isPlaying = false;
  bool _isFullScreen = false;
  List<Video> _videos = [];
  int _currentVideoIndex = 0;
  late Timer _countdownTimer;
  int _countdown = 0;

  @override
  void initState() {
    super.initState();
    _fetchVideos();
  }

  @override
  void dispose() {
    _controller.dispose();
    _stopCountdown();
    super.dispose();
  }

  void _fetchVideos() async {
    QuerySnapshot snapshot =
        await FirebaseFirestore.instance.collection('collection_name').get();

    List<Video> videos = [];
    snapshot.docs.forEach((doc) {
      String id = doc.id;
      String url = doc.get('url') ?? '';
      String description = doc.get('description') ?? '';
      String image = doc.get('image') ?? '';
      videos
          .add(Video(id: id, url: url, description: description, image: image));
    });

    setState(() {
      _videos = videos;
    });
  }

  void _playVideo(int index) {
    setState(() {
      _currentVideoIndex = index;
      _controller =
          VideoPlayerController.network(_videos[_currentVideoIndex].url)
            ..initialize().then((_) {
              setState(() {
                _isPlaying = true;
                _startCountdown();
              });
            });
      _controller.addListener(() {
        setState(() {});
      });
    });
  }

  void _playPauseVideo() {
    setState(() {
      if (_controller.value.isPlaying) {
        _controller.pause();
        _isPlaying = false;
      } else {
        _controller.play();
        _isPlaying = true;
      }
    });
  }

  void _seekForward() {
    setState(() {
      final Duration newPosition =
          _controller.value.position + Duration(seconds: 10);
      _controller.seekTo(newPosition);
    });
  }

  void _seekBackward() {
    setState(() {
      final Duration newPosition =
          _controller.value.position - Duration(seconds: 10);
      _controller.seekTo(newPosition);
    });
  }

  void _toggleFullScreen() {
    setState(() {
      _isFullScreen = !_isFullScreen;
    });
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "${duration.inHours > 0 ? twoDigits(duration.inHours) + ':' : ''}$twoDigitMinutes:$twoDigitSeconds";
  }

  void _startCountdown() {
    _countdownTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        if (_controller.value.isPlaying) {
          _countdown = _controller.value.duration.inSeconds -
              _controller.value.position.inSeconds;
          if (_countdown <= 0) {
            _countdownTimer.cancel();
          }
        }
      });
    });
  }

  void _stopCountdown() {
    _countdownTimer?.cancel();
    _countdown = 0;
  }

  Widget _buildVideoList() {
    return ListView.builder(
      itemCount: _videos.length,
      itemBuilder: (context, index) {
        return ListTile(
          leading: Image.network(_videos[index].image),
          title: Text(_videos[index].description),
          onTap: () {
            _playVideo(index);
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final double statusBarHeight = MediaQuery.of(context).padding.top;
    final double videoAspectRatio = _controller?.value?.aspectRatio ?? 16 / 9;

    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('Lecteur vidéo'),
        ),
        body: Stack(
          children: <Widget>[
            Positioned.fill(
              child: _buildVideoList(),
            ),
            if (_videos.isNotEmpty && _isPlaying)
              Container(
                margin: EdgeInsets.only(top: statusBarHeight),
                child: Center(
                  child: AspectRatio(
                    aspectRatio: videoAspectRatio,
                    child: VideoPlayer(_controller),
                  ),
                ),
              ),
            if (_videos.isNotEmpty && _isPlaying)
              GestureDetector(
                onTap: _playPauseVideo,
                child: Container(
                  margin: EdgeInsets.only(top: statusBarHeight),
                  color: Colors.transparent,
                ),
              ),
            if (!_isFullScreen && _videos.isNotEmpty && _isPlaying)
              Container(
                margin: EdgeInsets.only(top: statusBarHeight),
                child: Center(
                  child: IconButton(
                    icon: Icon(
                      _isPlaying ? Icons.pause : Icons.play_arrow,
                      size: 40.0,
                      color: Colors.white,
                    ),
                    onPressed: _playPauseVideo,
                  ),
                ),
              ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                color: Colors.black.withOpacity(0.5),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    IconButton(
                      icon: Icon(
                        Icons.replay_10,
                        color: Colors.white,
                      ),
                      onPressed: _seekBackward,
                    ),
                    IconButton(
                      icon: Icon(
                        _isPlaying ? Icons.pause : Icons.play_arrow,
                        color: Colors.white,
                      ),
                      onPressed: _playPauseVideo,
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.forward_10,
                        color: Colors.white,
                      ),
                      onPressed: _seekForward,
                    ),
                    IconButton(
                      icon: Icon(
                        _isFullScreen
                            ? Icons.fullscreen_exit
                            : Icons.fullscreen,
                        color: Colors.white,
                      ),
                      onPressed: _toggleFullScreen,
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              bottom: 45.0,
              left: 0,
              right: 0,
              child: VideoProgressIndicator(
                _controller,
                allowScrubbing: true,
                padding: EdgeInsets.symmetric(horizontal: 20.0),
                colors: VideoProgressColors(
                  playedColor: Colors.red,
                  bufferedColor: Colors.grey,
                  backgroundColor: Colors.white,
                ),
              ),
            ),
            Positioned(
              bottom: 20.0,
              right: 20.0,
              child: Row(
                children: [
                  Text(
                    '${_formatDuration(_controller.value?.position ?? Duration.zero)} / ${_formatDuration(_controller.value?.duration ?? Duration.zero)}',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(width: 10.0),
                  Text(
                    'Countdown: $_countdown seconds',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: _playNextVideo,
          child: Icon(Icons.skip_next),
        ),
      ),
    );
  }
}


*/