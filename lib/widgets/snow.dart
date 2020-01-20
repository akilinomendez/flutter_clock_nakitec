import 'dart:math';

import 'package:flutter/material.dart';


// For Snow inspire in https://github.com/windwp/flutter-snow-effect.git  merge with anothers animation

class SnowWidget extends StatefulWidget {
  final bool isShow;

  SnowWidget({Key key, this.isShow}) : super(key: key);

  _SnowWidgetState createState() => _SnowWidgetState();
}

class _SnowWidgetState extends State<SnowWidget>
    with SingleTickerProviderStateMixin {
  AnimationController controller;
  int _many = 150;
  Animation animation;
  List<Snow> _snow;
  Random _rnd;
  double angle = 0;
  double W = 0;
  double H = 0;
  @override
  void initState() {
    super.initState();
    initialize();
  }

  initialize() {
    _rnd = new Random();
    if (controller == null) {
      controller = new AnimationController(
          lowerBound: 0,
          upperBound: 1,
          vsync: this,
          duration: const Duration(milliseconds: 20000));
      controller.addListener(() {
        if (mounted) {
          setState(() {
            update();
          });
        }
      });
    }
    if (!widget.isShow) {
      controller.stop();
    } else {
      controller.repeat();
    }
  }

  @override
  dispose() {
    controller.dispose();
    super.dispose();
  }

  _createSnow() {
    _snow = new List();
    for (var i = 0; i < _many; i++) {
      _snow.add(new Snow(
          x: _rnd.nextDouble() * W,
          y: _rnd.nextDouble() * H,
          r: _rnd.nextDouble() * 4 + 1,
          d: _rnd.nextDouble()));
    }
  }

  update() {
    angle += 0.01;
    if (_snow == null || _many != _snow.length) {
      _createSnow();
    }
    for (var i = 0; i < _many; i++) {
      var snow = _snow[i];
      snow.y += (cos(angle + snow.d) + 1 + snow.r / 2);
      snow.x += sin(angle) * 2;
      if (snow.x > W + 5 || snow.x < -5 || snow.y > H) {
        if (i % 3 > 0) {         
          _snow[i] =
              new Snow(x: _rnd.nextDouble() * W, y: -10, r: snow.r, d: snow.d);
        } else {         
          if (sin(angle) > 0) {           
            _snow[i] =
                new Snow(x: -5, y: _rnd.nextDouble() * H, r: snow.r, d: snow.d);
          } else {           
            _snow[i] = new Snow(
                x: W + 5, y: _rnd.nextDouble() * H, r: snow.r, d: snow.d);
          }
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isShow && !controller.isAnimating) {
      controller.repeat();
    } else if (!widget.isShow && controller.isAnimating) {
      controller.stop();
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        if (_snow == null) {
          W = constraints.maxWidth;
          H = constraints.maxHeight;
        }
        return CustomPaint(
          willChange: widget.isShow,
          painter: SnowPainter(              
              isShow: widget.isShow,
              snows: _snow),
          size: Size.infinite,
        );
      },
    );
  }
}

class Snow {
  double x;
  double y;
  double r; //radius
  double d; //density
  Snow({this.x, this.y, this.r, this.d});
}

class SnowPainter extends CustomPainter {
  List<Snow> snows;
  bool isShow;

  SnowPainter({this.isShow, this.snows});

  @override
  void paint(Canvas canvas, Size size) {
    if (snows == null || !isShow) return;    
    final Paint paint = new Paint()
      ..color = Colors.white
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 10.0
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, 2.0);
    for (var i = 0; i < snows.length; i++) {
      var snow = snows[i];
      if (snow != null) {
        canvas.drawCircle(Offset(snow.x, snow.y), snow.r, paint);
      }
    }
  }


@override
bool shouldRepaint(SnowPainter oldDelegate) => isShow;
}
