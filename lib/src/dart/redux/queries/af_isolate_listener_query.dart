import 'dart:isolate';

import 'package:afib/afib_flutter.dart';


abstract class AFIsolateListenerQuery<TState extends AFFlexibleState, TMessage> extends AFAsyncListenerQuery<TState, TMessage> {
  Isolate? isolate;

  AFIsolateListenerQuery({
    AFID? id,
    AFOnResponseDelegate<TState, TMessage>? onSuccessDelegate,
    AFOnErrorDelegate<TState>? onErrorDelegate,
    AFPreExecuteResponseDelegate<TMessage>? onPreExecuteResponseDelegate
  }): super(
    id: id,
    onSuccessDelegate: onSuccessDelegate,
    onErrorDelegate: onErrorDelegate,
    onPreExecuteResponseDelegate: onPreExecuteResponseDelegate,
  );

  void runInIsolate(SendPort sendPort);
  
  @override
  void startAsync(AFStartQueryContext<TMessage> context) async {
    final rp = ReceivePort();
    isolate = await Isolate.spawn(runInIsolate, rp.sendPort);
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