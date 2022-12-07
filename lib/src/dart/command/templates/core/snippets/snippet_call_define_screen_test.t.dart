

import 'package:afib/src/dart/command/af_source_template.dart';
import 'package:afib/src/dart/command/templates/core/files/screen.t.dart';

class SnippetCallDefineScreenTest extends AFCoreSnippetSourceTemplate {
  String get template => '    define${insertMainType}Prototypes(context);';
}


