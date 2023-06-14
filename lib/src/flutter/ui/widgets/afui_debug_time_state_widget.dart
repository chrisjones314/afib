
//--------------------------------------------------------------------------------------
import 'package:afib/afib_command.dart';
import 'package:flutter/material.dart';

@immutable
class AFUIDebugTimeStateWidget extends StatelessWidget {
  final AFTimeState displayTime;

  const AFUIDebugTimeStateWidget({
    required this.displayTime,
  });
  
  @override
  Widget build(BuildContext c) {
    final rows = <Widget>[];
    rows.add(_createLine("Debug push time:"));
    rows.add(_createLine(displayTime.toString(), fontWeight: FontWeight.bold));
    rows.add(_createLine("Will update when the:"));
    rows.add(_createLine(displayTime.pushUpdateSpecificity.name, fontWeight: FontWeight.bold));
    rows.add(_createLine("changes.  But no more frequently than: "));
    rows.add(_createLine(displayTime.pushUpdateFrequency.toString(), fontWeight: FontWeight.bold));

    return Card(
      child: Column(children: rows),
    );
  }

  Widget _createLine(String text, { 
    FontWeight fontWeight = FontWeight.normal,
    EdgeInsets margin = const EdgeInsets.all(8.0),
  }) {
    return Container(
      margin: margin,
      child: Text(text, style: TextStyle(fontWeight: fontWeight)
    ));
  }
}

