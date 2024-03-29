

import 'package:afib/afib_command.dart';
import 'package:afib/src/dart/command/templates/core/snippets/snippet_query_shutdown_method.t.dart';

/// The command that handles 'generate query...'
class AFGenerateQuerySubcommand extends AFGenerateSubcommand {
  static const suffixQuery = "Query";
  static const suffixListenerQuery = "Listener$suffixQuery";
  static const suffixDeferredQuery = "Deferred$suffixQuery";
  static const suffixIsolateQuery = "Isolate$suffixQuery";
  static const argRootStateType = "root-state-type";
  static const argResultModelType = "result-type";

  AFGenerateQuerySubcommand();
  
  @override
  String get description => "Generate a query, including listener queries, deferred queries, and isolate (thread) queries";

  @override
  String get name => "query";

  @override
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
  ${AFGenerateSubcommand.argMemberVariablesHelp}  
  --$argRootStateType [YourRootState] - the name of the root state this query updates, defaults to your root state
  --$argExportTemplatesHelp
  --$argOverrideTemplatesHelp
  --$argForceOverwriteHelp

  ${AFCommand.argPrivateOptionHelp}

''';
  }

  static bool isQuery(String itemName) {
    return itemName.endsWith(suffixQuery);
  }

  @override
  Future<void> execute(AFCommandContext context) async {
    final generator = context.generator;

    final args = context.parseArguments(
      command: this,
      unnamedCount: 1,
      named: {
        argResultModelType: "",
        argRootStateType: generator.nameRootState,
        argExportTemplates: "",
        argOverrideTemplates: "",
        argExportTemplates: "false",
        argOverrideTemplates: "",
        AFGenerateSubcommand.argMemberVariables: "",
        AFGenerateSubcommand.argResolveVariables: "",
      }
    );

    final queryName = args.accessUnnamedFirst;

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
    final resultType = args.accessNamed(argResultModelType);

    createQuery(
      context: context,
      querySuffix: querySuffix,
      queryType: queryName,
      resultType: resultType,
      args: args,
      usage: usage,
    );
        
    // replace any default 
    context.generator.finalizeAndWriteFiles(context);

  }

  static void createQuery({
    required AFCommandContext context,
    required String querySuffix,
    required String queryType,
    required AFCommandArgumentsParsed args,
    required String usage,
    required String resultType,
    String? overrideParentType,
    AFSourceTemplate? overrideTemplate,
  }) {
    final rootStateType = args.accessNamed(argRootStateType);
    final memberVariables = context.memberVariables(context, args, queryType);

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
    final resultTypeCore = SimpleQueryT.findCoreResultType(resultType);    

    var queryInsertions = SimpleQueryT.augmentInsertions(
      parent: context.coreInsertions,
      queryType: queryType,
      resultType: resultType,
      resultTypeCore: resultTypeCore,
      queryParentType: overrideParentType ?? queryParentType,
      additionalMethods: additionalMethods,
      memberVariables: memberVariables?.declareVariables ?? AFSourceTemplate.empty,
      constructorParams: memberVariables?.constructorParamsBare ?? AFSourceTemplate.empty,
      memberVariableImports: memberVariables?.extraImports(context) ?? AFSourceTemplate.empty,
    );


    // create a screen name
    final generator = context.generator;
    final queryPath = generator.pathQuery(queryType);
    final queryFile = generator.createFile(context, queryPath, overrideTemplate ?? queryTemplate, insertions: queryInsertions);    
    
    // see if the state file exists
    final stateFilePath = generator.pathRootState(rootStateType);
    queryFile.importProjectPath(context, stateFilePath);
    
    // if the result exists in the models area
    if(resultType != "AFUnused") {
      final modelFilePath = generator.pathModel(resultTypeCore);
      if(modelFilePath != null) {
        queryFile.importProjectPath(context, modelFilePath);
      }
    }
  }

}