// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:ui' as ui;
import 'package:flutter/services.dart';
import 'package:flutter_clock_helper/model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:intl/intl.dart';
import 'dart:typed_data';

import 'drawn_hand.dart';

/// Total distance traveled by a second or a minute hand, each second or minute,
/// respectively.
// final radiansPerTick = radians(360 / 60);

/// Total distance traveled by an hour hand, each hour, in radians.
// final radiansPerHour = radians(360 / 12);

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
  ui.Image imageMe;
  ui.Image imageCoffee;
  ui.Image imageFlutter;
  int imageLoaded = 0;


  @override
  void initState() {
    super.initState();
    widget.model.addListener(_updateModel);
    // Set the initial values.
    init();
    _updateTime();
    _updateModel();
    // hack for horizontal orientation
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft
    ]);
  }

  Future <Null> init() async {
    final ByteData dataMe = await rootBundle.load('images/me@2x.png');
    final ByteData dataCoffee = await rootBundle.load('images/coffee@2x.png');
    final ByteData dataFlutter = await rootBundle.load('images/flutter@2x.png');
    imageMe = await loadImage(new Uint8List.view(dataMe.buffer));
    imageCoffee = await loadImage(new Uint8List.view(dataCoffee.buffer));
    imageFlutter = await loadImage(new Uint8List.view(dataFlutter.buffer));
  }

  Future<ui.Image> loadImage(List<int> img) async {
    final Completer<ui.Image> completer = new Completer();
    ui.decodeImageFromList(img, (ui.Image img) {
      setState(() {
        imageLoaded += 1;
      });
      return completer.complete(img);
    });
    return completer.future;
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

  Widget _buildClock() {
    if (this.imageLoaded == 3) {
      return Stack(
        children: [
          Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                for (var i = 1; i < 13; i++)
                Expanded(
                  flex: 1,
                  child: 
                  Container(
                    // color: Colors.yellow,
                    decoration: BoxDecoration(
                      border: Border(
                        right: BorderSide(
                          color: Color(0xffF6F4F3),
                          width: 1,
                        ),
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      mainAxisSize: MainAxisSize.max,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: <Widget>[
                        Text(i < 10 ? '0$i' : i.toString()),
                        Text((i * 5) < 10 ?'0${i * 5}' : (i * 5).toString()),
                      ],
                    ),
                  ),
                ),
              ],
          ),
          DrawnHand(
            color: Color(0xFFF3F0FA),
            colorFill: Color(0xFFB393FF),
            colorFillLight: Color(0xFFF3F0FA),
            thickness: 20,
            size: 1,
            topPosition: 0.2,
            pointPosition: (_now.hour % 12) / 12,
            image: imageMe,
          ),
          DrawnHand(
            color: Color(0xFFFAF0F0),
            colorFill: Color(0xFFFFA4A4),
            colorFillLight: Color(0xFFF3F0FA),
            thickness: 20,
            size: 0.9,
            topPosition: 0.5,
            pointPosition: _now.minute / 60,
            image: imageCoffee,
          ),
          DrawnHand(
            color: Color(0xFFEBFAFF),
            colorFill: Color(0xFF41D2FF),
            colorFillLight: Color(0xFFF3F0FA),
            thickness: 20,
            size: 0.9,
            topPosition: 0.8,
            pointPosition: _now.second / 60,
            image: imageFlutter,
          ),
        ],
      );
    } else {
      return Center(child: new Text('loading...'));
    }
  }

  @override
  Widget build(BuildContext context) {
    // There are many ways to apply themes to your clock. Some are:
    //  - Inherit the parent Theme (see ClockCustomizer in the
    //    flutter_clock_helper package).
    //  - Override the Theme.of(context).colorScheme.
    //  - Create your own [ThemeData], demonstrated in [AnalogClock].
    //  - Create a map of [Color]s to custom keys, demonstrated in
    //    [DigitalClock].
    final customTheme = Theme.of(context).brightness == Brightness.light
        ? Theme.of(context).copyWith(
            // Hour hand.
            primaryColor: Color(0xFF4285F4),
            // Minute hand.
            highlightColor: Color(0xFF8AB4F8),
            // Second hand.
            accentColor: Color(0xFF669DF6),
            backgroundColor: Color(0xFFFFFFFF),
          )
        : Theme.of(context).copyWith(
            primaryColor: Color(0xFFD2E3FC),
            highlightColor: Color(0xFF4285F4),
            accentColor: Color(0xFF8AB4F8),
            backgroundColor: Color(0xFF3C4043),
          );

    final time = DateFormat.Hms().format(DateTime.now());

    return Semantics.fromProperties(
      properties: SemanticsProperties(
        label: 'Analog clock with time $time',
        value: time,
      ),
      child: Container(
        color: customTheme.backgroundColor,
        child: _buildClock(),
      ),
    );
  }
}
