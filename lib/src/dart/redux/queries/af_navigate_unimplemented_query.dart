import 'package:afib/afib_flutter.dart';
import 'package:afib/src/flutter/ui/screen/afui_unimplemented_screen.dart';

class AFNavigateUnimplementedQuery extends AFAsyncQuery<AFUnused> {
  final String message;

  AFNavigateUnimplementedQuery(this.message);

  @override
  void startAsync(AFStartQueryContext<AFUnused> context) {
      context.onSuccess(AFUnused.unused);
  }

  @override
  void finishAsyncWithResponse(AFFinishQuerySuccessContext<AFUnused> context) {
    context.navigatePush(AFUIUnimplementedScreen.navigatePush(message));
  }
}
