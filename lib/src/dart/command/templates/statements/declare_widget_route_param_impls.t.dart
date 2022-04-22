import 'package:afib/src/dart/command/af_source_template.dart';

class DeclareWidgetRouteParamImplsT extends AFSourceTemplate {
  final String template = '''
  [!af_screen_name]RouteParam({
    required AFID id,
  }): super(id: id);

  factory [!af_screen_name]RouteParam.create({
    required AFID id,
  }) {
    return [!af_screen_name]RouteParam(
      id: id,
    );
  }

  [!af_screen_name]RouteParam copyWith() {
    return [!af_screen_name]RouteParam(
      id: id,
    );
  }
''';  
}
