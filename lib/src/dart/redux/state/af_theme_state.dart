
import 'dart:ui';

import 'package:afib/afib_dart.dart';
import 'package:afib/afib_flutter.dart';
import 'package:afib/src/dart/utils/af_id.dart';
import 'package:afib/src/flutter/core/afui.dart';
import 'package:afib/src/flutter/theme/af_text_builders.dart';
import 'package:flutter/material.dart';

/// Consolidating base class for [AFFundamentalTheme] and [AFConceptualTheme]
class AFTheme {

}

/// These are fundamental values for theming derived from the device
/// and operating system itself.
class AFFundamentalDeviceTheme {
  final Brightness brightnessValue;
  final bool alwaysUse24HourFormatValue;
  final WindowPadding padding;
  final WindowPadding viewInsets;
  final WindowPadding viewPadding;
  final Locale localeValue;
  final Size physicalSize;
  final double textScaleFactorValue;

  AFFundamentalDeviceTheme({
    @required this.brightnessValue,
    @required this.alwaysUse24HourFormatValue,
    @required this.padding,
    @required this.viewInsets,
    @required this.viewPadding,
    @required this.localeValue,
    @required this.physicalSize,
    @required this.textScaleFactorValue,
  });

  factory AFFundamentalDeviceTheme.create() {
    final window = WidgetsBinding.instance.window;
    final brightness = window.platformBrightness;
    final alwaysUse24 = window.alwaysUse24HourFormat;
    final padding = window.padding;
    final viewInsets = window.viewInsets;
    final viewPadding = window.viewPadding;
    final locale = window.locale;
    final physicalSize = window.physicalSize;
    final textScaleFactor = window.textScaleFactor;
    return AFFundamentalDeviceTheme(
      brightnessValue: brightness,
      alwaysUse24HourFormatValue: alwaysUse24,
      padding: padding,
      viewInsets: viewInsets,
      viewPadding: viewPadding,
      localeValue: locale,
      physicalSize: physicalSize,
      textScaleFactorValue: textScaleFactor
    );
  }

  Brightness brightness(AFFundamentalTheme fundamentals) {
    Brightness b = fundamentals.findValue(AFFundamentalThemeID.brightness);
    return b ?? brightnessValue;
  }

  bool alwaysUse24HourFormat(AFFundamentalTheme fundamentals) {
    bool b = fundamentals.findValue(AFFundamentalThemeID.alwaysUse24HourFormat);
    return b ?? alwaysUse24HourFormatValue;
  }

  Locale locale(AFFundamentalTheme fundamentals) {
    Locale l = fundamentals.findValue(AFFundamentalThemeID.locale);
    return l ?? localeValue;
  }

  double textScaleFactor(AFFundamentalTheme fundamentals) {
    double ts = fundamentals.findValue(AFFundamentalThemeID.textScaleFactor);
    return ts ?? textScaleFactorValue;
  }
}

/// A value which can be exposed to and edited by the
/// theme 
class AFFundamentalThemeValue {
  final AFThemeID id;
  final dynamic value;

  AFFundamentalThemeValue({
    @required this.id,
    @required this.value,
  });  
}

/// A theme value that refers to other values, and needs to be resolved 
/// at the end of the theme creation process.
abstract class AFThemeResolvableValue {
  void resolve(AFFundamentalTheme theme);
}

/// A summary of a text style composed from other theme components.
class AFTextStyle extends AFThemeResolvableValue {
  final AFThemeID color;
  final AFThemeID fontSize;
  final AFThemeID weight;

  TextStyle styleCache;

  AFTextStyle({
    @required this.color,
    @required this.fontSize,
    this.weight = AFFundamentalThemeID.weightNormal,
  });

  void resolve(AFFundamentalTheme theme) {
    final c = theme.foreground(color);
    final fs = theme.size(fontSize);
    final fw = theme.weight(weight);
    styleCache = TextStyle(
      color: c,
      fontSize: fs,
      fontWeight: fw,
    );
  }
}

/// A pairing of each color and its dark mode variant.
class AFColor extends AFThemeResolvableValue {
  final AFThemeID colorLight;
  final AFThemeID colorDark;

  Color colorLightCache;
  Color colorDarkCache;

  AFColor({
    @required this.colorLight,
    @required this.colorDark,
  });

  factory AFColor.createWithOne(AFThemeID color) {
    return AFColor(colorLight: color, colorDark: color);
  }

  Color color(Brightness brightness) { return brightness == Brightness.light ? colorLightCache : colorDarkCache; }

  void resolve(AFFundamentalTheme theme) {
    colorLightCache = theme.color(colorLight);
    colorDarkCache = theme.color(colorDark);
  }

} 

/// A pairing of [AFColor] for foreground and background.
/// 
/// You can register one of these, and then automatically get the 
/// correct color with [AFConceptualTheme.colorForeground] and
/// [AFConceptualTheme.colorBackground]
class AFColorPairing extends AFThemeResolvableValue {
  final AFColor foreground;
  final AFColor background;

