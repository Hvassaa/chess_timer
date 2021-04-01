import 'package:flutter/material.dart';
import 'dart:async';
// import 'package:async/async.dart';

void main() => runApp(Main());

class Main extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Chess Timer',
      // home: ChessTimer(),
      home: Scaffold(
        body: ChessTimer(),
      ),
    );
  }
}

class ChessTimer extends StatefulWidget {
  @override
  _ChessTimerState createState() => _ChessTimerState();
}

class _ChessTimerState extends State<ChessTimer> {
  // the counters, responsible for time keeping and the associated text
  CountdownUnit counter1;
  CountdownUnit counter2;
  // The "containers", which should draw buttons
  var container1;
  var container2;
  var activedContainer1;
  var activedContainer2;
  var deactivedContainer1;
  var deactivedContainer2;

  @override
  initState() {
    super.initState();
    counter1 = CountdownUnit();
    counter2 = CountdownUnit();

    // functions for pressing the clock-buttons
    // starts the opponents clock, and stops yours
    var f1 = () {
      // Dont do anything if time expired
      var hasEnded = counter1.getSeconds() == 0 || counter2.getSeconds() == 0;
      if (hasEnded) {
        counter1.stop();
        counter2.stop();
      } else {
        counter1.stop();
        counter2.start();
        setState(() {
          container1 = deactivedContainer1;
          container2 = activedContainer2;
        });
      }
    };
    var f2 = () {
      // Dont do anything if time expired
      var hasEnded = counter1.getSeconds() == 0 || counter2.getSeconds() == 0;
      if (hasEnded) {
        counter1.stop();
        counter2.stop();
      } else {
        counter2.stop();
        counter1.start();
        setState(() {
          container2 = deactivedContainer2;
          container1 = activedContainer1;
        });
      }
    };

    // the widget representing an "active" button; it's your turn
    activedContainer1 = Expanded(
      child: RotatedBox(
        quarterTurns: 2,
        child:
            ElevatedButton(onPressed: f1, onLongPress: null, child: counter1),
      ),
    );
    activedContainer2 = Expanded(
      child: ElevatedButton(onPressed: f2, onLongPress: null, child: counter2),
    );

    // the widget representing a "deactivated" button; it's the opponent's turn
    deactivedContainer1 = Expanded(
      child: RotatedBox(
        quarterTurns: 2,
        child:
            ElevatedButton(onPressed: null, onLongPress: null, child: counter1),
      ),
    );
    deactivedContainer2 = Expanded(
      child:
          ElevatedButton(onPressed: null, onLongPress: null, child: counter2),
    );

    // initially both are active
    container1 = activedContainer1;
    container2 = activedContainer2;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        container1,
        Padding(
          padding: EdgeInsets.all(30.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Expanded(
                child: Ink(
                  decoration: const ShapeDecoration(
                    color: Colors.grey,
                    shape: CircleBorder(),
                  ),
                  child: IconButton(
                    onPressed: () {
                      pause();
                      counter1.reset();
                      counter2.reset();
                    },
                    icon: Icon(Icons.refresh),
                    color: Colors.white,
                    iconSize: 50.0,
                  ),
                ),
              ),
              Expanded(
                child: Ink(
                  decoration: const ShapeDecoration(
                    color: Colors.grey,
                    shape: CircleBorder(),
                  ),
                  child: IconButton(
                    icon: Icon(Icons.settings),
                    color: Colors.white,
                    iconSize: 50.0,
                    onPressed: () {},
                  ),
                ),
              ),
              Expanded(
                child: Ink(
                  decoration: const ShapeDecoration(
                    color: Colors.grey,
                    shape: CircleBorder(),
                  ),
                  child: IconButton(
                    onPressed: pause,
                    icon: Icon(Icons.pause),
                    color: Colors.white,
                    iconSize: 50.0,
                  ),
                ),
              ),
            ],
          ),
        ),
        container2,
      ],
    );
  }

  void pause() {
    counter1.stop();
    counter2.stop();
    setState(() {
      container1 = activedContainer1;
      container2 = activedContainer2;
    });
  }
}

class CountdownUnit extends StatefulWidget {
  final _CountdownUnitState c = _CountdownUnitState();
  @override
  _CountdownUnitState createState() => c;

  void reset() {
    c.reset();
  }

  void start() {
    c.start();
  }

  void stop() {
    c.stop();
  }

  int getSeconds() {
    return c.getSeconds();
  }
}

class _CountdownUnitState extends State<CountdownUnit> {
  int originalSeconds;
  int millis;
  int seconds;
  Timer timer;

  @override
  void initState() {
    super.initState();
    originalSeconds = 5;
    reset();
  }

  void reset() {
    seconds = originalSeconds;
    millis = originalSeconds * 1000;
    setStateWrapper(seconds);
  }

  @override
  Widget build(BuildContext context) {
    // the idea here is to make the fontSize some decent size, and scale it down if needed
    return FittedBox(
      fit: BoxFit.fitHeight,
      child: Text(
        secsToMins(seconds),
        // this seem like a fitting max size
        style: TextStyle(fontSize: 100),
      ),
    );
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
    bool moreTime = seconds > 0;
    if (moreTime) {
      //subtract 0.1 second from millis
      millis -= 100;
      // if a whole second has passed, decremnt seconds and set state
      if (millis % 1000 == 0) {
        // perform callback when reaching 0 secs
        setStateWrapper(seconds -= 1);
      }
    } else {
      timer.cancel();
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

  String secsToMins(int secs) {
    int mins = secs ~/ 60;
    int newSecs = secs % 60;
    return "$mins:$newSecs";
  }

  void setStateWrapper(int secs) {
    setState(() => secsToMins(secs));
  }

  int getSeconds() {
    return seconds;
  }
}
