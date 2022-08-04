

import 'package:afib/afib_command.dart';
import 'package:afib/src/dart/command/commands/af_generate_command.dart';
import 'package:afib/src/dart/command/templates/statements/declare_query_shutdown_method.t.dart';

class AFGenerateQuerySubcommand extends AFGenerateSubcommand {
  static const suffixQuery = "Query";
  static const suffixListenerQuery = "Listener$suffixQuery";
  static const suffixDeferredQuery = "Deferred$suffixQuery";
  static const argRootStateType = "root-state-type";
  static const argResultModelType = "result-type";

  AFGenerateQuerySubcommand();
  
  @override
  String get description => "Generate a query";

  @override
  String get name => "query";

  String get usage {
    return '''
$usageHeader
  $nameOfExecutable generate query YourQueryName [any --options]

$descriptionHeader
  $description

$optionsHeader
  $suffixQuery - A simple query that reads/writes a value and then completes,
  $suffixListenerQuery - A query that listens for repeated updates which are pushed in from the outside world
  $suffixDeferredQuery - A query that waits for a duration and then executes, used for deferred calculation

  --$argResultModelType - The model object that will be returned by the asynchronous operation for integration
    into your state.   This is unnecessary for deferred queries, which do not have a result type.
  --$argRootStateType [YourRootState] - the name of the root state this query updates, defaults to your root state

  ${AFCommand.argPrivateOptionHelp}

''';
  }

  @override
  void execute(AFCommandContext ctx) {
    final unnamed = ctx.rawArgs;
    if(unnamed == null || unnamed.isEmpty ) {
      throwUsageError("Expected at least one argument");
    }

    final queryName = unnamed[0];
    final generator = ctx.generator;

    final args = parseArguments(unnamed, defaults: {
      argResultModelType: "",
      argRootStateType: generator.nameRootState,
    });

    verifyMixedCase(queryName, "query name");
    verifyEndsWith(queryName, suffixQuery);
    var querySuffix = suffixQuery;
    if(queryName.endsWith(suffixListenerQuery)) {
      querySuffix = suffixListenerQuery;
    } else if(queryName.endsWith(suffixDeferredQuery)) {
      querySuffix = suffixDeferredQuery;
    }

    createQuery(
      ctx: ctx,
      querySuffix: querySuffix,
      queryName: queryName,
      args: args,
      usage: usage,
    );
        
    // replace any default 
    ctx.generator.finalizeAndWriteFiles(ctx);

  }

  static void createQuery({
    required AFCommandContext ctx,
    required String querySuffix,
    required String queryName,
    required Map<String, dynamic> args,
    required String usage,
  }) {
    final rootStateType = args[argRootStateType];
    final resultModelType = args[argResultModelType];

    var fileKind = AFUISourceTemplateID.fileSimpleQuery;
    var queryType = "AFAsyncQuery";
    final isListener = querySuffix == suffixListenerQuery;
    final isDeferred = querySuffix == suffixDeferredQuery;
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
    final modelFilePath = generator.pathModel(resultModelType);
    generator.addImportsForPath(ctx, modelFilePath, imports: imports);

    queryFile.addImports(ctx, imports);

    final replaceCode = isListener || isDeferred ? DeclareQueryShutdownMethodT() : null;
    queryFile.replaceTextTemplate(ctx, AFUISourceTemplateID.textAdditionalMethods, replaceCode);
  }

}