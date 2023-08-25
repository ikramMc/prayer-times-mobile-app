import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:mawakit_fix/models/location.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<dynamic> salawat = [
    "Fajr",
    "Sunrise",
    "Dhuhr",
    "Asr",
    "Maghrib",
    "Isha",
    "Firstthird"
  ];
  late double long;
  late double lat;
  late var data;
  Future<Map<String, dynamic>> getPosition() async {
    Location lc = Location();
    await lc.getCurrentLocation();
    lat = lc.latitude;
    long = lc.longitude;
    return getPrayerTime();
  }

  Future<Map<String, dynamic>> getPrayerTime() async {
    http.Response res = await http.get(Uri.parse(
        'http://api.aladhan.com/v1/timings?latitude=${lat}&longitude=${long}&method=2'));
    // data=SalatData.fromJson(jsonDecode(res.body));
    data = jsonDecode(res.body);
    print(data);
    return data['data']['timings'];
    // print(data.data!.timings!.fajr);
    // print(data.data!.date!.readable);
    // var decodeData=jsonDecode(data);
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
            child: FutureBuilder(
                future: getPosition(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    return Column(
                      children: [
                        Expanded(
                          child: Stack(alignment: Alignment.center, children: [
                            Image.asset(
                              'assets/mosque.jpg',
                            ),
                            Positioned(
                              top: 10,
                              child: Text(
                                data['data']['date']['hijri']['weekday']['en'] +
                                    ': ' +
                                    data['data']['date']['hijri']['day'] +
                                    ' ' +
                                    data['data']['date']['hijri']['month']
                                        ['en'] +
                                    ' ' +
                                    data['data']['date']['hijri']['year'] +
                                    " - " +
                                    data['data']['date']['readable'],
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Color(0xff403847),
                                  backgroundColor: Color(0xffdec29a),
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            )
                          ]),
                          flex: 2,
                        ),
                        Expanded(
                          child: Column(
                            children: [
                              for (var salat in salawat)
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.all(10.0),
                                    child: Container(
                                      decoration: BoxDecoration(
                                          color: Color(0xffdec29a),
                                          borderRadius:
                                              BorderRadius.circular(20)),
                                      child: Row(
                                        children: [
                                          Text(
                                            salat,
                                            style: TextStyle(
                                                color: Color(0xffab527e),
                                                fontWeight: FontWeight.w600),
                                          ),
                                          Text(
                                            data['data']['timings'][salat],
                                            style: TextStyle(
                                                color: Color(0xffab527e),
                                                fontWeight: FontWeight.w600),
                                          ),
                                        ],
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceAround,
                                      ),
                                    ),
                                  ),
                                )
                            ],
                          ),
                          flex: 4,
                        )
                      ],
                    );
                  } else if (snapshot.hasError) {
                    print('Errorr');
                    return Container();
                  } else {
                    return Center(
                      child: CircularProgressIndicator(
                        backgroundColor: Color(0xffab527e),
                      ),
                    );
                  }
                })));
  }
}