  AFColorPairing({
    @required this.foreground,
    @required this.background,
  });

  Color forgroundColor(Brightness brightness) {
    return foreground.color(brightness);
  }

  Color backgroundColor(Brightness brightness) {
    return background.color(brightness);
  }

  void resolve(AFFundamentalTheme theme) {
    foreground.resolve(theme);
    background.resolve(theme);
  }
}

/// Allows different parties to contribute fundamental values
/// to a theme which are can be manipulated via the prototype 
/// drawer.
@immutable
class AFFundamentalThemeArea with AFThemeAreaUtilties {
  final ThemeData themeLight;
  final ThemeData themeDark;
  final Map<AFThemeID, AFFundamentalThemeValue> values;
  final Map<Locale, AFTranslationSet> translationSet;

  AFFundamentalThemeArea({
    @required this.themeLight,
    @required this.themeDark,
    @required this.values, 
    @required this.translationSet,
  });

  ThemeData themeData(Brightness brightness) {
    return brightness == Brightness.light ? themeLight : themeDark;
  }

  String translate(String idOrText, Locale locale) {
    var result = translation(idOrText, locale);
    if(result == null) {
      result = idOrText;
    }
    return result;
  }

  dynamic value(AFThemeID id) {
    return values[id]?.value;
  }

  String translation(String textOrId, Locale locale) {
    var setT = translationSet[locale];
    if(setT == null) {
      setT = translationSet[AFFundamentalThemeID.localeDefault];
    }
    if(setT == null) {
      return textOrId;
    }
    return setT.translate(textOrId);
  }

  dynamic findValue(AFThemeID id) {
    final val = values[id];
    if(val != null) {
      return val.value;
    }
    return null;
  }
}

class AFTranslationSet {
  final translations = <dynamic, String>{};

  void setTranslations(Map<dynamic, String> source) {
    source.forEach((key, text) {
      if(!translations.containsKey(key)) {
        translations[key] = text;
      }
    });
  }

  String translate(dynamic textOrId) {
    var result = translations[textOrId];
    if(result == null) {
      if(textOrId is String) {
        return textOrId;
      }
      throw AFException("Unknown translation $textOrId");
    }
    return result;
  }
}

class AFPluginFundamentalThemeAreaBuilder {
  final values = <AFThemeID, AFFundamentalThemeValue>{};
  final translationSet = <Locale, AFTranslationSet>{};

    
  /// Set a fundamental value.
  /// 
  /// If the value exists, it is not overwritten.  Because the app
  /// populates the builder first, this allows the app to override
  /// values for plugins.
  void setValue(AFThemeID id, dynamic value, {
    AFCreateDynamicDelegate defaultCalculation,
    bool notNull = true
  }) {
    if(!values.containsKey(id)) {
      if(value == null) {
        value = defaultCalculation();
      }
      if(notNull && value == null) {
        throw AFException("Value for $id cannot be null");
      }
      values[id] = AFFundamentalThemeValue(id: id, value: value);
    }
  }

  /// Use to set multiple values, usually from a statically
  /// declared map.
  /// 
  /// If the value exists, it is not over written.  Because the app
  /// populates the builder first, this allows the app to override
  /// values for plugins.
  void setValues(Map<AFThemeID, dynamic> toSet) {
    toSet.forEach((id, val) {
      values[id] = AFFundamentalThemeValue(id: id, value: val);
    });
  }

  void setTranslations(Locale locale, Map<String, String> translations) {
    var setT = translationSet[locale];
    if(setT == null) {
      setT = AFTranslationSet();
      translationSet[locale] = setT;
    }
    setT.setTranslations(translations);
  }

  void validate() {
  }
}

