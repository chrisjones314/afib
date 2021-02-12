// @dart=2.9
import 'package:meta/meta.dart';
import 'package:afib/afib_flutter.dart';

class AFAlwaysFailQuery<TState extends AFAppStateArea> extends AFAsyncQuery<TState, String> {
  final String message;
  
  //------------------------------------------------------------------------
  AFAlwaysFailQuery({@required this.message, AFID id}): super(id: id) {
    assert(TState != AFAppStateArea);
  }
  
  //------------------------------------------------------------------------
  @override
  void startAsync(AFStartQueryContext<String> context) {
    context.onError(AFQueryError(message: message));
  }

  //------------------------------------------------------------------------
  @override
  void finishAsyncWithResponse(AFFinishQuerySuccessContext<TState, String> context) {
    throw UnimplementedError();
  }
}

