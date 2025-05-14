import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:learn_app/model/dashboard_item.dart';
import 'package:learn_app/properties/app_constants.dart' as properties;
import 'package:learn_app/theme/circle_action_button_widget.dart';
import 'package:just_audio/just_audio.dart';
import 'package:avatar_glow/avatar_glow.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:flutter_glow/flutter_glow.dart';
import 'package:flutter_shake_animated/flutter_shake_animated.dart';

class ContentInteractiveView extends StatefulWidget {
  final String whichContent;

  const ContentInteractiveView({super.key, required this.whichContent});

  @override
  State<ContentInteractiveView> createState() => _ContentInteractiveViewState();
}

class _ContentInteractiveViewState extends State<ContentInteractiveView>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  bool clicked = false;
  var contentData = [];
  var whichDataIndex = 0;
  late AudioPlayer contentPlayer;
  bool contentAudioFlag = true;
  String randomObjectFrame1 = '';
  String randomObjectFrame2 = '';
  String contentImage = '';
  String contentBackgImage = '';

  Future<List<DashboardItem>> readJsonData() async {
    var contentLink = widget.whichContent;

    var contentJsonFromURL = await http
        .get(Uri.parse(properties.learningAppContentUrl + contentLink));
    final list = json.decode(contentJsonFromURL.body) as List<dynamic>;

    if (!(contentLink == "alphabets.json" || contentLink == "numbers.json")) {
      list.shuffle();
    }

    setState(() {
      contentData = list;
    });

    whichDataIndex = 0;
    if (contentAudioFlag) {
      contentPlayer.setUrl(properties.learningAppContentAudioUrl +
          contentData[whichDataIndex]['audio']);
      contentPlayer.play();
    } else {
      contentPlayer.stop();
    }

    contentImage = contentData[whichDataIndex]['url'];

    return list.map((e) => DashboardItem.fromJson(e)).toList();
  }

  Future<void> randomObjectsFramesData() async {
    var randomAnimalFramesJsonFromURL =
        await http.get(Uri.parse(properties.learningAppRandomFramesDataUrl));
    var randomAnimalsFramesList =
        json.decode(randomAnimalFramesJsonFromURL.body) as List<dynamic>;
    randomAnimalsFramesList.shuffle();

    setState(() {
      randomObjectFrame1 = randomAnimalsFramesList[0]['url'];
      randomObjectFrame2 = randomAnimalsFramesList[1]['url'];
    });
  }

  Future<void> randomBackgroundImageData() async {
    var randomContentBackgJsonFromURL =
        await http.get(Uri.parse(properties.learningAppBackgroundFramesUrl));
    var randomContentBackgList =
        json.decode(randomContentBackgJsonFromURL.body) as List<dynamic>;
    randomContentBackgList.shuffle();

    setState(() {
      contentBackgImage = randomContentBackgList[0]['url'];
    });
  }

  @override
  void initState() {
    super.initState();
    contentPlayer = AudioPlayer();
    contentPlayer.setSpeed(0.88);
    contentPlayer.setLoopMode(LoopMode.all);

    WidgetsBinding.instance.addObserver(this);
    readJsonData();
    randomObjectsFramesData();
    randomBackgroundImageData();
  }

  @override
  void dispose() {
    contentPlayer.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.detached ||
        state == AppLifecycleState.paused) {
      contentPlayer.stop();
    }

    if (state == AppLifecycleState.resumed) {
      if (contentAudioFlag) {
        contentPlayer.play();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: contentBackgImage == '' || contentImage == ''
          ? const LoadingIndicator(
              colors: properties.kDefaultRainbowColors,
              indicatorType: Indicator.pacman,
              strokeWidth: 3,
              pause: false,
            )
          : Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  fit: BoxFit.fill,
                  image: AssetImage(
                      "${properties.learningAppBackgroundItemsUrl}$contentBackgImage"),
                ),
              ),
              child: Stack(
                children: <Widget>[
                  Center(
                    child: ShakeWidget(
                      shakeConstant: ShakeSlowConstant1(),
                      autoPlay: true,
                      child: Card(
                        elevation: 20,
                        semanticContainer: true,
                        clipBehavior: Clip.antiAliasWithSaveLayer,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                          side: const BorderSide(
                            strokeAlign: BorderSide.strokeAlignInside,
                            color: Colors.pinkAccent,
                            width: 3.0,
                          ),
                        ),
                        child: SizedBox(
                          child: Image.network(
                            '${properties.learningAppContentMediaUrl}$contentImage',
                            loadingBuilder: (BuildContext context, Widget child,
                                ImageChunkEvent? loadingProgress) {
                              if (loadingProgress == null) return child;
                              return const LoadingIndicator(
                                colors: properties.kDefaultRainbowColors,
                                indicatorType: Indicator.pacman,
                                strokeWidth: 3,
                                pause: false,
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 365.0),
                    child: Center(
                      child: GlowText(
                        contentData[whichDataIndex]['name'],
                        style: const TextStyle(
                          fontSize: 50,
                          fontStyle: FontStyle.italic,
                          color: Colors.black54,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 440.0),
                    child: Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          AvatarGlow(
                            glowColor: Colors.pinkAccent,
                            child: CircularActionButton(
                              onPressed: () async {
                                setState(() {
                                  // last index of arr
                                  if (whichDataIndex ==
                                      contentData.length - 1) {
                                    whichDataIndex = 0;
                                  } else {
                                    whichDataIndex += 1;
                                  }
                                  contentImage =
                                      contentData[whichDataIndex]['url'];
                                });
                                if (contentAudioFlag) {
                                  await contentPlayer.setUrl(
                                      properties.learningAppContentAudioUrl +
                                          contentData[whichDataIndex]['audio']);
                                  contentPlayer.play();
                                } else {
                                  contentPlayer.stop();
                                }
                              },
                              icon: const Icon(
                                Icons.swipe_vertical_outlined,
                                color: Colors.pinkAccent,
                              ),
                              iconSize: 52,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: Align(
                      alignment: Alignment.topLeft,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25.0),
                          ),
                          padding: const EdgeInsets.all(15),
                        ),
                        child: const Icon(
                          Icons.arrow_back_rounded,
                          color: Colors.green,
                          size: 32,
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: Align(
                      alignment: Alignment.topRight,
                      child: ElevatedButton(
                        onPressed: () async {
                          // flag to toggle the content audio flag
                          setState(() {
                            contentAudioFlag = !contentAudioFlag;
                          });

                          if (contentAudioFlag) {
                            contentPlayer.play();
                          } else {
                            contentPlayer.stop();
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25.0),
                          ),
                          padding: const EdgeInsets.all(15),
                        ),
                        child: Icon(
                          contentAudioFlag
                              ? Icons.volume_up_rounded
                              : Icons.volume_off_rounded,
                          color: Colors.amber,
                          size: 32,
                        ),
                      ),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Align(
                        alignment: Alignment.bottomLeft,
                        child: SizedBox(
                          width: 198,
                          child: Image.network(
                            "${properties.learningAppRandomFramesUrl}$randomObjectFrame1",
                          ),
                        ),
                      ),
                      Align(
                        alignment: Alignment.bottomRight,
                        child: SizedBox(
                          width: 198,
                          child: Image.network(
                            "${properties.learningAppRandomFramesUrl}$randomObjectFrame2",
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
    );
  }
}
