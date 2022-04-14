import 'package:afib/src/dart/command/af_source_template.dart';

class DeclareRouteParamT extends AFSourceTemplate {
  final String template = '''
[!af_comment_route_param_intro]
@immutable
class [!af_screen_name]RouteParam extends AFRouteParam {
  [!af_route_param_impls]
}
''';  
}
