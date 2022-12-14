import 'package:afib/afib_command.dart';
import 'package:afib/src/dart/command/templates/core/snippets/snippet_return_null.t.dart';

class SimpleQueryT extends AFFileSourceTemplate {
  static const insertResultTypeInsertion = AFSourceTemplateInsertion("result_type");
  static const insertStartImplInsertion = AFSourceTemplateInsertion("start_impl");
  static const insertFinishImplInsertion = AFSourceTemplateInsertion("finish_impl");

  SimpleQueryT({
    required String templateFileId,
    required List<String> templateFolder,
    Object? insertExtraImports,
    Object? insertMemberVariables,
    Object? insertConstructorParams,
    Object? insertStartImpl,
    Object? insertFinishImpl,
    Object? insertAdditionalMethods,
    Object? insertSuperParams
  }): super(
    templateFileId: templateFileId,
    templateFolder: templateFolder,
    embeddedInsertions: AFSourceTemplateInsertions(
      insertions: <AFSourceTemplateInsertion, Object>{
        AFSourceTemplate.insertExtraImportsInsertion: insertExtraImports ?? AFSourceTemplate.empty,
        AFSourceTemplate.insertMemberVariablesInsertion: insertMemberVariables ?? AFSourceTemplate.empty,
        AFSourceTemplate.insertConstructorParamsInsertion: insertConstructorParams ?? AFSourceTemplate.empty,
        AFSourceTemplate.insertSuperParamsInsertion: insertSuperParams ?? AFSourceTemplate.empty,
        insertStartImplInsertion: insertStartImpl ?? AFSourceTemplate.empty,
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

  AFSourceTemplateInsertion get insertQueryType => AFSourceTemplate.insertMainTypeInsertion;
  AFSourceTemplateInsertion get insertQueryParentType => AFSourceTemplate.insertMainParentTypeInsertion;
  AFSourceTemplateInsertion get insertResultType => insertResultTypeInsertion;
  AFSourceTemplateInsertion get insertFinishImpl => insertFinishImplInsertion;
  AFSourceTemplateInsertion get insertStartImpl => insertStartImplInsertion;

  static AFSourceTemplateInsertions augmentInsertions({
    required AFSourceTemplateInsertions parent,
    required Object queryType,
    required Object queryParentType,
    required Object resultType,
    Object memberVariables = AFSourceTemplate.empty,
    Object constructorParams = AFSourceTemplate.empty,
    Object startImpl = AFSourceTemplate.empty,
    Object finishImpl = AFSourceTemplate.empty,
    Object additionalMethods = AFSourceTemplate.empty
  }) {
    return parent.reviseAugment({
        AFSourceTemplate.insertMainTypeInsertion: queryType,
        AFSourceTemplate.insertMainParentTypeInsertion: queryParentType,
        insertResultTypeInsertion: resultType,
        AFSourceTemplate.insertMemberVariablesInsertion: memberVariables,
        AFSourceTemplate.insertConstructorParamsInsertion: constructorParams,
        insertStartImplInsertion: startImpl,
        insertFinishImplInsertion: finishImpl,
        AFSourceTemplate.insertAdditionalMethodsInsertion: additionalMethods,
      }
    );
  }


  String get template => '''
$insertFileHeader
import 'package:afib/afib_flutter.dart';
$insertExtraImports

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

class DeferredQueryT extends SimpleQueryT {

  DeferredQueryT({
    required String templateFileId,
    required List<String> templateFolder,
    AFSourceTemplate? insertMemberVariables,
    AFSourceTemplate? insertStartImpl,
    AFSourceTemplate? insertConstructorParams,
    AFSourceTemplate? insertFinishImpl = const SnippetReturnNullT(),
    AFSourceTemplate? insertAdditionalMethods,
  }): super(
    templateFileId: templateFileId,
    templateFolder: templateFolder,
    insertMemberVariables: insertMemberVariables,
    insertConstructorParams: insertConstructorParams,
    insertStartImpl: insertStartImpl,
    insertFinishImpl: insertFinishImpl,
    insertAdditionalMethods: insertAdditionalMethods,
  );

  factory DeferredQueryT.core() {
     return DeferredQueryT(
      templateFileId: "query_deferred",
      templateFolder: AFProjectPaths.pathGenerateCoreFiles,
    );
  }

  String get template => '''
import 'package:afib/afib_flutter.dart';
$insertExtraImports

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

class IsolateQueryT extends SimpleQueryT {

  IsolateQueryT({
    required String templateFileId,
    required List<String> templateFolder,
    AFSourceTemplate? insertMemberVariables,
    AFSourceTemplate? insertConstructorParams,
    AFSourceTemplate? insertStartImpl,
    AFSourceTemplate? insertFinishImpl,
    AFSourceTemplate? insertAdditionalMethods,
  }): super(
    templateFileId: templateFileId,
    templateFolder: templateFolder,
    insertMemberVariables: insertMemberVariables,
    insertConstructorParams: insertConstructorParams,
    insertStartImpl: insertStartImpl,
    insertFinishImpl: insertFinishImpl,
    insertAdditionalMethods: insertAdditionalMethods,
  );

  factory IsolateQueryT.core() {
     return IsolateQueryT(
      templateFileId: "query_isolate",
      templateFolder: AFProjectPaths.pathGenerateCoreFiles,
    );
  }

  String get template => '''
import 'package:afib/afib_flutter.dart';
$insertExtraImports

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