
import 'package:afib/afib_command.dart';
import 'package:afib/src/dart/command/commands/af_config_command.dart';
import 'package:afib/src/dart/command/commands/af_create_command.dart';
import 'package:afib/src/dart/command/commands/af_echo_command.dart';
import 'package:afib/src/dart/command/commands/af_generate_custom_command.dart';
import 'package:afib/src/dart/command/commands/af_generate_id_command.dart';
import 'package:afib/src/dart/command/commands/af_generate_test_command.dart';
import 'package:afib/src/dart/command/commands/af_integrate_command.dart';
import 'package:afib/src/dart/command/commands/af_require_command.dart';
import 'package:afib/src/dart/command/commands/af_test_command.dart';
import 'package:afib/src/dart/command/commands/af_version_command.dart';
import 'package:afib/src/dart/command/templates/af_template_registry.dart';
import 'package:afib/src/dart/command/templates/core/snippets/snippet_declare_test_id.t.dart';
import 'package:afib/src/dart/command/templates/core/snippets/snippet_import_from_package.t.dart';
import 'package:afib/src/dart/utils/afib_d.dart';
import 'package:args/args.dart' as args;
import 'package:collection/collection.dart';
import 'package:path/path.dart';
import 'package:pubspec_parse/pubspec_parse.dart';
class AFItemWithNamespace {
  /// The namespace used to differentiate third party commands.
  final String namespace;

  /// The name of the command itself (e.g. help)
  /// 
  /// Note that packages which are not native to afib must be referenced
  /// using package:command as the command.
  final String key;
  
  AFItemWithNamespace(this.namespace, this.key);

  String get namespaceKey {
    final sb = StringBuffer();
    if(namespace != AFConfigEntries.afNamespace) {
      sb.write(namespace);
      sb.write(":");
    }
    sb.write(key);
    return sb.toString();
  }

  static List<T> sortIterable<T extends AFItemWithNamespace>(Iterable<T> it) {
    final result = List<T>.of(it);
    result.sort((l, r) {
      return l.namespaceKey.compareTo(r.namespaceKey);
    });
    return result;
  }

}

class AFCommandArgumentsParsed {
  static const argTrue = "true";
  static const argFalse = "false";
  final List<String> unnamed;
  final Map<String, String?> named;

  AFCommandArgumentsParsed({
    required this.unnamed,
    required this.named,
  });

  factory AFCommandArgumentsParsed.empty() {
    return AFCommandArgumentsParsed(unnamed: <String>[], named: <String, String>{});
  }

  String get accessUnnamedFirst => unnamed.first;
  String get accessUnnamedSecond => unnamed[1];
  String get accessUnnamedThird => unnamed[2];
  String accessNamed(String name) {
    final result = named[name];
    if(result == null) {
      throw AFException("Missing parameter --$name");
    }
    return result;
  }

  void setIfNull(String name, String value) {
    if(named[name] == null) {
      named[name] = value;
    }
  }

  bool accessNamedFlag(String name) {
    return accessNamed(name) != argFalse;
  }


}

/// Parent for commands executed through the afib command line app.
abstract class AFCommand { 
  static const optionPrefix = "--";
  static const argPrivate = "private";
  static const argPrivateOptionHelp = "--${AFCommand.argPrivate} - if specified for a library, does not export the generated class via [YourAppNamespace]_flutter.dart";
  
  
  final subcommands = <String, AFCommand>{};

  String get name;
  String get description;
  String get usage {
    return "";
  }

  String get usageHeader {
    return "Usage";
  }

  String get descriptionHeader {
    return "Description";
  }

  String get optionsHeader {
    return "Options";
  }

  String get nameOfExecutable {
    return "bin/${AFibD.config.appNamespace}_afib.dart";
  }

  /// Override this to implement the command.   The first item in the list is the command name.
  /// 
  /// [afibConfig] contains only the values from initialization/afib.g.dart, which can be 
  /// manipulated from the command line.
  Future<void> run(AFCommandContext ctx) async {
    // make sure we are in the project root.
    if(!errorIfNotProjectRoot(ctx)) {
      return;
    }

    await execute(ctx);
  }

  void addSubcommand(AFCommand cmd) {
    subcommands[cmd.name] = cmd;
  }

  void finalize() {}
  Future<void> execute(AFCommandContext context);

  bool errorIfNotProjectRoot(AFCommandContext ctx) {
    if(!AFProjectPaths.inRootOfAfibProject(ctx)) {
      ctx.output.writeErrorLine("Please run the $name command from the project root");
      return false;
    }
    return true;
  }  

  Never throwUsageError(String error) {
    throw AFCommandError(error: error, usage: usage);
  }

  static Never throwUsageErrorStatic(String error, String usage) {
    throw AFCommandError(error: error, usage: usage);
  }

  void verifyNotEmpty(String value, String msg) {
    if(value.isEmpty) {
      throwUsageError(msg);
    }
  }

  String verifyEndsWith(String value, String endsWith) {
    if(!value.endsWith(endsWith)) {
      throwUsageError("$value must end with $endsWith");
    }
    return value;
  }

  void verifyEndsWithOneOf(String value, List<String> suffixes) {
    for(final suffix in suffixes) {
      if(value.endsWith(suffix)) {
        return;
      }
    }
    throwUsageError("$value must end with one of $suffixes");
  }

