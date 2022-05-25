import 'package:afib/src/dart/utils/af_id.dart';

class AFUILibraryID {
  static const id = AFLibraryID(code: "af", name: "afib");
}

class AFUIQueryID extends AFQueryID {
  const AFUIQueryID(String code): super(code, AFUILibraryID.id);
  
  static const time = AFUIQueryID("time");
}

class AFUIScreenID extends AFScreenID {
  const AFUIScreenID(String code) : super(code, AFUILibraryID.id);
  static const screenUnimplemented = AFUIScreenID("screen_unimplemented");
  static const screenPrototypeDrawer = AFUIScreenID("screen_prototype_drawer");
  static const screenPrototypeBottomSheet = AFUIScreenID("screen_prototype_bottom_sheet");
  static const screenPrototypeDialog = AFUIScreenID("screen_prototype_dialog");
  static const screenPrototypeWaiting = AFUIScreenID("screen_prototype_waiting");
  static const screenDemoModeEnter = AFUIScreenID("screen_demo_mode_enter");
  static const screenDemoModeExit = AFUIScreenID("screen_demo_mode_exit");

  static const unused = AFUIScreenID("unused");
  static const screenPrototypeWireframesList = AFUIScreenID("screen_prototype_wireframes_list");
  static const screenPrototypeListSingleScreen = AFUIScreenID("prototype_list_single_screen");
  static const screenPrototypeListWorkflow = AFUIScreenID("prototype_list_multi_screen");
  static const screenPrototypeSingleScreen = AFUIScreenID("prototype_single_screen");
  static const screenPrototypeWorkflow = AFUIScreenID("prototype_multi_screen");
  static const drawerPrototype = AFUIScreenID("drawer_prototype");
  static const screenPrototypeHome = AFUIScreenID("prototype_home");
  static const screenPrototypeLoading = AFUIScreenID("prototype_loading");
  static const screenPrototypeWidget = AFUIScreenID("prototype_widget");
  static const screenStartupWrapper = AFUIScreenID("startup_wrapper");
  static const dialogStandardAlert = AFUIScreenID("standard_alert_dialog");
  static const screenPrototypeLibraryList = AFUIScreenID("protoype_library_list");
  static const screenPrototypeLibraryHome = AFUIScreenID("protoype_library_home");
  static const dialogStandardChoice = AFUIScreenID("standard_choice_dialog");
}

class AFUIWidgetID extends AFWidgetID {
  const AFUIWidgetID(String code) : super(code, AFUILibraryID.id);
  static const cardRelease = AFUIWidgetID("card_release");

  static const cardWireframes = AFUIWidgetID("card_wireframes");

  static const afibPassthroughSuffix = "_passthough";
  //static const screenStartup = AFUIScreenID("${afibScreenPrefix}startup");
  static const buttonBack = AFUIWidgetID("button_back");  
  static const textTestSearch = AFUIWidgetID("test_search");
  static const cardPrototype = AFUIWidgetID("card_prototype");
  static const contTestSearchControls = AFUIWidgetID("cont_test_search_controls");
  static const cardTestHomeSearchAndRun = AFUIWidgetID("card_test_home_search_and_run");
  static const cardTestGroup = AFUIWidgetID("card_test_group");
  static const buttonOK = AFUIWidgetID("button_ok");
  static const buttonCancel = AFUIWidgetID("button_cancel");
  static const textFilter = AFUIWidgetID("filter_text");
  static const widgetPrototypeTest = AFUIWidgetID("widget_prototype_test");
  static const cardLibrary = AFUIWidgetID("library");
  static const textTime = AFUIWidgetID("text_time");
  static const textTimeAdjust = AFUIWidgetID("text_time_adjust");
  static const positionedTopHosted = AFUIWidgetID("positioned_top_hosted");
  static const positionedBottomHosted = AFUIWidgetID("positioned_bottom_hosted");
  static const positionedCenterHosted = AFUIWidgetID("positioned_center_hosted");
  static const contHostedControls = AFUIWidgetID("cont_hosted_controls");
  static const unused = AFUIWidgetID("unused");
  static const widgetWelcome = AFUIWidgetID("welcome");
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
  static const stateTests = AFUITranslationID("state_tests");
  static const release = AFUITranslationID("release");
  
