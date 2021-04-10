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
  static const String route = '/chess-timer';
  @override
  _ChessTimerState createState() => _ChessTimerState();
}

class _ChessTimerState extends State<ChessTimer> {
  // the counters, responsible for time keeping and the associated text
  CountdownUnit counter1;
  CountdownUnit counter2;
  // The "containers", which should draw buttons
  Expanded container1;
  Expanded container2;
  Expanded activedContainer1;
  Expanded activedContainer2;
  Expanded deactivedContainer1;
  Expanded deactivedContainer2;
  GameType gameType;

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
        if (gameType == GameType.fischer) {
          counter1.giveGameTypeTime();
        }
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
        if (gameType == GameType.fischer) {
          counter2.giveGameTypeTime();
        }
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

    // gameType is standard initially
    gameType = GameType.standard;
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
                      reset();
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
                      reset();
                      // result is the new seconds for the timer,
                      // could be 0, if no new time is given
                      final DataWrapper result = await Navigator.push(context,
                          MaterialPageRoute(builder: (context) {
                        return SettingsScreen(
                            orginalData: DataWrapper(
                                gameType,
                                counter1.getOriginalSeconds(),
                                counter1.getGameTypeSeconds()));
                      }));
                      // update time
                      setTime(result.initialTime);
                      setGameTypeTime(result.gameTypeTime);
                      gameType = result.gameType;
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

  void reset() {
    pause();
    counter1.reset();
    counter2.reset();
  }

  void setTime(int secs) {
    counter1.setOriginalSeconds(secs);
    counter2.setOriginalSeconds(secs);
  }

  void setGameTypeTime(int secs) {
    counter1.setGameTypeTime(secs);
    counter2.setGameTypeTime(secs);
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

  int getOriginalSeconds() {
    return c.getOriginalSeconds();
  }

  int getGameTypeSeconds() {
    return c.getGameTypeSeconds();
  }

  void giveGameTypeTime() {
    c.giveGameTypeTime();
  }

  void setGameTypeTime(int seconds) {
    c.setGameTypeTime(seconds);
  }
}

class _CountdownUnitState extends State<CountdownUnit> {
  int originalSeconds;
  int millis;
  int seconds;
  Timer timer;
  // seconds to add after your turn
  int gameTypeTime;

  @override
  void initState() {
    super.initState();
    originalSeconds = 600;
    gameTypeTime = 0;
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

  int getOriginalSeconds() {
    return originalSeconds;
  }

  int getGameTypeSeconds() {
    return gameTypeTime;
  }

  void setGameTypeTime(int seconds) {
    gameTypeTime = seconds;
  }

  void giveGameTypeTime() {
    if (millis != originalSeconds * 1000) {
      seconds += gameTypeTime;
      millis += gameTypeTime * 1000;
      setStateWrapper(seconds);
    }
  }
}

class SettingsScreen extends StatefulWidget {
  static const String route = '/settings';
  final DataWrapper orginalData;
  SettingsScreen({Key key, @required this.orginalData}) : super(key: key);

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  int newSeconds;
  int newMinutes;
  int newHours;
  int newIncrementOrDelaySec;
  TextEditingController secController;
  TextEditingController minController;
  TextEditingController hourController;
  TextEditingController incrementOrDelaySecController;
  Container secField;
  Container minField;
  Container hourField;
  Container incrementOrDelaySecField;
  Function cancel;
  GameType gameType;

  @override
  void initState() {
    super.initState();
    cancel = () => Navigator.pop(
        context, widget.orginalData); //DataWrapper(gameType, 0, 0));
    newSeconds = widget.orginalData.initialTime % 60;
    newMinutes = (widget.orginalData.initialTime ~/ 60) % 60;
    newHours = widget.orginalData.initialTime ~/ 3600;
    newIncrementOrDelaySec = widget.orginalData.gameTypeTime;

    double fieldWidth = 100;
    secController = TextEditingController(text: "$newSeconds");
    minController = TextEditingController(text: "$newMinutes");
    hourController = TextEditingController(text: "$newHours");
    incrementOrDelaySecController =
        TextEditingController(text: "$newIncrementOrDelaySec");
    secField = Container(
      width: fieldWidth,
      child: TextField(
        decoration: InputDecoration(
          border: OutlineInputBorder(),
          labelText: "Seconds",
        ),
        onChanged: (String value) {
          newSeconds = 0;
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
          newMinutes = 0;
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
          newHours = 0;
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

    incrementOrDelaySecField = Container(
      width: fieldWidth,
      child: TextField(
        decoration: InputDecoration(
          border: OutlineInputBorder(),
          labelText: "Seconds",
        ),
        onChanged: (String value) {
          newIncrementOrDelaySec = 0;
          var newS = int.parse(value);
          newIncrementOrDelaySec = newS;
        },
        controller: incrementOrDelaySecController,
        keyboardType: TextInputType.number,
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly,
        ],
      ),
    );
    gameType = widget.orginalData.gameType;
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
                cancel();
              }),
          title: Text("Settings"),
          actions: [],
        ),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Padding(
              padding: EdgeInsets.all(20.0),
              child: Text(
                "Initial game time",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                hourField,
                minField,
                secField,
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                DropdownButton<GameType>(
                  underline: Container(
                    height: 2,
                    color: Colors.blue,
                  ),
                  onChanged: (GameType result) => setState(
                    () => gameType = result,
                  ),
                  value: gameType,
                  items: [
                    GameType.standard,
                    GameType.fischer,
                    GameType.simpleDelay,
                    GameType.bronsteinDelay
                  ].map<DropdownMenuItem<GameType>>((GameType val) {
                    return DropdownMenuItem(
                      child: Text(val.toString()),
                      value: val,
                    );
                  }).toList(),
                ),
                incrementOrDelaySecField,
              ],
            ),
            Padding(
              padding: EdgeInsets.all(20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Padding(
                    padding: EdgeInsets.only(right: 10.0),
                    child: Ink(
                      decoration: ShapeDecoration(
                        color: Colors.red,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16.0)),
                      ),
                      child: IconButton(
                        iconSize: 30,
                        color: Colors.white,
                        onPressed: () {
                          cancel();
                        },
                        icon: Icon(Icons.cancel),
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(left: 10.0),
                    child: Ink(
                      decoration: ShapeDecoration(
                        color: Colors.lightGreen,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16.0)),
                      ),
                      child: IconButton(
                        iconSize: 30,
                        color: Colors.white,
                        onPressed: () {
                          int newTime = newSeconds +
                              (newMinutes * 60) +
                              (newHours * 60 * 60);
                          if (newTime == 0) {
                            newTime = widget.orginalData.initialTime;
                          }
                          if (newIncrementOrDelaySec == 0 &&
                              gameType != GameType.standard) {
                            newIncrementOrDelaySec =
                                widget.orginalData.gameTypeTime;
                          }
                          Navigator.pop(
                              context,
                              DataWrapper(
                                  // gameType, newTime, incrementOrDelaySecField));
                                  gameType,
                                  newTime,
                                  newIncrementOrDelaySec));
                        },
                        icon: Icon(Icons.thumb_up),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

enum GameType { standard, fischer, simpleDelay, bronsteinDelay }

class DataWrapper {
  final GameType gameType;
  final int initialTime;
  final int gameTypeTime;

  DataWrapper(this.gameType, this.initialTime, this.gameTypeTime);
}
