
import 'dart:async';
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

  dynamic findDeviceValue(AFThemeID id) {
    if(id == AFUIThemeID.brightness) {
      return this.brightnessValue;
    } else if(id == AFUIThemeID.alwaysUse24HourFormat) {
      return this.alwaysUse24HourFormatValue;
    } else if(id == AFUIThemeID.textScaleFactor) {
      return this.textScaleFactorValue;
    } else if(id == AFUIThemeID.locale) {
      return this.localeValue;
    } else if(id == AFUIThemeID.physicalSize) {
      return this.physicalSize;
    }
    throw AFException("Unknown device theme value: $id");
  }

  Brightness brightness(AFFundamentalTheme fundamentals) {
    Brightness b = fundamentals.findValue(AFUIThemeID.brightness);
    return b ?? brightnessValue;
  }

  bool alwaysUse24HourFormat(AFFundamentalTheme fundamentals) {
    bool b = fundamentals.findValue(AFUIThemeID.alwaysUse24HourFormat);
    return b ?? alwaysUse24HourFormatValue;
  }

  Locale locale(AFFundamentalTheme fundamentals) {
    Locale l = fundamentals.findValue(AFUIThemeID.locale);
    return l ?? localeValue;
  }

  double textScaleFactor(AFFundamentalTheme fundamentals) {
    double ts = fundamentals.findValue(AFUIThemeID.textScaleFactor);
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
    this.weight,
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
  final Map<AFThemeID, AFFundamentalThemeValue> overrides;
  final Map<AFThemeID, List<dynamic>> optionsForType;

  AFFundamentalThemeArea({
    @required this.themeLight,
    @required this.themeDark,
    @required this.values, 
    @required this.translationSet,
    @required this.overrides,
    @required this.optionsForType,
  });

  AFFundamentalThemeArea reviseOverrideThemeValue(AFThemeID id, dynamic value) {
    final revised = Map<AFThemeID, AFFundamentalThemeValue>.from(overrides);
    revised[id] = AFFundamentalThemeValue(id: id, value: value);
    return copyWith(
      overrides: revised
    );
  }

  AFFundamentalThemeArea copyWith({
    ThemeData themeLight,
    ThemeData themeDark,
    Map<AFThemeID, AFFundamentalThemeValue> values,
    Map<Locale, AFTranslationSet> translationSet,
    Map<AFThemeID, AFFundamentalThemeValue> overrides,
  }) {
    return AFFundamentalThemeArea(
      themeLight: themeLight ?? this.themeLight,
      themeDark: themeDark ?? this.themeDark,
      values: values ?? this.values,
      translationSet: translationSet ?? this.translationSet,
      overrides: overrides ?? this.overrides,
      optionsForType: this.optionsForType,
    );
  }

  List<String> get areaList {
    final map = <String, bool>{};
    for(final val in this.values.values) {
      map[val.id.tag] = true;
    }
    final result = map.keys.toList();
    result.insert(0, AFUIThemeID.tagDevice);
    return result;
  }

  List<AFThemeID> attrsForArea(String area) {
    final result = <AFThemeID>[];
    for(final val in this.values.values) {
      if(val.id.tag == area) {
        result.add(val.id);
      }
    }

    if(area == AFUIThemeID.tagDevice) {
      result.add(AFUIThemeID.brightness);
      result.add(AFUIThemeID.alwaysUse24HourFormat);
      result.add(AFUIThemeID.textScaleFactor);
      result.add(AFUIThemeID.locale);
    }
    return result;
  }

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
      setT = translationSet[AFUIThemeID.localeDefault];
    }
    if(setT == null) {
      return textOrId;
    }
    return setT.translate(textOrId);
  }

  dynamic findValue(AFThemeID id) {
    var val = overrides[id];
    if(val == null) {
      val = values[id];
    }
    return val?.value;
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
  Map<AFThemeID, List<dynamic>> optionsForType;

  AFPluginFundamentalThemeAreaBuilder(
    this.optionsForType
  );

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

  /// Used to specify a list of string values that can be selected
  /// in the test drawer/theme panel for a given AFThemeID.
  void setOptionsForType(AFThemeID id, List<dynamic> values) {
    optionsForType[id] = values;
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
    if(id == null ) {
      return null;
    }
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

  AFAppFundamentalThemeAreaBuilder({
    @required Map<AFThemeID, List<dynamic>> optionsForType
  }): super(optionsForType);

  factory AFAppFundamentalThemeAreaBuilder.create() {
    final options = <AFThemeID, List<dynamic>>{};
    options[AFUIThemeID.brightness] = Brightness.values;
    return AFAppFundamentalThemeAreaBuilder(optionsForType: options);
  }
  
  /// The app must call this method, or [setFundamentalThemeData] in order
  /// to establish the basic theme of the app.
  void setFlutterFundamentals({
    ColorScheme colorSchemeLight,
    ColorScheme colorSchemeDark,
    TextTheme textTheme,
  }) {
    themeLight = ThemeData.from(colorScheme: colorSchemeLight, textTheme: textTheme);
    themeDark = ThemeData.from(colorScheme: colorSchemeDark, textTheme: textTheme);
  }

  /// Most apps should use [setFlutterFundamentals], but this method gives you more control
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
  void setAfibFundamentals({
    double margin = 8.0,
    IconData iconBack = Icons.arrow_back,
    IconData iconNavDown = Icons.chevron_right,
  }) {
    // icons
    setValue(AFUIThemeID.sizeMargin, margin);
    setValue(AFUIThemeID.iconBack, iconBack);
    setValue(AFUIThemeID.iconNavDown, iconNavDown);
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
    return AFFundamentalThemeArea(
      themeLight: themeLight, 
      themeDark: themeDark, 
      values: this.values, 
      translationSet: translationSet,
      overrides: <AFThemeID, AFFundamentalThemeValue>{},
      optionsForType: optionsForType,
    );
  }

  @override 
  void validate() {
    if(themeLight == null || themeDark == null) {
      throw AFException("You must call setFlutterFundamentals in fundamental_theme.dart");
    }
    if(values.isEmpty) {
      throw AFException("You must call setAFibFundamentals in fundamental_theme.dart");
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

  List<dynamic> optionsForType(AFThemeID id) {
    return area.optionsForType[id];
  }

  AFFundamentalTheme reviseOverrideThemeValue(AFThemeID id, dynamic value) {

    return copyWith(
      device: device,
      area: area.reviseOverrideThemeValue(id, value)
    );
  }

  AFFundamentalTheme copyWith({
    AFFundamentalDeviceTheme device,
    AFFundamentalThemeArea area,
  }) {
    return AFFundamentalTheme(
      area: area ?? this.area,
      device: device ?? this.device
    );
  }

  String translate(dynamic idOrText) {
    return area.translate(idOrText, device.locale(this));
  }

  ThemeData get themeData {
    return area.themeData(device.brightness(this));
  }

  List<String> get areaList {
    return area.areaList;
  }

  List<AFThemeID> attrsForArea(String area) {
    return this.area.attrsForArea(area);
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

  TextTheme get styleOnCard {
    return themeData.textTheme;
  }

  TextTheme get styleOnPrimary {
    return themeData.primaryTextTheme;
  }

  TextTheme get styleOnAccent {
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

  FontWeight weight(dynamic id) {
    return area.weight(id);
  } 

  dynamic findValue(AFThemeID id) {
    var result = area.findValue(id);
    if(result == null && id.tag == AFUIThemeID.tagDevice) {
      result = device.findDeviceValue(id);
    }
    return result;
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
  /// final cols = context.t.childrenRow();
  /// ```
  List<Widget> childrenRow() { return <Widget>[]; }

  /// A utility for creating a list of widgets in a column.
  /// 
  /// This allows for a reasonable syntax like:
  /// ```dart
  /// final rows = context.t.childrenColumn();
  /// ```
  List<Widget> childrenColumn() { return <Widget>[]; }


  /// A utility for creating a list of child widgets
  /// 
  /// This allows for a readable syntax like:
  /// ```dart
  /// final cols = context.t.children();
  /// ```
  List<Widget> children() { return <Widget>[]; }

  /// A utility for create a list of table rows in a table.
  List<TableRow> childrenTable() { return <TableRow>[]; }

  /// A utility for creating a list of expansion panels in an expansion list.
  List<ExpansionPanel> childrenExpansionList() { return <ExpansionPanel>[]; }


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

  /// See [TextTheme], text theme to use on a card background
  TextTheme get styleOnCard {
    return fundamentals.styleOnCard;
  }

  /// See [TextTheme], text theme to use on a primary color background
  TextTheme get styleOnPrimary {
    return fundamentals.styleOnPrimary;
  }

  /// See [TextTheme], text theme to use on an accent color backgroun
  TextTheme get styleOnAccent {
    return fundamentals.styleOnAccent;
  }

  Radius radiusCircular(double r) {
    return Radius.circular(r);
  }

  BorderRadius borderRadiusScaled({
    double all,
    double left,
    double right,
    double top,
    double bottom,
    double leftTop,
    double leftBottom,
    double rightTop,
    double rightBottom,
    Radius Function(double) createRadius,
  }) {
    // by default, the radius is half the margin.
    final base = margin * 0.5;
    var lt = base;
    var lb = lt;
    var rt = lt;
    var rb = lt;
    if(all != null) {
      lt = base * all;
      lb = base * all;
      rt = base * all;
      rb = base * all;
    }
    if(left != null) {
      lt = base * left;
      lb = base * left;
    }
    if(right != null) {
      rt = base * right;
      rb = base * right;
    }
    if(top != null) {
      lt = base * top;
      rt = base * top;
    }   
    if(bottom != null) {
      lb = base * bottom;
      rb = base * bottom;
    }
    if(leftTop !=  null) {
      lt = base * leftTop;
    }
    if(leftBottom != null) {
      lb = base * leftBottom;
    }
    if(rightTop != null) {
      rt = base * rightTop;
    }
    if(rightBottom != null) {
      rb = base * rightBottom;
    }
    if(createRadius == null) {
      createRadius = radiusCircular;
    }

    return BorderRadius.only(
      topLeft: createRadius(lt),
      bottomLeft: createRadius(lb),
      topRight: createRadius(rt),
      bottomRight: createRadius(rb)
    );
  }

  /// Whether times should use a 24 hour format.
  bool get alwaysUse24HourFormat {
    return fundamentals.device.alwaysUse24HourFormat(fundamentals);
  }

  /// Translate the specified string id and return it.
  /// 
  /// See also [childTextBuilder] and [childRichTextBuilder]
  String translate(dynamic text) {
    return fundamentals.translate(text);
  }

  FontWeight weight(dynamic weight) {
    return fundamentals.weight(weight);
  }

  AFRichTextBuilder childRichTextBuilder({
    AFWidgetID wid,
    dynamic idOrTextStyleNormal,
    dynamic idOrTextStyleBold,
    dynamic idOrTextStyleTapable,
    dynamic idOrTextStyleMuted,
  }) {
    final normal = idOrTextStyleNormal != null ? styleText(idOrTextStyleNormal) : null;
    final bold = idOrTextStyleBold != null ? styleText(idOrTextStyleBold) : null;
    final tapable = idOrTextStyleTapable != null ? styleText(idOrTextStyleTapable) : null;
    final muted = idOrTextStyleMuted != null ? styleText(idOrTextStyleMuted) : null;

    return AFRichTextBuilder(
      theme: fundamentals,
      wid: wid,
      normal: normal,
      bold: bold,
      tapable: tapable,
      muted: muted
    );
  }

  AFTextBuilder childTextBuilder({
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


  Text childText(dynamic text, {
    AFWidgetID wid, 
    dynamic style,
    dynamic textColor,
    dynamic fontSize,
    dynamic fontWeight,
    TextAlign textAlign,
  }) {
    TextStyle styleS;
    if(style != null) {
      styleS = styleText(style);
    }

    if(textColor != null || fontSize != null || fontWeight != null) {
      styleS = TextStyle(
        color: color(textColor) ?? styleS?.color,
        fontSize: size(fontSize) ?? styleS?.fontSize,
        fontWeight: weight(fontWeight) ?? styleS?.fontWeight
      );
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

  /// The orientation of the device.
  Orientation get deviceOrientation {
    final dSize = devicePhysicalSize;
    return (dSize.height >= dSize.width) ? Orientation.portrait : Orientation.landscape;
  }

  // Whether to always use 24-hour time format.
  bool get deviceAlwaysUse24HourFormat {
    return fundamentals.device.alwaysUse24HourFormat(fundamentals);
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

  /// The light/dark mode setting of the device.
  Brightness get deviceBrightness {
    return fundamentals.device.brightness(fundamentals);

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

  Color colorForeground(dynamic idOrColor) {
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

  TextStyle styleText(dynamic idOrTextStyle) {
    if(idOrTextStyle is TextStyle) {
      return idOrTextStyle;
    }
    return fundamentals.textStyle(idOrTextStyle);
  }

  double size(dynamic id, { double scale = 1.0 }) {
    if(id is double) {
      return id * scale;
    }
    return fundamentals.size(id, scale: scale);
  }

  double get margin { 
    return fundamentals.size(AFUIThemeID.sizeMargin);
  }

  Widget icon(dynamic id, {
    dynamic iconColor,
    dynamic iconSize
  }) {
    return fundamentals.icon(id, iconColor: iconColor, iconSize: iconSize);
  }

  Widget iconNavDown({
    dynamic iconColor,
    dynamic iconSize
  }) {
    return icon(AFUIThemeID.iconNavDown, iconColor: iconColor, iconSize: iconSize);
  }

  Widget iconBack({
    dynamic iconColor,
    dynamic iconSize
  }) {
    return icon(AFUIThemeID.iconBack, iconColor: iconColor, iconSize: iconSize);
  }

  Color get colorSecondary {
    return fundamentals.colorSecondary;
  }

  /// Important: the values you are passing in are scale factors on the
  /// value specified by [AFUIThemeID.sizeMargin], they are not
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
  /// value specified by [AFUIThemeID.sizeMargin], they are not
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
    
  /// Creates a standard back button, which navigates up the screen hierarchy.
  /// 
  /// The back button can optionally display a dialog which checks whether the user
  /// should continue, see [standardShouldContinueAlertCheck] for more.
  Widget childStandardBackButton(AFBuildContext context, {
    AFWidgetID wid = AFUIWidgetID.buttonBack,
    dynamic iconIdOrWidget = AFUIThemeID.iconBack,
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
          if(shouldContinueCheck == null || await shouldContinueCheck() == AFShouldContinue.yesContinue) {
            context.dispatchNavigate(AFNavigatePopAction(id: wid));
          }
        }
    );
  }
  
  /// 
  AFShouldContinueCheckDelegate standardShouldContinueAlertCheck({
    @required AFBuildContext context,
    @required bool shouldAsk,
    AFScreenID screen,
    AFRouteParam param,
    AFNavigatePushAction navigate
  }) {
    return () {
        final completer = Completer<AFShouldContinue>();
        if(navigate != null) {
          screen = navigate.screen;
          param = navigate.param;
        }

        assert(screen != null);
        assert(param != null);

        if(shouldAsk && !AFibD.config.isTestContext) {
          // set up the buttons
          // show the dialog
          context.showDialog(
            screenId: screen,
            param: param,
            onReturn: (param) {
              if(param is! AFShouldContinueRouteParam) {
                throw AFException("The dialog for standardShouldContinueAlertCheck must return an AFShouldContinueRouteParam");
              }
              final AFShouldContinueRouteParam should = param;
              completer.complete(should.shouldContinue);
            }
          );
        } else {
          completer.complete(AFShouldContinue.yesContinue);
        }
        
        return completer.future;    
    };
  }


  /// Replaces ListTile.divideTiles, including a key based on [widBase]
  /// for each one.
  /// 
  /// When I tried ListTile.divideTiles, it didn't seem to maintain a key
  /// on the dividers, which caused text widgets in the list to lose focus
  /// when the list was re-rendered.
  List<Widget> childrenDivideWidgets(List<Widget> rows, AFWidgetID widBase, {
    dynamic colorLine,
    dynamic thickness,
    dynamic height,
    dynamic indent

  }) {
    final c = color(colorLine);
    final thick = size(thickness);
    final h = size(height);
    final ind = size(indent);
    final result = childrenColumn();
    for(var i = 0; i < rows.length; i++) {
      final widget = rows[i];
      result.add(widget);
      if(i+1 < rows.length) {
        result.add(Divider(
          key: keyForWID(widBase.with2("divider", i.toString())),
          color: c,
          height: h,
          thickness: thick,
          indent: ind,
        ));
      }
    }
    return result;
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

  AFThemeState reviseOverrideThemeValue(AFThemeID id, dynamic value) {
    final revised = fundamentals.reviseOverrideThemeValue(id, value);
    return copyWith(
      fundamentals: revised,
      conceptuals: AFibF.g.createConceptualThemes(revised));
  }

  AFThemeState reviseRebuildAll() {
    return AFibF.g.initializeThemeState();
  }

  AFThemeState copyWith({
    AFFundamentalTheme fundamentals,
    List<AFConceptualTheme> conceptuals,
  }) {
    return AFThemeState.create(
      conceptuals: conceptuals ?? this.conceptuals,
      fundamentals: fundamentals ?? this.fundamentals
    );
  }

  static String _keyFor(dynamic theme) {
    if(theme is Type) {
      return theme.toString();
    }
    return theme.runtimeType.toString();
  }
}