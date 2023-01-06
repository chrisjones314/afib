


import 'package:afib/src/dart/command/af_source_template.dart';

class SnippetStandardRootMethodsT extends AFCoreSnippetSourceTemplate {

  @override 
  List<String> get extraImports => [
    "import 'package:$insertPackagePath/state/models/${AFSourceTemplate.insertMainTypeNoRootInsertion.snake}.dart';"
  ];    

  String get template => '''
@override
String itemId(${AFSourceTemplate.insertMainTypeNoRootInsertion} item) => item.id;

@override
$insertMainType reviseItems(Map<String, ${AFSourceTemplate.insertMainTypeNoRootInsertion}> items) => copyWith(items: items);
''';
}