  static const wireframes = AFUITranslationID("wireframes");
  static const afibPrototypeMode = AFUITranslationID("afib_prototype_mode");
  static const recent = AFUITranslationID("recent");
  static const prototype = AFUITranslationID("prototypes");
  static const run = AFUITranslationID("run");
  static const testResults = AFUITranslationID("test_results");
  static const searchResults = AFUITranslationID("search_results");
  static const libraries = AFUITranslationID("third_party");
  static const workflowTests = AFUITranslationID("workflow_prototypes");
  static const screenPrototypes = AFUITranslationID("screen_prototypes");
  static const widgetPrototypes = AFUITranslationID("widget_prototypes");
  static const appTitle = AFUITranslationID("app_title");
  static const notTranslated = AFUITranslationID("not_translated");
  static const afibPrototypeLoading = AFUITranslationID("afib_prototype_loading");
  static const afibUnimplemented = AFUITranslationID("afib_unimplemented");
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
  static const fileTestConfig = AFUISourceTemplateID("test_config");
  static const fileScreenTest = AFUISourceTemplateID("screen_test");
  static const fileScreen = AFUISourceTemplateID("file_screen");
  static const fileAppcodeAFib = AFUISourceTemplateID("appcode_afib");
  static const fileModel = AFUISourceTemplateID("file_model");
  static const fileStateView = AFUISourceTemplateID("file_state_view");
  static const fileSimpleQuery = AFUISourceTemplateID("file_simple_query");
  static const fileDeferredQuery = AFUISourceTemplateID("file_deferred_query");
  static const fileExtendBase = AFUISourceTemplateID("file_extend_base");
  static const fileExtendBaseLibrary = AFUISourceTemplateID("file_extend_base_third_party");
  static const fileExtendCommand = AFUISourceTemplateID("file_extend_command");
  static const fileExtendCommandLibrary = AFUISourceTemplateID("file_extend_command_third_party");
  static const fileCreateDartParams = AFUISourceTemplateID("file_create_dart_params");
  static const fileExtendLibrary = AFUISourceTemplateID("file_extend_third_party");
  static const fileExtendApplication = AFUISourceTemplateID("file_extend_application");
  static const fileMain = AFUISourceTemplateID("file_main");
  static const fileMainUILibrary = AFUISourceTemplateID("file_main_ui_library");
  static const fileApp = AFUISourceTemplateID("file_app");
  static const fileAppcodeID = AFUISourceTemplateID("file_appcode_id");
  static const fileEnvironment = AFUISourceTemplateID("file_enviroment");
  static const fileStateModelAccess = AFUISourceTemplateID("file_state_model_access");
  static const fileState = AFUISourceTemplateID("file_state");
  static const fileMainAFibTest = AFUISourceTemplateID("file_main_afib_test");
  static const fileConnectedBase = AFUISourceTemplateID("file_connected_base");
  static const fileExtendApp = AFUISourceTemplateID("file_extend_app");
  static const fileExtendAppUILibrary = AFUISourceTemplateID("file_extend_app_ui_library");
  static const fileExtendTest = AFUISourceTemplateID("file_extend_test");
  static const fileDefaultTheme = AFUISourceTemplateID("file_default_theme");
  static const fileDefineUI = AFUISourceTemplateID("file_define_ui");
  static const fileDefineTests = AFUISourceTemplateID("file_define_tests");
  static const fileTestData = AFUISourceTemplateID("file_test_data");
  static const fileStateTestShortcuts = AFUISourceTemplateID("file_state_test_shortcuts");
  static const fileCommand = AFUISourceTemplateID("file_command");
  static const fileLibExports = AFUISourceTemplateID("file_lib_exports");
  static const fileInstallUI = AFUISourceTemplateID("file_install_ui");
  static const fileInstallCommand = AFUISourceTemplateID("file_install_command");
  static const fileLPI = AFUISourceTemplateID("file_lpi");
  
  static const stmtDeclareID = AFUISourceTemplateID("declare_id");
  static const stmtDeclareRouteParam = AFUISourceTemplateID("declare_route_param");
  static const stmtDeclareStateView = AFUISourceTemplateID("declare_state_view");
  static const stmtDeclareSPI = AFUISourceTemplateID("declare_spi");


