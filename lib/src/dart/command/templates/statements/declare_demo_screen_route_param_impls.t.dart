


import 'package:afib/src/dart/command/af_source_template.dart';

class DeclareDemoScreenRouteParamImplsT extends AFSourceTemplate {
  final String template = '''
  final int clickCount;
  StartupScreenRouteParam({
    required this.clickCount,
  }): super(id: HCScreenID.startup);

  factory StartupScreenRouteParam.create() {
    return StartupScreenRouteParam(clickCount: 0);
  }

  StartupScreenRouteParam reviseIncrementClickCount() {
    return copyWith(clickCount: clickCount+1);
  }

  StartupScreenRouteParam copyWith({
    int? clickCount
  }) {
    return StartupScreenRouteParam(
      clickCount: clickCount ?? this.clickCount,
    );
  }
''';
}


  