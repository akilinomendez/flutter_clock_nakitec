
import "package:flutter/material.dart";

import 'dart:async';
import 'dart:math';
import 'package:intl/intl.dart';

import 'package:flare_dart/math/mat2d.dart';
import 'package:flare_flutter/flare.dart';
import "package:flare_flutter/flare_actor.dart";
import 'package:flare_flutter/flare_controller.dart';
import 'package:provider/provider.dart';
import 'package:testapp/flutter_clock_helper/model.dart';


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
  String _timeString;
  bool setMoon = false;

  double stateMoonx = 0;
  double nodeMoonLigthx = 0;
  
  ActorNode _nodeglobal;

  ClockModel clockModel;
  List<String> moonState = [
    'New Moon',
    'Full Moon',
    'First Quarter',
    'Third Quarter'
  ];
  

  @override
  void initState() {
    _timeString = _formatDateTime(DateTime.now());
    Timer.periodic(Duration(seconds: 1), (Timer t) => _getTime());  
    super.initState();
  }

  

  void getMoonState(FlutterActorArtboard artboard, state) {
    _nodeglobal = artboard.getNode("Global");
    ActorNode nodeluna =
        _nodeglobal.children.firstWhere((node) => node.name == 'Sol y Luna');
    ActorNode nodelunaLuz =
        nodeluna.children.firstWhere((node) => node.name == 'Luna luz');
    ActorNode luna =
        nodeluna.children.firstWhere((node) => node.name == 'Luna');    
    FlutterActorShape estadoluna =
        luna.children.firstWhere((node) => node.name == 'estadoluna');

    setState(() {
                    clockModel.location = 'sa';
                  });

    if(state == 'init') {
      setState(() {
        stateMoonx = estadoluna.x;
        nodeMoonLigthx  = nodelunaLuz.x;
      });
      
    }  else {
      estadoluna.x =stateMoonx;
      nodelunaLuz.x =  nodeMoonLigthx;
    }

    // REMPLACE FOR REST API GET STATE    
    final _randomMock = new Random();
    print(clockModel.location);
    String mockluna = moonState[_randomMock.nextInt(moonState.length)];
    print(mockluna);
    switch (mockluna) {
      case 'New Moon':
        
        estadoluna.x = estadoluna.x;
        nodelunaLuz.x = -10000;
        break;
      case 'Full Moon':
        
        estadoluna.x = estadoluna.x - 300;
        break;
      case 'First Quarter':
        
        estadoluna.x = estadoluna.x - 80;
        break;
      case 'Third Quarter':
        
        estadoluna.x = estadoluna.x + 80;
        break;
      default:
    }
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
    //_reinit animation overflow
    if(_cicleTime >= 24) {      
      _cicleTime = 0;
      _cicleTime += elapsed * _speed;
    }
 
    if(_cicleTime >= 6 && _cicleTime < 7 && setMoon == false) {
      setMoon = true;      
      getMoonState(artboard, 'change');
    }

    if(_cicleTime < 6 || _cicleTime >= 7) {
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
   
    return Scaffold(
      body: Stack(
        children: <Widget>[
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Expanded(
                    child: FlareActor("assets/ciclo_lanzarote.flr",
                        alignment: Alignment.center,
                        fit: BoxFit.cover,
                        controller: this))
              ],
            ),
          ),
          Container(
            child: Center(
              child: Text(
                _timeString,
                style: TextStyle(
                    color: Colors.white,
                    fontSize: MediaQuery.of(context).size.width / 8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _getTime() {
   
    final DateTime now = DateTime.now();
    final String formattedDateTime = _formatDateTime(now);

    setState(() {
      _timeString = formattedDateTime;
      
    });
  }

  String _formatDateTime(DateTime dateTime) {
    return DateFormat('HH:mm').format(dateTime);
  }
}