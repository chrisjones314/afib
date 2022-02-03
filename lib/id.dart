import 'package:afib/src/dart/utils/af_id.dart';

class AFUILibraryID {
  static const id = AFLibraryID(code: "af", name: "AFib Core Library");
}

class AFUIQueryID extends AFQueryID {
  const AFUIQueryID(String code): super(code, AFUILibraryID.id);
  
  static const time = AFUIQueryID("time");
}

class AFUIScreenID extends AFScreenID {
  const AFUIScreenID(String code) : super(code, AFUILibraryID.id);

  static const unused = AFUIScreenID("unused");
  static const screenPrototypeWireframesList = AFUIScreenID("screen_prototype_wireframes_list");
  static const screenPrototypeListSingleScreen = AFUIScreenID("prototype_list_single_screen");
  static const screenPrototypeListWorkflow = AFUIScreenID("prototype_list_multi_screen");
  static const screenPrototypeSingleScreen = AFUIScreenID("prototype_single_screen");
  static const screenPrototypeWorkflow = AFUIScreenID("prototype_multi_screen");
  static const screenTestDrawer = AFUIScreenID("prototype_test_drawer");
  static const screenPrototypeHome = AFUIScreenID("prototype_home");
  static const screenPrototypeLoading = AFUIScreenID("prototype_loading");
  static const screenPrototypeWidget = AFUIScreenID("prototype_widget");
  static const screenStartupWrapper = AFUIScreenID("startup_wrapper");
  static const dialogStandardAlert = AFUIScreenID("standard_alert_dialog");
  static const screenPrototypeThirdPartyList = AFUIScreenID("protoype_third_party_list");
  static const screenPrototypeThirdPartyHome = AFUIScreenID("protoype_third_party_home");
  static const dialogStandardChoice = AFUIScreenID("standard_choice_dialog");
}

class AFUIWidgetID extends AFWidgetID {
  const AFUIWidgetID(String code) : super(code, AFUILibraryID.id);

  static const cardWireframes = AFUIWidgetID("card_wireframes");

  static const afibPassthroughSuffix = "_passthough";
  //static const screenStartup = AFUIScreenID("${afibScreenPrefix}startup");
  static const buttonBack = AFUIWidgetID("button_back");  
  static const textTestSearch = AFUIWidgetID("test_search");
  static const cardTestHomeHeader = AFUIWidgetID("card_test_home_header");
  static const contTestSearchControls = AFUIWidgetID("cont_test_search_controls");
  static const cardTestHomeSearchAndRun = AFUIWidgetID("card_test_home_search_and_run");
  static const cardTestGroup = AFUIWidgetID("card_test_group");
  static const buttonOK = AFUIWidgetID("button_ok");
  static const buttonCancel = AFUIWidgetID("button_cancel");
  static const textFilter = AFUIWidgetID("filter_text");
  static const widgetPrototypeTest = AFUIWidgetID("widget_prototype_test");
  static const cardThirdParty = AFUIWidgetID("third_party");
  static const textTime = AFUIWidgetID("text_time");
  static const textTimeAdjust = AFUIWidgetID("text_time_adjust");
  static const positionedTopHosted = AFUIWidgetID("positioned_top_hosted");
  static const positionedBottomHosted = AFUIWidgetID("positioned_bottom_hosted");
  static const positionedCenterHosted = AFUIWidgetID("positioned_center_hosted");
  static const contHostedControls = AFUIWidgetID("cont_hosted_controls");
  static const unused = AFUIWidgetID("unused");
}

class AFUIScreenTestID extends AFScreenTestID {
  const AFUIScreenTestID(String code, { List<String>? tags }): super(code, AFUILibraryID.id, tags: tags); 

  static const smoke = AFUIScreenTestID("smoke");
  static const all = AFUIScreenTestID("all");
  static const workflow = AFUIScreenTestID("workflow");
  static const wireframe = AFUIScreenTestID("wireframe");
}

class AFUITranslationID extends AFTranslationID{
  const AFUITranslationID(String code) : super(code, AFUILibraryID.id);
  
