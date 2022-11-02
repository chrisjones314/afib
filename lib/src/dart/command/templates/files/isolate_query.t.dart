import 'package:afib/src/dart/command/af_source_template.dart';

class IsolateQueryT extends AFSourceTemplate {

  final String template = '''
class [!af_query_name] extends AFIsolateListenerQuery<[!af_result_type]> {
  
  /// Be careful about what members variables you place in here.  If they are
  /// not serializable (according to Flutter's internal ability to serialize data,
  /// see the isolate docs), you will get strange compiler errors.  Basically,
  /// to create the isolate, Flutter has to make a copy of your member variables
  /// using its own serialization mechanism.
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
  void executeInIsolate(AFIsolateListenerExecutionContext<[!af_result_type]> context) async {
    /// Put the code that actually implements the thread logic here, then, use
    /// context.executeSendMessage([!af_result_type]), to send results back to your main thread.
    /// Again, [!af_result_type] must be serializable according to flutter, because Flutter
    /// copies the memory to the main threads space.   

    /// Here, you intentionally cannot manipulate the UI or state directly via the context.   You
    /// are not in the correct thread/memory space to do that.
  }

  @override
  void finishAsyncWithResponse(AFFinishQuerySuccessContext<[!af_result_type]> context) {
    /// This is where you can process results from the threads context.executeSendMessage call
    /// on the main UI thread.   Here, you can update the state/UI as you normally would, as this
    /// method executes in the correct memory space.
  }

  [!af_additional_methods]

}
''';
}

