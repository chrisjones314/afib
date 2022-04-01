

import 'package:afib/afib_command.dart';
import 'package:afib/src/dart/command/commands/af_generate_command.dart';
import 'package:afib/src/dart/command/templates/statements/declare_query_shutdown_method.t.dart';
import 'package:args/args.dart' as args;

class AFGenerateQuerySubcommand extends AFGenerateSubcommand {
  static const kindSimple = "simple";
  static const kindListener = "listener";
  static const kindDeferred = "deferred";

  AFGenerateQuerySubcommand();
  
  @override
  String get description => "Generate a query";

  @override
  String get name => "query";

  @override
  void registerArguments(args.ArgParser parser) {
  }

  String get usage {
    return '''
Usage 
  afib.dart generate query [$kindSimple|$kindListener|$kindDeferred] YourQueryName YourStateType [YourResultModelType]

Description
  Creates a new query of the specified kind.  

Options
  $kindSimple - A simple query that reads/writes a value and then completes,
  $kindListener - A query that listens for repeated updates which are pushed in from the outside world
  $kindDeferred - A query that waits for a duration and then executes, used for deferred calculation

  YourStateType - the name of your root state type
  YourResultModelType - The model object that will be returned by the asynchronous operation for integration
    into your state.   This is unnecessary for deferred queries, which do not have a result type.
''';
  }

  @override
  void execute(AFCommandContext ctx) {
    final unnamed = ctx.unnamedArguments;
    if(unnamed == null || unnamed.length < 3) {
      throwUsageError("Expected 3-4 arguments");
    }

    final queryKind = unnamed[0];
    final queryName = unnamed[1];
    final stateType = unnamed[2];
    final resultType = unnamed.length > 3 ? unnamed[3] : "";

    verifyMixedCase(queryName, "query name");
    verifyUsageOption(queryKind, [
      kindSimple,
      kindListener,
      kindDeferred
    ]);
    verifyDoesNotEndWith(queryName, "Query");

    var fileKind = AFUISourceTemplateID.fileSimpleQuery;
    var queryType = "AFAsyncQuery";
    final isListener = queryKind == kindListener;
    final isDeferred = queryKind == kindDeferred;
    if(!isDeferred && unnamed.length != 4) {
      throwUsageError("Expected four arguments");
    }
    if(isListener) {
      queryType = "AFAsyncListenerQuery";
    } else if(isDeferred) {
      fileKind = AFUISourceTemplateID.fileDeferredQuery;
    }
    
    // create a screen name
    final generator = ctx.generator;
    final queryPath = generator.pathQuery(queryName);
    final queryFile = generator.createFile(ctx, queryPath, fileKind);

    queryFile.replaceText(ctx, AFUISourceTemplateID.textQueryName, queryName);
    queryFile.replaceText(ctx, AFUISourceTemplateID.textResultType, resultType);
    queryFile.replaceText(ctx, AFUISourceTemplateID.textStateType, stateType);
    queryFile.replaceText(ctx, AFUISourceTemplateID.textQueryType, queryType);
    
    final imports = <String>[];
    // see if the state file exists
    final stateFilePath = generator.pathRootState(stateType);
    generator.addImportsForPath(ctx, stateFilePath, imports: imports);
    
    // if the result exists in the models area
    final modelFilePath = generator.pathModel(resultType);
    generator.addImportsForPath(ctx, modelFilePath, imports: imports);

    queryFile.replaceTextLines(ctx, AFUISourceTemplateID.textImportStatements, imports);

    final replaceCode = isListener || isDeferred ? DeclareQueryShutdownMethodT() : null;
    queryFile.replaceTextTemplate(ctx, AFUISourceTemplateID.textAdditionalMethods, replaceCode);
        
    // replace any default 
    generator.finalizeAndWriteFiles(ctx);

  }

}