mixin AFThemeAreaUtilties {
  double size(dynamic id, { double scale = 1.0 }) {
    if(id == null) {
      return null;
    }
    if(id is double) {
      return id;
    }
    final val = value(id);
    var number;
    if(val is double) {
      number = val;
    } else if(val is TextStyle) {
      number = val.fontSize;
    } else {
      _throwUnsupportedType(id, val);
    }
    return number * scale;
  }

  Widget icon(dynamic idOrIcon, {
    dynamic iconColor, 
    dynamic iconSize
  }) { 
    if(idOrIcon is Widget) {
      return idOrIcon;
    }
    final val = value(idOrIcon);
    if(val is Widget) {
      return val;
    } else if(val is IconData) {
      final c = color(iconColor);
      final s = size(iconSize);

      return Icon(
        val,
        size: s,
        color: c
      );
    } else {
      _throwUnsupportedType(idOrIcon, val);
    }
    return null;
  }


  TextStyle textStyle(dynamic idOrTextStyle) {
    if(idOrTextStyle == null) {
      return null;
    }
    if(idOrTextStyle is TextStyle) {
      return idOrTextStyle;
    }
    final val = value(idOrTextStyle);
    var result;
    if(val is TextStyle) {
      result = val;
    } else if(val is AFTextStyle) {
      result = val.styleCache;
    } else {
      _throwUnsupportedType(idOrTextStyle, val);
    }
    return result;
  }

  FontWeight weight(dynamic id) {
    if(id is FontWeight) {
      return id;
    }
    final val = value(id);
    var result;
    if(val is FontWeight) {
      result = val;
    } else {
      _throwUnsupportedType(id, val);
    }
    return result;
  }

  Color foreground(AFThemeID id, Brightness brightness) {
    final val = value(id);
    var color;
    if(val is Color) {
      color = val;
    } else if(val is TextStyle) {
      color = val.color;
    } else if(val is AFColorPairing) {
      color = val.forgroundColor(brightness);
    } else {
      _throwUnsupportedType(id, val);
    }
    return color;
  }

  Color background(AFThemeID id, Brightness brightness) {
    final val = value(id);
    var color;
    if(val is Color) {
      color = val;
    } else if(val is TextStyle) {
      color = val.color;
    } else if(val is AFColorPairing) {
      color = val.backgroundColor(brightness);
    } else {
      _throwUnsupportedType(id, val);
    }
    return color;
  }

  String translate(String idOrText, Locale locale) {
    var result = translation(idOrText, locale);
    if(result == null) {
      result = idOrText;
    }
    return result;
  }

  int flag(AFThemeID id) {
    final val = value(id);
    var result;
    if(val is int) {
      result = val;
    } else {
      _throwUnsupportedType(id, val);      
    }
    return result;
  }

  Color color(dynamic id) {
    if(id is Color) {
      return id;
    }
    if(id == null) {
      return null;
    }
    final val = value(id);
    var color;
    if(val is Color) {
      color = val;
    } else if(val is TextStyle) {
      color = val.color;
    } else {
      _throwUnsupportedType(id, val);
    }
    return color;
  }

  AFColorPairing colors(AFThemeID id) {
    final val = value(id);
    var result;
    if(val is AFColorPairing) {
      result = val;
    } else {
      _throwUnsupportedType(id, val);
    }
    return result;
  }

  Color darkerColor(AFThemeID id, { int percent = 10 }) {
    final c = color(id);
    if(c == null) {
      throw AFException("$id must be a valid color");
    }
    return darken(c, percent);    
  }

  Color lighterColor(dynamic id, { int percent = 10 }) {
    final c = color(id);
    if(c == null) {
      throw AFException("$id must be a valid color");
    }
    return brighten(c, percent);
  }

  dynamic value(AFThemeID id);
  String translation(String idOrText, Locale locale);  

  void _throwUnsupportedType(dynamic id, dynamic val) {
    throw AFException("In fundamental theme, $id has unsupported type ${val.runtimeType}");
  }

  Color darken(Color c, int percent) {
    assert(1 <= percent && percent <= 100);
    var f = 1 - percent / 100;
    return Color.fromARGB(
        c.alpha,
        (c.red * f).round(),
        (c.green  * f).round(),
        (c.blue * f).round()
    );
  }

  Color brighten(Color c, int percent) {
      assert(1 <= percent && percent <= 100);
      var p = percent / 100;
      return Color.fromARGB(
          c.alpha,
          c.red + ((255 - c.red) * p).round(),
          c.green + ((255 - c.green) * p).round(),
          c.blue + ((255 - c.blue) * p).round()
      );
  }
}

class AFAppFundamentalThemeAreaBuilder extends AFPluginFundamentalThemeAreaBuilder with AFThemeAreaUtilties {
  ThemeData themeLight;
  ThemeData themeDark;
  
  /// The app must call this method, or [setFundamentalThemeData] in order
  /// to establish the basic theme of the app.
  void setFundamentals({
    ColorScheme colorSchemeLight,
    ColorScheme colorSchemeDark,
    TextTheme textTheme,
  }) {
    themeLight = ThemeData.from(colorScheme: colorSchemeLight, textTheme: textTheme);
    themeDark = ThemeData.from(colorScheme: colorSchemeDark, textTheme: textTheme);
  }

  /// Most apps should use [setFundamentals], but this method gives you more control
  /// to create the theme data exactly as you wish.
  void setFundamentalThemeData({
    ThemeData themeLight,
    ThemeData themeDark
  }) {
    this.themeLight = themeLight;
    this.themeDark = themeDark;
  }

