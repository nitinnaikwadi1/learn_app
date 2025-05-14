import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:just_audio/just_audio.dart';
import 'package:learn_app/model/dashboard_item_list.dart';
import 'package:learn_app/content_interactive_view.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:learn_app/properties/app_constants.dart' as properties;
import 'package:spring/spring.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(home: MyHomePage());
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with WidgetsBindingObserver {
  late AudioPlayer backgroundMusicPlayer;
  bool backgroundMusicFlag = false;
  String randomObjectFrame1 = '';
  String randomObjectFrame2 = '';
  String randomBackMusicName = '';
  String dashboardBackgName = '';
  bool pause = true;

  Future<List<DashboardItemlist>> readJsonData() async {
    var learningItemsJsonFromURL =
        await http.get(Uri.parse(properties.learningAppDashboardUrl));
    final list = json.decode(learningItemsJsonFromURL.body) as List<dynamic>;
    list.shuffle();
    return list.map((e) => DashboardItemlist.fromJson(e)).toList();
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
    var randomDashboardBackgJsonFromURL =
        await http.get(Uri.parse(properties.learningAppBackgroundFramesUrl));
    var randomDashboardBackgList =
        json.decode(randomDashboardBackgJsonFromURL.body) as List<dynamic>;
    randomDashboardBackgList.shuffle();

    setState(() {
      dashboardBackgName = randomDashboardBackgList[0]['url'];
    });
  }

  Future<void> randomBackgroundMusicIndex() async {
    var randomBackMusicJsonFromURL =
        await http.get(Uri.parse(properties.learningAppBackMusicDataUrl));
    var randomBackMusicList =
        json.decode(randomBackMusicJsonFromURL.body) as List<dynamic>;
    randomBackMusicList.shuffle();

    setState(() {
      randomBackMusicName = randomBackMusicList[0]['url'];
    });
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    backgroundMusicPlayer = AudioPlayer();
    backgroundMusicPlayer.setVolume(0.1);
    backgroundMusicPlayer.setLoopMode(LoopMode.all);
    randomObjectsFramesData();
    randomBackgroundMusicIndex();
    randomBackgroundImageData();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
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
                color: Colors.redAccent,
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
              await backgroundMusicPlayer.setUrl(
                  "${properties.learningAppBackMusicUrl}$randomBackMusicName");
              backgroundMusicPlayer.play();
            } else {
              backgroundMusicPlayer.stop();
            }
          }),
      body: dashboardBackgName == ''
          ? const LoadingIndicator(
              colors: properties.kDefaultRainbowColors,
              indicatorType: Indicator.pacman,
              strokeWidth: 3,
              pause: false,
            )
          :Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            fit: BoxFit.cover,
            image: AssetImage(
                "${properties.learningAppBackgroundItemsUrl}$dashboardBackgName"),
          ),
        ),
        child: Stack(
          children: <Widget>[
            Center(
              child: FutureBuilder(
                  future: readJsonData(),
                  builder: (context, data) {
                    if (data.hasError) {
                      return Center(child: Text('${data.error}'));
                    } else {
                      if (data.hasData) {
                        var items = data.data as List<DashboardItemlist>;
                        return GridView.builder(
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 4,
                              childAspectRatio: (1 / .5),
                              mainAxisSpacing: 5,
                              crossAxisSpacing: 5,
                            ),
                            itemCount: items.length,
                            padding: const EdgeInsets.all(120),
                            shrinkWrap: true,
                            itemBuilder: (BuildContext ctx, index) {
                              return Spring.bubbleButton(
                                delay: const Duration(milliseconds: 365),
                                animDuration: const Duration(seconds: 1),
                                child: Card(
                                  semanticContainer: true,
                                  shadowColor: Colors.teal,
                                  clipBehavior: Clip.antiAliasWithSaveLayer,
                                  child: GestureDetector(
                                    onTap: () async {
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                ContentInteractiveView(
                                                    whichContent: items[index]
                                                        .whichContent),
                                          ));

                                      // start playing background audio when onclick event happens
                                      if (!backgroundMusicFlag) {
                                        // flag to toggle the background music icon
                                        setState(() {
                                          backgroundMusicFlag = true;
                                        });
                                        await backgroundMusicPlayer.setUrl(
                                            "${properties.learningAppBackMusicUrl}$randomBackMusicName");
                                        backgroundMusicPlayer.play();
                                      }
                                    },
                                    child: Image.asset(
                                        "${properties.learningAppDashboardItemsUrl}${items[index].url}",
                                        fit: BoxFit.contain),
                                  ),
                                ),
                              );
                            });
                      } else {
                        return Container(
                          height: double.infinity,
                          color: Colors.redAccent,
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox.square(
                                dimension: 25,
                                child: CircularProgressIndicator(),
                              )
                            ],
                          ),
                        );
                      }
                    }
                  }),
            ),
            randomObjectFrame1 == ''
                ? const CircularProgressIndicator()
                : Align(
                    alignment: Alignment.bottomLeft,
                    child: SizedBox(
                      width: 198,
                      child: Image.network(
                        "${properties.learningAppRandomFramesUrl}$randomObjectFrame1",
                      ),
                    ),
                  ),
            randomObjectFrame2 == ''
                ? const CircularProgressIndicator()
                : Align(
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
      ),
    );
  }
}
