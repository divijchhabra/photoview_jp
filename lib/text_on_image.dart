import 'package:flutter/material.dart';

class TextOnImage extends StatefulWidget {
  final Offset? textOffset;
  final double? scale;
  final String txt;
  const TextOnImage({Key? key, this.textOffset, this.scale, required this.txt})
      : super(key: key);

  @override
  State<TextOnImage> createState() => _TextOnImageState();
}

class _TextOnImageState extends State<TextOnImage> {
  late Offset offset;
  late double _scaleFactor;
  late double _baseScaleFactor;
  late String text;
  @override
  Widget build(BuildContext context) {
    _scaleFactor = widget.scale ?? 1.0;
    _baseScaleFactor = widget.scale ?? 1.0;
    offset = widget.textOffset ?? Offset(250, 250);
    text = widget.txt;
    return Positioned(
      left: offset.dx,
      top: offset.dy,
      child: GestureDetector(
          onScaleStart: (details) {
            _baseScaleFactor = _scaleFactor;
          },
          onScaleUpdate: (details) {
            setState(() {
              offset = Offset(offset.dx + details.focalPointDelta.dx,
                  offset.dy + details.focalPointDelta.dy);
              _scaleFactor = _baseScaleFactor * details.scale;
            });
          },
          child: Text(text,
              textAlign: TextAlign.center,
              textScaleFactor: _scaleFactor,
              style: const TextStyle(color: Colors.red))),
    );
  }
}
