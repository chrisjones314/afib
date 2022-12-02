import 'package:afib/src/dart/command/af_source_template.dart';

class DeclareStartupScreenTestImplT extends AFSourceTemplate {
  final String template = '''
      await e.matchText([!af_app_namespace(upper)]WidgetID.textCountRouteParam, ft.equals("3"));
      await e.applyTap([!af_app_namespace(upper)]WidgetID.buttonIncrementRouteParam);
      await e.applyTap([!af_app_namespace(upper)]WidgetID.buttonIncrementRouteParam);
      await e.applyTap([!af_app_namespace(upper)]WidgetID.buttonIncrementRouteParam);
      await e.matchText([!af_app_namespace(upper)]WidgetID.textCountRouteParam, ft.equals("6"));
''';
}
