
import 'package:afib/src/dart/command/af_source_template.dart';

class SnippetDialogBuildBodyT extends AFCoreSnippetSourceTemplate {
  String get template => '''
    final t = spi.t;
    final rows = t.column();
    
    rows.add(Row(
      mainAxisSize: MainAxisSize.max,
      children: [t.childText(uiTitle)]
    ));

    rows.add(t.childButtonPrimaryText(
      key: t.keyForWID(${insertAppNamespaceUpper}WidgetID.standardClose),
      text: "Close", 
      onPressed: spi.onPressedClose
    ));

    return Dialog(
      insetPadding: t.margin.standard,
      backgroundColor: t.colorSurface,
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: t.colorPrimary),
          borderRadius: t.borderRadius.standard,
        ),
        child: t.childMargin(
          margin: t.margin.standard,
          child: t.childColumn(rows,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min
          )
        )
      )
    );
''';
}