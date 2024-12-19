import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CupertinoStyles {
  static const primaryColor = CupertinoColors.activeBlue;

  static Widget cupertinoAppBar(String title) {
    return CupertinoNavigationBar(
      middle: Text(title, style: TextStyle(color: CupertinoColors.black)),
    );
  }

  static Widget loadingIndicator() {
    return Center(child: CupertinoActivityIndicator());
  }

  static BoxDecoration cardDecoration() {
    return BoxDecoration(
      color: CupertinoColors.white,
      borderRadius: BorderRadius.circular(10),
      boxShadow: [
        BoxShadow(
          color: CupertinoColors.systemGrey.withOpacity(0.5),
          blurRadius: 5,
          spreadRadius: 2,
        ),
      ],
    );
  }
}
