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
import 'package:flare_dart/math/mat2d.dart';
import 'package:flare_dart/math/vec2d.dart';
import 'package:testapp/helpers/timerState.dart';
import 'package:testapp/widgets/snow.dart';
import 'package:testapp/widgets/thunder.dart';

class DefaultPage extends StatefulWidget {
  final bool demo;
  DefaultPage({Key key, this.demo}) : super(key: key);

  @override
  _DefaultPageState createState() => _DefaultPageState();
}

class _DefaultPageState extends State<DefaultPage> with FlareController {
  double _cicleAmount = 1;
  double _cicleTime = 0;
  double _cloudyTime = 0;
  double _rainyTime = 0;
  bool _isPaused = false;
  ActorAnimation _cicle;
  ActorAnimation _cloudy;
  ActorAnimation _rainy;
  bool _cloudyAnimation = false;
  bool _rainyAnimation = false;
  bool _transitionAnimation = false;
  bool _snowAnimation = false;
  bool _thunderAnimation = false;
  bool _isSnow = false;
  bool _isThunder = false;

  MoonPhase getMoon = MoonPhase();

  ClockModel clockModel;

  TimerState timerState;
  String _timeString = '';
  DateTime _timeMoon;
  WeatherCondition _currentWeather = WeatherCondition.sunny;

  @override
  void initState() {
    super.initState();
    if (widget.demo) {
      randomWeather();
    }
  }

  void getMoonState(FlutterActorArtboard artboard, date) {
    // Get Nodes for change Phase
    ActorNode _nodeglobal = artboard.getNode("Global");
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

  bool advance(FlutterActorArtboard artboard, double elapsed) {
    if (!_transitionAnimation) {
      if (_currentWeather != clockModel.weatherCondition) {
        _cloudyTime = 0;
        _rainyTime = 0;
        _cloudy.apply(_cloudyTime, artboard, 1);
        _rainy.apply(_rainyTime, artboard, 1);
        _transitionAnimation = true;
        print('Distinto');
        setState(() {
          _currentWeather = clockModel.weatherCondition;
        });
        switch (clockModel.weatherCondition) {
          case WeatherCondition.cloudy:
           _thunderAnimation = false;
            _snowAnimation = false;
            _isSnow = false;
            _isThunder = false; 
            _cloudyAnimation = true;
            break;

          case WeatherCondition.rainy:
           _thunderAnimation = false;
            _snowAnimation = false;
            _isSnow = false;
            _isThunder = false; 
            _rainyAnimation = true;
            break;

          case WeatherCondition.snowy:
            _thunderAnimation = false;
            _snowAnimation = true;           
            _isThunder = false; 
            break;
          case WeatherCondition.thunderstorm:
            _thunderAnimation = true;
            _snowAnimation = false;            
            _isSnow = false;       
           
            break;

          default:
            _transitionAnimation = false;
            _thunderAnimation = false;
            _snowAnimation = false;
            _isSnow = false;
            _isThunder = false;  
            break;
        }
      }
    }

    if (_cloudyAnimation) {
      _cloudyTime += elapsed;
      _cloudy.apply(_cloudyTime % _cloudy.duration, artboard, 0.9);
      if (_cloudyTime >= _cloudy.duration) {
        _cloudy.apply(_cloudy.duration, artboard, 0.9);
        _cloudyAnimation = false;
        _transitionAnimation = false;
      }
    }

    if (_snowAnimation) {
      _rainyTime += elapsed;
      _rainy.apply(_rainyTime % _rainy.duration, artboard, 1);
      if (_rainyTime >= _rainy.duration) {
        _rainy.apply(_rainy.duration, artboard, 1);
        _rainyAnimation = false;
        _isSnow = true;
        _transitionAnimation = false;
      }
    }

    if (_thunderAnimation) {
      _rainyTime += elapsed;
      _rainy.apply(_rainyTime % _rainy.duration, artboard, 1);
      if (_rainyTime >= _rainy.duration) {
        _rainy.apply(_rainy.duration, artboard, 1);
        _rainyAnimation = false;
        _isThunder = true;
        _transitionAnimation = false;
      }
    }

    if (_rainyAnimation) {
      _rainyTime += elapsed;
      _rainy.apply(_rainyTime % _rainy.duration, artboard, 0.5);
      if (_rainyTime >= _rainy.duration) {
        _rainy.apply(_rainy.duration, artboard, 0.5);
        _rainyAnimation = false;
        _transitionAnimation = false;
      }
    }

    if (widget.demo) {
      _cicleTime += elapsed * 2;
      //
      //_reinit animation overflowb
      if (_cicleTime >= 24) {
        _cicleTime = 0;
        _cicleTime += elapsed * 2;
      }
    } else {
      _cicleTime = double.parse(_timeString);
    }
    getMoonState(artboard, _timeMoon);
    _cicle.apply(_cicleTime % _cicle.duration, artboard, _cicleAmount);
    return true;
  }

// Convert Datetime to Animation frame value, 6:00  is sunset animation value 0;
  void _listenTimer(BuildContext context, data) {
    if (widget.demo) {
      /* Testing all hours;*/

      DateTime date =
          DateTime(2020, 01, 9, 23, 0).subtract(new Duration(hours: 6));
      _timeMoon = date;
      _timeString = DateFormat('HH.mm').format(date);
    } else {
      // Set from provider TimerState data
      DateTime date = data.subtract(new Duration(hours: 6));
      _timeMoon = date;
      _timeString = DateFormat('HH.mm').format(date);
    }
  }

  @override
  void setViewTransform(Mat2D viewTransform) {}
  @override
  Widget build(BuildContext context) {
    clockModel = Provider.of<ClockModel>(context);
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
                    ThunderWidget(
                      isShow: _isThunder,
                      children: <Widget>[
                        Container(),
                        Center(
                            child: SizedBox(
                          child: Opacity(
                            opacity: 0.2,
                            child: Container(
                             decoration: BoxDecoration(
                               
                               color: Colors.yellow[100]),

                          )),
                        ))
                        
                      ],
                    ),
                    SnowWidget(
                      isShow: _isSnow,
                    ),
                    Positioned(
                      bottom: 10,
                      right: 10,
                      child: Center(
                        child: Column(
                          children: <Widget>[
                            Text(
                              DateFormat('HH:mm').format(snap.data),
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize:
                                      MediaQuery.of(context).size.width / 25),
                            ),
                            InkWell(
                              // onTap: () => taprandomWeather(), // only for testing develop
                              child: Text(
                                clockModel.weatherString,
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize:
                                        MediaQuery.of(context).size.width / 50),
                              ),
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
    Timer.periodic(Duration(seconds: 15), (t) {
      print("change Weather");
      Random random = Random();
      WeatherCondition weather = WeatherCondition
          .values[random.nextInt(WeatherCondition.values.length)];
      clockModel.setWeatherCondition(weather);
    });
  }

  taprandomWeather() {
    // only for development
    print("change Weather Tap");
    Random random = Random();
    WeatherCondition weather =
        WeatherCondition.values[random.nextInt(WeatherCondition.values.length)];
    clockModel.setWeatherCondition(weather);
  }
}
