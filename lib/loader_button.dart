import 'package:demo_app_flutter/constants.dart';
import 'package:flutter/material.dart';

class LoaderButton extends StatelessWidget {
  final void Function()? onTap;
  const LoaderButton({Key? key, this.onTap}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: IconButton(
          onPressed: onTap,
          icon: Icon(
            Icons.refresh,
            size: Constants.height * 4,
          )),
    );
  }
}