  /// The app must call this method to establish some fundamental theme values that both 
  /// flutter and AFib expect.  
  /// 
  /// Values which are not specified will be derived intelligently.
  void setFundamentalsOld({
    @required Color colorPrimary,
    @required Color colorPrimaryForeground,
    Color colorPrimaryDarkMode,
    Color colorPrimaryForegroundDarkMode,
    int lighterPercent = 30,
    int darkerPercent = 30,
    Color colorPrimaryDarker,
    Color colorPrimaryLighter,
    @required Color colorSecondary,
    Color colorSecondaryDarker,
    Color colorSecondaryLighter,
    Color colorCardBody,
    Color colorCardBodyForeground,
    Color colorCardBodyDarkMode,
    Color colorCardBodyForegroundDarkMode,
    Color colorTapable = Colors.blueAccent,
    Color colorTapableDarkMode,
    Color colorMuted = Colors.grey,
    Color colorMutedDarkMode,
    Color colorDrawerTitle,
    @required double sizeBodyText,
    double sizeMargin = 8.0,
    double sizeAppTitle,
    double sizeScreenTitle,
    double sizeHeadingMajor,
    double sizeHeadingMinor,
    double sizeTinyText,
    FontWeight weightNormal = FontWeight.normal,
    FontWeight weightBold = FontWeight.bold,
    AFColorPairing colorsSplashScreen,
    AFColorPairing colorsScreenTitle,
    AFColorPairing colorsAppBackground,
    AFColorPairing colorsCardTitle,
    AFColorPairing colorsCardBody,
    AFColorPairing colorsDrawerTitle,
    AFColorPairing colorsDrawerBody,
    AFColorPairing colorsBottomBar,
    AFColorPairing colorsActionButton,
    dynamic styleAppTitleSplash,
    dynamic styleScreenTitle,
    dynamic styleCardBodyNormal,
    dynamic styleCardBodyBold,
    IconData iconBack = Icons.arrow_back,
    IconData iconNavDown = Icons.chevron_right,
  }) {

    // colors.
    setValue(AFFundamentalThemeID.colorPrimary, colorPrimary);
    setValue(AFFundamentalThemeID.colorPrimaryDarkMode, colorPrimaryDarkMode, defaultCalculation: () => Colors.black);
    setValue(AFFundamentalThemeID.colorPrimaryForeground, colorPrimaryForeground);
    setValue(AFFundamentalThemeID.colorPrimaryForegroundDarkMode, colorPrimaryForegroundDarkMode, defaultCalculation: () => color(AFFundamentalThemeID.colorPrimaryForeground));
    setValue(AFFundamentalThemeID.colorPrimaryDarker, colorPrimaryDarker, defaultCalculation: () => darkerColor(AFFundamentalThemeID.colorPrimary, percent: lighterPercent));
    setValue(AFFundamentalThemeID.colorPrimaryLighter, colorPrimaryLighter, defaultCalculation: () => lighterColor(AFFundamentalThemeID.colorPrimary, percent: darkerPercent));
    setValue(AFFundamentalThemeID.colorSecondary, colorSecondary);
    setValue(AFFundamentalThemeID.colorSecondaryDarker, colorSecondaryDarker, defaultCalculation: () => darkerColor(AFFundamentalThemeID.colorSecondary, percent: lighterPercent));
    setValue(AFFundamentalThemeID.colorSecondaryLighter, colorSecondaryLighter, defaultCalculation: () => lighterColor(AFFundamentalThemeID.colorSecondary, percent: darkerPercent));

    setValue(AFFundamentalThemeID.colorTapable, colorTapable);
    setValue(AFFundamentalThemeID.colorMuted, colorMuted);
    setValue(AFFundamentalThemeID.colorTapableDarkMode, colorTapableDarkMode, defaultCalculation: () => colorTapable);
    setValue(AFFundamentalThemeID.colorMutedDarkMode, colorMutedDarkMode, defaultCalculation: () => colorMuted);


    setValue(AFFundamentalThemeID.colorCardBody, colorCardBody, defaultCalculation: () => Colors.white);
    setValue(AFFundamentalThemeID.colorCardBodyForeground, colorCardBodyForeground, defaultCalculation: () => Colors.black);
    setValue(AFFundamentalThemeID.colorCardBodyDarkMode, colorCardBodyDarkMode, defaultCalculation: () => Colors.black);
    setValue(AFFundamentalThemeID.colorCardBodyForegroundDarkMode, colorCardBodyForegroundDarkMode, defaultCalculation: () => Colors.white);

    // sizes.
    setValue(AFFundamentalThemeID.sizeBodyText, sizeBodyText);
    setValue(AFFundamentalThemeID.sizeAppTitle, sizeAppTitle, defaultCalculation: () => size(AFFundamentalThemeID.sizeBodyText, scale: 2.5));
    setValue(AFFundamentalThemeID.sizeScreenTitle, sizeScreenTitle, defaultCalculation: () => size(AFFundamentalThemeID.sizeBodyText, scale: 1.7));
    setValue(AFFundamentalThemeID.sizeHeadingMajor, sizeHeadingMajor, defaultCalculation: () => size(AFFundamentalThemeID.sizeBodyText, scale: 1.4));
    setValue(AFFundamentalThemeID.sizeHeadingMinor, sizeHeadingMinor, defaultCalculation: () => size(AFFundamentalThemeID.sizeBodyText, scale: 1.0));
    setValue(AFFundamentalThemeID.sizeTinyText, sizeTinyText, defaultCalculation: () => size(AFFundamentalThemeID.sizeBodyText, scale: 0.7));
    setValue(AFFundamentalThemeID.sizeMargin, sizeMargin, defaultCalculation: () => 8);

    // weights
    setValue(AFFundamentalThemeID.weightNormal, weightNormal);
    setValue(AFFundamentalThemeID.weightBold, weightBold);

    // icons
    setValue(AFFundamentalThemeID.iconBack, iconBack);
    setValue(AFFundamentalThemeID.iconNavDown, iconNavDown);

    // color themes
    setValue(AFFundamentalThemeID.colorsSplashScreen, colorsScreenTitle, 
      defaultCalculation: () => defaultColors(AFFundamentalThemeID.colorPrimary, AFFundamentalThemeID.colorPrimaryForeground, AFFundamentalThemeID.colorPrimaryDarkMode, AFFundamentalThemeID.colorPrimaryForegroundDarkMode));
    setValue(AFFundamentalThemeID.colorsScreenTitle, colorsScreenTitle, 
      defaultCalculation: () => colors(AFFundamentalThemeID.colorsSplashScreen));
    setValue(AFFundamentalThemeID.colorsCardBody, colorsCardBody, 
      defaultCalculation: () => defaultColors(AFFundamentalThemeID.colorCardBody, AFFundamentalThemeID.colorCardBodyForeground, AFFundamentalThemeID.colorCardBodyDarkMode, AFFundamentalThemeID.colorCardBodyForegroundDarkMode));

    // text styles
    setValue(AFFundamentalThemeID.styleAppTitleSplash, styleAppTitleSplash, 
      defaultCalculation: () => defaultTextStyle(AFFundamentalThemeID.colorsSplashScreen, AFFundamentalThemeID.sizeAppTitle, AFFundamentalThemeID.weightBold));
    setValue(AFFundamentalThemeID.styleScreenTitle, styleScreenTitle, 
      defaultCalculation: () => defaultTextStyle(AFFundamentalThemeID.colorsScreenTitle, AFFundamentalThemeID.sizeScreenTitle, AFFundamentalThemeID.weightBold));
    setValue(AFFundamentalThemeID.styleMajorCardTitle, styleAppTitleSplash, 
      defaultCalculation: () => defaultTextStyle(AFFundamentalThemeID.colorsSplashScreen, AFFundamentalThemeID.sizeHeadingMajor, AFFundamentalThemeID.weightBold));
    setValue(AFFundamentalThemeID.styleCardBodyNormal, styleCardBodyNormal, 
      defaultCalculation: () => defaultTextStyle(AFFundamentalThemeID.colorsCardBody, AFFundamentalThemeID.sizeBodyText, AFFundamentalThemeID.weightNormal));
    setValue(AFFundamentalThemeID.styleCardBodyBold, styleCardBodyBold, 
      defaultCalculation: () => defaultTextStyle(AFFundamentalThemeID.colorsCardBody, AFFundamentalThemeID.sizeBodyText, AFFundamentalThemeID.weightBold));
  }