  void verifyAllUppercase(String value) {
    for(var i = 0; i < value.length; i++) {
      final c = value[i];
      if(c != c.toUpperCase()) {
        throwUsageError("Expected $value to be all uppercase");
      }
    }
  }

  void verifyOneOf(String value, List<String> oneOf) {
    final found = oneOf.contains(value);
    if(!found) {
      throwUsageError("Expected $value to be one of $oneOf");
    }

  }


  void verifyAllLowercase(String value) {
    for(var i = 0; i < value.length; i++) {
      final c = value[i];
      if(c != c.toLowerCase()) {
        throwUsageError("Expected $value to be all lowercase");
      }
    }
  }


  String convertToPrefix(String value, String suffix) {
    final lower = suffix.toLowerCase();
    final prefix = value.substring(0, value.length-suffix.length);
    return "$lower$prefix";
  }

  void verifyMixedCase(String value, String valueKindInError) {
    if(value[0].toUpperCase() != value[0]) {
      throwUsageError("The $valueKindInError should be mixed case");
    }
  }

  void verifyNotOption(String value) {
    if(value.startsWith(optionPrefix)) {
      throwUsageError("Options must come after other values in the command");
    }
  }



  void verifyDoesNotEndWith(String value, String excluded) {
    if(value.endsWith(excluded)) {
      throwUsageError("Please do not add '$excluded' to the end of $value, AFib will add it for you");
    }
  }

  void verifyUsageOption(String value, List<String> options) {
    if(options.contains(value)) {
      return;
    }

    final msg = StringBuffer("$value must be one of (");
    for(final key in options) {
      msg.write(key);
      msg.write(", ");
    }    
    msg.write(")");
    throwUsageError(msg.toString());
  }
}

abstract class AFCommandGroup extends AFCommand {

  @override 
  String get usage {
    final result = StringBuffer();
    result.write('''
Usage 
  afib $name <subcommand>...

Available subcommands
''');


    for(final sub in subcommands.values) {
      result.write("  ${sub.name} - ${sub.description}\n");
    }
    
    return result.toString();
  }

}


class AFMemberVariableTemplates {
  static const includeMemberVars = 0x01;
  static const includeResolveVars = 0x02;
  static const includeAllVars = includeMemberVars | includeResolveVars;

  final bool isIntId;
  final Map<String, String> memberVars;
  final Map<String, String> resolveVars;
  final String mainType;
  String? standardRootMapType;
 
  AFMemberVariableTemplates({
    required this.memberVars,
    required this.resolveVars,
    required this.isIntId,
    required this.mainType,
  }); 

  factory AFMemberVariableTemplates.createEmpty({
    required String mainType,
    bool isIntId = false,
  }) {
    return AFMemberVariableTemplates(
      memberVars: <String, String>{}, 
      resolveVars: <String, String>{},
      isIntId: isIntId, 
      mainType: mainType
    );
  }

  void setStandardRootMapType(String kind) {
    standardRootMapType = kind;
  }

  bool _hasFlag(int test, int flag) {
    return (test & flag) != 0;
  }

  String _ensureIdSuffix(String source) {
    if(!source.endsWith("Id")) {
      source = "${source}Id";
    }
    return source;
  }

  String get declareVariables {
    final result = StringBuffer();
    _iterate(
      include: includeAllVars,
      visit: (identifier, kind, isLast, includeKind) {
      result.write("final $kind $identifier;");
      if(!isLast || resolveVars.isNotEmpty) {
        result.writeln();
      }
    });

    return result.toString();
  }

  String? _generateImportFor(AFCommandContext context, String kind) {
    // it might be a local type, see if we can find it.
    final generator = context.generator;
    final pathModel = generator.pathModel(kind);
    if(!generator.fileExists(pathModel)) {
      return null;
    }
    final importPath = generator.importStatementPath(pathModel);
    final declareImport = SnippetImportFromPackageT().toBuffer(context, insertions: {
      AFSourceTemplate.insertPackageNameInsertion: AFibD.config.packageName,
      AFSourceTemplate.insertPackagePathInsertion: importPath,
    });

    return declareImport.lines.first;
  }

  String extraImports(AFCommandContext context) {
    final result = StringBuffer();
    _iterate(
      include: includeMemberVars,
      visit: (identifier, kind, isLast, includeKind) { 
      if(kind == "int" || kind == "double" || kind == "String") {
        return;
      }

      final import = _generateImportFor(context, kind);
      if(import != null) {
        result.writeln(import);
      }
    });

    _iterate(
      include: includeResolveVars,
      visit: (identifier, kind, isLast, includeKind) { 
        final import = _generateImportFor(context, kind);
        if(import != null) {
          result.writeln(import);
        }
        final kindRoot = "${AFCodeGenerator.pluralize(kind)}Root";
        final importRoot = _generateImportFor(context, kindRoot);
        if(importRoot != null) {
          result.writeln(importRoot);
        }
      }
    );

    return result.toString();
  }

  String get standardReviseMethods {
    final result = StringBuffer();
    _iterate(
      include: includeAllVars,
      visit: (identifier, kind, isLast, includeKind) {
        final methodSuffix = AFCodeGenerator.upcaseFirst(identifier);
        result.write("$mainType revise$methodSuffix($kind $identifier) => copyWith($identifier: $identifier);");
        if(!isLast) {
          result.writeln();
        }
    });
    return result.toString();
  }
 
