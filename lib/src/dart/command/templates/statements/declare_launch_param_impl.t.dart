

import 'package:afib/src/dart/command/af_source_template.dart';

class DeclareLaunchParamImplT extends AFSourceTemplate {
  final String template = '''
    launchParam: [!af_screen_name]RouteParam.create(),
''';
}


