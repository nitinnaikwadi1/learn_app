import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

VideoPlayerController videoPlayerController =
    VideoPlayerController.networkUrl(Uri.parse(''));

ValueNotifier<Future<void>?> videoFuture = ValueNotifier(null);