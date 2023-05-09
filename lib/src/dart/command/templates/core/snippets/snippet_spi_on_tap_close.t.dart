


import 'package:afib/src/dart/command/af_source_template.dart';
import 'package:afib/src/dart/command/templates/core/files/screen.t.dart';

class SnippetSPIOnTapCloseT extends AFCoreSnippetSourceTemplate {

  String get template => '''
    void onTapClose() {
      onClose${ScreenT.insertControlTypeSuffix}();
    }
''';
}
