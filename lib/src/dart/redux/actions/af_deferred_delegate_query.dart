
import 'package:meta/meta.dart';
import 'package:afib/afib_flutter.dart';

class AFDeferredDelegateQuery<TState extends AFAppStateArea> extends AFDeferredQuery<TState> {
  final AFPressedDelegate onExecute;
  
  AFDeferredDelegateQuery({@required this.onExecute, Duration duration = const Duration(milliseconds: 200), AFID id, AFOnResponseDelegate<TState, AFUnused> onSuccessDelegate}): super(duration, id: id, onSuccessDelegate: onSuccessDelegate);

  @override
  Duration finishAsyncExecute(AFFinishQuerySuccessContext<TState, AFUnused> context) {
    onExecute();
    return null;
  }

  @override
  void shutdown() {
  }

}