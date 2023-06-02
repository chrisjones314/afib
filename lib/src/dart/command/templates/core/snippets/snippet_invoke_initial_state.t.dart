import 'package:afib/src/dart/command/af_source_template.dart';

class SnippetInvokeInitialStateT extends AFSourceTemplate {
  @override
  String get template => '$insertMainType.initialState(),';
}


