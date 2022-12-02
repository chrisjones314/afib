


import 'package:afib/src/dart/command/af_source_template.dart';

class DeclareDemoScreenRouteParamImplsT extends AFSourceTemplate {
  final String template = '''
  final int clickCount;
  StartupScreenRouteParam({
    required this.clickCount,
  }): super(screenId: [!af_app_namespace(upper)]ScreenID.startup);

  factory StartupScreenRouteParam.create({
    required int clickCount
  }) {
    return StartupScreenRouteParam(clickCount: clickCount);
  }

  StartupScreenRouteParam reviseIncrementClickCount() => copyWith(clickCount: clickCount+1);

  StartupScreenRouteParam copyWith({
    int? clickCount
  }) {
    return StartupScreenRouteParam(
      clickCount: clickCount ?? this.clickCount,
    );
  }
''';
}


  