  dynamic value(AFThemeID id) {
    return values[id]?.value;
  }

  String translation(dynamic idOrValue, Locale locale) {
    /// we shouldn't do translations at build time.
    throw UnimplementedError();
  }

  AFTextStyle defaultTextStyle(AFThemeID c, AFThemeID fs, AFThemeID fw) {
    return AFTextStyle(
      color: c,
      fontSize: fs,
      weight: fw
    );
  }

  AFColorPairing defaultColors(AFThemeID b, AFThemeID f, AFThemeID bd, AFThemeID fd) {
    return AFColorPairing(
      foreground: AFColor(colorLight: f, colorDark: fd),
      background: AFColor(colorLight: b, colorDark: bd),
    );
  }

  AFFundamentalThemeArea create() {
    validate();
    return AFFundamentalThemeArea(themeLight: themeLight, themeDark: themeDark, values: this.values, translationSet: translationSet);
  }

  @override 
  void validate() {
    if(themeLight == null || themeDark == null) {
      throw AFException("You must call setFundamentals in fundamental_theme.dart");
    }
  }
}


/// Fundamental values that contribute to theming in the app.
/// 
/// An [AFFundamentalTheme] provides fundamental values like
/// colors, fonts, and measurements which determine the basic
/// properties of the UI.   It is the place where you store
/// and manipulate data values that contribute to a them.
/// 
/// [AFConceptualTheme] doesn't have its own mutable data values,
/// instead it provides a functional wrapper that creates 
/// conceptual components in the UI based on the values in 
/// a fundamental theme.
@immutable
class AFFundamentalTheme {
  final AFFundamentalDeviceTheme device;
  final AFFundamentalThemeArea area;
  
