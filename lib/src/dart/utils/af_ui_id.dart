
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

}

/// Identifiers for the fundamental theme
/// 
/// These identifiers can be used by third parties, and are usually the values used to create the flutter ThemeData.
class AFFundamentalThemeID {
  static const tagFundamental = "${AFUIID.afibIDPrefix}fundamental";
  static const tagDeviceOverride = "${AFUIID.afibIDPrefix}device_override";
  
  static const colorPrimary = AFThemeID("color_primary", tagFundamental, "Primary color");
  static const colorPrimaryLighter = AFThemeID("color_primary_lighter", tagFundamental, "Primary color lighter");
  static const colorPrimaryDarker = AFThemeID("color_primary_darker", tagFundamental, "Primary color darker");
  static const colorPrimaryForeground = AFThemeID("color_primary_foreground ", tagFundamental, "Primary color foreground");
  static const colorPrimaryLighterForeground = AFThemeID("color_primary_lighter_foreground", tagFundamental, "Primary color lighter foreground");
  static const colorPrimaryDarkerForeground = AFThemeID("color_primary_darker_foreground", tagFundamental, "Primary color darker foreground");
  static const colorPrimaryDarkMode = AFThemeID("color_primary_dark_mode", tagFundamental, "Primary color in dark mode");
  static const colorPrimaryForegroundDarkMode = AFThemeID("color_primary_foreground_dark_mode", tagFundamental, "Primary color foreground in dark mode");
  static const colorTapable = AFThemeID("color_tapable", tagFundamental, "Tapable color");
  static const colorTapableDarkMode = AFThemeID("color_tapable_dark_mode", tagFundamental, "Tapable color dark mode");
  static const colorMuted = AFThemeID("color_muted", tagFundamental, "Color muted");
  static const colorMutedDarkMode = AFThemeID("color_muted_dark_mode", tagFundamental, "Color muted dark mode");

  static const colorSecondary = AFThemeID("color_secondary", tagFundamental, "Secondary color");
  static const colorSecondaryDarker = AFThemeID("color_secondary_dark", tagFundamental, "Secondary color darker");
  static const colorSecondaryLighter = AFThemeID("color_secondary_darker", tagFundamental, "Secondary color darker");
  static const colorSecondaryForeground = AFThemeID("color_secondary_foreground", tagFundamental, "Secondary color foreground");
  static const colorSecondaryDarkerForeground = AFThemeID("color_secondary_dark_foreground", tagFundamental, "Secondary color darker foreground");
  static const colorSecondaryLighterForeground = AFThemeID("color_secondary_darker_foreground", tagFundamental, "Secondary color darker foreground");

  static const colorCardBody = AFThemeID("color_card_body", tagFundamental, "Card body background");
  static const colorCardBodyForeground = AFThemeID("color_card_body_foreground", tagFundamental, "Card body foreground");
  static const colorCardBodyDarkMode = AFThemeID("color_card_body_background", tagFundamental, "Card body background in dark mode");
  static const colorCardBodyForegroundDarkMode = AFThemeID("color_card_body_foreground_dark_mode", tagFundamental, "Card body foreground in dark mode");

  
  /// Should be used for something like the app name on the login page.
  static const sizeAppTitle = AFThemeID("size_app_title", tagFundamental, "App title size");

  /// Should be used for the title of each page
  static const sizeScreenTitle = AFThemeID("size_screen_title", tagFundamental, "Page title size");

  /// Should be used for major headings within the app, maybe a label at the top of a card.
  static const sizeHeadingMajor = AFThemeID("size_heading_major", tagFundamental, "Heading major size");

  /// Should be used for minor headings wihtin the app, maybe a label within a subsection of a card.
  static const sizeHeadingMinor = AFThemeID("size_heading_minor", tagFundamental, "Heading minor size");

  /// Should be used for standard text within the app
  static const sizeBodyText = AFThemeID("size_body_text", tagFundamental, "Body text size");

  /// The standard margin to create space around UI compoenents.
  static const sizeMargin = AFThemeID("size_margin", tagFundamental, "Size standard margin");

