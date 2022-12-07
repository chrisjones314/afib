

import 'package:afib/afib_command.dart';
import 'package:afib/src/dart/command/commands/af_generate_command.dart';
import 'package:afib/src/dart/command/templates/core/files/queries.t.dart';
import 'package:afib/src/dart/command/templates/core/snippets/snippet_query_shutdown_method.t.dart';

class AFGenerateQuerySubcommand extends AFGenerateSubcommand {
  static const suffixQuery = "Query";
  static const suffixListenerQuery = "Listener$suffixQuery";
  static const suffixDeferredQuery = "Deferred$suffixQuery";
  static const suffixIsolateQuery = "Isolate$suffixQuery";
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
  $suffixIsolateQuery - A query that runs in a different thread

  --$argResultModelType - The model object that will be returned by the asynchronous operation for integration
    into your state.   This is unnecessary for deferred queries, which do not have a result type.
  --$argRootStateType [YourRootState] - the name of the root state this query updates, defaults to your root state
  --$argExportTemplatesHelp
  --$argOverrideTemplatesHelp

  ${AFCommand.argPrivateOptionHelp}

''';
  }

  @override
  void execute(AFCommandContext context) {
    final unnamed = context.rawArgs;
    if(unnamed.isEmpty ) {
      throwUsageError("Expected at least one argument");
    }

    final queryName = unnamed[0];
    final generator = context.generator;

    final args = parseArguments(unnamed, defaults: {
      argResultModelType: "",
      argRootStateType: generator.nameRootState,
      argExportTemplates: "",
      argOverrideTemplates: "",
    });

    verifyMixedCase(queryName, "query name");
    verifyEndsWith(queryName, suffixQuery);
    var querySuffix = suffixQuery;
    if(queryName.endsWith(suffixListenerQuery)) {
      querySuffix = suffixListenerQuery;
    } else if(queryName.endsWith(suffixDeferredQuery)) {
      querySuffix = suffixDeferredQuery;
    } else if(queryName.endsWith(suffixIsolateQuery)) {
      querySuffix = suffixIsolateQuery;
    }

    final coreInsertions = AFSourceTemplateInsertions.createCore(context);

    createQuery(
      context: context,
      insertions: coreInsertions,
      querySuffix: querySuffix,
      queryType: queryName,
      args: args.named,
      usage: usage,
    );
        
    // replace any default 
    context.generator.finalizeAndWriteFiles(context);

  }

  static void createQuery({
    required AFCommandContext context,
    required AFSourceTemplateInsertions insertions,
    required String querySuffix,
    required String queryType,
    required Map<String, dynamic> args,
    required String usage,
  }) {
    final rootStateType = args[argRootStateType];
    final resultType = args[argResultModelType];

    AFSourceTemplate queryTemplate = SimpleQueryT.core();
    var queryParentType = "AFAsyncQuery";
    final isListener = querySuffix == suffixListenerQuery;
    final isDeferred = querySuffix == suffixDeferredQuery;
    final isIsolate  = querySuffix == suffixIsolateQuery;
    if(!isDeferred && resultType.isEmpty) {
      AFCommand.throwUsageErrorStatic("Please specify a result model type using --$argResultModelType", usage);
    }
    if(isListener) {
      queryParentType = "AFAsyncListenerQuery";
    } else if(isDeferred) {
      queryTemplate = DeferredQueryT.core();
    } else if(isIsolate) {
      queryTemplate = IsolateQueryT.core();
    }

    AFSourceTemplate additionalMethods = AFSourceTemplate.empty;
    if(isListener || isDeferred) {
      additionalMethods = SnippetQueryShutdownMethodT();
    }
    
    var queryInsertions = SimpleQueryT.augmentInsertions(
      parent: insertions,
      queryType: queryType,
      resultType: resultType,
      queryParentType: queryParentType,
      additionalMethods: additionalMethods,
    );


    // create a screen name
    final generator = context.generator;
    final queryPath = generator.pathQuery(queryType);
    final queryFile = generator.createFile(context, queryPath, queryTemplate, insertions: queryInsertions);    
    
    final imports = <String>[];
    // see if the state file exists
    final stateFilePath = generator.pathRootState(rootStateType);
    generator.addImportsForPath(context, stateFilePath, imports: imports, requireExists: false);
    
    // if the result exists in the models area
    final modelFilePath = generator.pathModel(resultType);
    generator.addImportsForPath(context, modelFilePath, imports: imports);

    queryFile.addImports(context, imports);

  }

}