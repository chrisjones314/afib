import 'package:afib/src/dart/command/af_source_template.dart';

class SimpleQueryT extends AFSourceTemplate {

  final String template = '''
import 'package:afib/afib_flutter.dart';

class [!af_query_name] extends [!af_query_type]<[!af_result_type]> {
  
  [!af_query_name]({
    AFID? id,
    AFOnResponseDelegate<[!af_result_type]>? onSuccess,
    AFOnErrorDelegate? onError,
    AFPreExecuteResponseDelegate<[!af_result_type]>? onPreExecuteResponse
  }): super(
    id: id,
    onSuccess: onSuccess,
    onError: onError,
    onPreExecuteResponse: onPreExecuteResponse,
  );
  
  @override
  void startAsync(AFStartQueryContext<[!af_result_type]> context) {
    // do something asynchronous in here, then call context.onSuccess or 
    // context.onError()
    // note that while prototyping, you don't need to implement this, as 
    // screen and state prototypes will automatically skip this method and pass a specified
    // response to the method below.
  }

  @override
  void finishAsyncWithResponse(AFFinishQuerySuccessContext<[!af_result_type]> context) {
    // this is the value passed to context.onSuccess in startAsync:
    // final response = context.r;
    // use context.update... to integrate the response into your state.

  }

  //@override
  //void finishAsyncWithError(AFFinishQueryErrorContext context) {
    // for scenarios with errors that are code-paths, like bad password on login, you can use
    // this.  For network errors, etc, you will usually just let it fall through to the 
    // global error handler.
  //}

  [!af_additional_methods]

}
''';
}

