import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:just_audio/just_audio.dart';
import 'package:learn_app/model/dashboard_item_list.dart';
import 'package:learn_app/content_interactive_view.dart';

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

  Future<List<DashboardItemlist>> readJsonData() async {
    var vedeoJsonFromURL = await http.get(Uri.parse(
        "https://nitinnaikwadi1.github.io/vedeobase/data/learning_app/learning_app_dashboard.json"));
    final list = json.decode(vedeoJsonFromURL.body) as List<dynamic>;
    list.shuffle();
    return list.map((e) => DashboardItemlist.fromJson(e)).toList();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    backgroundMusicPlayer = AudioPlayer();
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
                color: Colors.blueAccent,
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
              fit: BoxFit.fill, image: AssetImage("assets/images/back1.gif")),
        ),
        child: Center(
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
                          return Card(
                            semanticContainer: true,
                            shadowColor: Colors.teal,
                            clipBehavior: Clip.antiAliasWithSaveLayer,
                            child: GestureDetector(
                              onTap: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          ContentInteractiveView(
                                              whichContent:
                                                  items[index].whichContent,
                                              whichAudio:
                                                  items[index].whichAudio),
                                    ));
                              },
                              child: Image.asset(
                                  'assets/images/dashboard/${items[index].url}',
                                  fit: BoxFit.contain),
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
      ),
    );
  }
}