  AFFundamentalTheme({
    @required this.device,
    @required this.area
  });    

  String translate(dynamic idOrText) {
    return area.translate(idOrText, device.locale(this));
  }

  ThemeData get themeData {
    return area.themeData(device.brightness(this));
  }

  /// Used for flags that determine UI layout.  For example, maybe a 'compact' vs 'spacious' flag.
  int flag(AFThemeID id) {
    return area.flag(id);
  }

  Color get colorPrimary {
    return themeData.colorScheme.primary;
  }

  Color get colorOnPrimary {
    return themeData.colorScheme.onPrimary;
  }

  Color get colorPrimaryVariant {
    return themeData.colorScheme.primaryVariant;
  }

  Color get colorSecondaryVariant {
    return themeData.colorScheme.secondaryVariant;
  }

  Color get colorBackground {
    return themeData.colorScheme.background;
  }

  Color get colorOnBackground {
    return themeData.colorScheme.onBackground;
  }

  Color get colorError {
    return themeData.colorScheme.error;
  }

  Color get colorOnError {
    return themeData.colorScheme.onError;
  }

  Color get colorSurface {
    return themeData.colorScheme.surface;
  }

  Color get colorOnSurface {
    return themeData.colorScheme.onSurface;
  }

  Color get colorPrimaryLight {
    return themeData.primaryColorLight;
  }

  Color get colorSecondary {
    return themeData.colorScheme.secondary;
  }

  /// This indicates whether this is a bright or dark color scheme,
  /// use [deviceBrightness] to find out the current mode of the device.
  /// 
  /// Note that the primary 'bright' color scheme could still be 'dark'
  /// in nature.
  Brightness get colorSchemeBrightness {
    return themeData.colorScheme.brightness;
  }

  TextTheme get textOnCard {
    return themeData.textTheme;
  }

  TextTheme get textOnPrimary {
    return themeData.primaryTextTheme;
  }

  TextTheme get textOnAccent {
    return themeData.accentTextTheme;
  }

  Color color(AFThemeID id) {
    return area.color(id);
  }

  Color foreground(AFThemeID id) {
    return area.foreground(id, device.brightness(this));
  }

  Color background(AFThemeID id) {
    return area.background(id, device.brightness(this));
  }

  double size(AFThemeID id, { double scale = 1.0 }) {
    return area.size(id, scale: scale);
  }

  Widget icon(dynamic idOrValue, {
    dynamic iconColor, 
    dynamic iconSize
  }) {
    return area.icon(idOrValue, iconColor: iconColor, iconSize: iconSize);
  }

  TextStyle textStyle(dynamic idOrTextStyle) {
    return area.textStyle(idOrTextStyle);
  }

  FontWeight weight(AFThemeID id) {
    return area.weight(id);
  } 

  dynamic findValue(AFThemeID id) {
    return area.findValue(id);
  }

  void resolve() {
    for(final val in area.values.values) {
      final item = val.value;
      if(item is AFThemeResolvableValue) {
        item.resolve(this);
      }
    }
  }

}

/// Conceptual themes are interfaces that provide UI theming
/// for conceptual componenets that are shared across many pages
/// in the app
/// 
/// For example, a conceptual theme would answer the question,
/// what does a 'primary button' look like, or what does a 
/// 'secondary button' look like.
/// 
/// An app will have at least one conceptual theme, but it might
/// split conceptual themes up into multiple areas (e.g. settings, 
/// signin, main app, etc).
/// 
/// Conceptual themes also provide a way for complex third party 
/// components (for example, an entire set of third party signin pages,
/// a map or audio/video component) to delegate theming decisions
/// to the app that contains them.
/// 
/// Each [AFConnectedWidget] is parmeterized with a conceptual theme
/// type, and that theme will be accessible via the context.theme and
/// context.t methods.
class AFConceptualTheme extends AFTheme {

  final AFFundamentalTheme fundamentals;
  AFConceptualTheme({
    @required this.fundamentals
  });

  /// A utility for creating a list of widgets in a row.   
  /// 
  /// This allows for a readable syntax like:
  /// ```dart
  /// final cols = context.t.row();
  /// ```
  List<Widget> row() { return <Widget>[]; }

  /// A utility for creating a list of widgets in a column.
  /// 
  /// This allows for a reasonable syntax like:
  /// ```dart
  /// final rows = context.t.column();
  /// ```
  List<Widget> column() { return <Widget>[]; }


  /// A utility for create a list of table rows in a table.
  List<TableRow> tableColumn() { return <TableRow>[]; }

  // The primary color from [ThemeData], adjusted for light/dark mode.
  Color get colorPrimary {
    return fundamentals.colorPrimary;
  }

