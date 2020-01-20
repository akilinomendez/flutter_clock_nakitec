import 'package:flutter/material.dart';

class ThunderWidget extends StatefulWidget {
  final List<Widget> children;
  final int interval;
  final bool isShow;

  ThunderWidget(
      {@required this.children,
      @required this.isShow,
      this.interval = 1000,
      Key key})
      : super(key: key);

  @override
  _ThunderWidgetState createState() => _ThunderWidgetState();
}

class _ThunderWidgetState extends State<ThunderWidget>
    with SingleTickerProviderStateMixin {
  AnimationController _controller;
  int _currentWidget = 0;

  initState() {
    super.initState();

    _controller = new AnimationController(
        duration: Duration(milliseconds: widget.interval), vsync: this);

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() {
          if (++_currentWidget == widget.children.length) {
            _currentWidget = 0;
          }
        });

        _controller.forward(from: 0.0);
      }
    });
    if (!widget.isShow) {
      _controller.stop();
    } else {
       _controller.forward();
    }
   
  }

  dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isShow) {
      _controller.stop();
    } else {
       _controller.forward();
    }
    return Container(
      child: widget.children[_currentWidget],
    );
  }
}
