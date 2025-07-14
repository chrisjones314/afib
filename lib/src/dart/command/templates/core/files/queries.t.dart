import 'package:afib/afib_command.dart';
import 'package:afib/src/dart/command/templates/core/snippets/snippet_return_null.t.dart';

/// Any class that ends in "T" is a source template used in code generation.
class SimpleQueryT extends AFFileSourceTemplate {
  static const insertResultTypeInsertion = AFSourceTemplateInsertion("result_type");
  static const insertResultTypeSingleInsertion = AFSourceTemplateInsertion("result_type_single");
  static const insertStartImplInsertion = AFSourceTemplateInsertion("start_impl");
  static const insertFinishImplInsertion = AFSourceTemplateInsertion("finish_impl");

  SimpleQueryT({
    required super.templateFileId,
    required super.templateFolder,
    Object? insertExtraImports,
    Object? insertStartImpl,
    Object? insertFinishImpl,
    Object? insertAdditionalMethods,
    Object? insertSuperParams
  }): super(
    embeddedInsertions: AFSourceTemplateInsertions(
      insertions: <AFSourceTemplateInsertion, Object>{
        AFSourceTemplate.insertExtraImportsInsertion: insertExtraImports ?? AFSourceTemplate.empty,
        AFSourceTemplate.insertSuperParamsInsertion: insertSuperParams ?? AFSourceTemplate.empty,
        insertStartImplInsertion: insertStartImpl ?? '''
throwUnimplemented();
''',
        insertFinishImplInsertion: insertFinishImpl ?? AFSourceTemplate.empty,
        AFSourceTemplate.insertAdditionalMethodsInsertion: insertAdditionalMethods ?? AFSourceTemplate.empty,
      }
    ) 
  );

  SimpleQueryT.withMemberVariables({
    required super.templateFileId,
    required super.templateFolder,
    Object? insertExtraImports,
    Object? insertStartImpl,
    Object? insertFinishImpl,
    Object? insertAdditionalMethods,
    Object? insertSuperParams,
    required Object insertConstructorParams,
    required Object insertMemberVariables,
  }): super(
    embeddedInsertions: AFSourceTemplateInsertions(
      insertions: <AFSourceTemplateInsertion, Object>{
        AFSourceTemplate.insertExtraImportsInsertion: insertExtraImports ?? AFSourceTemplate.empty,
        AFSourceTemplate.insertSuperParamsInsertion: insertSuperParams ?? AFSourceTemplate.empty,
        AFSourceTemplate.insertConstructorParamsInsertion: insertConstructorParams,
        AFSourceTemplate.insertMemberVariablesInsertion: insertMemberVariables,
        insertStartImplInsertion: insertStartImpl ?? '''
throwUnimplemented();
''',
        insertFinishImplInsertion: insertFinishImpl ?? AFSourceTemplate.empty,
        AFSourceTemplate.insertAdditionalMethodsInsertion: insertAdditionalMethods ?? AFSourceTemplate.empty,
      }
    ) 
  );

  factory SimpleQueryT.core() {
     return SimpleQueryT(
       templateFileId: "query_simple",
       templateFolder: AFProjectPaths.pathGenerateCoreFiles,
    );
  }

  factory SimpleQueryT.startupEmpty() {
     return SimpleQueryT.withMemberVariables(
       templateFileId: "query_startup_empty",
       templateFolder: AFProjectPaths.pathGenerateCoreFiles,
       insertMemberVariables: AFSourceTemplate.empty,
       insertConstructorParams: AFSourceTemplate.empty,
       insertStartImpl: AFSourceTemplate.empty,
    );
  }


  AFSourceTemplateInsertion get insertQueryType => AFSourceTemplate.insertMainTypeInsertion;
  AFSourceTemplateInsertion get insertQueryParentType => AFSourceTemplate.insertMainParentTypeInsertion;
  AFSourceTemplateInsertion get insertResultType => insertResultTypeInsertion;
  AFSourceTemplateInsertion get insertFinishImpl => insertFinishImplInsertion;
  AFSourceTemplateInsertion get insertStartImpl => insertStartImplInsertion;

  static AFSourceTemplateInsertions augmentInsertions({
    required AFSourceTemplateInsertions parent,
    required Object queryType,
    required Object queryParentType,
    required String resultType,
    required String resultTypeCore,
    Object memberVariables = AFSourceTemplate.empty,
    Object constructorParams = AFSourceTemplate.empty,
    Object startImpl = AFSourceTemplate.empty,
    Object finishImpl = AFSourceTemplate.empty,
    Object additionalMethods = AFSourceTemplate.empty,
    Object memberVariableImports = AFSourceTemplate.empty,
  }) {
    return parent.reviseAugment({
        AFSourceTemplate.insertMainTypeInsertion: queryType,
        AFSourceTemplate.insertMainParentTypeInsertion: queryParentType,
        insertResultTypeInsertion: resultType,
        insertResultTypeSingleInsertion: resultTypeCore,
        AFSourceTemplate.insertMemberVariablesInsertion: memberVariables,
        AFSourceTemplate.insertConstructorParamsInsertion: constructorParams,
        insertStartImplInsertion: startImpl,
        insertFinishImplInsertion: finishImpl,
        AFSourceTemplate.insertAdditionalMethodsInsertion: additionalMethods,
        AFSourceTemplate.insertMemberVariableImportsInsertion: memberVariableImports,
      }
    );
  }

