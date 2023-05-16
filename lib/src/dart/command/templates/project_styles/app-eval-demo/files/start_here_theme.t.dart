

import 'package:afib/src/dart/command/af_project_paths.dart';
import 'package:afib/src/dart/command/af_source_template.dart';
import 'package:afib/src/dart/command/templates/core/files/theme.t.dart';

class StartHereThemeT {

  static ThemeT example() {
    return ThemeT(
      templateFileId: "start_here_theme",
      templateFolder: AFProjectPaths.pathGenerateExampleEvalDemoFiles,
      embeddedInsertions: AFSourceTemplateInsertions(insertions: {
        AFSourceTemplate.insertExtraImportsInsertion: '''
import 'package:flutter/material.dart';
''',
        AFSourceTemplate.insertAdditionalMethodsInsertion: '''
Widget childCaptionSimulatedLatency() {
  return childText(text: "(with simulated latency)", style: styleOnCard.caption);
}

Widget childSingleRowButton({ required Widget button }) {
  final cols = row();
  cols.add(const Spacer(flex: 1));
  cols.add(Expanded(
    flex: 5,
    child: button,
  ));
  cols.add(const Spacer(flex: 1));
  return Row(children: cols);
}

Widget childStandardCard(List<Widget> rows) {
  return Card(
    child: childMarginStandard(
      child: Column(
        children: rows
      )
    )
  );
}

void buildCardHeader({
  required List<Widget> rows,
  required String title,
  String? subtitle,
}) {
  rows.add(childMargin(
    margin: margin.b.standard,
    child: childText(text: title, style: styleOnCard.bodyText1)
  ));

  if(subtitle != null) {
    rows.add(childMargin(
      margin: margin.b.standard,
      child: childText(text: subtitle, style: styleOnCard.caption)
    ));
  }
}

void buildStateCount({ required List<Widget> rows, required int clickCount }) {
  buildCardHeader(rows: rows, title: "Aggregate Persistent Count", subtitle: "(global state)");
  rows.add(childText(text: clickCount.toString(), style: styleOnCard.headline2));
}
''',
      })
    );
  } 

}