import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:weathery/tabs/news.dart';
import 'package:weathery/tabs/weather.dart';
import 'package:weathery/application_state.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => ApplicationState(),
      child: Weathery(),
    )
  );
}

class Weathery extends StatelessWidget {
  const Weathery({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    // SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    return MaterialApp(
      title: 'Flutter Demo',
      home: const HomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        extendBodyBehindAppBar: true,
        backgroundColor: Colors.white,
        body: Stack(
          children: [
            TabBarView(
              children: [
                WeatherTab(),
                NewsTab(),
              ],
            ),
            // Floating TabBar overlay
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                height: 60,
                padding: EdgeInsets.symmetric(horizontal: 4),
                decoration: BoxDecoration(
                  color: Color.fromARGB(200, 255, 255, 255), // Semi-transparent
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  )
                ),
                child: TabBar(
                  tabs: [
                    Tab(icon: Icon(Icons.cloud)),
                    Tab(icon: Icon(Icons.newspaper)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
