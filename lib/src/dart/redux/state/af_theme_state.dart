
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

/// A summary of colors used to make adjusting to dark mode easier.
/// 
/// You can register one of these, and then automatically get the 
/// correct color with [AFConcpetualTheme.colorForeground] and
/// [AFConceptualTheme.colorBackground]
class AFColorScheme extends AFThemeResolvableValue {
  final AFThemeID foreground;
  final AFThemeID background;
  final AFThemeID foregroundDarkMode;
  final AFThemeID backgroundDarkMode;

  Color foregroundCache;
  Color backgroundCache;  
  Color foregroundDarkModeCache;
  Color backgroundDarkModeCache;

  AFColorScheme({
    @required this.foreground,
    @required this.background,
    @required this.foregroundDarkMode,
    @required this.backgroundDarkMode,
  });

  
  

  Color forgroundColor(Brightness brightness) {
    return (brightness == Brightness.light) ? foregroundCache : foregroundDarkModeCache;
  }

  Color backgroundColor(Brightness brightness) {
    return (brightness == Brightness.light) ? backgroundCache : backgroundDarkModeCache;
  }

  void resolve(AFFundamentalTheme theme) {
    foregroundCache = theme.color(foreground);
    backgroundCache = theme.color(background);
    foregroundDarkModeCache = theme.color(foregroundDarkMode);
    backgroundDarkModeCache = theme.color(backgroundDarkMode);
  }
}

/// Allows different parties to contribute fundamental values
/// to a theme which are can be manipulated via the prototype 
/// drawer.
@immutable
class AFFundamentalThemeArea with AFThemeAreaUtilties {
  final Map<AFThemeID, AFFundamentalThemeValue> values;
  final Map<Locale, AFTranslationSet> translationSet;

