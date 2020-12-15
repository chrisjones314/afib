 import 'package:afib/src/dart/redux/state/af_app_state.dart';
import 'package:afib/src/dart/redux/state/af_theme_state.dart';
import 'package:afib/src/dart/utils/af_ui_id.dart';

AFFundamentalThemeArea createPrototypeThemeArea(AFFundamentalDeviceTheme device, AFAppStateAreas appState) {
  final result = AFFundamentalThemeArea(id: AFPrimaryThemeID.prototypeTheme);
  return result;  
}