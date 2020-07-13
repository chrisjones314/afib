import 'package:afib/src/dart/command/af_project_paths.dart';
import 'package:afib/src/dart/command/af_source_template.dart';
import 'package:afib/src/dart/command/generator_code/af_code_generator.dart';
import 'package:afib/src/dart/command/generator_code/af_namespace_generator.dart';
import 'package:afib/src/dart/command/templates/files/afib.t.dart';
import 'package:afib/src/dart/command/templates/files/id.t.dart';
import 'package:afib/src/dart/command/templates/statements/declare_id_statement.dart';
import 'package:afib/src/dart/command/templates/statements/import_statements.dart';

class AFGeneratorRegistry {
  final replacementGenerators = Map<String, AFCodeGenerator>();

  AFGeneratorRegistry();

  void registerGlobals() {
    registerGenerator(AFCodeGeneratorWithTemplate(ImportAfibDartT()));
    registerGenerator(AFCodeGeneratorWithTemplate(ImportAfibCommandT()));
    registerGenerator(AFNamespaceGenerator());
  }

  /// Set a handler for a dynamic section (e.g. AFRP(insert_code_here) in the template)
  void registerGenerator(AFCodeGenerator gen) {
    replacementGenerators[gen.namespaceKey] = gen;
  }

  bool hasGeneratorFor(AFTemplateReplacementPoint point) {
    return replacementGenerators.containsKey(point.namespaceKey);
  }

  AFCodeGenerator generatorFor(AFTemplateReplacementPoint point) {
    return replacementGenerators[point.namespaceKey];
  }
}

class AFTemplateRegistry {
  final fileTemplates = Map<String, AFFileSourceTemplate>();
  final statementTemplates = Map<String, AFStatementSourceTemplate>();

  AFTemplateRegistry() {
    registerFile(AFProjectPaths.afibConfigPath, AFibT());
    registerFile(AFProjectPaths.idPath, IdentifierT());

    registerStatement(AFStatementID.stmtDeclareID, DeclareIDStatementT());
  }  

  void registerFile(List<String> projectPath, AFFileSourceTemplate source) {
    final path = AFProjectPaths.relativePathFor(projectPath);
    fileTemplates[path] = source;
  }

  void registerStatement(String id, AFStatementSourceTemplate source) {
    statementTemplates[id] = source;
  }

  AFFileSourceTemplate templateForFile(List<String> projectPath) {
    final path = AFProjectPaths.relativePathFor(projectPath, allowExtra: false);
    return fileTemplates[path];
  }

  AFStatementSourceTemplate templateForStatement(String id) {
    return statementTemplates[id];
  }

}