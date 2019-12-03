import 'dart:async';
import 'dart:math';

import 'package:flare_flutter/flare.dart';
import "package:flare_flutter/flare_actor.dart";
import "package:flare_flutter/flare_cache_builder.dart";
import 'package:flare_flutter/flare_controller.dart';
import "package:flutter/material.dart";
import 'package:flare_dart/math/mat2d.dart';
import 'package:flare_dart/math/vec2d.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

void main() {
  SystemChrome.setPreferredOrientations([DeviceOrientation.landscapeLeft]);
  SystemChrome.setEnabledSystemUIOverlays([]);
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flare Demo',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: MyHomePage(title: 'Flare-Flutter'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with FlareController {
  double _rockAmount = 1;
  //double _speed = 0.00001157407; // 24 HOUR
  double _speed = 1;
  double _rockTime = 0;
  double _cloudyTime = 0;
  bool _isPaused = false;
  ActorAnimation _rock;
  ActorAnimation _cloudy;
  bool end = false;
  String _timeString;
  double counter = 0;
  ActorNode _nodeglobal;
  List<String> moonState = [
    'New Moon',
    'Full Moon',
    'First Quarter',
    'Third Quarter'
  ];
  Vec2D _lunanewpos = Vec2D();

  @override
  void initState() {
    _timeString = _formatDateTime(DateTime.now());

    Timer.periodic(Duration(seconds: 1), (Timer t) => _getTime());
    super.initState();
  }

  @override
  void initialize(FlutterActorArtboard artboard) {
    _nodeglobal = artboard.getNode("Global");
    ActorNode nodeluna =
        _nodeglobal.children.firstWhere((node) => node.name == 'Sol y Luna');
    ActorNode nodelunaLuz =
        nodeluna.children.firstWhere((node) => node.name == 'Luna luz');
    ActorNode luna =
        nodeluna.children.firstWhere((node) => node.name == 'Luna');
    FlutterActorEllipse estadolunaluz =
        nodelunaLuz.children.firstWhere((node) => node.name == 'Ellipse Path');
    FlutterActorShape estadoluna =
        luna.children.firstWhere((node) => node.name == 'estadoluna');
    final _random = new Random();
    String randomluna = moonState[_random.nextInt(moonState.length)];
    switch ('New Moon') {
      case 'New Moon':
        print('New Moon');
        estadoluna.x = estadoluna.x;
       nodelunaLuz.x = -10000;
        break;
      case 'Full Moon':
        print('Full Moo');
        estadoluna.x = estadoluna.x - 300;
        break;
      case 'First Quarter':
        print('First Quarter');
        estadoluna.x = estadoluna.x - 80;
        break;
      case 'Third Quarter':
        print('Third Quarter');
        estadoluna.x = estadoluna.x + 80;
        break;
      default:
    }

    DateTime date = DateTime.now();
    double hour = date.hour.toDouble();

    _rockTime = hour - 8;

    _rock = artboard.getAnimation("ciclo");
    _cloudy = artboard.getAnimation("cloudy");
  }

  bool advance(FlutterActorArtboard artboard, double elapsed) {
    _rockTime += elapsed * _speed;

    //
    //_rock
    _rock.apply(_rockTime % _rock.duration, artboard, _rockAmount);
    
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
      counter++;
    });
  }

  String _formatDateTime(DateTime dateTime) {
    return DateFormat('HH:mm').format(dateTime);
  }
}
