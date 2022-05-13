import 'package:afib/src/dart/redux/actions/af_async_query.dart';
import 'package:afib/src/dart/redux/state/models/af_app_state.dart';
import 'package:afib/src/dart/redux/state/models/af_package_info_state.dart';
import 'package:afib/src/flutter/utils/af_typedefs_flutter.dart';
import 'package:package_info_plus/package_info_plus.dart';

class AFPackageInfoQuery<TState extends AFFlexibleState> extends AFAsyncQuery<TState, AFPackageInfoState> {

  AFPackageInfoQuery({    
    AFOnResponseDelegate<TState, AFPackageInfoState>? onSuccessDelegate,
    AFPreExecuteResponseDelegate<AFPackageInfoState>? onPreExecuteResponseDelegate,
  }):
    super(onSuccessDelegate: onSuccessDelegate, onPreExecuteResponseDelegate: onPreExecuteResponseDelegate);

  @override
  void startAsync(AFStartQueryContext<AFPackageInfoState> context) {
    PackageInfo.fromPlatform().then((packageInfo) {
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
  
    context.updateComponentStateOne<TState>(packageInfo);
  }
}
