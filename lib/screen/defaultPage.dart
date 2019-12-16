import 'dart:math';

import "package:flutter/material.dart";

import 'dart:async';
import 'package:intl/intl.dart';

import 'package:flare_dart/math/mat2d.dart';
import 'package:flare_flutter/flare.dart';
import "package:flare_flutter/flare_actor.dart";
import 'package:flare_flutter/flare_controller.dart';
import 'package:provider/provider.dart';
import 'package:testapp/helpers/clock_model.dart';
import 'package:testapp/helpers/moon_phase.dart';
import 'package:testapp/helpers/timerState.dart';

class DefaultPage extends StatefulWidget {
  DefaultPage({Key key}) : super(key: key);

  @override
  _DefaultPageState createState() => _DefaultPageState();
}

class _DefaultPageState extends State<DefaultPage> with FlareController {
  double _cicleAmount = 1;
  //double _speed = 0.00001157407; // 24 HOUR
  double _speed = 1;
  double _cicleTime = 0;
  double _cloudyTime = 0;
  bool _isPaused = false;
  ActorAnimation _cicle;
  ActorAnimation _cloudy;
  ActorAnimation _rainy;
  bool end = false;

  bool setMoon = false;
  MoonPhase getMoon = MoonPhase();
  double stateMoonx = 0;
  double nodeMoonLigthx = 0;
  bool _rainybool = false;
  ActorNode _nodeglobal;
  ClockModel clockModel;

  TimerState timerState;
  String _timeString = '';
  DateTime _timeMoon;

  @override
  void initState() {
    super.initState();
  }

  void getMoonState(FlutterActorArtboard artboard, date) {
    // Get Nodes for change Phase
    _nodeglobal = artboard.getNode("Global");
    ActorNode nodeSunandMoon =
        _nodeglobal.children.firstWhere((node) => node.name == 'sun and moon');
    ActorNode nodeMoonLight =
        nodeSunandMoon.children.firstWhere((node) => node.name == 'moonLightS');
    ActorNode moon =
        nodeSunandMoon.children.firstWhere((node) => node.name == 'moon');
    FlutterActorShape newMoon =
        moon.children.firstWhere((shape) => shape.name == 'new');
    FlutterActorShape firstQuarter =
        moon.children.firstWhere((shape) => shape.name == 'first-quarter');
    FlutterActorShape waningGib =
        moon.children.firstWhere((shape) => shape.name == 'waning-gib');
    FlutterActorShape waxingGib =
        moon.children.firstWhere((shape) => shape.name == 'waxing-gib');
    FlutterActorShape thirdQuarter =
        moon.children.firstWhere((shape) => shape.name == 'third-quarter');
    FlutterActorShape waxingCre =
        moon.children.firstWhere((shape) => shape.name == 'waxing-cre');
    FlutterActorShape waningCre =
        moon.children.firstWhere((shape) => shape.name == 'waning-cre');

    // Set Initial values.
    nodeMoonLight.opacity = 0;
    newMoon.opacity = 0;
    firstQuarter.opacity = 0;
    waningGib.opacity = 0;
    waxingGib.opacity = 0;
    thirdQuarter.opacity = 0;
    waxingCre.opacity = 0;
    waningCre.opacity = 0;

    // get  Moon
    List moonList = getMoon.phase(date);
    int moonPhase = moonList[0];

    // Set Moon Ilumination
    double moonIlumination = moonList[1];
    nodeMoonLight.opacity = moonIlumination;

    // Set Moon Phase
    switch (moonPhase) {
      case 0:
        newMoon.opacity = 1;
        nodeMoonLight.opacity = 0;
        break;
      case 1:
        waxingCre.opacity = 1;
        break;
      case 2:
        firstQuarter.opacity = 1;
        break;
      case 3:
        waxingGib.opacity = 1;
        break;
      case 4:
        waxingGib.opacity = 1;
        break;
      case 5:
        // Full Moon;
        nodeMoonLight.opacity = 1;
        break;
      case 6:
        waningGib.opacity = 1;

        break;
      case 7:
        waningGib.opacity = 1;
        break;
      case 8:
        thirdQuarter.opacity = 1;
        break;
      case 9:
        waningCre.opacity = 1;
        break;
      case 10:
        newMoon.opacity = 1;
        nodeMoonLight.opacity = 0;
        break;
    }
  }

  @override
  void initialize(FlutterActorArtboard artboard) {
    _cicle = artboard.getAnimation("ciclo");
    _cloudy = artboard.getAnimation("cloudy");
    _rainy = artboard.getAnimation("raining");
  }

  listenerClock() {
    print('change');
    print(clockModel.weatherCondition);
  }

  bool advance(FlutterActorArtboard artboard, double elapsed) {
    _cicleTime = double.parse(_timeString);
    getMoonState(artboard, _timeMoon);
    _cicle.apply(_cicleTime % _cicle.duration, artboard, _cicleAmount);
    return true;
  }

// Convert Datetime to Animation frame value, 8:00  is sunset animation value 0;
  void _listenTimer(BuildContext context, data) {
    /* Testing all hours;
    DateTime date =
        DateTime(2019, 12, 16, 2, 0).subtract(new Duration(hours: 8));
    */
    // Set from provider TimerState data
    DateTime date = data.subtract(new Duration(hours: 8));
    _timeMoon = date;
    _timeString = DateFormat('HH.mm').format(date);
  }

  @override
  void setViewTransform(Mat2D viewTransform) {}
  @override
  Widget build(BuildContext context) {
    clockModel = Provider.of<ClockModel>(context);
    clockModel.addListener(listenerClock());
    timerState = Provider.of<TimerState>(context);
    return Scaffold(
        body: StreamBuilder<DateTime>(
            stream: timerState.$time,
            builder: (context, AsyncSnapshot<DateTime> snap) {
              if (!snap.hasData) {
                return CircularProgressIndicator();
              } else {
                // Update Animation Frame
                _listenTimer(context, snap.data);
                // Return Widget
                return Stack(
                  children: <Widget>[
                    Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Expanded(
                              child: FlareActor("assets/ciclo_lanzarote.flr",
                                  alignment: Alignment.center,
                                  controller: this))
                        ],
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Center(
                        child: Column(
                          children: <Widget>[
                            Text(
                              DateFormat('HH:mm').format(snap.data),
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize:
                                      MediaQuery.of(context).size.width / 18),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              }
            }));
  }

  randomWeather() {
    Random random = Random();
    setState(() {
      clockModel.weatherCondition = WeatherCondition
          .values[random.nextInt(WeatherCondition.values.length)];
    });
  }
}
