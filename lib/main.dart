import 'package:flutter/material.dart';
import 'dart:async';
// import 'package:async/async.dart';

void main() => runApp(Main());

class Main extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Chess Timer',
      home: ChessTimer(),
    );
  }
}

class ChessTimer extends StatefulWidget {
  @override
  _ChessTimerState createState() => _ChessTimerState();
}

class _ChessTimerState extends State<ChessTimer> {
  CountdownUnit c1 = CountdownUnit();
  CountdownUnit c2 = CountdownUnit();

  @override
  Widget build(BuildContext context) {
    // time1seconds = time1millis ~/ 1000; // millis / 1000 = seconds
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        RotatedBox(
          quarterTurns: 0,
          // child: Text("$time1seconds")), // quarterTurns should be 2
          child: c1,
        ), // quarterTurns should be 2
        FloatingActionButton(onPressed: () {
          c1.start();
        }),
        c2,
      ],
    );
  }
}

class CountdownUnit extends StatefulWidget {
  final _CountdownUnitState c = _CountdownUnitState();
  @override
  _CountdownUnitState createState() => c;

  void start() {
    c.start();
  }

  void stop() {
    c.stop();
  }
}

class _CountdownUnitState extends State<CountdownUnit> {
  int millis;
  int seconds;
  Timer timer;

  @override
  void initState() {
    super.initState();
    seconds = 100;
    millis = seconds * 1000;
  }

  @override
  Widget build(BuildContext context) {
    return Text("$seconds");
  }

  void start() {
    if (timer == null) {
      timer = Timer.periodic(const Duration(milliseconds: 100), decrementClock);
    }
  }

  void stop() {
    if (timer != null) {
      timer.cancel();
      timer = null;
    }
  }

  void decrementClock(Timer timer) {
    //subtract 0.1 second from millis
    millis -= 100;
    // if a whole second has passed, decremnt seconds and set state
    if (millis % 1000 == 0) {
      setState(() => seconds -= 1);
    }
  }

  @override
  void dispose() {
    super.dispose();
    if (timer != null) {
      timer.cancel();
      timer = null;
    }
  }
}
