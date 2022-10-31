import 'package:afib/src/dart/command/af_source_template.dart';

class DeclareStartupScreenTestImplT extends AFSourceTemplate {
  final String template = '''
      await e.matchText(HCWidgetID.textCountRouteParam, ft.equals("0"));
      await e.applyTap(HCWidgetID.buttonIncrementRouteParam);
      await e.applyTap(HCWidgetID.buttonIncrementRouteParam);
      await e.applyTap(HCWidgetID.buttonIncrementRouteParam);
      await e.matchText(HCWidgetID.textCountRouteParam, ft.equals("3"));
''';
}