  String get constructorParamsBare {
    final result = StringBuffer();
    if(standardRootMapType != null) {
      result.writeln("required Map<String, $standardRootMapType> items,");
    }

    _iterate(
      include: includeAllVars,
      visit: (identifier, kind, isLast, includeKind) {
        result.write("required this.$identifier,");
        if(!isLast) {
          result.writeln();
        }
    });
    return result.toString();
  }

  String get constructorParams {
    final result = StringBuffer("{");
    result.writeln(constructorParamsBare);
    result.write("}");
    return result.toString();
  }
  
  String get copyWithParams {
    final result = StringBuffer("{");
    result.writeln();
    if(standardRootMapType != null) {
      result.write("  Map<String, $standardRootMapType>? items,");
    }

    _iterate(
      include: includeAllVars,
      visit: (identifier, kind, isLast, includeKind) {
        result.write("  $kind? $identifier,");
        result.writeln();
    });
    result.write("}");
    return result.toString();    
  }
  
  String get copyWithCall {
    final result = StringBuffer();
    result.writeln();
    if(standardRootMapType != null) {
      result.write("items: items ?? this.items");
    }
    _iterate(
      include: includeAllVars,
      visit: (identifier, kind, isLast, includeKind) {
        result.write("$identifier: $identifier ?? this.$identifier,");
        result.writeln();
    });
    return result.toString();    
  }

  String get initialValueDeclaration {
    final result = StringBuffer();
    result.writeln();
    if(standardRootMapType != null) {
      result.writeln("items: const <String, $standardRootMapType>{},");
    }

    _iterate(
      include: includeAllVars,
      visit: (identifier, kind, isLast, includeKind) {
      var val = "null";
      if(kind == "int") {
        val = "0";
      } else if (kind == "String") {
        val = '""';
      } else if (kind == "double") {
        val = '0.0';
      }
 
      result.write("$identifier: $val,");
      result.writeln();
    });
    return result.toString();    
  }

  String get serializeFrom {
    final result = StringBuffer();
    _iterate(
      include: includeAllVars,
      visit: (identifier, kind, isLast, includeKind) {
        final upcaseIdentifier = AFCodeGenerator.upcaseFirst(identifier);
        var convertToString = "";
        if(isIntId && (identifier == AFDocumentIDGenerator.columnId) || _hasFlag(includeKind, includeResolveVars)) {
          convertToString = ".toString()";
        } 
        result.writeln("final item$upcaseIdentifier = source[col$upcaseIdentifier]$convertToString;");
    });

    result.writeln("return $mainType(");
    _iterate(
      include: includeAllVars,
      visit: (identifier, kind, isLast, includeKind) {
        final upcaseIdentifier = AFCodeGenerator.upcaseFirst(identifier);
        result.writeln("  $identifier: item$upcaseIdentifier,");
    });
    result.writeln(");");


    return result.toString();
  }

  String get serializeTo {
    final result = StringBuffer();
    _iterate(
      include: includeAllVars,
      visit: (identifier, kind, isLast, includeKind) {
      final upcaseIdentifier = AFCodeGenerator.upcaseFirst(identifier);
      var intConvertPrefix = "";
      var intConvertSuffix = "";
      if(isIntId && (identifier == AFDocumentIDGenerator.columnId) || _hasFlag(includeKind, includeResolveVars)) {
        intConvertPrefix = "int.tryParse(";
        intConvertSuffix = ")";
      }
      result.writeln("result[col$upcaseIdentifier] = ${intConvertPrefix}item.$identifier$intConvertSuffix;");
    });
    return result.toString();
  }

  String get serialConstants {
    final result = StringBuffer();
    result.writeln("static const tableName = '${AFCodeGenerator.convertMixedToSnake(mainType)}';");
    _iterate(
      include: includeAllVars,
      visit: (identifier, kind, isLast, includeKind) {
      final upcaseIdentifier = AFCodeGenerator.upcaseFirst(identifier);
      var val = "'${AFCodeGenerator.convertMixedToSnake(identifier)}'";
      if(identifier == "id") {
        val = "AFDocumentIDGenerator.columnId";
      }
      result.writeln("static const col$upcaseIdentifier = $val;");
    });
    return result.toString();
  }

  String get resolveFunctions {
    final result = StringBuffer();
    _iterate(
      include: includeResolveVars,
      visit: (identifier, kind, isLast, includeKind) {
        var upcaseIdentifier = AFCodeGenerator.upcaseFirst(identifier);
        if(upcaseIdentifier.endsWith("Id")) {
          upcaseIdentifier = upcaseIdentifier.substring(0, upcaseIdentifier.length - 2);
        }
        final kindPlural = AFCodeGenerator.pluralize(kind);
        final kindPluralCamel = AFCodeGenerator.convertToCamelCase(kindPlural);
        result.writeln("$kind? resolve$upcaseIdentifier(${kindPlural}Root $kindPluralCamel) => $kindPluralCamel.findById($identifier);");
      }
    );
    return result.toString();  
  }

