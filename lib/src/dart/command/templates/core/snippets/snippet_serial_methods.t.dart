


import 'package:afib/src/dart/command/af_project_paths.dart';
import 'package:afib/src/dart/command/af_source_template.dart';

class SnippetSerialMethodsT extends AFSnippetSourceTemplate {
  static const insertSerializeToBody = AFSourceTemplateInsertion("serialize_to_body");
  static const insertSerializeFromBody = AFSourceTemplateInsertion("serialize_from_body");

  SnippetSerialMethodsT({
    required String templateFileId,
    required List<String> templateFolder,
    required Object serializeFrom,
    required Object serializeTo,
  }): super(
    templateFileId: templateFileId,
    templateFolder: templateFolder,
    embeddedInsertions: AFSourceTemplateInsertions(insertions: {
      insertSerializeToBody: serializeTo,
      insertSerializeFromBody: serializeFrom,
    }),
  );

  factory SnippetSerialMethodsT.core({
    required Object serializeFrom,
    required Object serializeTo,
  }) {
    return SnippetSerialMethodsT(
      templateFileId: "serial_methods",
      templateFolder: AFProjectPaths.pathGenerateCoreSnippets,
      serializeFrom: serializeFrom,
      serializeTo: serializeTo
    );
  }

  String get template {
    return '''
static Map<String, dynamic> serializeToMap($insertMainType item) {
  final result = <String, dynamic>{};
  $insertSerializeToBody
  return result;
}

static $insertMainType serializeFromMap(Map<String, dynamic> source) {
  $insertSerializeFromBody
}
  ''';
  }
}
