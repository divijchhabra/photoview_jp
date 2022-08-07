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
  GlobalKey renderKey = GlobalKey();
  List<Stroke> lines = <Stroke>[], undoLines = <Stroke>[];
  late double height, width;
  Stroke? line;
  bool isFreehand = false, isText = false;

  StrokeOptions options = StrokeOptions();

  StreamController<Stroke> currentLineStreamController =
      StreamController<Stroke>.broadcast();

  StreamController<List<Stroke>> linesStreamController =
      StreamController<List<Stroke>>.broadcast();
  double scaleValue = 0.0;

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

    final box = renderKey.currentContext!.findRenderObject() as RenderBox;
    final offset = box.globalToLocal(details.position);
    // final offset =
    //     Offset(fakeOffset.dx - width * 10, fakeOffset.dy - height * 15);
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
    final box = renderKey.currentContext!.findRenderObject() as RenderBox;
    final offset = box.globalToLocal(details.position);
    // final offset =
    //     Offset(fakeOffset.dx - width * 10, fakeOffset.dy - height * 15);
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
    setState(() {});
  }

  void clear() {
    if (lines.isNotEmpty) {
      setState(() {
        lines.clear();
        line = null;
        undoLines.clear();
      });
    }
  }

  void undo() {
    if (lines.isNotEmpty) {
      setState(() {
        Stroke undoLine = lines[lines.length - 1];
        undoLines.add(undoLine);
        lines.remove(undoLine);
        line = null;
      });
    }
  }

  void redo() {
    if (undoLines.isNotEmpty) {
      setState(() {
        Stroke redoLine = undoLines[undoLines.length - 1];
        lines.add(redoLine);
        undoLines.remove(redoLine);
      });
    }
  }

  Widget buildCurrentPath(BuildContext context) {
    return Listener(
      onPointerDown: onPointerDown,
      onPointerMove: onPointerMove,
      onPointerUp: onPointerUp,
      child: SizedBox(
        height: height * 70,
        width: width * 90,
        child: StreamBuilder<Stroke>(
            stream: currentLineStreamController.stream,
            builder: (context, snapshot) {
              return CustomPaint(
                painter: Sketcher(
                  lines: line == null ? [] : [line!],
                  options: options,
                ),
              );
            }),
      ),
    );
  }

  Widget buildAllPaths(BuildContext context) {
    return SizedBox(
      height: height * 70,
      width: width * 90,
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
    );
  }

  @override
  Widget build(BuildContext context) {
    height = MediaQuery.of(context).size.height / 100;
    width = MediaQuery.of(context).size.width / 100;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        actions: [
          Padding(
            padding: EdgeInsets.only(right: width * 2),
            child: IconButton(
                onPressed: undo,
                icon: Icon(
                  Icons.undo,
                  size: height * 3,
                  color: lines.isEmpty ? Colors.grey : Colors.black,
                )),
          ),
          Padding(
            padding: EdgeInsets.only(right: width * 2),
            child: IconButton(
                onPressed: redo,
                icon: Icon(
                  Icons.redo,
                  size: height * 3,
                  color: undoLines.isEmpty ? Colors.grey : Colors.black,
                )),
          ),
          Padding(
            padding: EdgeInsets.only(right: width * 5),
            child: IconButton(
                onPressed: clear,
                icon: Icon(
                  Icons.clear_all,
                  size: height * 4,
                  color: lines.isEmpty ? Colors.grey : Colors.black,
                )),
          ),
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
                  color: Colors.black,
                  border: Border.all(
                    width: 2,
                  ),
                  borderRadius: BorderRadius.circular(5)),
              alignment: Alignment.center,
              child: InteractiveViewer(
                panEnabled: !isFreehand,
                scaleEnabled: !isFreehand,
                child: Container(
                  height: height * 70,
                  width: width * 90,
                  key: renderKey,
                  decoration: BoxDecoration(
                      image: DecorationImage(
                          image: NetworkImage(widget.imageUrl),
                          fit: BoxFit.fill)),
                  child: Stack(
                    children: [
                      buildAllPaths(context),
                      if (isFreehand) buildCurrentPath(context),
                    ],
                  ),
                ),
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