  /// The foreground color on a primary background from [ThemeData]
  Color get colorOnPrimary {
    return fundamentals.colorOnPrimary;
  }

  Color get colorPrimaryVariant {
    return fundamentals.colorPrimaryVariant;
  }

  Color get colorSecondaryVariant {
    return fundamentals.colorSecondaryVariant;
  }

  Color get colorSurface {
    return fundamentals.colorSurface;
  }

  Color get colorBackground {
    return fundamentals.colorBackground;
  }

  Color get colorOnSurface {
    return fundamentals.colorOnSurface;
  }

  Color get colorOnBackground {
    return fundamentals.colorOnBackground;
  }

  Color get colorError {
    return fundamentals.colorError;
  }

  Color get colorOnError {
    return fundamentals.colorOnError;
  }

  Brightness get colorSchemeBrightness {
    return fundamentals.colorSchemeBrightness;
  }

  /// Whether the device is in light or dark mode.
  Brightness get brightness { 
    return fundamentals.device.brightness(fundamentals);
  }

  /// See [TextTheme], text theme to use on a card background
  TextTheme get textOnCard {
    return fundamentals.textOnCard;
  }

  /// See [TextTheme], text theme to use on a primary color background
  TextTheme get textOnPrimary {
    return fundamentals.textOnPrimary;
  }

  /// See [TextTheme], text theme to use on an accent color backgroun
  TextTheme get textOnAccent {
    return fundamentals.textOnAccent;
  }

  /// Whether times should use a 24 hour format.
  bool get alwaysUse24HourFormat {
    return fundamentals.device.alwaysUse24HourFormat(fundamentals);
  }

  /// Translate the specified string id and return it.
  /// 
  /// See also [textBuilder] and [richTextBuilder]
  String translate(dynamic text) {
    return fundamentals.translate(text);
  }

  AFRichTextBuilder richTextBuilder({
    AFWidgetID wid,
    dynamic idOrTextStyleNormal = AFFundamentalThemeID.styleCardBodyNormal,
    dynamic idOrTextStyleBold = AFFundamentalThemeID.styleCardBodyBold,
    dynamic idOrTextStyleTapable = AFFundamentalThemeID.styleCardBodyTapable,
    dynamic idOrTextStyleMuted = AFFundamentalThemeID.styleCardBodyMuted
  }) {
    final normal = idOrTextStyleNormal != null ? textStyle(idOrTextStyleNormal) : null;
    final bold = idOrTextStyleBold != null ? textStyle(idOrTextStyleBold) : null;
    final tapable = idOrTextStyleTapable != null ? textStyle(idOrTextStyleTapable) : null;
    final muted = idOrTextStyleMuted != null ? textStyle(idOrTextStyleMuted) : null;

    return AFRichTextBuilder(
      theme: fundamentals,
      wid: wid,
      normal: normal,
      bold: bold,
      tapable: tapable,
      muted: muted
    );
  }

  AFTextBuilder textBuilder({
    AFWidgetID wid,
    dynamic textStyle
  }) {
    final style = textStyle != null ? textStyle(textStyle) : null;
    return AFTextBuilder(
      theme: fundamentals,
      wid: wid,
      style: style
    );
  }


  Text text(dynamic text, {
    AFWidgetID wid, 
    dynamic style,
    dynamic textColor,
    dynamic size,
    TextAlign textAlign,
  }) {
    var styleS;
    if(textColor != null) {
      styleS = TextStyle(color: color(textColor));
    } else {
      styleS = textStyle(style);
    }
    final textT = translate(text);
    return Text(textT, 
      key: keyForWID(wid),
      style: styleS,
      textAlign: textAlign,
      textScaleFactor: deviceTextScaleFactor,
    );
  }


  /// The locale for the device.
  /// 
  /// See also the [translate] function.
  Locale get deviceLocale {
    return fundamentals.device.locale(fundamentals);
  }

  /// The physical size of the screen.
  /// 
  /// This value updates automatically when the
  /// device switches from landscape to portrait.
  Size get devicePhysicalSize {
    return fundamentals.device.physicalSize;
  }

  /// The text scale factor for the device.
  double get deviceTextScaleFactor {
    return fundamentals.device.textScaleFactor(fundamentals);
  }

  /// See Flutter [Window]
  WindowPadding get devicePadding {
    return fundamentals.device.padding;
  }

  /// See Flutter [Window]
  WindowPadding get deviceViewInsets {
    return fundamentals.device.viewInsets;
  }
  
  /// See Flutter [Window]
  WindowPadding get deviceViewPadding {
    return fundamentals.device.viewPadding;
  }
  
  /// Returns a unique key for the specified widget.
  Key keyForWID(AFWidgetID wid) {
    return AFUI.keyForWID(wid);
  }

  Color color(dynamic idOrColor) {
    if(idOrColor is Color) {
      return idOrColor;
    }
    return fundamentals.color(idOrColor);
  }

