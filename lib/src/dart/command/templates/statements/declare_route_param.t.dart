import 'package:afib/src/dart/command/af_source_template.dart';

class DeclareRouteParamT extends AFSourceTemplate {
  final String template = '''
class [!af_screen_name]RouteParam extends AFRouteParam {
  final String exampleParam;

  [!af_screen_name]RouteParam({
    this.exampleParam
  });

}
''';  
}
