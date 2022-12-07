import 'package:afib/src/dart/command/af_source_template.dart';

class SnippetDeclareModelAccessorT extends AFSourceTemplate {

  String get template => '  $insertMainType get ${insertMainTypeNoRoot.camel} { return findType<$insertMainType>(); }';
}
