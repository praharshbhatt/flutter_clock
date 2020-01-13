// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:flutter_clock_helper/model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:intl/intl.dart';
import 'package:vector_math/vector_math_64.dart' show radians;
import 'drawn_hand.dart';
import 'flutter__clock_icons.dart';

/// Total distance traveled by a second or a minute hand, each second or minute,
/// respectively.
final radiansPerTick = radians(360 / 60);

/// Total distance traveled by an hour hand, each hour, in radians.
final radiansPerHour = radians(360 / 12);

/// A basic analog clock.
///
/// You can do better than this!
class AnalogClock extends StatefulWidget {
  const AnalogClock(this.model);

  final ClockModel model;

  @override
  _AnalogClockState createState() => _AnalogClockState();
}

class _AnalogClockState extends State<AnalogClock> {
  var _now = DateTime.now();
  var _temperature = '';
  var _temperatureRange = '';
  var _condition = '';
  var _location = '';
  Timer _timer;

  @override
  void initState() {
    super.initState();
    widget.model.addListener(_updateModel);
    // Set the initial values.
    _updateTime();
    _updateModel();
  }

  @override
  void didUpdateWidget(AnalogClock oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.model != oldWidget.model) {
      oldWidget.model.removeListener(_updateModel);
      widget.model.addListener(_updateModel);
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    widget.model.removeListener(_updateModel);
    super.dispose();
  }

  void _updateModel() {
    setState(() {
      _temperature = widget.model.temperatureString;
      _temperatureRange = '(${widget.model.low} - ${widget.model.highString})';
      _condition = widget.model.weatherString;
      _location = widget.model.location;
    });
  }

  void _updateTime() {
    setState(() {
      _now = DateTime.now();
      // Update once per second. Make sure to do it at the beginning of each
      // new second, so that the clock is accurate.
      _timer = Timer(
        Duration(seconds: 1) - Duration(milliseconds: _now.millisecond),
        _updateTime,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    double size = MediaQuery.of(context).size.width < MediaQuery.of(context).size.height
        ? MediaQuery.of(context).size.width
        : MediaQuery.of(context).size.height;

    final customTheme = Theme.of(context).brightness == Brightness.light
        ? Theme.of(context).copyWith(
            // Hour hand.
            primaryColor: Color(0xFF4285F4),
            // Minute hand.
            highlightColor: Color(0xFF8AB4F8),
            // Second hand.
            accentColor: Color.fromARGB(255, 252, 0, 83),
            backgroundColor: Colors.white,
            textTheme: TextTheme(body1: TextStyle(color: Colors.black, fontFamily: "Railway", fontSize: size * 0.04)))
        : Theme.of(context).copyWith(
            primaryColor: Color(0xFFD2E3FC),
            highlightColor: Color(0xFF4285F4),
            accentColor: Color.fromARGB(255, 252, 0, 83),
            backgroundColor: Colors.black,
            textTheme: TextTheme(body1: TextStyle(color: Colors.white, fontFamily: "Railway", fontSize: size * 0.04)));

    //We do not want to show the weather info here
    final time = DateFormat.Hms().format(DateTime.now());
//    final weatherInfo = DefaultTextStyle(
//      style: TextStyle(color: customTheme.primaryColor),
//      child: Column(
//        crossAxisAlignment: CrossAxisAlignment.start,
//        children: [
//          Text(_temperature),
//          Text(_temperatureRange),
//          Text(_condition),
//          Text(_location),
//        ],
//      ),
//    );

    return Semantics.fromProperties(
      properties: SemanticsProperties(
        label: 'Analog clock with time $time',
        value: time,
      ),
      child: Container(
        padding: EdgeInsets.all(15),
        color: customTheme.backgroundColor,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            //Hours
            Expanded(
              flex: 5,
              child: Stack(
                alignment: AlignmentDirectional.center,
                children: [
                  // Example of a hand drawn with [Container].
                  Image.asset(Theme.of(context).brightness == Brightness.light
                      ? "assets/images/hour_bg_light.png"
                      : "assets/images/hour_bg_dark.png"),
                  DrawnHand(
                    color: customTheme.accentColor,
                    thickness: 2,
                    size: size * 0.001,
                    angleRadians: _now.hour * radiansPerTick,
                  ),
                ],
              ),
            ),

            //Date and weather
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[

                //Weather
                Padding(
                  padding: EdgeInsets.fromLTRB(0, 15, 0, 0),
                  child: Stack(
                    alignment: AlignmentDirectional.center,
                    children: <Widget>[
                      //Background Image
                      Image.asset(
                          Theme.of(context).brightness == Brightness.light
                              ? "assets/images/weather_light.png"
                              : "assets/images/weather_dark.png",
                          width: size * 0.16),

                      //Weather Icon
                      Icon(getWeatherIcon(), color: customTheme.accentColor, size: size*0.07,)
                    ],
                  ),
                ),

                //Date
                Padding(
                  padding: EdgeInsets.fromLTRB(0, 0, 0, 15),
                  child: Stack(
                    alignment: AlignmentDirectional.center,
                    children: <Widget>[
                      //Background Image
                      Image.asset(
                          Theme.of(context).brightness == Brightness.light
                              ? "assets/images/date_light.png"
                              : "assets/images/date_dark.png",
                          width: size * 0.24),

                      //Date
                      Center(
                          child: Text(
                              DateTime.now().day.toString() + " " + getMonthsFromInt(DateTime.now().month).toString(),
                              style: customTheme.textTheme.body1.copyWith(fontWeight: FontWeight.normal),
                              textAlign: TextAlign.center))
                    ],
                  ),
                )
              ],
            ),

            //Minutes
            Expanded(
              flex: 5,
              child: Stack(
                alignment: AlignmentDirectional.center,
                children: [
                  // Example of a hand drawn with [CustomPainter].
                  Image.asset(Theme.of(context).brightness == Brightness.light
                      ? "assets/images/minute_bg_light.png"
                      : "assets/images/minute_bg_dark.png"),

                  //Seconds
                  DrawnHand(
                    color: customTheme.accentColor,
                    thickness: 1,
                    size: size * 0.001,
                    angleRadians: _now.second * radiansPerTick,
                  ),

                  //Minutes
                  DrawnHand(
                    color: customTheme.accentColor,
                    thickness: 2,
                    size: size * 0.0017,
                    angleRadians: _now.minute * radiansPerTick,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData getWeatherIcon() {
    if (_condition == "cloudy")
      return Icons.cloud;
    else if (_condition == "foggy")
      return Flutter_Clock.fog;
    else if (_condition == "rainy")
      return Icons.grain;
    else if (_condition == "snowy")
      return Flutter_Clock.snow_inv;
    else if (_condition == "sunny")
      return Icons.wb_sunny;
    else if (_condition == "thunderstorm")
      return Flutter_Clock.cloud_flash;
    else if (_condition == "windy")
      return Flutter_Clock.wind;
    else
      return Flutter_Clock.na;
  }
}

getMonthsFromInt(int month) {
  if (month == 1)
    return "Jan";
  else if (month == 2)
    return "Feb";
  else if (month == 3)
    return "March";
  else if (month == 4)
    return "April";
  else if (month == 5)
    return "May";
  else if (month == 6)
    return "June";
  else if (month == 7)
    return "July";
  else if (month == 8)
    return "Aug";
  else if (month == 9)
    return "Sep";
  else if (month == 10)
    return "Oct";
  else if (month == 11)
    return "Nov";
  else if (month == 12) return "Dec";
}
