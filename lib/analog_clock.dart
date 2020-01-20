import 'dart:async';
import 'dart:ui' as ui;
import 'dart:typed_data';
import 'dart:math';
import 'package:flutter/services.dart';
import 'package:flutter_clock_helper/model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:intl/intl.dart';

import 'drawn_hand.dart';

class AnalogClock extends StatefulWidget {
  const AnalogClock(this.model);

  final ClockModel model;

  @override
  _AnalogClockState createState() => _AnalogClockState();
}

class _AnalogClockState extends State<AnalogClock> {
  var _now = DateTime.now();
  var _is24HourFormat = false;
  Timer _timer;
  ui.Image imageMe;
  ui.Image imageCoffee;
  ui.Image imageFlutter;
  ui.Image imageMeTrace;
  ui.Image imageCoffeeTrace;
  ui.Image imageFlutterTrace;
  int imageLoaded = 0;
  int imageExpected = 6;
  double lineThickness = 20;

  @override
  void initState() {
    super.initState();
    widget.model.addListener(_updateModel);
    // Set the initial values.
    _initSources();
    _updateTime();
    _updateModel();
    // Set always landscape orientation
    SystemChrome.setPreferredOrientations(
        [DeviceOrientation.landscapeRight, DeviceOrientation.landscapeLeft]);
  }

  Future<Null> _initSources() async {
    final ByteData dataMe = await rootBundle.load('images/me.png');
    final ByteData dataCoffee = await rootBundle.load('images/coffee.png');
    final ByteData dataFlutter = await rootBundle.load('images/flutter.png');
    final ByteData dataMeTrace = await rootBundle.load('images/cry.png');
    final ByteData dataCoffeeTrace = await rootBundle.load('images/cookie.png');
    final ByteData dataFlutterTrace = await rootBundle.load('images/fire.png');
    imageMe = await loadImage(new Uint8List.view(dataMe.buffer));
    imageCoffee = await loadImage(new Uint8List.view(dataCoffee.buffer));
    imageFlutter = await loadImage(new Uint8List.view(dataFlutter.buffer));
    imageMeTrace = await loadImage(new Uint8List.view(dataMeTrace.buffer));
    imageCoffeeTrace =
        await loadImage(new Uint8List.view(dataCoffeeTrace.buffer));
    imageFlutterTrace =
        await loadImage(new Uint8List.view(dataFlutterTrace.buffer));
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
      _is24HourFormat = widget.model.is24HourFormat;
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

  List<Widget> _getTableColumns() {
    final List<Widget> columns = [];
    for (var i = 1; i < 13; i++) {
      int hourTick = (_now.hour > 12 && _is24HourFormat) ? 12 + i : i;
      String hourMark = (hourTick < 10) ? '0$hourTick' : hourTick.toString();
      int minuteTick = i * 5;
      String minuteMark =
          minuteTick < 10 ? '0$minuteTick' : minuteTick.toString();
      columns.add(Expanded(
        flex: 1,
        child: Container(
          decoration: BoxDecoration(
            border: Border(
              right: BorderSide(
                color: Color(0xFFF6F4F3),
                width: 1,
              ),
            ),
          ),
          padding: EdgeInsets.symmetric(horizontal: 0, vertical: 15),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: <Widget>[
              Text(hourMark, style: TextStyle(color: Color(0xFFBBBBBB))),
              Text(minuteMark, style: TextStyle(color: Color(0xFFBBBBBB))),
            ],
          ),
        ),
      ));
    }
    return columns;
  }

  Widget _buildClock() {
    if (this.imageLoaded == this.imageExpected) {
      Random rand = Random(_now.microsecond + _now.millisecond);
      return Stack(
        children: [
          Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: _getTableColumns(),
          ),
          DrawnHand(
            color: Color(0xFFF3F0FA),
            colorFill: Color(0xFFB393FF),
            colorFillLight: Color(0xFFF3F0FA),
            thickness: lineThickness,
            topPosition: 0.2,
            pointPosition: (_now.hour % 12) / 12,
            image: imageMe,
            imageTrace: imageMeTrace,
            isHit: rand.nextBool() && rand.nextBool() && rand.nextBool(),
          ),
          DrawnHand(
            color: Color(0xFFFAF0F0),
            colorFill: Color(0xFFFFA4A4),
            colorFillLight: Color(0xFFF3F0FA),
            thickness: lineThickness,
            topPosition: 0.5,
            pointPosition: _now.minute / 60,
            image: imageCoffee,
            imageTrace: imageCoffeeTrace,
            isHit: rand.nextBool(),
          ),
          DrawnHand(
            color: Color(0xFFEBFAFF),
            colorFill: Color(0xFF41D2FF),
            colorFillLight: Color(0xFFF3F0FA),
            thickness: lineThickness,
            topPosition: 0.8,
            pointPosition: _now.second / 60,
            image: imageFlutter,
            imageTrace: imageFlutterTrace,
            isHit: rand.nextBool() && rand.nextBool(),
          ),
        ],
      );
    } else {
      return Center(child: new Text('loading...'));
    }
  }

  @override
  Widget build(BuildContext context) {
    final customTheme = Theme.of(context).brightness == Brightness.light
        ? Theme.of(context).copyWith(
            backgroundColor: Color(0xFFFFFFFF),
          )
        : Theme.of(context).copyWith(
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
