

import 'package:afib/afib_command.dart';
import 'package:afib/src/dart/command/commands/af_generate_command.dart';
import 'package:afib/src/dart/command/templates/statements/declare_query_shutdown_method.t.dart';
import 'package:afib/src/dart/utils/afib_d.dart';
import 'package:args/args.dart' as args;

class AFGenerateQuerySubcommand extends AFGenerateSubcommand {
  static const kindSimple = "simple";
  static const kindListener = "listener";
  static const kindDeferred = "deferred";
  static const argRootStateType = "root-state-type";
  static const argResultModelType = "result-model";

  AFGenerateQuerySubcommand();
  
  @override
  String get description => "Generate a query";

  @override
  String get name => "query";

  String get usage {
    return '''
Usage 
  afib.dart generate query [$kindSimple|$kindListener|$kindDeferred] YourQueryName [any --options]

Description
  Creates a new query of the specified kind.  

Options
  $kindSimple - A simple query that reads/writes a value and then completes,
  $kindListener - A query that listens for repeated updates which are pushed in from the outside world
  $kindDeferred - A query that waits for a duration and then executes, used for deferred calculation

  --$argResultModelType - The model object that will be returned by the asynchronous operation for integration
    into your state.   This is unnecessary for deferred queries, which do not have a result type.
  --$argRootStateType [YourRootState] - the name of the root state this query updates, defaults to your root state

  ${AFCommand.argPrivateOptionHelp}

''';
  }

  @override
  void execute(AFCommandContext ctx) {
    final unnamed = ctx.unnamedArguments;
    if(unnamed == null || unnamed.length < 2) {
      throwUsageError("Expected at least two arguments");
    }

    final queryKind = unnamed[0];
    final queryName = unnamed[1];
    final generator = ctx.generator;

    final args = parseArguments(unnamed, defaults: {
      argResultModelType: "",
      argRootStateType: generator.nameRootState,
    });

    verifyMixedCase(queryName, "query name");
    verifyUsageOption(queryKind, [
      kindSimple,
      kindListener,
      kindDeferred
    ]);
    verifyEndsWith(queryName, "Query");

    createQuery(
      ctx: ctx,
      queryKind: queryKind,
      queryName: queryName,
      args: args,
      usage: usage,
    );
        
    // replace any default 
    ctx.generator.finalizeAndWriteFiles(ctx);

  }

  static void createQuery({
    required AFCommandContext ctx,
    required String queryKind,
    required String queryName,
    required Map<String, dynamic> args,
    required String usage,
  }) {
    final rootStateType = args[argRootStateType];
    final resultModelType = args[argResultModelType];

    var fileKind = AFUISourceTemplateID.fileSimpleQuery;
    var queryType = "AFAsyncQuery";
    final isListener = queryKind == kindListener;
    final isDeferred = queryKind == kindDeferred;
    if(!isDeferred && resultModelType.isEmpty) {
      AFCommand.throwUsageErrorStatic("Please specify a result model type using --$argResultModelType", usage);
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
    queryFile.replaceText(ctx, AFUISourceTemplateID.textResultType, resultModelType);
    queryFile.replaceText(ctx, AFUISourceTemplateID.textStateType, rootStateType);
    queryFile.replaceText(ctx, AFUISourceTemplateID.textQueryType, queryType);
    
    final imports = <String>[];
    // see if the state file exists
    final stateFilePath = generator.pathRootState(rootStateType);
    generator.addImportsForPath(ctx, stateFilePath, imports: imports, requireExists: false);
    
    // if the result exists in the models area
    final modelFilePath = generator.pathModel(rootStateType);
    generator.addImportsForPath(ctx, modelFilePath, imports: imports);

    queryFile.replaceTextLines(ctx, AFUISourceTemplateID.textImportStatements, imports);

    final replaceCode = isListener || isDeferred ? DeclareQueryShutdownMethodT() : null;
    queryFile.replaceTextTemplate(ctx, AFUISourceTemplateID.textAdditionalMethods, replaceCode);
  }

}