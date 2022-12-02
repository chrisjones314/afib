

import 'package:afib/src/dart/command/af_project_paths.dart';
import 'package:afib/src/dart/command/af_source_template.dart';

class ScreenT extends AFFileSourceTemplate {
  static const insertDeclareRouteParam = AFSourceTemplateInsertion("declare_route_param");
  static const insertDeclareSPI = AFSourceTemplateInsertion("declare_spi");
  static const insertStateViewPrefix = AFSourceTemplateInsertion("state_view_prefix");
  static const insertControlTypeSuffix = AFSourceTemplateInsertion("control_type_suffix");
  static const insertStateViewType = AFSourceTemplateInsertion("state_view_type");
  static const insertBuildWithSPIImpl = AFSourceTemplateInsertion("build_with_spi_impl");  
  static const insertBuildBodyImpl = AFSourceTemplateInsertion("build_body_impl");
  static const insertNavigateMethods = AFSourceTemplateInsertion("navigate_methods");
  static const insertScreenIDType = AFSourceTemplateInsertion("screen_id_type");
  static const insertScreenID = AFSourceTemplateInsertion("screen_id");

  ScreenT(): super(
    templatePath: const <String>[AFProjectPaths.folderCore, "screen"],
  );

  String get template => '''
import 'package:afib/afib_flutter.dart';
import 'package:flutter/material.dart';
import 'package:$insertPackageName/${insertAppNamespace}_id.dart';
import 'package:$insertPackageName/state/${insertAppNamespace}_state.dart';

$insertDeclareRouteParam

$insertDeclareSPI

class $insertMainType extends ${insertAppNamespaceUpper}Connected$insertControlTypeSuffix<${insertMainType}SPI, $insertStateViewType, ${insertMainType}RouteParam> {
  static final config = $insertStateViewPrefix${insertControlTypeSuffix}Config<${insertMainType}SPI, ${insertMainType}RouteParam> (
    spiCreator: ${insertMainType}SPI.create,
  );

  $insertMainType(
    $insertConstructorParams
  ): super(
    $insertSuperParams
  );

  $insertNavigateMethods
  
  @override
  Widget buildWithSPI(${insertMainType}SPI spi) {
    $insertBuildWithSPIImpl
  }

  Widget _buildBody(${insertMainType}SPI spi) {
    $insertBuildBodyImpl
  }

  $insertAdditionalMethods
}
''';
}
