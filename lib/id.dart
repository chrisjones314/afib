
import 'package:afib/src/dart/utils/af_id.dart';

class AFUILibraryID {
  static const id = AFLibraryID(code: "afui", name: "AFib Core UI");
}

class AFUIScreenID {
  static const screenPrototypeListSingleScreen = AFScreenID("prototype_list_single_screen", AFUILibraryID.id);
  static const screenPrototypeListWorkflow = AFScreenID("prototype_list_multi_screen", AFUILibraryID.id);
  static const screenPrototypeSingleScreen = AFScreenID("prototype_single_screen", AFUILibraryID.id);
  static const screenPrototypeWorkflow = AFScreenID("prototype_multi_screen", AFUILibraryID.id);
  static const screenTestDrawer = AFScreenID("prototype_test_drawer", AFUILibraryID.id);
  static const screenPrototypeHome = AFScreenID("prototype_home", AFUILibraryID.id);
  static const screenPrototypeWidget = AFScreenID("prototype_widget", AFUILibraryID.id);
  static const screenStartupWrapper = AFScreenID("startup_wrapper", AFUILibraryID.id);
  static const dialogStandardError = AFScreenID("standard_error_dialog", AFUILibraryID.id);
  static const screenPrototypeThirdPartyList = AFScreenID("protoype_third_party_list", AFUILibraryID.id);
  static const screenPrototypeThirdPartyHome = AFScreenID("protoype_third_party_home", AFUILibraryID.id);
}

class AFUIWidgetID {

  static const afibPassthroughSuffix = "_passthough";
  //static const screenStartup = AFScreenID("${afibScreenPrefix}startup");
  static const buttonBack = AFWidgetID("button_back", AFUILibraryID.id);  
  static const textTestSearch = AFWidgetID("test_search", AFUILibraryID.id);
  static const cardTestHomeHeader = AFWidgetID("card_test_home_header", AFUILibraryID.id);
  static const contTestSearchControls = AFWidgetID("cont_test_search_controls", AFUILibraryID.id);
  static const cardTestHomeSearchAndRun = AFWidgetID("card_test_home_search_and_run", AFUILibraryID.id);
  static const cardTestGroup = AFWidgetID("card_test_group", AFUILibraryID.id);
  static const buttonOK = AFWidgetID("button_ok", AFUILibraryID.id);
  static const buttonCancel = AFWidgetID("button_cancel", AFUILibraryID.id);
  static const textFilter = AFWidgetID("filter_text", AFUILibraryID.id);
  static const widgetPrototypeTest = AFWidgetID("widget_prototype_test", AFUILibraryID.id);
  static const cardThirdParty = AFWidgetID("third_party", AFUILibraryID.id);
}

class AFUITestID {
  static const smokeTest = AFSingleScreenTestID("smoke", AFUILibraryID.id);
}


/// Identifiers for the fundamental theme
/// 
/// These identifiers can be used by third parties, and are usually the values used to create the flutter ThemeData.
class AFUIThemeID {

  /// constant used by [AFConceptualTheme.childButtonStandardBack]
  static const shouldStop = 1;
  /// constant used by [AFConceptualTheme.childButtonStandardBack]
  static const shouldContinue = 2;

  static const tagFundamental = "fundamental";
  static const tagDevice = "device";

  static const conceptualUnused = AFThemeID("conceptual_unused", AFUILibraryID.id, tagFundamental);
  static const conceptualPrototype = AFThemeID("conceptual_proto", AFUILibraryID.id, tagFundamental);
  
  /// Used for the icon that indicates you are navigating up into a parent screen, often the left caret.
  static const iconBack = AFThemeID("icon_back", AFUILibraryID.id, tagFundamental);

  /// Used for the icon that indicates you are navigating down into more detailed screens, often a right caret.
  static const iconNavDown = AFThemeID("icon_nav_down", AFUILibraryID.id, tagFundamental);

  /// Used to determine the values of [AFConceptualTheme.margin...], must be an array of 6 values, indicating the
  /// margin amount for s0 through s5 (the first should be zero, or s0 will be confusing).
  static const marginSizes = AFThemeID("margin_sizes", AFUILibraryID.id, tagFundamental);
  static const paddingSizes = AFThemeID("padding_sizes", AFUILibraryID.id, tagFundamental);
  static const borderRadiusSizes = AFThemeID("border_radius_sizes", AFUILibraryID.id, tagFundamental);

  /// Color used for text that can be tapped like a hyperlink.
  static const colorTapableText = AFThemeID("color_tapable_text", AFUILibraryID.id, tagFundamental);

  /// Used in prototype mode to override the device value.  Shouldn't generally be used in production.
  static const brightness = AFThemeID("brightness", AFUILibraryID.id, tagDevice);

  /// Used in prototype mode to override the device value.  Shouldn't generally be used in production.
  static const alwaysUse24HourFormat = AFThemeID("always_use_24_hour_format", AFUILibraryID.id, tagDevice);

  /// Used in prototype mode to override the device value.  Shouldn't generally be used in production.
  static const locale = AFThemeID("locale", AFUILibraryID.id, tagDevice);

  /// Used in prototype mode to override the device value.  Shouldn't generally be used in production.
  static const textScaleFactor = AFThemeID("text_scale_factor", AFUILibraryID.id, tagDevice);

  /// Used in prototype mode to display the value in the test/theme drawer, should not be used in production and cannot be overriden.
  static const physicalSize = AFThemeID("physical_size", AFUILibraryID.id, tagDevice);


}
