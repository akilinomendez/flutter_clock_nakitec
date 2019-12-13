import "package:flutter/material.dart";
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:testapp/screen/defaultPage.dart';

import 'helpers/clock_model.dart';
import 'helpers/timerState.dart';
import 'package:flare_flutter/flare_actor.dart';

void main() {
  
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([DeviceOrientation.landscapeLeft]);
    SystemChrome.setEnabledSystemUIOverlays([]);
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'LanzaClock',
        theme: ThemeData(primarySwatch: Colors.blue),
        home: MultiProvider(
          providers: [
            ChangeNotifierProvider(
              create: (_) => ClockModel(),
            ),
            Provider<TimerState>(create: (_) => TimerState()),
          ],
          child: MyHomePage(),
        ));
  }
}


class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => new _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return new FlareActor("assets/ciclo_lanzarote.flr", alignment:Alignment.center, fit:BoxFit.contain, animation:"ciclo");
  }
}