  void _iterate({
    required int include,
    required void Function(String name, String kind, bool isLast, int includeKind) visit 
  }) {
    final includeMember = (include & includeMemberVars) != 0;
    final includeResolve = (include & includeResolveVars) != 0;

    if(includeMember) { 
      var identifiers = memberVars.keys.toList();
      for(var i = 0; i < identifiers.length; i++) {
        final identifier = identifiers[i];
        final kind = memberVars[identifier];
        if(kind != null) {
          final isLast = (i == identifiers.length - 1 && (!includeResolve || resolveVars.isEmpty));
          visit(identifier, kind, isLast, includeMemberVars);
        }
      }
    }

    if(!includeResolve) {
      return;
    }
    
    final resolveIds = resolveVars.keys.toList();
    for(var i = 0; i < resolveIds.length; i++) {
      final identifier = resolveIds[i];
      var kind = resolveVars[identifier];
      if(include != includeResolveVars) {
        kind = "String";
      }
      final isLast = i == resolveIds.length - 1;       
      if(kind != null) {
        visit(_ensureIdSuffix(identifier), kind, isLast, includeResolveVars);
      }
    }
  }
}

class AFCommandContext {
  final List<AFCommandContext> parents;
  final AFCommandAppExtensionContext definitions;
  final AFCommandOutput output;
  final AFCodeGenerator generator;
  final args.ArgResults arguments;
  String packagePath;
  AFSourceTemplateInsertions coreInsertions;
  Map<String, String> globalTemplateOverrides;

  int commandArgCount = 1;

  AFCommandContext({
    required this.parents,
    required this.output, 
    required this.definitions,
    required this.generator,
    required this.arguments,
    required this.packagePath,
    required this.coreInsertions,
    required this.globalTemplateOverrides 
  });

  bool get isRootCommand => parents.isEmpty;

  AFCommandArgumentsParsed parseArguments({
    required AFCommand command,
    int unnamedCount = -1,
    required Map<String, String?> named
  }) {
    final unnamed = <String>[];
    final allNamed = Map<String, String?>.from(named);
    allNamed[AFCommand.argPrivate] = "false";
    allNamed[AFGenerateSubcommand.argExportTemplatesFlag] = "";
    allNamed[AFGenerateSubcommand.argOverrideTemplatesFlag] = "";
    allNamed[AFGenerateSubcommand.argForceOverwrite] = "";

    final foundNamed = Map<String, String?>.from(named);
    foundNamed[AFCommand.argPrivate] = "false";
    final source = rawArgs;

    for(var i = 0; i < source.length; i++) {
      final arg = source[i];
      if(arg.startsWith(AFCommand.optionPrefix)) {
        var argValue = AFCommandArgumentsParsed.argTrue;
        if((i+1 < source.length)) {
          final next = source[i+1];
          if(!next.startsWith(AFCommand.optionPrefix)) {
            argValue = next;
            i++;
          }
        }
        final argEntry = arg.substring(2);
        foundNamed[argEntry] = argValue;
      } else {
        unnamed.add(arg);
      }
    }

    final parsedArguments = AFCommandArgumentsParsed(
      named: foundNamed,
      unnamed: unnamed,
    );

    if(unnamedCount >= 0 && unnamed.length != unnamedCount) {
      command.throwUsageError("Expected $unnamedCount unnamed arguments, but found ${unnamed.length}");
    }

    for(final foundKey in foundNamed.keys) {
      if(!allNamed.containsKey(foundKey)) {
        command.throwUsageError("Found unexpected option --$foundKey");
      }
    }

    return parsedArguments;
  }

  Map<String, String> _parseSemicolonDeclarations(AFCommandContext context, String vars) {
    final varItems = vars.split(";");
    varItems.removeWhere((val) => val.trim().isEmpty);
    final result = <String, String>{};
    for(final item in varItems) {
      final itemTrimmed = item.trim();
      final idxIdentifier = itemTrimmed.lastIndexOf(" ");
      if(idxIdentifier < 0) {
        throw AFCommandError(error: "Expected '$item' to have the form 'type identifier', e.g. 'int count'");
      }
      final name = itemTrimmed.substring(idxIdentifier+1);
      final kind = itemTrimmed.substring(0, idxIdentifier);
      result[name] = kind;
    }
    return result;
  }

  AFMemberVariableTemplates? memberVariables(AFCommandContext context, AFCommandArgumentsParsed args, String mainType) {
    final isRoot = mainType.endsWith(AFCodeGenerator.rootSuffix);
    final isQuery = mainType.endsWith(AFGenerateQuerySubcommand.suffixQuery);
    final memberVarsSource = args.accessNamed(AFGenerateSubcommand.argMemberVariables);
    
    final memberVars = _parseSemicolonDeclarations(context, memberVarsSource);
    // if they specified serial, then make sure they specified an ID.
    var isIntId = false;
    if(!isRoot && !isQuery && !args.accessNamedFlag(AFGenerateStateSubcommand.argNotSerial)) {
      var idType = memberVars[AFDocumentIDGenerator.columnId];
      if(idType == "int") {
        isIntId = true;
        memberVars[AFDocumentIDGenerator.columnId]= "String";
        context.output.writeTwoColumns(col1: "info ", col2: "Converting 'int id' to a String on the client, so that String test ids can be used");
      }
      final errIdColumn = "You must either specify --${AFGenerateStateSubcommand.argNotSerial}, or you must specify a --${AFGenerateSubcommand.argMemberVariables} containing either 'String ${AFDocumentIDGenerator.columnId}' or 'int ${AFDocumentIDGenerator.columnId}'";

      if(idType == null) {
        throw AFCommandError(error: errIdColumn);
      }

      if(idType != "int" && idType != "String") {
        throw AFCommandError(error: errIdColumn);
      }
    }

    final resolveVarsSource = args.accessNamed(AFGenerateSubcommand.argResolveVariables);
    final resolveVars = _parseSemicolonDeclarations(context, resolveVarsSource);

    if(memberVars.isEmpty && resolveVars.isEmpty) {
      return null;
    }

    return AFMemberVariableTemplates(
      memberVars: memberVars, 
      resolveVars: resolveVars,
      isIntId: isIntId, 
      mainType: mainType
    );
  }

