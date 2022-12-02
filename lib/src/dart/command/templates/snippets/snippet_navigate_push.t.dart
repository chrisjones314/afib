import 'package:afib/src/dart/command/af_source_template.dart';

class SnippetNavigatePushT extends AFSnippetSourceTemplate {
  static const insertParamDecl = AFSourceTemplateInsertion("param_decl");
  static const insertParamCall = AFSourceTemplateInsertion("param_call");

  SnippetNavigatePushT({
    AFSourceTemplateInsertions? embeddedInsertions,
  }): super(
    embeddedInsertions: embeddedInsertions,
  )
  ;

  factory SnippetNavigatePushT.noCreateParams() {
    return SnippetNavigatePushT(
      embeddedInsertions: const AFSourceTemplateInsertions(insertions: {
        insertParamDecl: AFSourceTemplate.empty,
        insertParamCall: AFSourceTemplate.empty,
      })
    );
  }

  String get template {
    return '''
  static AFNavigatePushAction navigatePush(
    $insertParamDecl
  ) {
    return AFNavigatePushAction(
      launchParam: ${insertMainType}RouteParam.create(
        $insertParamCall
      )
    );
  }
  ''';
  }
}
