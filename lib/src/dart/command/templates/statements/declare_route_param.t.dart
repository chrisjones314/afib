import 'package:afib/src/dart/command/af_source_template.dart';

class DeclareRouteParamT extends AFSourceTemplate {
  final String template = '''
@immutable
class [!af_screen_name]RouteParam extends AFRouteParam {

  [!af_screen_name]RouteParam(): super(id: [!af_screen_id_type].[!af_screen_id]);

  factory [!af_screen_name]RouteParam.create() {
    return [!af_screen_name]RouteParam();
  }

  [!af_screen_name]RouteParam copyWith() {
    return [!af_screen_name]RouteParam(
    );
  }
}
''';  
}