  /// font weight for normal text
  static const weightNormal = AFThemeID("weight_normal", tagFundamental, "Font weight for normal text");

  /// font weight for bold text
  static const weightBold = AFThemeID("weight_normal", tagFundamental, "Font weight for bold text");
  

  /// pass this as the factor to get half the normal size.
  /// ```dart
  /// context.t.size(AFFundamentalThemeID.sizeMargin, factor: AFFundamentalThemeID.sizeHalf);
  /// ````
  static const sizeHalf = 0.5;

  /// pass this as the factor to get double the normal size
  /// ```dart
  /// context.t.size(AFFundamentalThemeID.sizeMargin, factor: AFFundamentalThemeID.sizeDouble);
  /// ````
  static const sizeDouble = 2;


  /// Should be used for tiny text within the app, like legalities or footnotes
  static const sizeTinyText = AFThemeID("size_tiny_text", tagFundamental, "Tiny text size");

  /// Color scheme for a fancy splash screen.
  static const colorsSplashScreen = AFThemeID("colors_splash_screen", tagFundamental, "Colors splash screen");

  /// Color theme for the screen title at the top of the screen.
  static const colorsScreenTitle = AFThemeID("colors_screen_title", tagFundamental, "Colors screen title");

  /// Color theme for the app background 
  static const colorsAppBackground = AFThemeID("colors_app_background", tagFundamental, "Colors app background");

  /// Color scheme for a portion of a card contining its title label.
  static const colorsCardTitle = AFThemeID("colors_card_title", tagFundamental, "Colors card title");

  /// Color scheme for a portion of a card containing its body content.
  static const colorsCardBody = AFThemeID("colors_card_body", tagFundamental, "Colors card body");

  /// Color scheme for the top/title area of a drawer.
  static const colorsDrawerTitle = AFThemeID("colors_drawer_title", tagFundamental, "Colors drawer title");

  /// Color Scheme for the body of the drawer.
  static const colorsDrawerBody = AFThemeID("colors_drawer_body", tagFundamental, "Colors drawer body");

  /// Color scheme for the bottom bar.
  static const colorsBottomBar = AFThemeID("colors_bottom_bar", tagFundamental, "Colors bottom bar");

  /// Color Scheme for the action button
  static const colorsActionButton = AFThemeID("colors_action_button", tagFundamental, "Colors action button");


  static const styleAppTitleSplash = AFThemeID("style_app_title_splash", tagFundamental, "Text style for app title on splash screen");
  static const styleScreenTitle = AFThemeID("style_screen_title", tagFundamental, "Text style for screen title");
  static const styleMajorCardTitle = AFThemeID("style_major_card_title", tagFundamental, "Text style for a major heading in a card title");
  static const styleCardBodyNormal = AFThemeID("style_card_body_normal", tagFundamental, "Text style for normal card body text");
  static const styleCardBodyBold = AFThemeID("style_card_body_bold", tagFundamental, "Text style for bold card body text");
  static const styleCardBodyTapable = AFThemeID("style_card_body_tapable", tagFundamental, "Text style for card body tapable");
  static const styleCardBodyMuted = AFThemeID("style_card_body_muted", tagFundamental, "Text style for card body muted");
    

  /// Used in prototype mode to override the system brightness.  Shouldn't generally be used in production.
  static const brightness = AFThemeID("brightness", tagDeviceOverride, "Brightness");
  static const alwaysUse24HourFormat = AFThemeID("always_use_24_hour_format", tagDeviceOverride, "Always use 24 hour format");
  static const locale = AFThemeID("locale", tagDeviceOverride, "Locale");
  static const textScaleFactor = AFThemeID("text_scale_factor", tagDeviceOverride, "Text scale factor");

  static const Locale localeDefault = Locale('en', 'US');

}

/// Language translation ids used in the afib prototype screens.
class AFPrototypeLangID {
  static final prototypeTag = "${AFUIID.afibIDPrefix}prototype";
}
