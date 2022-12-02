import 'package:afib/src/dart/command/af_source_template.dart';
import 'package:afib/src/dart/command/templates/core/screen.t.dart';

class SnippetStandardRouteParamT extends AFSnippetSourceTemplate {
  String get template => '''
class ${insertMainType}RouteParam extends AF${ScreenT.insertControlTypeSuffix}RouteParam {
  ${insertMainType}RouteParam(): super(screenId: ${ScreenT.insertScreenIDType}.${ScreenT.insertScreenID});

  factory ${insertMainType}RouteParam.create() {
    return ${insertMainType}RouteParam();
  }

  ${insertMainType}RouteParam copyWith() {
    return ${insertMainType}RouteParam(
    );
  }
}
''';  
}