  void setProjectStyle(String projectStyle) {
    coreInsertions = coreInsertions.reviseOverwrite({
      AFSourceTemplate.insertProjectStyleInsertion: projectStyle,
    });
  }

  void setProjectStyleGlobalOverrides(String templateOverrides) {
    if(templateOverrides.isNotEmpty) {
      globalTemplateOverrides = _parseOverrides(templateOverrides);
    }
  }

  

  static String findProjectStyleGlobalOverrides(AFCommandContext context, List<String> rawLines) {
    var consolidated = AFCommandContext.consolidateProjectStyleLines(context, rawLines);
    if(consolidated.isNotEmpty && consolidated.first.startsWith("--${AFGenerateSubcommand.argOverrideTemplatesFlag}")) {
      final args = AFArgs.parseArgs(consolidated.first);
      return args.last;
    }
    return "";    
  }

  factory AFCommandContext.withArguments({
    required AFCommandAppExtensionContext definitions,
    required AFCommandOutput output,
    required AFCodeGenerator generator,
    required String packagePath,
    required AFArgs arguments,
    required AFSourceTemplateInsertions coreInsertions,
    List<AFCommandContext>? parents,
    required Map<String, String>? globalTemplateOverrides,
  }) {
    final parsed = args.ArgParser.allowAnything();
    final argsParsed = parsed.parse(arguments.args);
    return AFCommandContext(
      parents: parents ?? <AFCommandContext>[],
      output: output, 
      packagePath: packagePath,
      definitions: definitions, 
      generator: generator, 
      arguments: argsParsed,
      coreInsertions: coreInsertions,
      globalTemplateOverrides: globalTemplateOverrides ?? const <String, String>{}
    );
  }

  bool get isForceOverwrite {
    var overwrite = findArgument(AFGenerateSubcommand.argForceOverwrite);
    if(overwrite is bool) {
      return overwrite;
    }
    return false;
  }

  Future<void> executeSubCommand(String cmd, AFSourceTemplateInsertions? insertions) async {
    final arguments = AFArgs.createFromString(cmd);
    final revisedCommand = this.reviseWithArguments(
      insertions: insertions ?? coreInsertions, 
      arguments: arguments
    );

    revisedCommand.startCommand();
    await definitions.execute(revisedCommand);
  }

  Pubspec loadPubspec( { String? packageName }) {
    final pathPubspec = generator.pathPubspecYaml;
    if(!generator.fileExists(pathPubspec)) {
      throw AFCommandError(error: "The file ${pathPubspec.last} must exist in the folder from which you are running this command");
    }

    final filePubspec = generator.modifyFile(this, pathPubspec);
    final pubspec = filePubspec.loadPubspec();
    final name = pubspec.name;

    if(packageName != null && name != packageName) {
      throw AFCommandError(error: "Expected yourpackagename to be $name but found $packageName");
    }

    final import = pubspec.dependencies["afib"];
    if(import == null) {
      throw AFCommandError(error: "You must update your pubspec's dependencies section to include afib");
    }
    
    return pubspec;
  }

  void setCoreInsertions(AFSourceTemplateInsertions insertions, { required String packagePath }) {
    coreInsertions = insertions;
    this.packagePath = packagePath;
  }

  AFCommandContext reviseWithArguments({
    required AFSourceTemplateInsertions insertions,
    required AFArgs arguments,
  }) {
    final revisedParents = parents.toList();
    revisedParents.add(this);
    var revisedArgs = arguments;
    if(isExportTemplates) {
      revisedArgs = revisedArgs.reviseAddArg("--${AFGenerateSubcommand.argExportTemplatesFlag}");
    }

    return AFCommandContext.withArguments(
      parents: revisedParents,
      packagePath: packagePath,
      output: this.output,
      definitions: this.definitions,
      generator: this.generator,
      arguments: revisedArgs,
      coreInsertions: insertions,   
      globalTemplateOverrides: this.globalTemplateOverrides
    );
  }

  static String simplifyProjectStyleCommand(String line) {
    var simpleLine = line;
    /*
    final idxOverride = line.indexOf("--${AFGenerateSubcommand.argOverrideTemplatesFlag}");
    if(idxOverride > 0) {
      simpleLine = line.substring(0, idxOverride).trim();
    }
    */
    return simpleLine;
  }

  void startCommand() {
    if(isRootCommand && isExportTemplates) {
      // output.writeTwoColumns(col1: "detected ", col2: "--${AFGenerateSubcommand.argExportTemplatesFlag}");
    }

    var override = findArgument(AFGenerateSubcommand.argOverrideTemplatesFlag) as String?;
    if(override != null) {
      // output.writeTwoColumns(col1: "detected ", col2: "--${AFGenerateSubcommand.argOverrideTemplatesFlag}: $override");

      final overrides = _parseOverrides(override);
      for(final overrideSource in overrides.keys) {
        if(!_templateExists(overrideSource)) {
          throw AFException("The source template $overrideSource was not found on the filesystem or embedded");
        }
        final overrideDest = overrides[overrideSource];
        if(overrideDest == null) {
          continue;
        }
        if(!_templateExists(overrideDest))  {
          throw AFException("The override template $overrideDest was not found on the filesystem or embedded.");
        }
      }
      
    }
  }

