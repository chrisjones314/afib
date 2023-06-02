/// IDs used in the UI provided by AFib, like the prototype mode UI.
library afib_uiid;

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
  static const screenUnimplemented = AFUIScreenID("screenUnimplemented");
  static const screenPrototypeDrawer = AFUIScreenID("screenPrototypeDrawer");
  static const screenPrototypeBottomSheet = AFUIScreenID("screenPrototypeBottomSheet");
  static const screenPrototypeDialog = AFUIScreenID("screenPrototypeDialog");
  static const screenPrototypeWaiting = AFUIScreenID("screenPrototypeWaiting");
  static const screenDemoModeEnter = AFUIScreenID("screenDemoModeEnter");
  static const screenDemoModeExit = AFUIScreenID("screenDemoModeExit");

  static const unused = AFUIScreenID("unused");
  static const screenPrototypeWireframesList = AFUIScreenID("screenPrototypeWireframesList");
  static const screenPrototypeListSingleScreen = AFUIScreenID("screenPrototypeListSingleScreen");
  static const screenStateTestListScreen = AFUIScreenID("screenStateTestListScreen");
  static const screenPrototypeListWorkflow = AFUIScreenID("screenPrototypeListWorkflow");
  static const screenPrototypeSingleScreen = AFUIScreenID("screenPrototypeSingleScreen");
  static const screenPrototypeWorkflow = AFUIScreenID("screenPrototypeWorkflow");
  static const drawerPrototype = AFUIScreenID("drawerPrototype");
  static const screenPrototypeHome = AFUIScreenID("screenPrototypeHome");
  static const screenPrototypeLoading = AFUIScreenID("screenPrototypeLoading");
  static const screenPrototypeWidget = AFUIScreenID("screenPrototypeWidget");
  static const screenStartupWrapper = AFUIScreenID("screenStartupWrapper");
  static const dialogStandardAlert = AFUIScreenID("dialogStandardAlert");
  static const screenPrototypeLibraryList = AFUIScreenID("screenPrototypeLibraryList");
  static const screenPrototypeLibraryHome = AFUIScreenID("screenPrototypeLibraryHome");
  static const dialogStandardChoice = AFUIScreenID("dialogStandardChoice");
}

class AFUIWidgetID extends AFWidgetID {
  const AFUIWidgetID(String code) : super(code, AFUILibraryID.id);
  static const cardSearchResults = AFUIWidgetID("cardSearchResults");
  static const rowSearchControls = AFUIWidgetID("rowSearchControls");
  static const cardSearchControls = AFUIWidgetID("cardSearchControls");
  static const columnSearchControls = AFUIWidgetID("columnSearchControls");
  static const editSearch = AFUIWidgetID("editSearch");
  static const cardRelease = AFUIWidgetID("cardRelease");
  static const viewParent = AFUIWidgetID("viewParent");
  static const viewDepth = AFUIWidgetID("viewDepth");
  static const useScreenParam = AFUIWidgetID("useScreenParam");

  static const cardWireframes = AFUIWidgetID("cardWireframes");

  static const afibPassthroughSuffix = "afibPassthroughSuffix";
  //static const screenStartup = AFUIScreenID("screenStartup");
  static const buttonBack = AFUIWidgetID("buttonBack");  
  static const textTestSearch = AFUIWidgetID("textTestSearch");
  static const cardPrototype = AFUIWidgetID("cardPrototype");
  static const contTestSearchControls = AFUIWidgetID("contTestSearchControls");
  static const cardRecent = AFUIWidgetID("cardRecent");
  static const cardTestGroup = AFUIWidgetID("cardTestGroup");
  static const buttonOK = AFUIWidgetID("buttonOK");
  static const buttonCancel = AFUIWidgetID("buttonCancel");
  static const textFilter = AFUIWidgetID("textFilter");
  static const widgetPrototypeTest = AFUIWidgetID("widgetPrototypeTest");
  static const cardLibrary = AFUIWidgetID("cardLibrary");
  static const textTime = AFUIWidgetID("textTime");
  static const textTimeAdjust = AFUIWidgetID("textTimeAdjust");
  static const positionedTopHosted = AFUIWidgetID("positionedTopHosted");
  static const positionedBottomHosted = AFUIWidgetID("positionedBottomHosted");
  static const positionedCenterHosted = AFUIWidgetID("positionedCenterHosted");
  static const contHostedControls = AFUIWidgetID("contHostedControls");
  static const unused = AFUIWidgetID("unused");
  static const widgetWelcome = AFUIWidgetID("widgetWelcome");
}

class AFUIScreenTestID extends AFScreenTestID {
  const AFUIScreenTestID(String code, { List<String>? tags }): super(code, AFUILibraryID.id); 

