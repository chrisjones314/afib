

import 'package:afib/src/dart/command/af_source_template.dart';
import 'package:afib/src/dart/command/templates/core/screen.t.dart';

class SnippetDeclareSPIT extends AFSnippetSourceTemplate {
  String get template => '''
@immutable
class ${insertMainType}SPI extends $insertMainParentType<${ScreenT.insertStateViewType}, ${insertMainType}RouteParam> {
  ${insertMainType}SPI(AFBuildContext<${ScreenT.insertStateViewType}, ${insertMainType}RouteParam> context, AFStandardSPIData standard): super(context, standard);
  
  factory ${insertMainType}SPI.create(AFBuildContext<${ScreenT.insertStateViewType}, ${insertMainType}RouteParam> context, AFStandardSPIData standard) {
    return ${insertMainType}SPI(context, standard,
    );
  }

  $insertAdditionalMethods
}
''';
}