  bool _templateExists(String path) {
    final overridePath = path.split("/");
    final embedded = findEmbeddedTemplateFile(overridePath);
    final snippet = findEmbeddedTemplateSnippet(overridePath);
    final found = (embedded != null || snippet != null || AFProjectPaths.generateFileExists(overridePath));
    return found;
  }

  void createDeclareId(String id) {
    final splitVals = id.split(".");
    if(splitVals.length != 2) {
      throw AFException("Expected IDClass.idName, found $id");
    }
    final clz = splitVals[0];
    final identifier = splitVals[1];

    final idFile = generator.modifyFile(this, generator.pathIdFile);
    final regexClz = RegExp("class\\s+$clz");
    final idxOpenClass = idFile.findFirstLineContaining(this, regexClz);
    if(idxOpenClass < 0) {
      throw AFException("Could not find $regexClz in id file");
    }

    final lineOpen = idFile.buffer.lines[idxOpenClass];
    final isClassDecl = lineOpen.contains("extends");
    var lines = <String>[];
    if(isClassDecl) {
      // finally, add the id we are using.
      final declareTestID = SnippetDeclareClassTestIDT().toBuffer(this, insertions: {
        SnippetDeclareClassTestIDT.insertTestId: identifier,
        SnippetDeclareClassTestIDT.insertClassId: clz,
      });
      lines = declareTestID.lines;
    } else {
      final declareTestID = SnippetDeclareStringTestIDT().toBuffer(this, insertions: {
        SnippetDeclareStringTestIDT.insertTestId: identifier,
      });
      lines = declareTestID.lines;
    }  
    
    idFile.addLinesAfterIdx(this, idxOpenClass, lines);
  }

  AFCodeBuffer createSnippet(
    Object source, {
      AFSourceTemplateInsertions? extend,
      Map<AFSourceTemplateInsertion, Object>? insertions
    }
  ) {
    var fullInsert = this.coreInsertions;
    if(extend != null) {
      fullInsert = fullInsert.reviseOverwrite(extend.insertions);
    }
    if(insertions != null) {
      fullInsert = fullInsert.reviseOverwrite(insertions);
    }

    if(source is! AFSourceTemplate) {
      throw AFException("Expected AFSnippetSourceTemplate");
    }

    var effective = source.toBuffer(this, insertions: fullInsert.insertions);

   if(source is AFSnippetSourceTemplate) {
      // see if the source is overridden
    final originalPath = source.templatePath;
    final overridePath = this.findOverrideTemplate(originalPath);
    final hasOverride = overridePath != originalPath;
      if(hasOverride) {
        if(AFProjectPaths.generateFileExists(overridePath)) {
          effective = AFCodeBuffer.fromGeneratePath(overridePath);
        } else {
          // if the path changed, and the override path is not on the filesystem, see if it 
          // is one of our predefined paths.
          if(hasOverride) {
            final overrideTemplate = findEmbeddedTemplateSnippet(overridePath);
            if(overrideTemplate == null) {
              throw AFException("The override ${joinAll(overridePath)} was not found on the file system, or in the AFTemplateRegistry, for ${joinAll(originalPath)}");
            }
            effective = overrideTemplate.toBuffer(this, insertions: fullInsert.insertions);
          }
        }
      }
   }

    return effective;
  }

  AFGeneratedFile createFile(
    List<String> projectPath,
    AFFileSourceTemplate template, { 
      AFSourceTemplateInsertions? extend,
      Map<AFSourceTemplateInsertion, Object>? insertions 
    })  {
    var fullInsert = this.coreInsertions;
    if(insertions != null) {
      fullInsert = fullInsert.reviseAugment(insertions);
    }
    if(extend != null) {
      fullInsert = fullInsert.reviseAugment(extend.insertions);
    }
    final originalEmbedded = template.embeddedInsertions?.insertions;
    if(originalEmbedded != null) {
      fullInsert = fullInsert.reviseAugment(originalEmbedded);
    }

    return generator.createFile(this, projectPath, template, insertions: fullInsert);
  }

  static List<String> consolidateProjectStyleLines(AFCommandContext context, List<String> rawLines) {
    final result = <String>[];
    var idxLine = 0;
    while(idxLine < rawLines.length) {
      var rawLine = rawLines[idxLine].trim();
      if(rawLine.startsWith('import')) {
        idxLine++;
        final params = rawLine.split(" ");
        if(params.length != 2) {
          throw AFException("Expected import project_styles/your-project-style, found '$rawLine'");
        }
        final importStylePath = params[1].split('/');
        final importStyle = context.readProjectStyle(importStylePath);
        final consolidated = consolidateProjectStyleLines(context, importStyle.buffer.lines);
        result.addAll(consolidated);
        continue;
      }


      if(rawLine.endsWith("+")) {
        rawLine = rawLine.substring(0, rawLine.length-1).trim();
      }
      idxLine++;
      final compressed = StringBuffer();
      var lineNext = (idxLine < rawLines.length) ? rawLines[idxLine].trim() : "";
      while(lineNext.startsWith("+")) {
        final add = lineNext.substring(1);
        if(compressed.isNotEmpty) {
          compressed.write(",");
        }
        compressed.write(add);
        idxLine++;
        lineNext = (idxLine < rawLines.length) ? rawLines[idxLine].trim() : "";
      }
      
      if(compressed.isNotEmpty) {
        rawLine = '$rawLine "$compressed"';
      }
      result.add(rawLine);
    }

    return result;
  }