  static const smoke = AFUIScreenTestID("smoke");
  static const all = AFUIScreenTestID("all");
  static const workflow = AFUIScreenTestID("workflow");
  static const wireframe = AFUIScreenTestID("wireframe");
}

class AFUITranslationID extends AFTranslationID{
  const AFUITranslationID(String code) : super(code, AFUILibraryID.id);
  static const stateTests = AFUITranslationID("stateTests");
  static const release = AFUITranslationID("release");
  
  static const wireframes = AFUITranslationID("wireframes");
  static const afibPrototypeMode = AFUITranslationID("afibPrototypeMode");
  static const recent = AFUITranslationID("recent");
  static const favorites = AFUITranslationID('favorites');
  static const prototype = AFUITranslationID("prototype");
  static const run = AFUITranslationID("run");
  static const testResults = AFUITranslationID("testResults");
  static const searchResults = AFUITranslationID("searchResults");
  static const libraries = AFUITranslationID("libraries");
  static const workflowTests = AFUITranslationID("workflowTests");
  static const screenPrototypes = AFUITranslationID("screenPrototypes");
  static const widgetPrototypes = AFUITranslationID("widgetPrototypes");
  static const appTitle = AFUITranslationID("appTitle");
  static const afibPrototypeLoading = AFUITranslationID("afibPrototypeLoading");
  static const afibUnimplemented = AFUITranslationID("afibUnimplemented");
}

/// Identifiers for the fundamental theme
/// 
/// These identifiers can be used by third parties, and are usually the values used to create the flutter ThemeData.
class AFUIThemeID extends AFThemeID {
  static const tagDevice = "tagDevice";
  const AFUIThemeID(String code): super(code, AFUILibraryID.id);   

  /// constant used by [AFFunctionalTheme.childButtonStandardBack]
  static const shouldStop = 1;
  /// constant used by [AFFunctionalTheme.childButtonStandardBack]
  static const shouldContinue = 2;

  static const unused = AFUIThemeID("unused");
  static const defaultTheme = AFUIThemeID("defaultTheme");
  
  /// Used for the icon that indicates you are navigating up into a parent screen, often the left caret.
  static const iconBack = AFUIThemeID("iconBack");

  /// Used for the icon that indicates you are navigating down into more detailed screens, often a right caret.
  static const iconNavDown = AFUIThemeID("iconNavDown");

  /// Used to determine the values of `AFFunctionalTheme.margin...`, must be an array of 6 values, indicating the
  /// margin amount for s0 through s5 (the first should be zero, or s0 will be confusing).
  static const marginSizes = AFUIThemeID("marginSizes");
  static const paddingSizes = AFUIThemeID("paddingSizes");
  static const borderRadiusSizes = AFUIThemeID("borderRadiusSizes");
  static const formFactor = AFUIThemeID("formFactor");
  static const formOrientation = AFUIThemeID("formOrientation");
  static const formFactorDelegate = AFUIThemeID("formFactorDelegate");

  /// Color used for text that can be tapped like a hyperlink.
  static const colorTapableText = AFUIThemeID("colorTapableText");

  /// Used in prototype mode to override the device value.  Shouldn't generally be used in production.
  static const brightness = AFUIThemeID("brightness");

  /// Used in prototype mode to override the device value.  Shouldn't generally be used in production.
  static const alwaysUse24HourFormat = AFUIThemeID("alwaysUse24HourFormat");

  /// Used in prototype mode to override the device value.  Shouldn't generally be used in production.
  static const locale = AFUIThemeID("locale");

  /// Used in prototype mode to override the device value.  Shouldn't generally be used in production.
  static const textScaleFactor = AFUIThemeID("textScaleFactor");

  /// Used in prototype mode to display the value in the test/theme drawer, should not be used in production and cannot be overriden.
  static const physicalSize = AFUIThemeID("physicalSize");

  /// Indicates that where a UI uses AFLanguageIDs for translation, the UI should show the IDs rather than the 
  /// translations.
  static const showTranslationsIDs = AFUIThemeID("showTranslationsIDs");

  static const colorPrimaryDarker = AFUIThemeID("colorPrimaryDarker");
  static const colorPrimaryLighter = AFUIThemeID("colorPrimaryLighter");
  static const colorAlert = AFUIThemeID("colorAlert");
  static const colorOnAlert = AFUIThemeID("colorOnAlert");

}


class AFUISourceTemplateID extends AFSourceTemplateID {
  const AFUISourceTemplateID(String code) : super(code, AFUILibraryID.id);



}

class AFUIPrototypeID extends AFPrototypeID {
  const AFUIPrototypeID(String code, { List<String>? tags }): super(code, AFUILibraryID.id); 
  static const visualize = AFUIPrototypeID("visualize");
  static const workflowStateTest = AFUIPrototypeID("workflowStateTest");

}
