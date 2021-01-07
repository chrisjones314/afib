
import 'dart:ui';

import 'package:afib/src/dart/utils/af_id.dart';

class AFUIScreenID {
  static const screenPrototypeListSingleScreen = AFScreenID("${AFUIWidgetID.afibIDPrefix}prototype_list_single_screen");
  static const screenPrototypeListWorkflow = AFScreenID("${AFUIWidgetID.afibIDPrefix}prototype_list_multi_screen");
  static const screenPrototypeSingleScreen = AFScreenID("${AFUIWidgetID.afibIDPrefix}prototype_single_screen");
  static const screenPrototypeWorkflow = AFScreenID("${AFUIWidgetID.afibIDPrefix}prototype_multi_screen");
  static const screenTestDrawer = AFScreenID("${AFUIWidgetID.afibIDPrefix}prototype_test_drawer");
  static const screenPrototypeHome = AFScreenID("${AFUIWidgetID.afibIDPrefix}prototype_home");
  static const screenPrototypeWidget = AFScreenID("${AFUIWidgetID.afibIDPrefix}prototype_widget");
  static const screenStartupWrapper = AFScreenID("${AFUIWidgetID.afibIDPrefix}startup_wrapper");
}

class AFUIWidgetID {
  static const afibIDPrefix = "_afib_";
  //static const screenStartup = AFScreenID("${afibScreenPrefix}startup");
  static const buttonBack = AFWidgetID("${afibIDPrefix}button_back");  
  static const textTestSearch = AFWidgetID("${afibIDPrefix}test_search");
  static const cardTestHomeHeader = AFWidgetID("${afibIDPrefix}card_test_home_header");
  static const contTestSearchControls = AFWidgetID("${afibIDPrefix}cont_test_search_controls");
  static const cardTestHomeSearchAndRun = AFWidgetID("${afibIDPrefix}card_test_home_search_and_run");
  static const cardTestGroup = AFWidgetID("${afibIDPrefix}card_test_group");
  static const buttonOK = AFWidgetID("${afibIDPrefix}button_ok");
  static const buttonCancel = AFWidgetID("${afibIDPrefix}button_cancel");
  static const textFilter = AFWidgetID("${afibIDPrefix}filter_text");
  static const widgetPrototypeTest = AFWidgetID("${afibIDPrefix}widget_prototype_test");
}

class AFUITestID {
  static const smokeTest = AFSingleScreenTestID("smoke");
}


/// Identifiers for the fundamental theme
/// 
/// These identifiers can be used by third parties, and are usually the values used to create the flutter ThemeData.
class AFUIThemeID {

  /// constant used by [AFConceptualTheme.childButtonStandardBack]
  static const shouldStop = 1;
  /// constant used by [AFConceptualTheme.childButtonStandardBack]
  static const shouldContinue = 2;

  static const tagFundamental = "${AFUIWidgetID.afibIDPrefix}fundamental";
  static const tagDevice = "${AFUIWidgetID.afibIDPrefix}device";
  
  /// Used for the icon that indicates you are navigating up into a parent screen, often the left caret.
  static const iconBack = AFThemeID("icon_back", tagFundamental);

  /// Used for the icon that indicates you are navigating down into more detailed screens, often a right caret.
  static const iconNavDown = AFThemeID("icon_nav_down", tagFundamental);

  static const sizeMargin = AFThemeID("size_margin", tagFundamental);

  /// Used in prototype mode to override the device value.  Shouldn't generally be used in production.
  static const brightness = AFThemeID("brightness", tagDevice);

  /// Used in prototype mode to override the device value.  Shouldn't generally be used in production.
  static const alwaysUse24HourFormat = AFThemeID("always_use_24_hour_format", tagDevice);

  /// Used in prototype mode to override the device value.  Shouldn't generally be used in production.
  static const locale = AFThemeID("locale", tagDevice);

  /// Used in prototype mode to override the device value.  Shouldn't generally be used in production.
  static const textScaleFactor = AFThemeID("text_scale_factor", tagDevice);

  /// Used in prototype mode to display the value in the test/theme drawer, should not be used in production and cannot be overriden.
  static const physicalSize = AFThemeID("physical_size", tagDevice);

  /// Used in prototype mode to override the device value.  Shouldn't generally be used in production.
  static const Locale localeDefault = Locale('en', 'US');

}
