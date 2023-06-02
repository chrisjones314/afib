

import 'package:afib/src/dart/command/af_source_template.dart';

class SnippetCallDefineScreenTest extends AFCoreSnippetSourceTemplate {
  @override
  String get template => '    define${insertMainType}Prototypes(context);';
}