  Color foreground(dynamic idOrColor) {
    if(idOrColor is Color) {
      return idOrColor;
    }
    return fundamentals.foreground(idOrColor);
  }

  Color background(dynamic idOrColor) {
    if(idOrColor is Color) {
      return idOrColor;
    }
    return fundamentals.background(idOrColor);
  }

  TextStyle textStyle(dynamic idOrTextStyle) {
    if(idOrTextStyle is TextStyle) {
      return idOrTextStyle;
    }
    return fundamentals.textStyle(idOrTextStyle);
  }

  double size(AFThemeID id, { double scale = 1.0 }) {
    return fundamentals.size(id, scale: scale);
  }

  double get margin { 
    return fundamentals.size(AFFundamentalThemeID.sizeMargin);
  }

  Widget icon(dynamic id, {
    dynamic iconColor,
    dynamic iconSize
  }) {
    return fundamentals.icon(id, iconColor: iconColor, iconSize: iconSize);
  }

  Color get colorSecondary {
    return fundamentals.colorSecondary;
  }

  /// Important: the values you are passing in are scale factors on the
  /// value specified by [AFFundamentalThemeID.sizeMargin], they are not
  /// absolute measurements.
  /// 
  /// For example, if the default margin is 8.0, and you pass in all: 2,
  /// you will get 16 all the way around.
  EdgeInsets paddingScaled({
    double horizontal,
    double vertical,
    double top,
    double bottom,
    double left,
    double right,
    double all
  }) {
    return marginScaled(
      horizontal: horizontal,
      vertical: vertical,
      top: top,
      bottom: bottom,
      left: left,
      right: right,
      all: all
    );
  }

  /// Important: the values you are passing in are scale factors on the
  /// value specified by [AFFundamentalThemeID.sizeMargin], they are not
  /// absolute measurements.
  /// 
  /// For example, if the default margin is 8.0, and you pass in all: 2,
  /// you will get 16 all the way around.
  EdgeInsets marginScaled({
    double horizontal,
    double vertical,
    double top,
    double bottom,
    double left,
    double right,
    double all
  }) {
    final m = margin;
    var t = m;
    var b = m;
    var l = m;
    var r = m;
    if(all != null) {
      final ms = m*all;
      t = ms;
      b = ms;
      l = ms;
      r = ms;
    }
    if(vertical != null) {
      final ms = m*vertical;
      b = ms;
      t = ms;
    }
    if(horizontal != null) {
      final ms = m*horizontal;
      l = ms;
      r = ms;
    }
    if(top != null) {
      t = m*top;
    }
    if(bottom != null) {
      b = m*bottom;
    }
    if(left != null) {
      l = m*left;
    }
    if(right != null) {
      r = m*right;
    }

    return EdgeInsets.fromLTRB(l, t, r, b);
  }
    
  Widget standardBackButton(AFDispatcher dispatcher, {
    AFWidgetID wid = AFUIID.buttonBack,
    dynamic iconIdOrWidget = AFFundamentalThemeID.iconBack,
    dynamic iconColor,
    dynamic iconSize,
    String tooltip = "Back",
    AFShouldContinueCheckDelegate shouldContinueCheck,   
  }) {
    return IconButton(
        key: keyForWID(wid),      
        icon: icon(iconIdOrWidget, iconColor: iconColor, iconSize: iconSize),
        tooltip: translate(tooltip),
        onPressed: () async {
          if(shouldContinueCheck == null || await shouldContinueCheck() == AFFundamentalThemeID.shouldContinue) {
            dispatcher.dispatch(AFNavigatePopAction(id: wid));
          }
        }
    );
  }

}

/// Can be used as a template parameter when you don't want a theme.
class AFConceptualThemeUnused extends AFConceptualTheme {
  AFConceptualThemeUnused(AFFundamentalTheme fundamentals): super(fundamentals: fundamentals);
}


/// Captures the current state of the primary theme, and
/// any registered third-party themes.
class AFThemeState {
  final AFFundamentalTheme fundamentals;
  final Map<String, AFConceptualTheme> conceptuals;  

  AFThemeState({
    @required this.fundamentals,
    @required this.conceptuals
  });

  AFConceptualTheme findByType(Type t) {
    final key = _keyFor(t);
    return conceptuals[key];
  }

  factory AFThemeState.create({
    AFFundamentalTheme fundamentals,
    List<AFConceptualTheme> conceptuals
  }) {
    final map = <String, AFConceptualTheme>{};

    for(final conceptual in conceptuals) {
      final key = _keyFor(conceptual);
      if(!map.containsKey(key)) {
        map[key] = conceptual;
      }
    }

    return AFThemeState(
      fundamentals: fundamentals,
      conceptuals: map
    );
  }

  static String _keyFor(dynamic theme) {
    if(theme is Type) {
      return theme.toString();
    }
    return theme.runtimeType.toString();
  }
}