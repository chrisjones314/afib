import 'package:afib/afib_flutter.dart';

class AFAlwaysFailQuery<TState extends AFFlexibleState> extends AFAsyncQuery<String> {
  final String message;
  
  //------------------------------------------------------------------------
  AFAlwaysFailQuery({
    required this.message, 
    AFID? id
  }): super(id: id) {
    assert(TState != AFFlexibleState);
  }
  
  //------------------------------------------------------------------------
  @override
  void startAsync(AFStartQueryContext<String> context) {
    context.onError(AFQueryError(message: message));
  }

  //------------------------------------------------------------------------
  @override
  void finishAsyncWithResponse(AFFinishQuerySuccessContext<String> context) {
    throw UnimplementedError();
  }
}

