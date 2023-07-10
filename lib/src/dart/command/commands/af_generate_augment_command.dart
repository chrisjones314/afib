import 'package:afib/afib_command.dart';
import 'package:afib/src/dart/command/templates/af_code_regexp.dart';
import 'package:afib/src/dart/command/templates/core/files/model.t.dart';
import 'package:afib/src/dart/command/templates/core/snippets/snippet_declare_spi.t.dart';
import 'package:afib/src/dart/command/templates/core/snippets/snippet_navigate_push.t.dart';
import 'package:afib/src/dart/command/templates/core/snippets/snippet_serial_methods.t.dart';
import 'package:path/path.dart';

class AFGenerateAugmentSubcommand extends AFGenerateSubcommand {
  static const argNotSerial = "no-serial-methods";
  static const argNoReviseMethods = "no-revise-methods";
  static const argAddStandardRoot = "add-standard-root";

  AFGenerateAugmentSubcommand();
  
  @override
  String get description => "Add member variables to an existing model, route parameter/SPI or query";

  @override
  String get name => "augment";

  @override 
  String get usage {
    return '''
$usageHeader
  $nameOfExecutable generate augment ExistingClass [any --options]

$descriptionHeader
  $description

  If your identifier ends with [${AFGenerateUISubcommand.allUISuffixes.join('|')}], it is treated as a screen
  If your identifier ends with ${AFGenerateQuerySubcommand.suffixQuery}, it is treated as a query
  If your identifier ends with ${AFCodeGenerator.rootSuffix}, it is treated as a root state
  Otherwise, it is treated as a model

$optionsHeader
  ${AFGenerateSubcommand.argMemberVariablesHelp} 
    Note: If your backend store has integer ids, specify "int id;" as your id, AFib will automatically convert to/from a string on the client.
  ${AFGenerateSubcommand.argResolveVariablesHelp}

  For Simple Models Only
    --$argAddStandardRoot - Add if you want to also generate a standard root containing a map of String ids to objects of this model.
    --$argNoReviseMethods - Include if you do not want to generate default revise methods for each member variable 
    --$argNotSerial - Include if you do not want to generate standard serialization methods
  
  Standard Options
    --$argExportTemplatesHelp
    --$argOverrideTemplatesHelp
    ${AFCommand.argPrivateOptionHelp}    
''';
  }