  AFFundamentalThemeArea({
    @required this.values, 
    @required this.translationSet,
  });

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
  double size(AFThemeID id, { double scale = 1.0 }) {
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

  TextStyle textStyle(dynamic idOrTextStyle) {
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

  FontWeight weight(AFThemeID id) {
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
    } else if(val is AFColorScheme) {
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
    } else if(val is AFColorScheme) {
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

  Color color(AFThemeID id) {
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

  AFColorScheme colors(AFThemeID id) {
    final val = value(id);
    var result;
    if(val is AFColorScheme) {
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

  Color lighterColor(AFThemeID id, { int percent = 10 }) {
    final c = color(id);
    if(c == null) {
      throw AFException("$id must be a valid color");
    }
    return brighten(c, percent);
  }

  dynamic value(AFThemeID id);
  String translation(String idOrText, Locale locale);  

  void _throwUnsupportedType(AFThemeID id, dynamic val) {
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
  bool hasSetFundamentals = false;
  /// The app must call this method to establish some fundamental theme values that both 
  /// flutter and AFib expect.  
  /// 
  /// Values which are not specified will be derived intelligently.
  void setFundamentals({
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
    @required double sizeBodyText,
    double sizeMargin = 8.0,
    double sizeAppTitle,
    double sizeScreenTitle,
    double sizeHeadingMajor,
    double sizeHeadingMinor,
    double sizeTinyText,
    FontWeight weightNormal = FontWeight.normal,
    FontWeight weightBold = FontWeight.bold,
    AFColorScheme colorsSplashScreen,
    AFColorScheme colorsScreenTitle,
    AFColorScheme colorsAppBackground,
    AFColorScheme colorsCardTitle,
    AFColorScheme colorsCardBody,
    AFColorScheme colorsDrawerTitle,
    AFColorScheme colorsDrawerBody,
    AFColorScheme colorsBottomBar,
    AFColorScheme colorsActionButton,
    dynamic styleAppTitleSplash,
    dynamic styleScreenTitle,
    dynamic styleCardBodyNormal,
    dynamic styleCardBodyBold,
  }) {
    hasSetFundamentals = true;

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


  AFColorScheme defaultColors(AFThemeID b, AFThemeID f, AFThemeID bd, AFThemeID fd) {
    return AFColorScheme(
      foreground: f,
      background: b,
      foregroundDarkMode: fd,
      backgroundDarkMode: bd,
    );
  }


  AFFundamentalThemeArea create() {
    validate();
    return AFFundamentalThemeArea(values: this.values, translationSet: translationSet);
  }

  @override 
  void validate() {
    if(!hasSetFundamentals) {
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
  final ThemeData themeData;
  
  AFFundamentalTheme({
    @required this.device,
    @required this.area,
    @required this.themeData
  });    

  String translate(dynamic idOrText) {
    return area.translate(idOrText, device.locale(this));
  }

  /// Used for flags that determine UI layout.  For example, maybe a 'compact' vs 'spacious' flag.
  int flag(AFThemeID id) {
    return area.flag(id);
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

  /// A utikity for creating a list of widgets in a column.
  /// 
  /// This allows for a reasonable syntax like:
  /// ```dart
  /// final rows = context.t.column();
  /// ```
  List<Widget> column() { return <Widget>[]; }

  /// Whether the device is in light or dark mode.
  Brightness get brightness { 
    return fundamentals.device.brightness(fundamentals);
  }

  /// Whether times should use a 24 hour format.
  bool get alwaysUse24HourFormat {
    return fundamentals.device.alwaysUse24HourFormat(fundamentals);
  }

  /// Translate the specified string id and return it.
  /// 
  /// See also [textBuilder] and [richTextBuilder]
  String translate(dynamic textOrId) {
    return fundamentals.translate(textOrId);
  }

  AFRichTextBuilder createRichTextBuilder({
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

  AFTextBuilder createTextBuilder({
    AFWidgetID wid,
    dynamic idOrTextStyle = AFFundamentalThemeID.styleCardBodyNormal,
  }) {
    final style = idOrTextStyle != null ? textStyle(idOrTextStyle) : null;
    return AFTextBuilder(
      theme: fundamentals,
      wid: wid,
      style: style
    );
  }


  Text createText(AFWidgetID wid, dynamic textOrLangID, dynamic styleOrStyleId) {
    final text = translate(textOrLangID);
    final style = textStyle(styleOrStyleId);
    return Text(text, 
      key: keyForWID(wid),
      style: style,
      textScaleFactor: textScaleFactor,
    );
  }

  /// The locale for the device.
  /// 
  /// See also the [translate] function.
  Locale get locale {
    return fundamentals.device.locale(fundamentals);
  }

  /// The physical size of the screen.
  /// 
  /// This value updates automatically when the
  /// device switches from landscape to portrait.
  Size get physicalSize {
    return fundamentals.device.physicalSize;
  }

  /// The text scale factor for the device.
  double get textScaleFactor {
    return fundamentals.device.textScaleFactor(fundamentals);
  }

  /// See Flutter [Window]
  WindowPadding get padding {
    return fundamentals.device.padding;
  }

  /// See Flutter [Window]
  WindowPadding get viewInsets {
    return fundamentals.device.viewInsets;
  }
  
  /// See Flutter [Window]
  WindowPadding get viewPadding {
    return fundamentals.device.viewPadding;
  }
  
  /// Returns a unique key for the specified widget.
  Key keyForWID(AFWidgetID wid) {
    return AFUI.keyForWID(wid);
  }

  Color color(AFThemeID id) {
    return fundamentals.color(id);
  }

  TextStyle textStyle(dynamic idOrTextStyle) {
    return fundamentals.textStyle(idOrTextStyle);
  }

  double size(AFThemeID id, { double scale = 1.0 }) {
    return fundamentals.size(id, scale: scale);
  }

  double get margin { 
    return fundamentals.size(AFFundamentalThemeID.sizeMargin);
  }

  /// Important: the values you are passing in are scale factors on the
  /// value specified by [AFFundamentalThemeID.sizeMargin], they are not
  /// absolute measurements.
  /// 
  /// For example, if the default margin is 8.0, and you pass in all: 2,
  /// you will get 16 all the way around.
  EdgeInsets scaledPaddingInsets({
    double horizontal,
    double vertical,
    double top,
    double bottom,
    double left,
    double right,
    double all
  }) {
    return scaledMarginInsets(
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
  EdgeInsets scaledMarginInsets({
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