  AFGeneratedFile readProjectStyle(
    List<String> projectPath, { 
      AFSourceTemplateInsertions? extend,
      Map<AFSourceTemplateInsertion, Object>? insertions 
    })  {
    var fullInsert = this.coreInsertions;
    if(insertions != null) {
      fullInsert = fullInsert.reviseAugment(insertions);
    }
    if(extend != null) {
      fullInsert = fullInsert.reviseAugment(extend.insertions);
    }
    
    // we need to find the template for this path.
    final templateOrig = generator.definitions.templates.findEmbeddedTemplateFile(projectPath);
    if(templateOrig == null) {
      throw AFException("No template found at ${joinAll(projectPath)}");
    }

    final generated = AFGeneratedFile.fromTemplate(
      context: this, 
      projectPath: projectPath, 
      template: templateOrig, 
      action: AFGeneratedFileAction.skip
    );
    generated.performInsertions(this, fullInsert);
    return generated;
  }

  Object? findArgument(String key) {
    final args = arguments.rest;
    for(var i = 0; i < args.length; i++) {
      final arg = args[i];
      if(arg.startsWith(AFCommand.optionPrefix) && arg.endsWith(key)) {
        final next = args.length > (i+1) ? args[i+1] : null;
        if(next == null || next.startsWith(AFCommand.optionPrefix)) {
          return true;
        } 
        return next;
      }
    }
    return null;
  }

  bool get isExportTemplates {
    return findArgument(AFGenerateSubcommand.argExportTemplatesFlag) != null;
  }

  Map<String, String> _parseOverrides(String override) {
    override = override.replaceAll('"', "");
    override = override.replaceAll(".tdart", "");

    final result = <String, String>{};
    final overrides = override.split(",");
    for(final overrideAssign in overrides) {
      final assign = overrideAssign.split("=");
      if(assign.length != 2) {
        throw AFException("Expected $overrideAssign to have the form a=b");
      }
      final left = assign[0];
      final right = assign[1];
      result[left] = right;
    }
    return result; 
  }

  List<String> findOverrideTemplate(List<String> sourceTemplate) {
    var override = findArgument(AFGenerateSubcommand.argOverrideTemplatesFlag);
    var found = <String, String>{};
    if(override != null && override is String) {
      found = _parseOverrides(override);
    }
    

    final sourcePath = joinAll(sourceTemplate);
    var result = found[sourcePath];
    if(result == null) {
      result = globalTemplateOverrides[sourcePath];
      if(result == null) {
        if(parents.isNotEmpty) {
          return parents.last.findOverrideTemplate(sourceTemplate);
        }
        return sourceTemplate;
      }
    }
    return result.split("/");
  }

  AFFileSourceTemplate? findEmbeddedTemplateFile(List<String> path) {
    return this.definitions.templates.findEmbeddedTemplateFile(path);
  }

  AFSnippetSourceTemplate? findEmbeddedTemplateSnippet(List<String> path) {
    return this.definitions.templates.findEmbeddedTemplateSnippet(path);
  }

  void setCommandArgCount(int count) {
    commandArgCount = count;
  }
  List<String> get rawArgs {
    return arguments.arguments.slice(commandArgCount);
  }

  AFCommandOutput get out { return output; }
}


class AFBaseExtensionContext {
  void registerLibrary(AFLibraryID id) {
    AFibD.registerLibrary(id);
  }
  void registerConfigurationItem(AFConfigurationItem entry) {
    AFibD.registerConfigEntry(entry);
  }
}

class AFCommandLibraryExtensionContext extends AFBaseExtensionContext {
  final AFDartParams paramsD;
  final AFCommandRunner commands;
  final AFTemplateRegistry templates;

  AFCommandLibraryExtensionContext({
    required this.paramsD, 
    required this.commands, 
    required this.templates, 
  });

  /// Used to register a new root level command 
  /// command line.
  AFCommand defineCommand(AFCommand command, { bool hidden = false }) {
    if(hidden) {
      commands.addHiddenCommand(command);
    } else {
      commands.addCommand(command);
    }
    return command;
  }
  
  AFCommand? findCommandByType<T extends AFCommand>() {
    final result = commands.all.firstWhereOrNull((c) => c is T);
    return result;
  }

  void registerTemplateFile(AFFileSourceTemplate source) {
    templates.registerFile(source);
  }

  void registerTemplateSnippet(AFSnippetSourceTemplate source) {
    templates.registerSnippet(source);
  }

  /*
  void finalize(AFCommandContext context) {
  for(final command in commands.all) {
      command.ctx = context;
      command.registerArguments(command.argParser);
      command.finalize();

      for(final sub in command.subcommands.values) {
        if(sub is AFCommand) {
          sub.ctx = context;
          sub.registerArguments(sub.argParser);
          sub.finalize();
        }
      }
    }
    
  }
  */

}

class AFCommandRunner {
  List<AFCommand> commands = <AFCommand>[];
  List<AFCommand> commandsHidden = <AFCommand>[];
  final String name;
  final String description;
  AFCommandRunner(this.name, this.description);

  List<AFCommand> get all {
    return commands;
  }

