
import 'dart:ui';

import 'package:afib/src/dart/utils/af_id.dart';

class AFUIID {
  static const afibIDPrefix = "_afib_";
  static const screenStartupWrapper = AFScreenID("${afibIDPrefix}startup_wrapper");
  //static const screenStartup = AFScreenID("${afibScreenPrefix}startup");
  static const screenPrototypeListSingleScreen = AFScreenID("${afibIDPrefix}prototype_list_single_screen");
  static const screenPrototypeListWorkflow = AFScreenID("${afibIDPrefix}prototype_list_multi_screen");
  static const screenPrototypeSingleScreen = AFScreenID("${afibIDPrefix}prototype_single_screen");
  static const screenPrototypeWorkflow = AFScreenID("${afibIDPrefix}prototype_multi_screen");
  static const screenTestDrawer = AFScreenID("${afibIDPrefix}prototype_test_drawer");
  static const screenPrototypeHome = AFScreenID("${afibIDPrefix}prototype_home");
  static const screenPrototypeWidget = AFScreenID("${afibIDPrefix}prototype_widget");
  static const buttonBack = AFWidgetID("${afibIDPrefix}button_back");  
  static const testTextSearch = AFWidgetID("${afibIDPrefix}test_search");
}

/// Identifiers for the fundamental theme
/// 
/// These identifiers can be used by third parties, and are usually the values used to create the flutter ThemeData.
class AFFundamentalThemeID {

  /// constant used by [AFConceptualTheme.standardBackButton]
  static const shouldStop = 1;
  /// constant used by [AFConceptualTheme.standardBackButton]
  static const shouldContinue = 2;

  static const tagFundamental = "${AFUIID.afibIDPrefix}fundamental";
  
  static const iconBack = AFThemeID("icon_back", tagFundamental);
  static const iconNavDown = AFThemeID("icon_nav_down", tagFundamental);

  static const sizeMargin = AFThemeID("size_margin", tagFundamental);

  /// Used in prototype mode to override the device value.  Shouldn't generally be used in production.
  static const brightness = AFThemeID("brightness", tagFundamental);

  /// Used in prototype mode to override the device value.  Shouldn't generally be used in production.
  static const alwaysUse24HourFormat = AFThemeID("always_use_24_hour_format", tagFundamental);

  /// Used in prototype mode to override the device value.  Shouldn't generally be used in production.
  static const locale = AFThemeID("locale", tagFundamental);

  /// Used in prototype mode to override the device value.  Shouldn't generally be used in production.
  static const textScaleFactor = AFThemeID("text_scale_factor", tagFundamental);

  /// Used in prototype mode to override the device value.  Shouldn't generally be used in production.
  static const Locale localeDefault = Locale('en', 'US');

}
