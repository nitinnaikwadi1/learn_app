import 'package:video_player/video_player.dart';
import 'package:learn_app/globals.dart';

Future<void> play(String url) async {
  if (url.isEmpty) return;
  if (videoPlayerController.value.isInitialized) {
    await videoPlayerController.dispose();
  }
  videoPlayerController = VideoPlayerController.networkUrl(
    Uri.parse(url),
    videoPlayerOptions: VideoPlayerOptions(mixWithOthers: true),
  );
  videoPlayerController.setLooping(false);
  
  return videoPlayerController
      .initialize()
      .then((value) => videoPlayerController.play());
}