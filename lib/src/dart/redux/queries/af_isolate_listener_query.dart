import 'dart:isolate';

import 'package:afib/afib_flutter.dart';

class AFIsolateListenerExecutionContext<TMessage> {
  final SendPort sendPort;
  AFIsolateListenerExecutionContext({
    required this.sendPort,
  });

  void executeSendMessage(TMessage message) {
    sendPort.send(message);
  }

}


abstract class AFIsolateListenerQuery<TMessage> extends AFAsyncListenerQuery<TMessage> {
  Isolate? isolate;

  AFIsolateListenerQuery({
    AFID? id,
    AFOnResponseDelegate<TMessage>? onSuccess,
    AFOnErrorDelegate? onError,
    AFPreExecuteResponseDelegate<TMessage>? onPreExecuteResponse
  }): super(
    id: id,
    onSuccess: onSuccess,
    onError: onError,
    onPreExecuteResponse: onPreExecuteResponse,
  );

  void runInIsolateInternal(SendPort sendPort) {
    final ctx = AFIsolateListenerExecutionContext<TMessage>(sendPort: sendPort);
    executeInIsolate(ctx);
  }

  void executeInIsolate(AFIsolateListenerExecutionContext<TMessage> context);
  
  @override
  void startAsync(AFStartQueryContext<TMessage> context) async {
    final rp = ReceivePort();
    isolate = await Isolate.spawn(runInIsolateInternal, rp.sendPort);
    rp.listen((value) {
      final message = value as TMessage;
      context.onSuccess(message);
    });
  }

  /// This method is called when you execute an AFShutdownOngoingQueriesAction
  /// or when you re-execute a query of this type, replacing the existing listener
  /// with a new/differently configured query.
  @override
  void shutdown() {
    isolate?.kill();
  }
}