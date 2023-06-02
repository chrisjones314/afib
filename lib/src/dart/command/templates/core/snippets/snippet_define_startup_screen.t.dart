import 'package:afib/src/dart/command/af_source_template.dart';

/// Any class that ends in "T" is a source template used in code generation.
class SnippetDefineStartupScreenT extends AFCoreSnippetSourceTemplate {
  static const insertScreenId = AFSourceTemplateInsertion("screen_id");
  static const insertCreateRouteParam = AFSourceTemplateInsertion("create_route_param");

  @override
  String get template => "  context.defineStartupScreen($insertScreenId, () => $insertCreateRouteParam);";
}

  
