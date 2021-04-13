import 'dart:async';
import 'dart:convert';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/src/widgets/image.dart' as img;
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'spaceX.dart';
import 'package:url_launcher/url_launcher.dart';

Future<SpaceX> fetchSpaceX() async {
  final response = await http
      .get(Uri.parse('https://api.spacexdata.com/v4/launches/latest'));

  if (response.statusCode == 200) {
    // If the server did return a 200 OK response,
    // then parse the JSON.
    return SpaceX.fromJson(jsonDecode(response.body));
  } else {
    // If the server did not return a 200 OK response,
    // then throw an exception.
    throw Exception('Failed to load album');
  }
}

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  MyApp({Key key}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Future<SpaceX> futureSpaceX;
  Widget logo;
  String url;

  @override
  void initState() {
    super.initState();
    futureSpaceX = fetchSpaceX();
    futureSpaceX.then(
      (value) => setState(() {
        if (value.links.patch.large != null) {
          url = value.links.patch.large;
          logo = img.Image.network(
            value.links.patch.large,
            width: 100,
            height: 100,
          );
        }
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Fetch Data Example',
      theme: ThemeData(
        primarySwatch: Colors.indigo,
      ),
      home: Scaffold(
        backgroundColor: Colors.black38,
        body: CustomScrollView(
          slivers: [
            SliverAppBar(
              centerTitle: true,
              expandedHeight: 250,
              shape: RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.vertical(bottom: Radius.circular(300))),
              backgroundColor: Colors.orange,
              flexibleSpace: FlexibleSpaceBar(
                collapseMode: CollapseMode.parallax,
                centerTitle: true,
                background: logo,
              ),
            ),
            SliverList(
              delegate: SliverChildListDelegate([
                Container(
                  height: 1500,
                  child: FutureBuilder<SpaceX>(
                    future: futureSpaceX,
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        return Column(
                          children: [
                            Expanded(
                              flex: 1,
                              child: Container(
                                child: Text(
                                  "SpaceX",
                                  style: TextStyle(
                                      color: Colors.orangeAccent, fontSize: 64),
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: Container(
                                padding: EdgeInsets.all(25),
                                child: Text(
                                  "Space Exploration Technologies Corp. (SpaceX) is an American aerospace manufacturer and space transportation services company headquartered in Hawthorne, California. It was founded in 2002 by Elon Musk with the goal of reducing space transportation costs to enable the colonization of Mars. SpaceX manufactures the Falcon 9 and Falcon Heavy launch vehicles, several rocket engines, Dragon cargo and crew spacecraft and Starlink satellites.",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: Container(
                                  child: Image.network(
                                      snapshot.data.links.flickr.original[0])),
                            ),
                            Expanded(
                              flex: 3,
                              child: Container(
                                  child: ListTile(
                                contentPadding: EdgeInsets.all(25),
                                onTap: () {
                                  AwesomeDialog(
                                      context: context,
                                      borderSide: BorderSide(
                                          color: Colors.orange, width: 2),
                                      width: 480,
                                      buttonsBorderRadius:
                                          BorderRadius.all(Radius.circular(2)),
                                      headerAnimationLoop: false,
                                      animType: AnimType.BOTTOMSLIDE,
                                      title: snapshot.data.name,
                                      desc: "Ships: " +
                                          snapshot.data.ships.toString() +
                                          "\n" +
                                          "Flight Number: " +
                                          snapshot.data.flightNumber
                                              .toString() +
                                          "\n" +
                                          "Launch Date: " +
                                          snapshot.data.dateUtc.toString() +
                                          "\n" +
                                          "Landing Success: " +
                                          snapshot.data.cores[0].landingSuccess
                                              .toString() +
                                          "\n",
                                      showCloseIcon: true,
                                      btnOkOnPress: () {},
                                      btnOkColor: Colors.orange,
                                      padding: EdgeInsets.all(10))
                                    ..show();
                                },
                                hoverColor: Colors.blue,
                                title: Text(
                                  snapshot.data.name + "\n",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      color: Colors.orangeAccent, fontSize: 32),
                                ), //check(snapshot, index),
                                subtitle: Column(
                                  children: [
                                    Text(
                                      snapshot.data.details,
                                      style: TextStyle(
                                          color: Colors.white, fontSize: 18),
                                    ),
                                    Text(
                                      "\n\nClick for the Mission Details..",
                                      style: TextStyle(
                                          color: Colors.orangeAccent,
                                          fontSize: 18),
                                    ),
                                  ],
                                ),
                              )),
                            ),
                            Expanded(
                              flex: 1,
                              child: Container(
                                color: Colors.white,
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    IconButton(
                                        splashColor: Colors.orangeAccent,
                                        iconSize: 64,
                                        icon: Image.asset(
                                          "lib/assets/reddit-logo.png",
                                        ),
                                        onPressed: () async {
                                          _openURL(snapshot
                                              .data.links.reddit.launch);
                                        }),
                                    IconButton(
                                      splashColor: Colors.grey,
                                      iconSize: 64,
                                      icon: Image.asset(
                                        "lib/assets/wikipedia_PNG33.png",
                                      ),
                                      onPressed: () async {
                                        _openURL(snapshot.data.links.wikipedia);
                                      },
                                    ),
                                    IconButton(
                                      splashColor: Colors.red,
                                      iconSize: 64,
                                      icon: Image.asset(
                                        "lib/assets/YouTube-Logo.png",
                                      ),
                                      onPressed: () async {
                                        _openURL(snapshot.data.links.webcast);
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        );
                      } else if (snapshot.hasError) {
                        return Text("${snapshot.error}");
                      }

                      return CircularProgressIndicator();
                    },
                  ),
                )
              ]),
            )
          ],
        ),
      ),
    );
  }
}

_openURL(String url) async {
  if (await canLaunch(url)) {
    await launch(url);
  } else {
    throw 'Could not launch $url';
  }
}

Text check(snapshot, index) {
  String s = "";
  try {
    s = snapshot.data.data.children[index].data.allAwardings[0].description;
  } catch (e) {
    s = "";
  }

  return Text(s);
}
