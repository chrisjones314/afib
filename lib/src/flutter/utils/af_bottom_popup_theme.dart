import 'package:flutter/material.dart';


//--------------------------------------------------------------------------------------
class AFBottomPopupTheme {
  final TextStyle cancelStyle;
  final TextStyle doneStyle;
  final TextStyle itemStyle;
  final Color backgroundColor;
  final Color headerColor;

  final double containerHeight;
  final double titleHeight;
  final double itemHeight;
  final bool showTitleActions;

  const AFBottomPopupTheme({
    this.cancelStyle = const TextStyle(color: Colors.black54, fontSize: 16),
    this.doneStyle = const TextStyle(color: Colors.blue, fontSize: 16),
    this.itemStyle = const TextStyle(color: Color(0xFF000046), fontSize: 18),
    this.backgroundColor = Colors.white,
    this.headerColor,
    this.containerHeight,
    this.titleHeight = 44.0,
    this.itemHeight = 36.0,
    this.showTitleActions = true,
  });
}
