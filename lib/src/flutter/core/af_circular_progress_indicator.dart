
import 'package:afib/src/flutter/af.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class AFCircularProgressIndicator extends StatelessWidget {
  final Key key;
  final Key childKey;
  final double value;
  final Color backgroundColor;
  final Animation<Color> valueColor;
  final double strokeWidth;
  final String semanticsLabel;
  final String semanticsValue;
  
  AFCircularProgressIndicator({
    this.key,
    this.childKey,
    this.value, 
    this.backgroundColor, 
    this.valueColor, 
    this.strokeWidth = 4.0, 
    this.semanticsLabel, 
    this.semanticsValue});

  @override
  Widget build(BuildContext context) {
    if(AF.config.isWidgetTesterContext) {
      return SizedBox(key: childKey, width: 20.0, height: 20.0);
    } else {
      return CircularProgressIndicator(
        key: childKey,
        value: value,
        backgroundColor: backgroundColor,
        valueColor: valueColor,
        strokeWidth: strokeWidth,
        semanticsLabel: semanticsLabel,
        semanticsValue: semanticsValue,
      );
    }
  }
  
}