import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';

import 'package:cached_video_player_plus/cached_video_player_plus.dart';

class VideoPlayerWidget extends StatefulWidget {
  final String videoUrl;

  const VideoPlayerWidget({Key? key, required this.videoUrl}) : super(key: key);

  @override
  State<VideoPlayerWidget> createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<VideoPlayerWidget> {
  late CachedVideoPlayerPlus _videoPlayerController;
  late ChewieController _chewieController;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    initializePlayer();
  }

  Future<void> initializePlayer() async {
    _videoPlayerController = CachedVideoPlayerPlus.networkUrl(
      Uri.parse(widget.videoUrl),
    );
    await _videoPlayerController.initialize();

    _chewieController = ChewieController(
      allowMuting: false,
      showControlsOnInitialize: false,
      videoPlayerController: _videoPlayerController.controller,
      autoPlay: true,
      looping: true,
      placeholder: Container(color: Colors.grey[300]),
    );

    setState(() {
      _isLoading = false;
    });
  }

  @override
  void dispose() {
    _videoPlayerController.dispose();
    _chewieController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Chewie(controller: _chewieController),
    );
  }
}
