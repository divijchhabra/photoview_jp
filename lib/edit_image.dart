import 'dart:async';
import 'dart:ui';

import 'package:demo_app_flutter/data_fields.dart';
import 'package:flutter/material.dart';
import 'package:perfect_freehand/perfect_freehand.dart';

import 'Freehand Tools/sketcher.dart';
import 'Freehand Tools/stroke.dart';
import 'Freehand Tools/stroke_options.dart';

class EditImage extends StatefulWidget {
  final String imageUrl;

  const EditImage({Key? key, required this.imageUrl}) : super(key: key);

  @override
  State<EditImage> createState() => _EditImageState();
}

class _EditImageState extends State<EditImage> {
  List<Stroke> lines = <Stroke>[];
  late double height, width;
  Stroke? line;
  bool isFreehand = false, isText = false;

  StrokeOptions options = StrokeOptions();

  StreamController<Stroke> currentLineStreamController =
      StreamController<Stroke>.broadcast();

  StreamController<List<Stroke>> linesStreamController =
      StreamController<List<Stroke>>.broadcast();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    if (DataFields.storedLines.isNotEmpty) {
      for (var line in DataFields.storedLines) {
        List<Point> strokePoints =
            line.map<Point>((e) => Point(e["x"], e["y"])).toList();
        lines.add(Stroke(strokePoints));
      }
    }
  }

  void onPointerDown(PointerDownEvent details) {
    options = StrokeOptions(
      simulatePressure: details.kind != PointerDeviceKind.stylus,
    );

    final box = context.findRenderObject() as RenderBox;
    final fakeOffset = box.globalToLocal(details.position);
    final offset =
        Offset(fakeOffset.dx - width * 10, fakeOffset.dy - height * 15);
    late final Point point;
    if (details.kind == PointerDeviceKind.stylus) {
      point = Point(
        offset.dx,
        offset.dy,
        (details.pressure - details.pressureMin) /
            (details.pressureMax - details.pressureMin),
      );
    } else {
      point = Point(offset.dx, offset.dy);
    }
    final points = [point];
    line = Stroke(points);
    currentLineStreamController.add(line!);
  }

  void onPointerMove(PointerMoveEvent details) {
    final box = context.findRenderObject() as RenderBox;
    final fakeOffset = box.globalToLocal(details.position);
    final offset =
        Offset(fakeOffset.dx - width * 10, fakeOffset.dy - height * 15);
    late final Point point;
    if (details.kind == PointerDeviceKind.stylus) {
      point = Point(
        offset.dx,
        offset.dy,
        (details.pressure - details.pressureMin) /
            (details.pressureMax - details.pressureMin),
      );
    } else {
      point = Point(offset.dx, offset.dy);
    }
    final points = [...line!.points, point];
    line = Stroke(points);
    currentLineStreamController.add(line!);
  }

  void onPointerUp(PointerUpEvent details) {
    lines = List.from(lines)..add(line!);
    linesStreamController.add(lines);
  }

  Future<void> clear() async {
    setState(() {
      lines = [];
      line = null;
    });
  }

  Widget buildCurrentPath(BuildContext context) {
    return Container(
      height: height * 70,
      width: width * 90,
      margin:
          EdgeInsets.symmetric(horizontal: width * 5, vertical: height * 1.5),
      child: Listener(
        onPointerDown: onPointerDown,
        onPointerMove: onPointerMove,
        onPointerUp: onPointerUp,
        child: RepaintBoundary(
          child: Container(
              color: Colors.transparent,
              child: StreamBuilder<Stroke>(
                  stream: currentLineStreamController.stream,
                  builder: (context, snapshot) {
                    return CustomPaint(
                      size: Size(width * 90, height * 70),
                      painter: Sketcher(
                        lines: line == null ? [] : [line!],
                        options: options,
                      ),
                    );
                  })),
        ),
      ),
    );
  }

  Widget buildAllPaths(BuildContext context) {
    return Container(
      height: height * 70,
      width: width * 90,
      margin:
          EdgeInsets.symmetric(horizontal: width * 5, vertical: height * 1.5),
      child: RepaintBoundary(
        child: StreamBuilder<List<Stroke>>(
          stream: linesStreamController.stream,
          builder: (context, snapshot) {
            return CustomPaint(
              painter: Sketcher(
                lines: lines,
                options: options,
              ),
            );
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    height = MediaQuery.of(context).size.height / 100;
    width = MediaQuery.of(context).size.width / 100;
    Offset offset = Offset.zero;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        actions: [
          Padding(
            padding: EdgeInsets.only(right: width * 5),
            child: IconButton(
                onPressed: clear,
                icon: Icon(
                  Icons.clear_all,
                  size: height * 4,
                )),
          )
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            const Expanded(
              child: SizedBox(),
            ),
            Container(
              height: height * 70,
              width: width * 90,
              margin: EdgeInsets.symmetric(
                  horizontal: width * 5, vertical: height * 1.5),
              decoration: BoxDecoration(
                  color: Colors.blue,
                  image: DecorationImage(
                      image: NetworkImage(widget.imageUrl), fit: BoxFit.fill),
                  border: Border.all(
                    width: 2,
                  ),
                  borderRadius: BorderRadius.circular(5)),
              alignment: Alignment.center,
              child: Stack(
                children: [
                  buildAllPaths(context),
                  if (isFreehand) buildCurrentPath(context),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(
                  horizontal: width * 30, vertical: height * 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () => setState(() => isFreehand = !isFreehand),
                    child: Container(
                        height: height * 7,
                        width: width * 12,
                        decoration: BoxDecoration(
                            color: isFreehand
                                ? Colors.black26
                                : Colors.transparent,
                            shape: BoxShape.circle,
                            border: Border.all()),
                        alignment: Alignment.center,
                        child: Icon(Icons.gesture, size: height * 2.7)),
                  ),
                  GestureDetector(
                    onTap: () {
                      DataFields.storedLines.clear();
                      for (int i = 0; i < lines.length; i++) {
                        List<Map> linePoints = lines[i].points.map<Map>((e) {
                          return {"x": e.x, "y": e.y};
                        }).toList();
                        DataFields.storedLines.add(linePoints);
                      }
                      Navigator.pop(context);
                    },
                    child: Container(
                        height: height * 7,
                        width: width * 12,
                        decoration: BoxDecoration(
                            shape: BoxShape.circle, border: Border.all()),
                        alignment: Alignment.center,
                        child: Icon(Icons.done, size: height * 2.7)),
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    linesStreamController.close();
    currentLineStreamController.close();
  }
}
