import 'package:rxdart/rxdart.dart';
import 'dart:async';

class TimerState {
  get setDate => _timer.sink.add;
  Stream get $time => _timer.stream;
  BehaviorSubject _timer = BehaviorSubject<DateTime>();

  TimerState() {
    update();
  }

  Future<void> update() async {
    setDate(DateTime.now());
    return Future.delayed(Duration(seconds: 1), update);
  }
}
