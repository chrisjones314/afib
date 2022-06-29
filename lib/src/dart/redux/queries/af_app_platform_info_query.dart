import 'dart:io';

import 'package:afib/src/dart/redux/actions/af_app_state_actions.dart';
import 'package:afib/src/dart/redux/actions/af_async_query.dart';
import 'package:afib/src/dart/redux/state/models/af_app_platform_info_state.dart';
import 'package:afib/src/flutter/utils/af_typedefs_flutter.dart';
import 'package:package_info_plus/package_info_plus.dart';

class AFAppPlatformInfoQuery extends AFAsyncQuery<AFAppPlatformInfoState> {

  AFAppPlatformInfoQuery({    
    AFOnResponseDelegate<AFAppPlatformInfoState>? onSuccessDelegate,
    AFPreExecuteResponseDelegate<AFAppPlatformInfoState>? onPreExecuteResponseDelegate,
  }):
    super(onSuccessDelegate: onSuccessDelegate, onPreExecuteResponseDelegate: onPreExecuteResponseDelegate);

  @override
  void startAsync(AFStartQueryContext<AFAppPlatformInfoState> context) {
    PackageInfo.fromPlatform().then((packageInfo) {
      final result = AFAppPlatformInfoState(
        appName: packageInfo.appName,
        packageName: packageInfo.packageName,
        appVersion: packageInfo.version,
        appBuildNumber: packageInfo.buildNumber,
        os: Platform.operatingSystem,
        osVersion: Platform.operatingSystemVersion,
        screenSize: "",
      );
      context.onSuccess(result);
    });
  }

  @override
  void finishAsyncWithResponse(AFFinishQuerySuccessContext<AFAppPlatformInfoState> context) {
    final packageInfo = context.r;
    context.dispatch(AFUpdateAppPlatformInfoAction(packageInfo));
  }
}
