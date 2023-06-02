


import 'package:afib/src/dart/command/af_source_template.dart';
import 'package:afib/src/dart/command/templates/core/files/screen.t.dart';

class SnippetSPIOnPressedCloseImplT extends AFCoreSnippetSourceTemplate {
  @override
  String get template => '''
void onPressedClose() {
  onClose${ScreenT.insertControlTypeSuffix}(context.p);
}
''';
}