  static const textDeclareCreatePrototype = AFUISourceTemplateID("declare_create_prototype");
  static const textScreenName = AFUISourceTemplateID("screen_name");
  static const textNavigateMethods = AFUISourceTemplateID("navigate_methods");
  static const textScreenID = AFUISourceTemplateID("screen_id");
  static const textScreenIDType = AFUISourceTemplateID("screen_id_type");
  static const textSPIParentType = AFUISourceTemplateID("spi_parent_type");
  static const textThemeType = AFUISourceTemplateID("theme_type");
  static const textThemeID = AFUISourceTemplateID("theme_id");
  static const textParentThemeType = AFUISourceTemplateID("parent_theme_type");
  static const textStateViewPrefix = AFUISourceTemplateID("state_view_prefix");
  static const textControlTypeSuffix = AFUISourceTemplateID("control_type_suffix");
  static const textLPIID = AFUISourceTemplateID("lpi_id");
  static const textSPIImpls = AFUISourceTemplateID("spi_impls");
  static const textSuperImpls = AFUISourceTemplateID("super_impls");
  static const textStateViewType = AFUISourceTemplateID("state_view_type");
  static const textAppNamespace = AFUISourceTemplateID("app_namespace");
  static const textPackageName = AFUISourceTemplateID("package_name");
  static const textPackagePath = AFUISourceTemplateID("package_path");
  static const textStateViewName = AFUISourceTemplateID("state_view_name");
  static const textModelName = AFUISourceTemplateID("model_name");
  static const textQueryName = AFUISourceTemplateID("query_name");
  static const textStateType = AFUISourceTemplateID("state_type");
  static const textQueryType = AFUISourceTemplateID("query_type");
  static const textResultType = AFUISourceTemplateID("result_type");
  static const textImportStatements = AFUISourceTemplateID("import_statements");
  static const textBuildWithSPIImpl = AFUISourceTemplateID("build_with_spi_impl");
  static const textBuildBodyImpl = AFUISourceTemplateID("build_body_impl");
  static const textEnvironmentName = AFUISourceTemplateID("environment_name");
  static const textTestKind = AFUISourceTemplateID("test_kind");
  static const textPackageCode = AFUISourceTemplateID("package_code");
  static const textExtendKind = AFUISourceTemplateID("extend_kind");
  static const textTestID = AFUISourceTemplateID("test_id");
  static const textLibKind = AFUISourceTemplateID("lib_kind");
  static const textExtendAppParam = AFUISourceTemplateID("extend_app_param");
  static const textFundamentalThemeInit = AFUISourceTemplateID("fundamental_theme_init");
  static const textLPIType = AFUISourceTemplateID("lpi_type");
  static const textLPIParentType = AFUISourceTemplateID("lpi_parent_type");
  
  static const textAdditionalMethods = AFUISourceTemplateID("additional_methods");
  static const textFileRelativePath = AFUISourceTemplateID("file_relative_path");
  static const textFullTestDataID = AFUISourceTemplateID("full_test_data_id");
  static const textScreenTestID = AFUISourceTemplateID("screen_test_id");
  static const textIDTypeSuffix = AFUISourceTemplateID("id_type_suffix");
  static const textScreenImpls = AFUISourceTemplateID("screen_impls");
  static const textParamsConstructor = AFUISourceTemplateID("params_constructor");
  static const textRouteParamImpls = AFUISourceTemplateID("route_param_impls");
  static const textCommandName = AFUISourceTemplateID("command_name");
  static const textCommandNameShort = AFUISourceTemplateID("command_name_short");

  static const commentSPIIntro = AFUISourceTemplateID("comment_spi_intro");
  static const commentRouteParamIntro = AFUISourceTemplateID("comment_route_param_intro");
  static const commentConfigDecl = AFUISourceTemplateID("comment_config_decl");
  static const commentNavigatePush = AFUISourceTemplateID("comment_navigate_push");
  static const commentBuildWithSPI = AFUISourceTemplateID("comment_build_with_spi");
  static const commentBuildBody = AFUISourceTemplateID("comment_build_body");

  static const dynConfigEntries = AFUISourceTemplateID("config_entries");
}

class AFUIPrototypeID extends AFPrototypeID {
  const AFUIPrototypeID(String code, { List<String>? tags }): super(code, AFUILibraryID.id, tags: tags); 
  static const visualize = AFUIPrototypeID("visualize");
  static const workflowStateTest = AFUIPrototypeID("workflow_state_test");

}
