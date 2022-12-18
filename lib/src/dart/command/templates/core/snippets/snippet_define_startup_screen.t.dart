import 'package:afib/src/dart/command/af_source_template.dart';

class SnippetDefineStartupScreenT extends AFCoreSnippetSourceTemplate {
  static const insertScreenId = AFSourceTemplateInsertion("screen_id");
  static const insertCreateRouteParam = AFSourceTemplateInsertion("create_route_param");

  String get template => "  context.defineStartupScreen($insertScreenId, () => $insertCreateRouteParam);";
}

  