  static String findCoreResultType(String resultType) {
    const startList = "List<";
    final idxStart = resultType.indexOf(startList);
    var result = resultType;
    if(idxStart >= 0) {
      final idxEnd = resultType.indexOf(">");
      if(idxEnd < 0) {
        throw AFException("Missing > in $resultType");
      }
      
      result = resultType.substring(idxStart+startList.length, idxEnd);
    }

    if(result.endsWith("?")) {
      result = result.substring(0, result.length-1);
    }

    return result;
  }


  @override
  String get template => '''
$insertFileHeader
import 'package:afib/afib_command.dart';
import 'package:afib/afib_flutter.dart';
$insertExtraImports
$insertMemberVariableImports

// ignore_for_file: unused_import

class $insertQueryType extends $insertQueryParentType<$insertResultType> {
  $insertMemberVariables
  
  $insertQueryType({
    AFID? id,
    $insertConstructorParams
    AFOnResponseDelegate<$insertResultType>? onSuccess,
    AFOnErrorDelegate? onError,
    AFPreExecuteResponseDelegate<$insertResultType>? onPreExecuteResponse
  }): super(
    id: id,
    onSuccess: onSuccess,
    $insertSuperParams
    onError: onError,
    onPreExecuteResponse: onPreExecuteResponse,
  );
  
  @override
  void startAsync(AFStartQueryContext<$insertResultType> context) async {
    $insertStartImpl
  }

  @override
  void finishAsyncWithResponse(AFFinishQuerySuccessContext<$insertResultType> context) {
    $insertFinishImpl
  }

  $insertAdditionalMethods
}
''';
}

/// Anything that ends in "T" is a source template used in code generation.
class DeferredQueryT extends SimpleQueryT {

  DeferredQueryT({
    required super.templateFileId,
    required super.templateFolder,
    AFSourceTemplate? super.insertStartImpl,
    AFSourceTemplate? super.insertFinishImpl = const SnippetReturnNullT(),
    AFSourceTemplate? super.insertAdditionalMethods,
  });

  factory DeferredQueryT.core() {
     return DeferredQueryT(
      templateFileId: "query_deferred",
      templateFolder: AFProjectPaths.pathGenerateCoreFiles,
    );
  }

  @override
  String get template => '''
// ignore_for_file: unused_import
import 'package:afib/afib_flutter.dart';
$insertExtraImports
$insertMemberVariableImports

class ${insertQueryType}Query extends AFDeferredQuery {
  $insertMemberVariables

  ${insertQueryType}Query({
    AFID? id,
    $insertConstructorParams
    Duration duration = const Duration(milliseconds: 300),
    AFOnResponseDelegate<AFUnused>? onSuccess,
  }): super(
    duration,
    $insertSuperParams
    id: id,
    onSuccess: onSuccess,
  );
  
  @override
  Duration? finishAsyncExecute(AFFinishQuerySuccessContext<AFUnused> context) {
    $insertFinishImpl;
  }

  $insertAdditionalMethods
}
''';
}

/// Any class that ends in "T" is a source template used in code generation.
class IsolateQueryT extends SimpleQueryT {

  IsolateQueryT({
    required super.templateFileId,
    required super.templateFolder,
    AFSourceTemplate? super.insertStartImpl,
    AFSourceTemplate? super.insertFinishImpl,
    AFSourceTemplate? super.insertAdditionalMethods,
  });

  factory IsolateQueryT.core() {
     return IsolateQueryT(
      templateFileId: "query_isolate",
      templateFolder: AFProjectPaths.pathGenerateCoreFiles,
    );
  }

  @override
  String get template => '''
import 'package:afib/afib_flutter.dart';
$insertExtraImports
$insertMemberVariableImports

class $insertQueryType extends AFIsolateListenerQuery<$insertResultType> {
  // AFib Help: 
  // Be careful about what members variables you place in here.  If they are
  // not serializable (according to Flutter's internal ability to serialize data,
  // see the isolate docs), you will get strange compiler errors.  Basically,
  // to create the isolate, Flutter has to make a copy of your member variables
  // using its own serialization mechanism.
  $insertMemberVariables


  $insertQueryType({
    AFID? id,
    $insertConstructorParams
    AFOnResponseDelegate<$insertResultType>? onSuccess,
    AFOnErrorDelegate? onError,
    AFPreExecuteResponseDelegate<$insertResultType>? onPreExecuteResponse
  }): super(
    id: id,
    $insertSuperParams,
    onSuccess: onSuccess,
    onError: onError,
    onPreExecuteResponse: onPreExecuteResponse,
  );
  
  @override
  void executeInIsolate(AFIsolateListenerExecutionContext<$insertResultType> context) async {
    // AFib Help:
    // Put the code that actually implements the thread logic here, then, use
    // context.executeSendMessage($insertResultType), to send results back to your main thread.
    // Again, $insertResultType must be serializable according to flutter, because Flutter
    // copies the memory to the main threads space.  
    //
    // Here, you intentionally cannot manipulate the UI or state directly via the context.   You
    // are not in the correct thread/memory space to do that.
    $insertStartImpl
  }

  @override
  void finishAsyncWithResponse(AFFinishQuerySuccessContext<$insertResultType> context) {
    // AFib Help:
    // This is where you can process results from the threads context.executeSendMessage call
    // on the main UI thread.   Here, you can update the state/UI as you normally would, as this
    // method executes in the correct memory space.
    $insertFinishImpl
  }

  $insertAdditionalMethods
}
''';
}
