


import 'package:afib/src/dart/redux/actions/af_app_state_actions.dart';
import 'package:afib/src/dart/redux/actions/af_async_query.dart';
import 'package:afib/src/dart/redux/state/af_app_state.dart';
import 'package:afib/src/dart/redux/state/af_package_info_state.dart';
import 'package:afib/src/dart/utils/af_query_error.dart';
import 'package:package_info/package_info.dart';

class AFPackageInfoQuery<TState extends AFAppState> extends AFAsyncQuery<TState, AFPackageInfoState> {

  AFPackageInfoQuery({List<dynamic> successActions, AFOnResponseDelegate<TState, AFPackageInfoState> onSuccessDelegate}):
    super(successActions: successActions, onSuccessDelegate: onSuccessDelegate);

  @override
  void startAsync(AFStartQueryContext<AFPackageInfoState, AFQueryError> context) {
    PackageInfo.fromPlatform().then((PackageInfo packageInfo) {
      final result = AFPackageInfoState(
        appName: packageInfo.appName,
        packageName: packageInfo.packageName,
        version: packageInfo.version,
        buildNumber: packageInfo.buildNumber
      );
      context.onSuccess(result);
    });
  }

  @override
  void finishAsyncWithResponse(AFFinishQuerySuccessContext<TState, AFPackageInfoState> context) {
    final packageInfo = context.r;
  
    final updateState = AFUpdateAppStateAction.updateOne(packageInfo);
    context.dispatch(updateState);
  }

  @override
  void finishAsyncWithError(AFFinishQueryErrorContext<TState, AFQueryError> context) {

  }
}