  void _handleError(AFCommandContext context, AFCommandError e, AFCommand cmd) {
    if(!context.isRootCommand) {
      throw AFCommandError(error: e.error, usage: e.usage);
    }
    printUsage(error: e.error, command: cmd);
  }

  Future<void> run(AFCommandContext ctx) async {
    final args = ctx.arguments.arguments;
    if(args.isEmpty) {
      printUsage();
      return;
    }

    final commandName = args.first;
    final command = findByName(commandName);
    if(command == null) {
      printUsage(error: "Unknown command $commandName");
      return;
    }

    
    if(command.subcommands.isNotEmpty) {
      if(args.length < 2) {
        printUsage(error: "Command $commandName expects a subcommand", command: command);
        return;
      }
      final subcommandName = args[1];
      final subcommand = command.subcommands[subcommandName];
      if(subcommand == null) {
        printUsage(error: "Command $commandName does not have a subcommand named $subcommandName, command: command");
        return;
      }
      ctx.setCommandArgCount(2);
      try {
        await subcommand.run(ctx);
      } on AFCommandError catch(e) {
        _handleError(ctx, e, subcommand);
      }
    } else {
      ctx.setCommandArgCount(1);
      try {
        await command.run(ctx);
      } on AFCommandError catch(e) {
        _handleError(ctx, e, command);
      }
    }
  }

  void printUsage({
    String? error,
    AFCommand? command,
  }) {
    final result = StringBuffer();
    
    if(command != null) {
      result.write(command.usage);
    } else {
      result.write('''
$description

Usage: $name <command> [arguments]

Available Commands
''');
      for(final command in commands) {
        result.write("  ${command.name} - ${command.description}\n");
      }
    }

    if(error != null) {
      result.write("\nERROR: $error\n");
    }
    print(result.toString());
  }

  AFCommand? findByName(String name) {
    var result = commands.firstWhereOrNull((c) => c.name == name);
    if(result == null) {
      result = commandsHidden.firstWhereOrNull((c) => c.name == name);
    }
    return result;
  }

  void addCommand(AFCommand command) {
    commands.add(command);
  }

  void addHiddenCommand(AFCommand command) {
    commandsHidden.add(command);
  }

}

class AFHelpCommand extends AFCommand {
  final name = "help";
  final description = "Show help for other commands";
  
  
  final usage = "afib help <command> [<subcommand>]";

  bool errorIfNotProjectRoot(AFCommandContext ctx) {
    return true;
  }

  void printFullUsage(AFCommandContext ctx) {
    final result = StringBuffer('''
Usage: $usage

Available commands:
''');

    for(final command in ctx.definitions.commands.all) {
      result.writeln("  ${command.name} - ${command.description}");
    }

    result.writeln("\nNote: to create a new afib project, use the afib_bootstrap command");
    print(result.toString());
  }

  @override
  Future<void> execute(AFCommandContext ctx) async {
    final args = ctx.arguments.arguments;
    if(args.length < 2) {
      printFullUsage(ctx);
      return;
    }

    final cmdName = args[1];
    final command = ctx.definitions.commands.findByName(cmdName);
    if(command == null) {
      print("Error: Unknown command $cmdName");
      return;
    } else {
      if(args.length > 2) {
        final subcommandName = args[2];
        final subcommand = command.subcommands[subcommandName];
        if(subcommand == null) {
          print("Error: Unknown subcommand $subcommandName");
          return;
        } else {
          print(subcommand.usage);
        }
      } else {
        print(command.usage);
      }
    }
  }
}


class AFCommandAppExtensionContext extends AFCommandLibraryExtensionContext {
  AFCommandAppExtensionContext({
    required AFDartParams paramsD, 
    required AFCommandRunner commands
  }): super(
      paramsD: paramsD, 
      commands: commands,
      templates: AFTemplateRegistry()
    );

    Future<void> execute(AFCommandContext context) async {
      await commands.run(context);
    }


    void registerBootstrapCommands() {
      defineCommand(AFHelpCommand());
      defineCommand(AFVersionCommand());
      defineCommand(AFCreateAppCommand());
      _defineGenerateCommand(hidden: true);
      defineCommand(AFRequireCommand(), hidden: true);
      defineCommand(AFIntegrateCommand(), hidden: true);
      defineCommand(AFEchoCommand(), hidden: true);
    }


    void registerStandardCommands() {
      //register(AFVersionCommand());
      defineCommand(AFConfigCommand());
      _defineGenerateCommand(hidden: false);
      defineCommand(AFTestCommand());
      defineCommand(AFHelpCommand());
      defineCommand(AFIntegrateCommand());
      defineCommand(AFRequireCommand(), hidden: true);
      defineCommand(AFEchoCommand(), hidden: true);
    }

    void _defineGenerateCommand({ required bool hidden }) {
      final generateCmd = defineCommand(AFGenerateParentCommand(), hidden: hidden);
      generateCmd.addSubcommand(AFGenerateUISubcommand());
      generateCmd.addSubcommand(AFGenerateStateSubcommand());
      generateCmd.addSubcommand(AFGenerateQuerySubcommand());
      generateCmd.addSubcommand(AFGenerateCommandSubcommand());      
      generateCmd.addSubcommand(AFGenerateTestSubcommand());
      generateCmd.addSubcommand(AFGenerateIDSubcommand());
      generateCmd.addSubcommand(AFGenerateOverrideSubcommand());
      generateCmd.addSubcommand(AFGenerateCustomSubcommand());
      
    }
}