  @override
  Future<void> execute(AFCommandContext context) async {

    final args = context.parseArguments(
      command: this, 
      unnamedCount: 1, 
      named: {
        argNotSerial: "false",
        argNoReviseMethods: "false",
        AFGenerateSubcommand.argMemberVariables: "",
        AFGenerateSubcommand.argResolveVariables: "",
      }
    );

    // get the model name.
    final itemName = args.accessUnnamedFirst;
    verifyMixedCase(itemName, "model name");

    // see if it exists on the filesystem 
    final generator = context.generator;
    generator.pathModel(itemName);
    final pathModel = generator.pathUnknown(itemName);
    if(pathModel == null) {
      throw AFException("Conversion from model to path failed.");
    }
    if(!generator.fileExists(pathModel)) {
      throw AFCommandError(error: "Expected $itemName to be in file ${joinAll(pathModel)}, but no such file exists");
    }

    final isQuery = AFGenerateQuerySubcommand.isQuery(itemName);
    final isUI = AFGenerateUISubcommand.hasUISuffix(itemName);
    final isModel = !isQuery && !isUI;
    final modelFile = generator.modifyFile(context, pathModel);
    final isIntId = modelFile.findFirstLineContaining(context, AFCodeRegExp.isIntId) > 0;
    if(isIntId) {
      AFCommandContext.writeConvertingIntIdMessage(context);
    }
       
    final itemNameFull = isUI ? "${itemName}RouteParam" : itemName;

    final memberVariables = context.memberVariables(context, args, itemNameFull, isAugment: true, isIntIdOverride: isIntId);
    if(memberVariables == null) {
      throw AFCommandError(error: "Please specify --${AFGenerateSubcommand.argMemberVariables} and/or --${AFGenerateSubcommand.argResolveVariables}");
    }

    context.output.writeTwoColumns(col1: "modify ", col2: joinAll(pathModel));


    // first, do the things that are universal
    _insertForBreadcrumb(context, modelFile, AFSourceTemplate.insertMemberVariablesInsertion, memberVariables.declareVariables);
    _insertForBreadcrumb(context, modelFile, AFSourceTemplate.insertConstructorParamsInsertion, memberVariables.constructorParamsBare);
    _insertForBreadcrumb(context, modelFile, AFSourceTemplate.insertExtraImportsInsertion, memberVariables.extraImports(context));

    if(isUI || isModel) {
      //_insertForBreadcrumb(context, modelFile, AFSourceTemplate.insertCreateParamsInsertion, memberVariables.initialValueDeclaration)
      _insertForBreadcrumb(context, modelFile, ModelT.insertResolveMethods, memberVariables.resolveMethods);
      _insertForBreadcrumb(context, modelFile, ModelT.insertReviseMethods, memberVariables.reviseMethods);
      _insertForBreadcrumb(context, modelFile, AFSourceTemplate.insertCopyWithParamsInsertion, memberVariables.copyWithParamsBare);
      _insertForBreadcrumb(context, modelFile, AFSourceTemplate.insertCopyWithCallInsertion, memberVariables.copyWithCall); 
    }

    if(isUI) {
      _insertForBreadcrumb(context, modelFile, SnippetDeclareSPIT.insertSPIResolveMethods, memberVariables.spiResolveMethods);
      _insertForBreadcrumb(context, modelFile, SnippetDeclareSPIT.insertSPIOnUpdateMethods, memberVariables.spiOnUpdateMethods);
      _insertForBreadcrumb(context, modelFile, SnippetNavigatePushT.insertNavigatePushParamDecl, memberVariables.navigatePushParamsBare);
      _insertForBreadcrumb(context, modelFile, SnippetNavigatePushT.insertNavigatePushParamCall, memberVariables.navigatePushCall);
      _insertForBreadcrumb(context, modelFile, AFSourceTemplate.insertCreateParamsCallInsertion, memberVariables.routeParamCreateCall);
    }

    if(isModel) {
      _insertForBreadcrumb(context, modelFile, ModelT.insertSerialConstantsInsertion, memberVariables.serialConstants);
      _insertForBreadcrumb(context, modelFile, SnippetSerialMethodsT.insertSerializeToBody, memberVariables.serializeTo);
      _insertForBreadcrumb(context, modelFile, SnippetSerialMethodsT.insertSerializeFromConstructorParams, memberVariables.serializeFromConstructorParams);
      _insertForBreadcrumb(context, modelFile, SnippetSerialMethodsT.insertSerializeFromDeserializeLines, memberVariables.serializeFromDeserializeLines);  
    }  
    
    if(modelFile.buffer.firstLineContaining(context, RegExp(AFMemberVariableTemplates.tempPlaceholderVarName)) >0) {
      var nRemoved = 0;
      final buffer = modelFile.buffer;
      for(var lineIdx = buffer.lines.length - 1; lineIdx >= 0; lineIdx--) {
        final line = buffer.lines[lineIdx];
        if(line.contains(AFMemberVariableTemplates.tempPlaceholderVarName)) {
          buffer.removeLineAt(lineIdx);
          nRemoved++;
        }
      }
      
      context.output.writeTwoColumns(col1: "info ", col2: "Removed $nRemoved lines containing ${AFMemberVariableTemplates.tempPlaceholderVarName}");
    }

    generator.finalizeAndWriteFiles(context);
  }

  void _insertForBreadcrumb(AFCommandContext context, AFGeneratedFile modelFile, AFSourceTemplateInsertion insert, String value) {
    final regex = RegExp(insert.breadcrumb);
    var idx = modelFile.findFirstLineContaining(context, regex);
    final output = context.output;
    var foundCount = 0;
    while(idx >= 0) {
      foundCount++;      
      final valueLines = value.split("\n");
      final line = modelFile.buffer.lines[idx];
      final identCount = line.indexOf(insert.breadcrumb);
      final identBuf = StringBuffer();
      for(var i = 0; i < identCount; i++) {
        identBuf.write(" ");
      }
      final ident = identBuf.toString();
      final valueLinesIndented = valueLines.map((e) => "$ident$e");
      final valueLinesNoExtra = valueLinesIndented.where((e) => e.trim().isNotEmpty);

      modelFile.buffer.addLinesBeforeIdx(context, idx, valueLinesNoExtra.toList());
      output.writeTwoColumns(col1: "found ", col2: insert.breadcrumb);
      idx = modelFile.findFirstLineContaining(context, regex, startAt: idx+valueLinesNoExtra.length+2);      
    }

    if(foundCount == 0) {
      output.writeTwoColumnsWarning(col1: "missing ", col2: insert.breadcrumb);
      return;
    }
  }
}