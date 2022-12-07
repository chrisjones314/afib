


import 'package:afib/src/dart/command/af_source_template.dart';
import 'package:afib/src/dart/command/templates/core/files/screen.t.dart';

class SnippetSPIOnPressedCloseImplT extends AFCoreSnippetSourceTemplate {
  String get template => '''
    void onPressedClose() {
      close${ScreenT.insertControlTypeSuffix}(null);
    }
''';
}