  static const wireframes = AFUITranslationID("wireframes");
  static const afibPrototypeMode = AFUITranslationID("afib_prototype_mode");
  static const searchAndRun = AFUITranslationID("search_and_run");
  static const prototypesAndTests = AFUITranslationID("prototypes_and_tests");
  static const run = AFUITranslationID("run");
  static const testResults = AFUITranslationID("test_results");
  static const searchResults = AFUITranslationID("search_results");
  static const thirdParty = AFUITranslationID("third_party");
  static const workflowPrototypes = AFUITranslationID("workflow_prototypes");
  static const screenPrototypes = AFUITranslationID("screen_prototypes");
  static const widgetPrototypes = AFUITranslationID("widget_prototypes");
  static const appTitle = AFUITranslationID("app_title");
  static const notTranslated = AFUITranslationID("not_translated");
  static const afibPrototypeLoading = AFUITranslationID("afib_prototype_loading");
}

/// Identifiers for the fundamental theme
/// 
/// These identifiers can be used by third parties, and are usually the values used to create the flutter ThemeData.
class AFUIThemeID extends AFThemeID {
  const AFUIThemeID(String code, String tag): super(code, AFUILibraryID.id, tag);   

  /// constant used by [AFFunctionalTheme.childButtonStandardBack]
  static const shouldStop = 1;
  /// constant used by [AFFunctionalTheme.childButtonStandardBack]
  static const shouldContinue = 2;

  static const tagFundamental = "fundamental";
  static const tagDevice = "device";

  static const unused = AFUIThemeID("unused", tagFundamental);
  static const defaultTheme = AFUIThemeID("default", tagFundamental);
  
  /// Used for the icon that indicates you are navigating up into a parent screen, often the left caret.
  static const iconBack = AFUIThemeID("icon_back", tagFundamental);

  /// Used for the icon that indicates you are navigating down into more detailed screens, often a right caret.
  static const iconNavDown = AFUIThemeID("icon_nav_down", tagFundamental);

  /// Used to determine the values of [AFFunctionalTheme.margin...], must be an array of 6 values, indicating the
  /// margin amount for s0 through s5 (the first should be zero, or s0 will be confusing).
  static const marginSizes = AFUIThemeID("margin_sizes", tagFundamental);
  static const paddingSizes = AFUIThemeID("padding_sizes", tagFundamental);
  static const borderRadiusSizes = AFUIThemeID("border_radius_sizes", tagFundamental);
  static const formFactor = AFUIThemeID("form_factor", tagFundamental);
  static const formOrientation = AFUIThemeID("form_orientation", tagFundamental);
  static const formFactorDelegate = AFUIThemeID("form_factor_delegate", tagFundamental);

  /// Color used for text that can be tapped like a hyperlink.
  static const colorTapableText = AFUIThemeID("color_tapable_text", tagFundamental);

  /// Used in prototype mode to override the device value.  Shouldn't generally be used in production.
  static const brightness = AFUIThemeID("brightness", tagDevice);

  /// Used in prototype mode to override the device value.  Shouldn't generally be used in production.
  static const alwaysUse24HourFormat = AFUIThemeID("always_use_24_hour_format", tagDevice);

  /// Used in prototype mode to override the device value.  Shouldn't generally be used in production.
  static const locale = AFUIThemeID("locale", tagDevice);

  /// Used in prototype mode to override the device value.  Shouldn't generally be used in production.
  static const textScaleFactor = AFUIThemeID("text_scale_factor", tagDevice);

  /// Used in prototype mode to display the value in the test/theme drawer, should not be used in production and cannot be overriden.
  static const physicalSize = AFUIThemeID("physical_size", tagDevice);

  /// Indicates that where a UI uses AFLanguageIDs for translation, the UI should show the IDs rather than the 
  /// translations.
  static const showTranslationsIDs = AFUIThemeID("show_translation_ids", tagFundamental);
}


class AFUISourceTemplateID extends AFSourceTemplateID {
  const AFUISourceTemplateID(String code) : super(code, AFUILibraryID.id);
 
  static const fileConfig = AFUISourceTemplateID("config");
  static const fileIds = AFUISourceTemplateID("ids");
  static const fileTestConfig = AFUISourceTemplateID("test_config");
  static const fileScreen = AFUISourceTemplateID("file_screen");

  static const stmtDeclareID = AFUISourceTemplateID("declare_id");
  static const stmtDeclareRouteParam = AFUISourceTemplateID("declare_route_param");
  static const stmtDeclareStateView = AFUISourceTemplateID("declare_state_view");

  static const textScreenName = AFUISourceTemplateID("screen_name");
  static const textAppNamespace = AFUISourceTemplateID("app_namespace");
  static const textPackageName = AFUISourceTemplateID("package_name");

  static const dynConfigEntries = AFUISourceTemplateID("config_entries");
}