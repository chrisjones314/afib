
import 'package:afib/src/dart/command/generator_code/af_code_generator.dart';
import 'package:afib/src/dart/command/templates/statements/declare_id_statement.dart';
import 'package:afib/src/dart/utils/af_config_entries.dart';

class AFIDCodeGenerator extends AFCodeGeneratorWithTemplate {
  AFIDCodeGenerator(String kind, String id): super(DeclareIDStatementT()) {
    final upcaseKind = AFCodeGenerator.toCapitalFirstLetter(kind);
    final idSnake = AFCodeGenerator.toSnakeCase(id);
    
    localGenerators.registerGenerator(new AFStaticCodeGenerator(AFConfigEntries.afNamespace, "id_identifier", id));
    localGenerators.registerGenerator(new AFStaticCodeGenerator(AFConfigEntries.afNamespace, "id_identifier_snake", idSnake));
    localGenerators.registerGenerator(new AFStaticCodeGenerator(AFConfigEntries.afNamespace, "id_identifier_kind", upcaseKind));    
  }
}