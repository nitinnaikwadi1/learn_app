import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:just_audio/just_audio.dart';
import 'package:http/http.dart' as http;
import 'package:learn_app/model/dashboard_item.dart';

class ContentInteractiveView extends StatefulWidget {
  final String whichContent;
  final String whichAudio;

  const ContentInteractiveView(
      {super.key, required this.whichContent, required this.whichAudio});

  @override
  State<ContentInteractiveView> createState() => _ContentInteractiveViewState();
}

class _ContentInteractiveViewState extends State<ContentInteractiveView>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  late AudioPlayer backgroundMusicPlayer;
  bool backgroundMusicFlag = false;
  late final AnimationController _controller;
  bool clicked = false;
  var contentData = [];
  var whichDataIndex = 0;

  Future<List<DashboardItem>> readJsonData() async {
    var contentJsonFromURL = await http.get(Uri.parse(
        "https://nitinnaikwadi1.github.io/vedeobase/data/learning_app/${widget.whichContent}"));
    final list = json.decode(contentJsonFromURL.body) as List<dynamic>;
    //list.shuffle();
    setState(() {
      contentData = list;
    });
    return list.map((e) => DashboardItem.fromJson(e)).toList();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    backgroundMusicPlayer = AudioPlayer();
    _controller =
        AnimationController(vsync: this, duration: Durations.extralong4);
    _controller.repeat();
    readJsonData();
    whichDataIndex = 0;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.detached ||
        state == AppLifecycleState.paused) {
      backgroundMusicPlayer.stop();
    }

    if (state == AppLifecycleState.resumed) {
      if (backgroundMusicFlag) {
        backgroundMusicPlayer.play();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      floatingActionButton: FloatingActionButton.small(
          backgroundColor: Colors.white,
          child: Material(
            shape: const CircleBorder(),
            child: Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(35.0),
              ),
              child: Icon(
                backgroundMusicFlag
                    ? Icons.volume_up_rounded
                    : Icons.volume_off_rounded,
                color: Colors.green,
                size: 24,
              ),
            ),
          ),
          onPressed: () async {
            // flag to toggle the background music icon
            setState(() {
              backgroundMusicFlag = !backgroundMusicFlag;
            });

            if (backgroundMusicFlag) {
              await backgroundMusicPlayer
                  .setAsset('assets/audio/backg_audio.mp3');
              backgroundMusicPlayer.play();
            } else {
              backgroundMusicPlayer.stop();
            }
          }),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
              fit: BoxFit.cover, image: AssetImage("assets/images/back.gif")),
        ),
        child: Stack(
          children: <Widget>[
            Center(
              child: Card(
                elevation: 10,
                semanticContainer: true,
                clipBehavior: Clip.antiAliasWithSaveLayer,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: SizedBox(
                  child: Image.network(
                    'https://nitinnaikwadi1.github.io/vedeobase/images/vedeo_app/learning_media/${contentData[whichDataIndex]['url']}',
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 300.0),
              child: Center(
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      // last index of arr
                      if (whichDataIndex == contentData.length) {
                        whichDataIndex = 0;
                      } else {
                        whichDataIndex += 1;
                      }
                    });
                  },
                  child: Lottie.asset(
                      "assets/animations/tap_button_yellow.json",
                      height: 252,
                      width: 252,
                      controller: _controller),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Align(
                alignment: Alignment.bottomLeft,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(35.0),
                    ),
                    padding: const EdgeInsets.all(15),
                  ),
                  child: const Icon(
                    Icons.arrow_back_rounded,
                    color: Colors.green,
                    size: 24,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
