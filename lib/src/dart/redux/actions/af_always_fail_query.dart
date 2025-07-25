import 'package:afib/afib_flutter.dart';

class AFAlwaysFailQuery extends AFAsyncQuery<String> {
  final String message;
  
  //------------------------------------------------------------------------
  AFAlwaysFailQuery({
    required this.message, 
    super.id
  });
  
  //------------------------------------------------------------------------
  @override
  void startAsync(AFStartQueryContext<String> context) {
    context.onError(AFQueryError.createMessage(message));
  }

  //------------------------------------------------------------------------
  @override
  void finishAsyncWithResponse(AFFinishQuerySuccessContext<String> context) {
    throw UnimplementedError();
  }
}

