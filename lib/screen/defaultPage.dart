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
  double _speed = 2;
  double _cicleTime = 0;
  double _cloudyTime = 0;
  bool _isPaused = false;
  ActorAnimation _cicle;
  ActorAnimation _cloudy;
  bool end = false;

  bool setMoon = false;
  MoonPhase moonPhase = MoonPhase();
  double stateMoonx = 0;
  double nodeMoonLigthx = 0;

  ActorNode _nodeglobal;
  ClockModel clockModel;

  @override
  void initState() {
    super.initState();
  }

  void getMoonState(FlutterActorArtboard artboard, state) {
    _nodeglobal = artboard.getNode("Global");
    ActorNode nodeluna =
        _nodeglobal.children.firstWhere((node) => node.name == 'sun and moon');
    ActorNode nodelunaLuz =
        nodeluna.children.firstWhere((node) => node.name == 'moon light');
    ActorNode luna =
        nodeluna.children.firstWhere((node) => node.name == 'moon');
    /*
    FlutterActorShape estadoluna =
        luna.children.firstWhere((node) => node.name == 'estadoluna');

    double roundPhase = moonPhase.phase();

    if (state == 'init') {
      setState(() {
        stateMoonx = estadoluna.x;
        nodeMoonLigthx = nodelunaLuz.x;
      });
    } else {
      estadoluna.x = stateMoonx;
      nodelunaLuz.x = nodeMoonLigthx;
    }
    // set MOON [ NEW, WAXING CRESCENT, FULLMOON , WANING CRESCENT ]
    if (roundPhase >= 0.9) {
      estadoluna.x = estadoluna.x;
      nodelunaLuz.x = -10000;
    }
    if (roundPhase == 0.5) {
      estadoluna.x = estadoluna.x - 300;
    }

    if (roundPhase <= 0.9 && roundPhase >= 0.6) {
      estadoluna.x = estadoluna.x - 80;
    }

    if (roundPhase > 0.1 && roundPhase <= 0.4) {
      estadoluna.x = estadoluna.x + 80;
    }

    if (roundPhase <= 0.1) {
      estadoluna.x = estadoluna.x;
      nodelunaLuz.x = -10000;
    }*/
  }

  @override
  void initialize(FlutterActorArtboard artboard) {
    getMoonState(artboard, 'init');
    DateTime date = DateTime.now();
    double hour = date.hour.toDouble();
    _cicleTime = hour - 8;
    _cicle = artboard.getAnimation("ciclo");
    _cloudy = artboard.getAnimation("cloudy");
  }

  bool advance(FlutterActorArtboard artboard, double elapsed) {
    _cicleTime += elapsed * _speed;

    //
    //_reinit animation overflowb
    if (_cicleTime >= 24) {
      _cicleTime = 0;
      _cicleTime += elapsed * _speed;
    }

    if (_cicleTime >= 6 && _cicleTime < 7 && setMoon == false) {
      setMoon = true;
      getMoonState(artboard, 'change');
    }

    if (_cicleTime < 6 || _cicleTime >= 7) {
      setMoon = false;
    }
    _cicle.apply(_cicleTime % _cicle.duration, artboard, _cicleAmount);

    if (_cloudyTime < 9.9 && end == false) {
      _cloudyTime += elapsed;
      _cloudy.apply(_cloudyTime % _cloudy.duration, artboard, 0.5);
    } else if (_cloudyTime > 0.1) {
      end = true;

      _cloudy.apply(_cloudyTime % _cloudy.duration, artboard, 0.5);
      _cloudyTime -= elapsed;
    }

    return true;
  }

  @override
  void setViewTransform(Mat2D viewTransform) {}
  @override
  Widget build(BuildContext context) {
    clockModel = Provider.of<ClockModel>(context);
    clockModel.addListener(listenerClock());
    final timerState = Provider.of<TimerState>(context);

    return Scaffold(
        body: StreamBuilder<DateTime>(
            stream: timerState.$time,
            builder: (context, AsyncSnapshot<DateTime> snap) {
              if (!snap.hasData) {
                return CircularProgressIndicator();
              }
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
                 
                  Container(
                    child: Center(
                      child: Column(
                        children: <Widget>[
                          Text(
                            DateFormat('HH:mm').format(snap.data),
                            style: TextStyle(
                                color: Colors.white,
                                fontSize:
                                    MediaQuery.of(context).size.width / 8),
                          ),
                          Text(
                            clockModel.temperatureString,
                            style: TextStyle(
                                color: Colors.white,
                                fontSize:
                                    MediaQuery.of(context).size.width / 16),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            }));
  }

  listenerClock() {
    print('change');
    print(clockModel.weatherCondition);
  }

  randomWeather() {
    Random random = Random();
    clockModel.weatherCondition =
        WeatherCondition.values[random.nextInt(WeatherCondition.values.length)];
  }
}
