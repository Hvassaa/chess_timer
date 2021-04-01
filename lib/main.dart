import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
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
                    onPressed: () async {
                      pause();
                      // result is the new seconds for the timer,
                      // could be null, if no new time is given
                      final result = await Navigator.push(context,
                          MaterialPageRoute(builder: (context) {
                        return SettingsScreen();
                      }));
                      // update time
                      if (result != 0) {
                        setTime(result);
                      }
                    },
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

  void setTime(int secs) {
    counter1.setOriginalSeconds(secs);
    counter2.setOriginalSeconds(secs);
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

  void setOriginalSeconds(int secs) {
    c.setOriginalSeconds(secs);
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
    String secsString = "$newSecs";
    if (secsString.length < 2) {
      secsString = "0" + secsString;
    }
    return "$mins:" + secsString;
  }

  void setStateWrapper(int secs) {
    setState(() => secsToMins(secs));
  }

  void setOriginalSeconds(int secs) {
    originalSeconds = secs;
    reset();
  }

  int getSeconds() {
    return seconds;
  }
}

class SettingsScreen extends StatefulWidget {
  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  int newSeconds;
  int newMinutes;
  int newHours;
  var secController;
  var minController;
  var hourController;
  var secField;
  var minField;
  var hourField;

  @override
  void initState() {
    super.initState();
    newSeconds = 0;
    newMinutes = 0;
    newHours = 0;

    double fieldWidth = 100;
    secController = TextEditingController();
    minController = TextEditingController();
    hourController = TextEditingController();
    secField = Container(
      width: fieldWidth,
      child: TextField(
        decoration: InputDecoration(
          border: OutlineInputBorder(),
          labelText: "Seconds",
        ),
        onChanged: (String value) {
          var newS = int.parse(value);
          newSeconds = newS;
        },
        controller: secController,
        keyboardType: TextInputType.number,
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly,
        ],
      ),
    );
    minField = Container(
      width: fieldWidth,
      child: TextField(
        decoration: InputDecoration(
          border: OutlineInputBorder(),
          labelText: "Minutes",
        ),
        onChanged: (String value) {
          var newM = int.parse(value);
          newMinutes = newM;
        },
        controller: minController,
        keyboardType: TextInputType.number,
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly,
        ],
      ),
    );

    hourField = Container(
      width: fieldWidth,
      child: TextField(
        decoration: InputDecoration(
          border: OutlineInputBorder(),
          labelText: "Hours",
        ),
        onChanged: (String value) {
          var newH = int.parse(value);
          newHours = newH;
        },
        controller: hourController,
        keyboardType: TextInputType.number,
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly,
        ],
      ),
    );
  }

  @override
  void dispose() {
    secController.dispose();
    minController.dispose();
    hourController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Settings",
      home: Scaffold(
        appBar: AppBar(
          leading: IconButton(
              icon: Icon(Icons.arrow_back),
              onPressed: () {
                Navigator.pop(context, 0);
              }),
          title: Text("Settings"),
        ),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text("Initial game time"),
                hourField,
                minField,
                secField,
                ElevatedButton(
                  onPressed: () {
                    int newTime =
                        newSeconds + (newMinutes * 60) + (newHours * 60 * 60);
                    Navigator.pop(context, newTime);
                  },
                  child: Icon(Icons.thumb_up),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
