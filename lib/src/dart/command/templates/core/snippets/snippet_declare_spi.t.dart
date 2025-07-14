

import 'package:afib/src/dart/command/af_project_paths.dart';
import 'package:afib/src/dart/command/af_source_template.dart';
import 'package:afib/src/dart/command/templates/core/files/screen.t.dart';

/// Any class that ends in "T" is a source template used in code generation.
class SnippetDeclareSPIT extends AFSnippetSourceTemplate {
  static const insertSPIResolveMethods = AFSourceTemplateInsertion("spi_resolve_methods");
  static const insertSPIOnUpdateMethods = AFSourceTemplateInsertion("spi_on_update_methods");

  SnippetDeclareSPIT({
    required super.templateFileId,
    required super.templateFolder,
    super.embeddedInsertions,
  });

  factory SnippetDeclareSPIT.core() {
    return SnippetDeclareSPIT(
      templateFileId: "declare_spi",    
      templateFolder: AFProjectPaths.pathGenerateCoreSnippets,
    );
  }

  @override
  String get template => '''
@immutable
class ${insertMainType}SPI extends $insertMainParentType<${ScreenT.insertStateViewType}, ${insertMainType}RouteParam> {
  const ${insertMainType}SPI(AFBuildContext<${ScreenT.insertStateViewType}, ${insertMainType}RouteParam> context, AFStandardSPIData standard): super(context, standard);
  
  factory ${insertMainType}SPI.create(AFBuildContext<${ScreenT.insertStateViewType}, ${insertMainType}RouteParam> context, AFStandardSPIData standard) {
    return ${insertMainType}SPI(context, standard,
    );
  }

  $insertSPIResolveMethods
  $insertSPIOnUpdateMethods
  $insertStandardAdditionalMethods
  $insertAdditionalMethods
}
''';
}