
import 'package:afib/src/dart/utils/af_id.dart';

class AFUILibraryID {
  static const id = AFLibraryID(code: "af", name: "AFib Core Library");
}

class AFUIScreenID {
  static const screenPrototypeWireframesList = AFScreenID("screen_prototype_wireframes_list", AFUILibraryID.id);
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
  static const dialogStandardChoice = AFScreenID("standard_choice_dialog", AFUILibraryID.id);
}

class AFUIWidgetID {
  static const cardWireframes = AFWidgetID("card_wireframes", AFUILibraryID.id);

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

class AFUIReusableTestID {
  static const smoke = AFScreenTestID("smoke", AFUILibraryID.id);
  static const all = AFScreenTestID("all", AFUILibraryID.id);
  static const workflow = AFScreenTestID("workflow", AFUILibraryID.id);
}

class AFUITranslationID {
  static const wireframes = AFTranslationID("wireframes", AFUILibraryID.id);
  static const afibPrototypeMode = AFTranslationID("afib_prototype_mode", AFUILibraryID.id);
  static const searchAndRun = AFTranslationID("search_and_run", AFUILibraryID.id);
  static const prototypesAndTests = AFTranslationID("prototypes_and_tests", AFUILibraryID.id);
  static const run = AFTranslationID("run", AFUILibraryID.id);
  static const testResults = AFTranslationID("test_results", AFUILibraryID.id);
  static const searchResults = AFTranslationID("search_results", AFUILibraryID.id);
  static const thirdParty = AFTranslationID("third_party", AFUILibraryID.id);
  static const workflowPrototypes = AFTranslationID("workflow_prototypes", AFUILibraryID.id);
  static const screenPrototypes = AFTranslationID("screen_prototypes", AFUILibraryID.id);
  static const widgetPrototypes = AFTranslationID("widget_prototypes", AFUILibraryID.id);
  static const appTitle = AFTranslationID("app_title", AFUILibraryID.id);
  static const notTranslated = AFTranslationID("not_translated", AFUILibraryID.id);
}

/// Identifiers for the fundamental theme
/// 
/// These identifiers can be used by third parties, and are usually the values used to create the flutter ThemeData.
class AFUIThemeID {

  /// constant used by [AFFunctionalTheme.childButtonStandardBack]
  static const shouldStop = 1;
  /// constant used by [AFFunctionalTheme.childButtonStandardBack]
  static const shouldContinue = 2;

  static const tagFundamental = "fundamental";
  static const tagDevice = "device";

  static const conceptualUnused = AFThemeID("conceptual_unused", AFUILibraryID.id, tagFundamental);
  static const conceptualUI = AFThemeID("conceptual_ui", AFUILibraryID.id, tagFundamental);
  
  /// Used for the icon that indicates you are navigating up into a parent screen, often the left caret.
  static const iconBack = AFThemeID("icon_back", AFUILibraryID.id, tagFundamental);

  /// Used for the icon that indicates you are navigating down into more detailed screens, often a right caret.
  static const iconNavDown = AFThemeID("icon_nav_down", AFUILibraryID.id, tagFundamental);

  /// Used to determine the values of [AFFunctionalTheme.margin...], must be an array of 6 values, indicating the
  /// margin amount for s0 through s5 (the first should be zero, or s0 will be confusing).
  static const marginSizes = AFThemeID("margin_sizes", AFUILibraryID.id, tagFundamental);
  static const paddingSizes = AFThemeID("padding_sizes", AFUILibraryID.id, tagFundamental);
  static const borderRadiusSizes = AFThemeID("border_radius_sizes", AFUILibraryID.id, tagFundamental);
  static const formFactor = AFThemeID("form_factor", AFUILibraryID.id, tagFundamental);
  static const formOrientation = AFThemeID("form_orientation", AFUILibraryID.id, tagFundamental);
  static const formFactorDelegate = AFThemeID("form_factor_delegate", AFUILibraryID.id, tagFundamental);

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

  /// Indicates that where a UI uses AFLanguageIDs for translation, the UI should show the IDs rather than the 
  /// translations.
  static const showTranslationsIDs = AFThemeID("show_translation_ids", AFUILibraryID.id, tagFundamental);
}


class AFUISourceTemplateID {
  static const fileConfig = AFSourceTemplateID("config", AFUILibraryID.id);
  static const fileIds = AFSourceTemplateID("ids", AFUILibraryID.id);
  static const fileTestConfig = AFSourceTemplateID("test_config", AFUILibraryID.id);
  static const fileScreen = AFSourceTemplateID("file_screen", AFUILibraryID.id);

  static const stmtDeclareID = AFSourceTemplateID("declare_id", AFUILibraryID.id);
  static const stmtDeclareRouteParam = AFSourceTemplateID("declare_route_param", AFUILibraryID.id);
  static const stmtDeclareStateView = AFSourceTemplateID("declare_state_view", AFUILibraryID.id);

  static const textScreenName = AFSourceTemplateID("screen_name", AFUILibraryID.id);
  static const textAppNamespace = AFSourceTemplateID("app_namespace", AFUILibraryID.id);
  static const textPackageName = AFSourceTemplateID("package_name", AFUILibraryID.id);

  static const dynConfigEntries = AFSourceTemplateID("config_entries", AFUILibraryID.id);
}