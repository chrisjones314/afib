import 'dart:async';
import 'dart:ui';

import 'package:afib/afib_uiid.dart';
import 'package:afib/afib_localeid.dart';
import 'package:afib/src/dart/command/af_command_enums.dart';
import 'package:afib/src/dart/redux/actions/af_route_actions.dart';
import 'package:afib/src/dart/utils/af_exception.dart';
import 'package:afib/src/dart/utils/af_id.dart';
import 'package:afib/src/dart/utils/af_route_param_with_flutter_state.dart';
import 'package:afib/src/dart/utils/af_should_continue_route_param.dart';
import 'package:afib/src/dart/utils/afib_d.dart';
import 'package:afib/src/flutter/test/af_screen_test.dart';
import 'package:afib/src/flutter/ui/dialog/afui_standard_choice_dialog.dart';
import 'package:afib/src/flutter/ui/drawer/afui_prototype_drawer.dart';
import 'package:afib/src/flutter/ui/screen/af_connected_screen.dart';
import 'package:afib/src/flutter/ui/theme/af_text_builders.dart';
import 'package:afib/src/flutter/ui/widgets/afui_text_field.dart';
import 'package:afib/src/flutter/utils/af_param_ui_state_holder.dart';
import 'package:afib/src/flutter/utils/af_typedefs_flutter.dart';
import 'package:afib/src/flutter/utils/afib_f.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

/// These are fundamental values for theming derived from the device
/// and operating system itself.
class AFFundamentalDeviceTheme {
  final Brightness brightnessValue;
  final bool alwaysUse24HourFormatValue;
  final ViewPadding padding;
  final ViewPadding viewInsets;
  final ViewPadding viewPadding;
  final Locale localeValue;
  final Size physicalSize;
  final Size logicalSize;
  final double textScaleFactorValue;
  final double devicePixelRatio;

  AFFundamentalDeviceTheme({
    required this.brightnessValue,
    required this.alwaysUse24HourFormatValue,
    required this.padding,
    required this.viewInsets,
    required this.viewPadding,
    required this.localeValue,
    required this.physicalSize,
    required this.logicalSize,
    required this.textScaleFactorValue,
    required this.devicePixelRatio,
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
    final devicePixelRatio = window.devicePixelRatio;
    final logicalSize = physicalSize / devicePixelRatio;
    return AFFundamentalDeviceTheme(
      brightnessValue: brightness,
      alwaysUse24HourFormatValue: alwaysUse24,
      padding: padding,
      viewInsets: viewInsets,
      viewPadding: viewPadding,
      localeValue: locale,
      physicalSize: physicalSize,
      logicalSize: logicalSize,
      textScaleFactorValue: textScaleFactor,
      devicePixelRatio: devicePixelRatio,
    );
  }

  bool isDeviceId(AFThemeID id) {
    return AFFundamentalThemeArea.deviceThemeIds.contains(id);
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

  Brightness brightness(AFFundamentalThemeState fundamentals) {
    final b = fundamentals.findValue<Brightness>(AFUIThemeID.brightness);
    return b ?? brightnessValue;
  }

  bool alwaysUse24HourFormat(AFFundamentalThemeState fundamentals) {
    final b = fundamentals.findValue<bool>(AFUIThemeID.alwaysUse24HourFormat);
    return b ?? alwaysUse24HourFormatValue;
  }

  Locale locale(AFFundamentalThemeState fundamentals) {
    final l = fundamentals.findValue<Locale>(AFUIThemeID.locale);
    return l ?? localeValue;
  }

  double textScaleFactor(AFFundamentalThemeState fundamentals) {
    final ts = fundamentals.findValue<double>(AFUIThemeID.textScaleFactor);
    return ts ?? textScaleFactorValue;
  }
}

/// A value which can be exposed to and edited by the
/// theme 
class AFFundamentalThemeValue {
  final AFThemeID id;
  final dynamic value;

  AFFundamentalThemeValue({
    required this.id,
    required this.value,
  });  
}

/// A theme value that refers to other values, and needs to be resolved 
/// at the end of the theme creation process.
abstract class AFThemeResolvableValue {
  void resolve(AFFundamentalThemeState theme);
}

/// A summary of a text style composed from other theme components.
class AFTextStyle extends AFThemeResolvableValue {
  final AFThemeID color;
  final AFThemeID fontSize;
  final AFThemeID? weight;

  TextStyle? styleCache;

  AFTextStyle({
    required this.color,
    required this.fontSize,
    this.weight,
  });

  @override
  void resolve(AFFundamentalThemeState theme) {
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

  Color? colorLightCache;
  Color? colorDarkCache;

  AFColor({
    required this.colorLight,
    required this.colorDark,
  });

  factory AFColor.createWithOne(AFThemeID color) {
    return AFColor(colorLight: color, colorDark: color);
  }

  Color? color(Brightness brightness) { return brightness == Brightness.light ? colorLightCache : colorDarkCache; }

  @override
  void resolve(AFFundamentalThemeState theme) {
    colorLightCache = theme.color(colorLight);
    colorDarkCache = theme.color(colorDark);
  }

} 

/// A pairing of [AFColor] for foreground and background.
/// 
/// You can register one of these, and then automatically get the 
/// correct color with [AFFunctionalTheme.colorForeground] and
/// [AFFunctionalTheme.colorBackground]
class AFColorPairing extends AFThemeResolvableValue {
  final AFColor foreground;
  final AFColor background;

  AFColorPairing({
    required this.foreground,
    required this.background,
  });

  Color? forgroundColor(Brightness brightness) {
    return foreground.color(brightness);
  }

  Color? backgroundColor(Brightness brightness) {
    return background.color(brightness);
  }

  @override
  void resolve(AFFundamentalThemeState theme) {
    foreground.resolve(theme);
    background.resolve(theme);
  }
}

/// Allows different parties to contribute fundamental values
/// to a theme which are can be manipulated via the prototype 
/// drawer.
@immutable
class AFFundamentalThemeArea with AFThemeAreaUtilties {
  static const deviceThemeIds = [
      AFUIThemeID.brightness,
      AFUIThemeID.alwaysUse24HourFormat,
      AFUIThemeID.textScaleFactor,
      AFUIThemeID.locale,
      //AFUIThemeID.formFactor,
      //AFUIThemeID.formOrientation,
  ];
  final ThemeData themeLight;
  final ThemeData themeDark;
  final Map<AFThemeID, AFFundamentalThemeValue> values;
  final Map<Locale, AFTranslationSet> translationSet;
  final List<Locale> supportedLocalesApp;
  static final List<Locale> supportedLocalesDefault = [AFUILocaleID.englishUS];
  final Map<AFThemeID, AFFundamentalThemeValue> overrides;
  final Map<AFThemeID, List<dynamic>> optionsForType;

  AFFundamentalThemeArea({
    required this.themeLight,
    required this.themeDark,
    required this.values, 
    required this.translationSet,
    required this.supportedLocalesApp,
    required this.overrides,
    required this.optionsForType,
  });

  AFFundamentalThemeArea reviseOverrideThemeValue(AFThemeID id, dynamic value) {
    final revised = Map<AFThemeID, AFFundamentalThemeValue>.from(overrides);
    revised[id] = AFFundamentalThemeValue(id: id, value: value);
    return copyWith(
      overrides: revised
    );
  }

  AFFundamentalThemeArea copyWith({
    ThemeData? themeLight,
    ThemeData? themeDark,
    Map<AFThemeID, AFFundamentalThemeValue>? values,
    Map<Locale, AFTranslationSet>? translationSet,
    List<Locale>? supportedLocalesApp,
    Map<AFThemeID, AFFundamentalThemeValue>? overrides,
  }) {
    return AFFundamentalThemeArea(
      themeLight: themeLight ?? this.themeLight,
      themeDark: themeDark ?? this.themeDark,
      values: values ?? this.values,
      translationSet: translationSet ?? this.translationSet,
      supportedLocalesApp: supportedLocalesApp ?? this.supportedLocalesApp,
      overrides: overrides ?? this.overrides,
      optionsForType: this.optionsForType,
    );
  }
  
  List<Locale> get supportedLocales {
    if(supportedLocalesApp.isEmpty) {
      return supportedLocalesDefault;
    }
    return supportedLocalesApp;
  }

  List<String> get areaList {
    final map = <String, bool>{};
    for(final val in this.values.values) {
      final tag = val.id.libraryTag;
      map[tag] = true;
    }
    final result = map.keys.toList();
    result.insert(0, AFUIThemeID.tagDevice);
    return result;
  }

  List<AFThemeID> attrsForArea(String area) {
    if(area == AFUIThemeID.tagDevice) {
      return deviceThemeIds;
    }

    final result = <AFThemeID>[];
    for(final val in this.values.values) {
      if(area == AFUILibraryID.id.codeId && deviceThemeIds.contains(val.id)) {
        continue;
      }
      if(val.id.libraryTag == area) {
        result.add(val.id);
      }
    }

    return result;
  }

  bool get showTranslationIds {
    if(!AFibD.config.isPrototypeMode) {
      return false;
    }
    final val = findValue(AFUIThemeID.showTranslationsIDs);
    return (val != null && val);
  }

  ThemeData themeData(Brightness brightness) {
    return brightness == Brightness.light ? themeLight : themeDark;
  }

  String _processTranslationTemplate(AFTranslationTemplate template, Locale locale) {
    var currentText = translate(text: template.template, locale: locale);
    for(final insertKey in template.insertions.keys) {
      final translatedValue = translate(text: template.insertions[insertKey], locale: locale);
      currentText = currentText.replaceAll(insertKey.toString() , translatedValue);
    }
    return currentText;
  }

  @override
  String translate({ AFWidgetID? wid, Object? text, required Locale locale}) {
    text ??= wid;

    if(text is AFNotTranslated) {
      return text.value;
    }

    if(text is AFTranslationTemplate) {
      return _processTranslationTemplate(text, locale);
    }

    if(showTranslationIds) {
      if (text is AFTranslationID) {
        return text.code;
      }
      if(text is AFWidgetID) {
        return text.code;
      }
    }

    Object? result = translation(text: text, locale: locale);
    if(result == null) {
      return text.toString();
    }
    return result.toString();
  }

  @override
  dynamic value(AFThemeID? id) {
    return values[id]?.value;
  }

  Locale get defaultLocale { 
    assert(supportedLocales.isNotEmpty, "You must have at least one setTranslations call on your fundamental theme");
    return supportedLocales.first;
  }

  static void failIfStrictTranslation(String msg) {
    if(AFibD.config.strictTranslationMode) {
      throw AFException(msg);
    }
  }

  @override
  String? translation({ Object? text, required Locale locale }) {    
    var setT = translationSet[locale];
    if(setT == null) {
      // 
      if(locale.scriptCode != null) {
        locale = Locale.fromSubtags(languageCode: locale.languageCode, countryCode: locale.countryCode);
        setT = translationSet[locale];
      }
      if(setT == null && locale.countryCode != null) {
        locale = Locale.fromSubtags(languageCode: locale.languageCode);
        setT = translationSet[locale];
      }
      setT = translationSet[defaultLocale];
    }
    if(setT == null) {
      failIfStrictTranslation("No translations for locale");
      return text.toString();
    }
    final universal = translationSet[AFUILocaleID.universal];
    if(universal == null) {
      failIfStrictTranslation("No universal translation set");
      return text.toString();
    }
    return setT.translate(text, universal);
  }

  dynamic findValue(AFThemeID id) {
    var val = overrides[id];
    val ??= values[id];
    return val?.value;
  }
}

class AFTranslationSet {
  final Locale locale;
  final translations = <dynamic, String>{};

  AFTranslationSet(this.locale);

  int get count { 
    return translations.length;
  }

  void setTranslations(Map<dynamic, String> source) {
    source.forEach((key, text) {
      if(!translations.containsKey(key)) {
        translations[key] = text;
      }
    });
  }

  void setTranslation(dynamic idOrText, String trans) {
    translations[idOrText] = trans;
  }

  String? translate(dynamic textOrId, AFTranslationSet universal) {
    if(textOrId is String) {
      if(textOrId.isEmpty) {
        return textOrId;
      }
    }
    var result = translations[textOrId];
    result ??= universal.translations[textOrId];      
    if(result == null) {
      if(AFibD.config.isTestContext) {
        AFibF.g.testMissingTranslations.register(locale, textOrId);
      }
      if(textOrId is String) {
        return textOrId;
      }
      return textOrId.toString();
      //throw AFException("Unknown translation $textOrId");
    }
    return result;
  }

}

class AFUILibraryFundamentalThemeAreaBuilder {
  final values = <AFThemeID, AFFundamentalThemeValue>{};
  final translationSet = <Locale, AFTranslationSet>{};
  final supportedLocalesApp = <Locale>[];
  Map<AFThemeID, List<dynamic>> optionsForType;

  AFUILibraryFundamentalThemeAreaBuilder(
    this.optionsForType
  );

  /// Set a fundamental value.
  /// 
  /// If the value exists, it is not overwritten.  Because the app
  /// populates the builder first, this allows the app to override
  /// values for plugins.
  void setValue(AFThemeID id, dynamic value, {
    AFCreateDynamicDelegate? defaultCalculation,
    bool notNull = true
  }) {
    if(!values.containsKey(id)) {
      if(value == null && defaultCalculation != null) {
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
      setValue(id, val);
    });
  }

  void setTranslations(Locale locale, Map<dynamic, String> translations) {
    var setT = translationSet[locale];
    if(setT == null) {
      setT = AFTranslationSet(locale);
      translationSet[locale] = setT;
      if(locale != AFUILocaleID.universal) {
        supportedLocalesApp.add(locale);
      }
    }
    setT.setTranslations(translations);
  }

  void validate() {
  }
}

mixin AFThemeAreaUtilties {
  double? size(dynamic id, { double scale = 1.0 }) {
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

  Widget? icon(dynamic idOrIcon, {
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


  TextStyle? textStyle(dynamic idOrTextStyle) {
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

  FontWeight? weight(dynamic id) {
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

  Color foreground(AFThemeID? id, Brightness brightness) {
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

  Color background(AFThemeID? id, Brightness brightness) {
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

  String? translate({ AFWidgetID? wid, Object? text, required Locale locale }) {
    assert(text != null || wid != null);
    text ??= wid;
    var result = translation(text: text, locale: locale);
    if(result == null) {
      if(text == null) {
        result = "ERROR";
      } else {
        result = text.toString();
      }
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

  Color? color(dynamic id) {
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

  dynamic value(AFThemeID? id);
  String? translation({ Object? text, required Locale locale });  

  void _throwUnsupportedType(dynamic id, dynamic val) {
    throw AFException("In fundamental theme, $id has unsupported type ${val.runtimeType}");
  }

  static Color colorDarker(Color c, int percent) {
    assert(1 <= percent && percent <= 100);
    var f = 1 - percent / 100;
    return Color.fromARGB(
        c.alpha,
        (c.red * f).round(),
        (c.green  * f).round(),
        (c.blue * f).round()
    );
  }

  static Color colorLighter(Color c, int percent) {
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

class AFAppFundamentalThemeAreaBuilder extends AFUILibraryFundamentalThemeAreaBuilder with AFThemeAreaUtilties {
  ThemeData? themeLight;
  ThemeData? themeDark;
  static const bootstrapStandardMargins = <double>[0, 2.0, 4.0, 8.0, 12.0, 16.0];
  static const bootstrapStandardPadding = bootstrapStandardMargins;
  static const bootstrapStandardBorderRadius = bootstrapStandardMargins;

  AFAppFundamentalThemeAreaBuilder({
    required Map<AFThemeID, List<dynamic>> optionsForType
  }): super(optionsForType);

  factory AFAppFundamentalThemeAreaBuilder.create() {
    final options = <AFThemeID, List<dynamic>>{};
    options[AFUIThemeID.brightness] = Brightness.values;
    return AFAppFundamentalThemeAreaBuilder(optionsForType: options);
  }
  
  /// The app must call this method, or [setFundamentalThemeData] in order
  /// to establish the basic theme of the app.
  void setFlutterFundamentals({
    required ColorScheme colorSchemeLight,
    required ColorScheme colorSchemeDark,
    TextTheme? textThemeLight,
    TextTheme? textThemeDark
  }) {

    themeLight = ThemeData.from(colorScheme: colorSchemeLight);
    themeDark = ThemeData.from(colorScheme: colorSchemeDark);
  }

  /// Most apps should use [setFlutterFundamentals], but this method gives you more control
  /// to create the theme data exactly as you wish.
  void setFundamentalThemeData({
    ThemeData? themeLight,
    ThemeData? themeDark
  }) {
    this.themeLight = themeLight;
    this.themeDark = themeDark;
  }

  static AFFormFactor convertFormFactor(Size size) {
    // normalize to portrait
    final width = size.width > size.height ? size.height : size.width;
    final height = size.width > size.height ? size.width : size.height;

    if(width >= AFFormFactorSize.sizeTabletLarge.width && height >= AFFormFactorSize.sizeTabletLarge.height) {
      return AFFormFactor.largeTablet;
    } else if(width >= AFFormFactorSize.sizeTabletStandard.width && height >= AFFormFactorSize.sizeTabletStandard.height) {
      return AFFormFactor.standardTablet;
    } else if(width >= AFFormFactorSize.sizeTabletSmall.width && height >= AFFormFactorSize.sizeTabletSmall.height) {
      return AFFormFactor.smallTablet;
    } else if(width >= AFFormFactorSize.sizePhoneLarge.width && height >= AFFormFactorSize.sizePhoneLarge.height) {
      return AFFormFactor.largePhone;
    } else if(width >= AFFormFactorSize.sizePhoneStandard.width && height >= AFFormFactorSize.sizePhoneStandard.height) {
      return AFFormFactor.standardPhone;
    }
    return AFFormFactor.smallPhone;    
  }

  /// The app must call this method to establish some fundamental theme values that both 
  /// flutter and AFib expect.  
  /// 
  /// Values which are not specified will be derived intelligently.
  /// 
  /// marginScale and paddingScale should each contain six values, starting with zero, which 
  /// specify the various values returned [AFFunctionalTheme.margin] and [AFFunctionalTheme.padding]
  void setAfibFundamentals({
    List<double> marginSizes = bootstrapStandardMargins,
    List<double> paddingSizes = bootstrapStandardPadding,
    List<double> borderRadiusSizes = bootstrapStandardBorderRadius,
    IconData iconBack = Icons.arrow_back,
    IconData iconNavDown = Icons.chevron_right,
    Color colorTapableText = Colors.blue,
    AFConvertSizeToFormFactorDelegate convertFormFactor = AFAppFundamentalThemeAreaBuilder.convertFormFactor,
    Color? colorAlert,
    Color colorOnAlert = Colors.white,
  }) {
    assert(marginSizes.length == bootstrapStandardMargins.length);
    assert(paddingSizes.length == bootstrapStandardPadding.length);
    assert(borderRadiusSizes.length == bootstrapStandardBorderRadius.length);
    //assert(formFactorLimits.length == afFormFactorMinimums.length);
    colorAlert ??= Colors.amber[900];

    // icons
    setValue(AFUIThemeID.marginSizes, marginSizes);
    setValue(AFUIThemeID.paddingSizes, paddingSizes);
    setValue(AFUIThemeID.borderRadiusSizes, borderRadiusSizes);
    setValue(AFUIThemeID.iconBack, iconBack);
    setValue(AFUIThemeID.iconNavDown, iconNavDown);
    setValue(AFUIThemeID.colorTapableText, colorTapableText);
    setValue(AFUIThemeID.formFactorDelegate, convertFormFactor);
    setValue(AFUIThemeID.colorAlert, colorAlert);
    setValue(AFUIThemeID.colorOnAlert, colorOnAlert);
  }


  @override
  dynamic value(AFThemeID? id) {
    return values[id]?.value;
  }

  @override
  String? translation({ Object? text, required Locale locale }) {
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
      themeLight: themeLight!, 
      themeDark: themeDark!, 
      values: this.values, 
      translationSet: translationSet,
      supportedLocalesApp: supportedLocalesApp,
      overrides: const <AFThemeID, AFFundamentalThemeValue>{},
      optionsForType: optionsForType,
    );
  }

  AFSpacing createMarginSpacing() {
    final List<double> factors = value(AFUIThemeID.marginSizes);
    return AFSpacing.create(factors);
  }

  AFSpacing createPaddingSpacing() {
    final List<double> factors = value(AFUIThemeID.paddingSizes);
    return AFSpacing.create(factors);
  }

  AFBorderRadius createBorderRadius() {
    final List<double> factors = value(AFUIThemeID.borderRadiusSizes);
    return AFBorderRadius.create(factors);
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

class AFBorderRadiusSet {
  final BorderRadius s1;
  final BorderRadius s2;
  final BorderRadius s3;
  final BorderRadius s4;
  final BorderRadius s5;

  AFBorderRadiusSet({
    required this.s1,
    required this.s2,
    required this.s3,
    required this.s4,
    required this.s5,
  });

  BorderRadius get size1 { return s1; }
  BorderRadius get size2 { return s2; }
  BorderRadius get size3 { return s3; }
  BorderRadius get size4 { return s4; }
  BorderRadius get size5 { return s5; }
  BorderRadius get standard { return s2; }

 factory AFBorderRadiusSet.create({
    required List<double> sizes,
    required BorderRadius Function(Radius r) createRadius,
   }) {
    final s1 = _createRadius(sizes[1], createRadius);
    final s2 = _createRadius(sizes[2], createRadius);
    final s3 = _createRadius(sizes[3], createRadius);
    final s4 = _createRadius(sizes[4], createRadius);
    final s5 = _createRadius(sizes[5], createRadius);
    return AFBorderRadiusSet(s1: s1, s2: s2, s3: s3, s4: s4, s5: s5);
  }

  static BorderRadius _createRadius(double amount, BorderRadius Function(Radius) createRadius) {    
    final radius = Radius.circular(amount);
    return createRadius(radius);
        
  }  
}

class AFBorderRadius {
  final List<double> sizes;
  final AFBorderRadiusSet a;
  final AFBorderRadiusSet l;
  final AFBorderRadiusSet r;
  final AFBorderRadiusSet t;
  final AFBorderRadiusSet b;

  AFBorderRadius({
    required this.sizes,
    required this.a,
    required this.l,
    required this.r,
    required this.t,
    required this.b,
  });

  AFBorderRadiusSet get all { return a; }
  AFBorderRadiusSet get left { return l; }
  AFBorderRadiusSet get right { return r; }
  AFBorderRadiusSet get top { return t; }
  AFBorderRadiusSet get bottom { return b; }
  BorderRadius get standard { return a.standard; }
  BorderRadius get smaller { return a.s2; }
  BorderRadius get smallest { return a.s1; }
  BorderRadius get larger { return a.s4; }
  BorderRadius get largest { return a.s5; }
  BorderRadius get none { return BorderRadius.zero; }


  factory AFBorderRadius.create(List<double> sizes) {
    final a = AFBorderRadiusSet.create(sizes: sizes, createRadius: (r) => BorderRadius.all(r));
    final l = AFBorderRadiusSet.create(sizes: sizes, createRadius: (r) => BorderRadius.only(topLeft: r, bottomLeft: r));
    final r = AFBorderRadiusSet.create(sizes: sizes, createRadius: (r) => BorderRadius.only(topRight: r, bottomRight: r));
    final t = AFBorderRadiusSet.create(sizes: sizes, createRadius: (r) => BorderRadius.only(topRight: r, topLeft: r));
    final b = AFBorderRadiusSet.create(sizes: sizes, createRadius: (r) => BorderRadius.only(bottomRight: r, bottomLeft: r));

    return AFBorderRadius(
      sizes: sizes,
      a: a,
      l: l,
      r: r,
      t: t,
      b: b,
    );
  }


}



class AFSpacingSet {
  final EdgeInsets s0;
  final EdgeInsets s1;
  final EdgeInsets s2;
  final EdgeInsets s3;
  final EdgeInsets s4;
  final EdgeInsets s5;

  AFSpacingSet({
    required this.s0,
    required this.s1,
    required this.s2,
    required this.s3,
    required this.s4,
    required this.s5,
  });

  EdgeInsets get size1 { return s1; }
  EdgeInsets get size2 { return s2; }
  EdgeInsets get size3 { return s3; }
  EdgeInsets get size4 { return s4; }
  EdgeInsets get size5 { return s5; }
  EdgeInsets get none { return s0; }
  EdgeInsets get smallest { return s1; }
  EdgeInsets get smaller { return s2; }
  EdgeInsets get standard { return s3; }
  EdgeInsets get bigger { return s4; }
  EdgeInsets get biggest { return s5; }

  factory AFSpacingSet.createLTRB(
    List<double> basicSizes,
    final double left,
    final double top,
    final double right,
    final double bottom,
   ) {
    final s0 = _createInsetsLTRB(basicSizes[0], left, top, right, bottom);
    final s1 = _createInsetsLTRB(basicSizes[1], left, top, right, bottom);
    final s2 = _createInsetsLTRB(basicSizes[2], left, top, right, bottom);
    final s3 = _createInsetsLTRB(basicSizes[3], left, top, right, bottom);
    final s4 = _createInsetsLTRB(basicSizes[4], left, top, right, bottom);
    final s5 = _createInsetsLTRB(basicSizes[5], left, top, right, bottom);
    return AFSpacingSet(s0: s0, s1: s1, s2: s2, s3: s3, s4: s4, s5: s5);
  }

  static EdgeInsets _createInsetsLTRB(double amount, double left, double top, double right, double bottom) {
    final t = top * amount;
    final b = bottom * amount;
    final r = right * amount;
    final l = left * amount;
    return EdgeInsets.fromLTRB(l, t, r, b);
  }
}

class AFSpacing {
  final List<double> sizes;
  final AFSpacingSet a;
  final AFSpacingSet t;
  final AFSpacingSet r;
  final AFSpacingSet b;
  final AFSpacingSet l;
  final AFSpacingSet v;
  final AFSpacingSet h;
  final AFSpacingSet th;
  final AFSpacingSet bh;
  final AFSpacingSet lv;
  final AFSpacingSet rv;

  AFSpacingSet get all { return a; }
  AFSpacingSet get top { return t; }
  AFSpacingSet get right { return r; }
  AFSpacingSet get bottom { return b; }
  AFSpacingSet get left { return l; }
  AFSpacingSet get vert { return v; }
  AFSpacingSet get horz { return h; }
  AFSpacingSet get y { return v; }
  AFSpacingSet get x { return h; }
  AFSpacingSet get topHorz { return th; }
  AFSpacingSet get bottomHorz { return bh; }
  AFSpacingSet get leftVert { return lv; }
  AFSpacingSet get rightVert { return rv; }

  EdgeInsets get smallest { return a.smallest; }
  EdgeInsets get smaller { return a.smaller; }
  EdgeInsets get standard { return a.standard; }
  EdgeInsets get bigger { return a.bigger; }
  EdgeInsets get biggest { return a.biggest; }
  EdgeInsets get none { return a.none; }


  AFSpacing({
    required this.sizes,
    required this.a,
    required this.t,
    required this.r,
    required this.b,
    required this.l,
    required this.v,
    required this.h,
    required this.th,
    required this.bh,
    required this.lv,
    required this.rv,
  });

  factory AFSpacing.create(List<double> sizes) {
    final m = AFSpacingSet.createLTRB(sizes, 1, 1, 1, 1);
    final mt = AFSpacingSet.createLTRB(sizes, 0, 1, 0, 0);
    final mr = AFSpacingSet.createLTRB(sizes, 0, 0, 1, 0);
    final mb = AFSpacingSet.createLTRB(sizes, 0, 0, 0, 1);
    final ml = AFSpacingSet.createLTRB(sizes, 1, 0, 0, 0);
    final mv = AFSpacingSet.createLTRB(sizes, 0, 1, 0, 1);
    final mh = AFSpacingSet.createLTRB(sizes, 1, 0, 1, 0);
    final th = AFSpacingSet.createLTRB(sizes, 1, 1, 1, 0);
    final bh = AFSpacingSet.createLTRB(sizes, 1, 0, 1, 1);
    final lv = AFSpacingSet.createLTRB(sizes, 1, 1, 0, 1);
    final rv = AFSpacingSet.createLTRB(sizes, 0, 1, 1, 1);
    return AFSpacing(
      sizes: sizes,
      a: m,
      l: ml,
      t: mt,
      r: mr,
      b: mb,
      v: mv,
      h: mh,
      th: th,
      bh: bh,
      lv: lv,
      rv: rv,
    );
  }

}

class AFNotTranslated {
  final String value;
  AFNotTranslated(this.value);

  @override
  String toString() => this.value;
}

class AFTranslationTemplate {
  final Object template;
  final Map<Object, Object> insertions;

  AFTranslationTemplate({
    required this.template,
    required this.insertions,
  });
}


/// Fundamental values that contribute to theming in the app.
/// 
/// An [AFFundamentalThemeState] provides fundamental values like
/// colors, fonts, and measurements which determine the basic
/// properties of the UI.   It is the place where you store
/// and manipulate data values that contribute to a them.
/// 
/// [AFFunctionalTheme] doesn't have its own mutable data values,
/// instead it provides a functional wrapper that creates 
/// conceptual components in the UI based on the values in 
/// a fundamental theme.
class AFFundamentalThemeState {
  static const orderedFormFactors = <AFFormFactor>[AFFormFactor.smallPhone, AFFormFactor.standardPhone, AFFormFactor.largePhone, AFFormFactor.smallTablet, AFFormFactor.standardTablet, AFFormFactor.largeTablet];
  static const badSizeIndexError = "You must specify an index into your 6 standard sizes";
  ThemeData? themeData;
  final AFFundamentalDeviceTheme device;
  final AFFundamentalThemeArea area;
  final AFSpacing marginSpacing;
  final AFSpacing paddingSpacing;
  final AFBorderRadius borderRadius;

  AFFundamentalThemeState({
    required this.device,
    required this.area,
    required this.marginSpacing,
    required this.paddingSpacing,
    required this.borderRadius,
    required this.themeData,
  });    

  List<dynamic>? optionsForType(AFThemeID id) {
    return area.optionsForType[id];
  }

  void updateThemeData(ThemeData td) {
    themeData = td;
  }

  bool deviceHasFormFactor({
    AFFormFactor? atLeast,
    AFFormFactor? atMost,
    Orientation? withOrientation
  }) {
    if(withOrientation != null) {
      if(deviceOrientation != withOrientation) {
        return false;
      }
    }
    
    var atLeastIdx = 0;
    var atMostIdx = orderedFormFactors.length;
    if(atLeast != null) {
      atLeastIdx = orderedFormFactors.indexOf(atLeast);
    }
    if(atMost != null) {
      atMostIdx = orderedFormFactors.indexOf(atMost);
    }

    final actualIdx = orderedFormFactors.indexOf(deviceFormFactor);
    return (actualIdx >= atLeastIdx && actualIdx <= atMostIdx);
  }

  AFFormFactor get deviceFormFactor {
    final dSize = device.physicalSize;
    final delegate = findValue(AFUIThemeID.formFactorDelegate) as AFConvertSizeToFormFactorDelegate;
    return delegate(dSize);
  }

  /// The orientation of the device.
  Orientation get deviceOrientation {
    final dSize = device.physicalSize;
    return (dSize.height >= dSize.width) ? Orientation.portrait : Orientation.landscape;
  }

  AFFundamentalThemeState reviseOverrideThemeValue(AFThemeID id, dynamic value) {

    return copyWith(
      device: device,
      area: area.reviseOverrideThemeValue(id, value)
    );
  }

  bool get showTranslationIds {
    return area.showTranslationIds;
  }

  AFFundamentalThemeState copyWith({
    AFFundamentalDeviceTheme? device,
    AFFundamentalThemeArea? area,
    ThemeData? themeData
  }) {
    return AFFundamentalThemeState(
      area: area ?? this.area,
      device: device ?? this.device,
      marginSpacing: this.marginSpacing,
      paddingSpacing: this.paddingSpacing,
      borderRadius: this.borderRadius,
      themeData: themeData ?? this.themeData,
    );
  }

  List<Locale> get supportedLocales {
    return area.supportedLocales;
  }

  Locale get deviceLocale {
    return device.locale(this);
  }

  String translate({ AFWidgetID? wid, Object? text }) {
    return area.translate(wid: wid, text: text, locale: deviceLocale);
  }

  ThemeData get themeDataActive {
    return area.themeData(device.brightness(this));
  }

  ThemeData get themeDataLight {
    return area.themeData(Brightness.light);
  }

  ThemeData get themeDataDark {
    return area.themeData(Brightness.dark);
  }

  Color? get colorTapableText {
    return area.color(AFUIThemeID.colorTapableText);
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
    return themeDataActive.colorScheme.primary;
  }

  Color get colorOnPrimary {
    return themeDataActive.colorScheme.onPrimary;
  }

  Color get colorBackground {
    return themeDataActive.colorScheme.background;
  }

  Color get colorOnBackground {
    return themeDataActive.colorScheme.onBackground;
  }

  Color get colorError {
    return themeDataActive.colorScheme.error;
  }

  Color get colorOnError {
    return themeDataActive.colorScheme.onError;
  }

  Color get colorSurface {
    return themeDataActive.colorScheme.surface;
  }

  Color get colorOnSurface {
    return themeDataActive.colorScheme.onSurface;
  }

  Color get colorPrimaryLight {
    return themeDataActive.primaryColorLight;
  }

  Color get colorSecondary {
    return themeDataActive.colorScheme.secondary;
  }

  /// This indicates whether this is a bright or dark color scheme.
  /// 
  /// Note that the primary 'bright' color scheme could still be 'dark'
  /// in nature.
  Brightness get colorSchemeBrightness {
    return themeDataActive.colorScheme.brightness;
  }

  TextTheme get styleOnCard {
    return themeDataActive.textTheme;
  }

  TextTheme get styleOnPrimary {
    return themeDataActive.primaryTextTheme;
  }

  TextTheme get styleOnSecondary {
    return themeDataActive.primaryTextTheme;
  }

  Color? color(AFThemeID? id) {
    return area.color(id);
  }

  Color foreground(AFThemeID? id) {
    return area.foreground(id, device.brightness(this));
  }

  Color background(AFThemeID? id) {
    return area.background(id, device.brightness(this));
  }

  double? size(AFThemeID? id, { double scale = 1.0 }) {
    return area.size(id, scale: scale);
  }

  Widget? icon(dynamic idOrValue, {
    dynamic iconColor, 
    dynamic iconSize
  }) {
    return area.icon(idOrValue, iconColor: iconColor, iconSize: iconSize);
  }

  TextStyle? textStyle(dynamic idOrTextStyle) {
    return area.textStyle(idOrTextStyle);
  }

  FontWeight? weight(dynamic id) {
    return area.weight(id);
  } 

  TReturn? findValue<TReturn extends Object>(AFThemeID id) {
    var result = area.findValue(id);
    if(result == null && device.isDeviceId(id)) {
      result = device.findDeviceValue(id);
    }
    if(result is! TReturn?) {
      throw AFException("Expected type $TReturn found ${result.runtimeType} for $id");
    }
    return result;
  }

  double get size1 { 
    return marginSpacing.a.s1.top;
  }

  double get size2 { 
    return marginSpacing.a.s2.top;
  }

  double get size3 { 
    return marginSpacing.a.s3.top;
  }

  double get size4 { 
    return marginSpacing.a.s4.top;
  }

  double get size5 { 
    return marginSpacing.a.s5.top;
  }

  AFSpacing get margin {
    return marginSpacing;
  }


  AFSpacing get padding {
    return paddingSpacing;
  }

  EdgeInsets marginCustom({
    int? horizontal,
    int? vertical,
    int? top,
    int? bottom,
    int? left,
    int? right,
    int? all
  }) {
    return spacingCustom(
      spacing: marginSpacing,
      all: all,
      horizontal: horizontal,
      vertical: vertical,
      top: top,
      left: left,
      right: right,
      bottom: bottom
    );
  }

  EdgeInsets paddingCustom({
    int? horizontal,
    int? vertical,
    int? top,
    int? bottom,
    int? left,
    int? right,
    int? all
  }) {
    return spacingCustom(
      spacing: paddingSpacing,
      all: all,
      horizontal: horizontal,
      vertical: vertical,
      top: top,
      left: left,
      right: right,
      bottom: bottom
    );
  }

  EdgeInsets spacingCustom({
    required AFSpacing spacing,
    int? horizontal,
    int? vertical,
    int? top,
    int? bottom,
    int? left,
    int? right,
    int? all
  }) {
    final basicSizes = spacing.sizes;
    const m = 0.0;
    var t = m;
    var b = m;
    var l = m;
    var r = m;
    if(all != null) {
      assert(all >= 0 && all < 6, badSizeIndexError);
      final ms = basicSizes[all];
      t = ms;
      b = ms;
      l = ms;
      r = ms;
    }
    if(vertical != null) {
      assert(vertical >= 0 && vertical < 6, badSizeIndexError);
      final ms = basicSizes[vertical];
      b = ms;
      t = ms;
    }
    if(horizontal != null) {
      assert(horizontal >= 0 && horizontal < 6, badSizeIndexError);
      final ms = basicSizes[horizontal];
      l = ms;
      r = ms;
    }
    if(top != null) {
      assert(top >= 0 && top < 6, badSizeIndexError);
      t = basicSizes[top];
    }
    if(bottom != null) {
      assert(bottom >= 0 && bottom < 6, badSizeIndexError);
      b = basicSizes[bottom];
    }
    if(left != null) {
      assert(left >= 0 && left < 6, badSizeIndexError);
      l = basicSizes[left];
    }
    if(right != null) {
      assert(right >= 0 && right < 6, badSizeIndexError);
      r = basicSizes[right];
    }

    return EdgeInsets.fromLTRB(l, t, r, b);
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

mixin AFDeviceFormFactorMixin {
  bool deviceHasFormFactor({
    AFFormFactor? atLeast,
    AFFormFactor? atMost,
    Orientation? withOrientation
  });

  bool get deviceIsTablet {
    return deviceHasFormFactor(atLeast: AFFormFactor.smallTablet);
  }

  bool get deviceIsPhone {
    return deviceHasFormFactor(atMost: AFFormFactor.largePhone);
  }

  bool get deviceIsLandscapeTablet {
    return deviceHasFormFactor(atLeast: AFFormFactor.smallTablet, withOrientation: Orientation.landscape);
  }
}

/// Functional themes are interfaces that provide UI theming
/// for conceptual components that are shared across many pages
/// in the app.
/// 
/// For example, a functional theme might answer the question,
/// what does a recurring 'section header' look like across the app.
/// 
/// An app will have at least one functional theme, but it might
/// split functional themes up into multiple areas (e.g. settings, 
/// signin, main app, etc).
/// 
/// Functional themes also provide a way for complex third party 
/// components (for example, an entire set of third party signin pages,
/// a map or audio/video component) to delegate theming decisions
/// to the app that contains them.  Apps can override the functional themes
/// provided by third parties.  
/// 
/// Functional themes should never contain data.  Data should be stored in
/// the [AFFundamentalThemeState], which is referenced by each functional theme.
/// 
/// Each [AFConnectedWidget] is parmeterized with a functional theme
/// type, and that theme will be accessible via the context.theme and
/// context.t methods.
@immutable
class AFFunctionalTheme with AFDeviceFormFactorMixin {
  final AFThemeID id;
  final AFFundamentalThemeState fundamentals;
  final AFBuildContext context;
  AFFunctionalTheme(
    this.id,
    this.fundamentals,
    this.context,
  );

  ThemeData? get themeData {
    return fundamentals.themeData;
  }

  TFunctionalTheme accessTheme<TFunctionalTheme extends AFFunctionalTheme>(AFThemeID themeId) {
    final fundamentals = AFibF.g.internalOnlyActiveStore.state.public.themes.fundamentals;
    return AFibF.g.coreDefinitions.createFunctionalTheme(themeId, fundamentals, context) as TFunctionalTheme;
  }

  /// Intended to be used in subclasses to access [AFOnEventContext] in event handlers for returned widgets.
  /// 
  /// Data from this object should not be used in rendering.  If you need additional data for rendering in a theme subclass
  /// (especially for a third party library), then see ..._define_core.dart `context.addStateViewAugmentationHandler`.
  AFOnEventContext accessOnEventContext() {
    return AFBuildOnEventContext(
      dispatcher: context.dispatcher,
      buildContext: context,
    );
  }

  /// A utility for creating a list of widgets in a row.   
  /// 
  /// This allows for a readable syntax like:
  /// ```dart
  /// final cols = context.t.childrenRow();
  /// ```
  List<Widget> row() { return <Widget>[]; }

  /// A utility for creating a list of widgets in a column.
  /// 
  /// This allows for a reasonable syntax like:
  /// ```dart
  /// final rows = context.t.childrenColumn();
  /// ```
  List<Widget> column() { return <Widget>[]; }


  /// Identical to [row], except prefixed with children to enhance discoverability
  List<Widget> childrenRow() { return <Widget>[]; }

  /// Identical to [column], except prefixed with children to enhance discoverability
  List<Widget> childrenColumn() { return <Widget>[]; }

  /// Returns a string label fpor hours and minutes that respects the device's 
  /// always24Hours settings
  /// 
  String textHourMinuteLabel(int hour, int minute, { bool? alwaysUse24Hours }) {
    var always = alwaysUse24Hours ?? deviceAlwaysUse24HourFormat;
    var suffix = ' am';
    var nHour = hour;
    if(always) {
      suffix = '';
    } else if(nHour >= 12) {
      suffix = ' pm';
      if(nHour > 12) {
        nHour -= 12;
      }
    }
    final buffer = StringBuffer();
    buffer.write(nHour);
    buffer.write(':');
    buffer.write(minute.toString().padLeft(2, '0'));
    buffer.write(suffix);
    return buffer.toString();
  }

  Widget childEmbeddedRender({
    required AFRenderEmbeddedChildDelegate render
  }) {
    return render();
  }

  Widget childTextEmpty() {
    return childText(text: "");
  }


  /// A utility for creating a list of child widgets
  /// 
  /// This allows for a readable syntax like:
  /// ```dart
  /// final cols = context.t.children();
  /// ```
  List<Widget> children() { return <Widget>[]; }

  /// A utility for create a list of table rows in a table.
  List<TableRow> columnTable() { return <TableRow>[]; }

  /// A utility for create a list of table rows in a table.
  List<TableRow> childrenTable() { return <TableRow>[]; }

  /// A utility for creating a list of expansion panels in an expansion list.
  List<ExpansionPanel> childrenExpansionList() { return <ExpansionPanel>[]; }


  Color colorDarker(dynamic color, { int percent = 10 }) {
    final c = color(color);
    if(c == null) {
      throw AFException("$color must be a valid color");
    }
    return AFThemeAreaUtilties.colorDarker(c, percent);    
  }

  Color colorLighter(dynamic c, { int percent = 10 }) {
    final cFound = color(c);
    if(cFound == null) {
      throw AFException("$color must be a valid color");
    }
    return AFThemeAreaUtilties.colorLighter(cFound, percent);
  }

  // The primary color from [ThemeData], adjusted for light/dark mode.
  Color get colorPrimary {
    return fundamentals.colorPrimary;
  }

  Color get colorPrimaryDarker {
    return fundamentals.findValue<Color>(AFUIThemeID.colorPrimaryDarker) ?? colorPrimary;
  }

  Color get colorPrimaryLighter {
    return fundamentals.findValue<Color>(AFUIThemeID.colorPrimaryLighter) ?? colorPrimary;
  }

  Color get colorAlert {
    return fundamentals.findValue<Color>(AFUIThemeID.colorAlert) ?? colorPrimary;
  }

  Color get colorOnAlert {
    return fundamentals.findValue<Color>(AFUIThemeID.colorOnAlert) ?? colorPrimary;
  }

  Color get colorWhite {
    return Colors.white;
  }

  Color get colorBlack {
    return Colors.black;
  }

  Color colorGreyShade(int shade) {
    return Colors.grey[shade] ?? Colors.grey;
  }

  Color get colorPrimaryDisabled {
    final result = Colors.grey[400];
    if(result == null) {
      return Colors.grey;
    }
    return result;
  }

  /// The foreground color on a primary background from [ThemeData]
  Color get colorOnPrimary {
    return fundamentals.colorOnPrimary;
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

  ButtonStyle styleTextButton({
    Color? color,
    Color? textColor
  }) {
    return TextButton.styleFrom(
      backgroundColor: color,
      foregroundColor: textColor
    );
  }


  ButtonStyle styleTextButtonPrimary() {
    return styleTextButton(
      color: colorPrimary,
      textColor: colorOnPrimary,
    );
  }

  /// See [TextTheme], text theme to use on a card background
  TextTheme get styleOnCard {
    return themeData!.textTheme;
  }

  /// See [TextTheme], text theme to use on a primary color background
  TextTheme get styleOnPrimary {
    return themeData!.primaryTextTheme;
  }

  /// Flutter by default does not have a styleOnSecondary, I am not sure why.
  /// 
  /// This is here so that you can override it if you need to, and can maintain
  /// a more logical style of code where text on top of the secondary color has the
  /// 'OnSecondary' style.
  TextTheme get styleOnSecondary {
    return themeData!.primaryTextTheme;
  }

  /// Merges bold into whatever the style would have been.
  TextStyle styleBold() { 
    return const TextStyle(fontWeight: FontWeight.bold);
  }

  TextStyle hintStyle() {
    return const TextStyle(color: Colors.grey);
  }

  TextStyle styleHint() {
    return hintStyle();
  }

  TextStyle errorStyle() {
    return TextStyle(color: colorOnError);
  }

  TextStyle styleError() { 
    return errorStyle();    
  }

  Radius radiusCircular(double r) {
    return Radius.circular(r);
  }

  AFNotTranslated notTranslated(Object value) {
    return AFNotTranslated(value.toString());
  }

  /// Here for discoverability, you might prefer [notTranslated].
  AFNotTranslated translateNever(Object value) {
    return notTranslated(value);
  }

  AFTranslationTemplate translateTemplate({ 
    required Object template,
    required Map<Object, Object> insertions
  }) {
    return AFTranslationTemplate(template: template, insertions: insertions);
  }

  BorderRadius borderRadiusScaled({
    double? all,
    double? left,
    double? right,
    double? top,
    double? bottom,
    double? leftTop,
    double? leftBottom,
    double? rightTop,
    double? rightBottom,
    Radius Function(double)? createRadius,
  }) {
    // by default, the radius is half the margin.
    final base = size2;
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
    createRadius ??= radiusCircular;

    return BorderRadius.only(
      topLeft: createRadius(lt),
      bottomLeft: createRadius(lb),
      topRight: createRadius(rt),
      bottomRight: createRadius(rb)
    );
  }

  /// Translate the specified string id and return it.
  /// 
  /// The text parameter can be one of five different values types:
  ///   * An String in your default language, useful for prototyping
  ///   * An AFTranslationID, if you wish to explicitly specify translation IDs
  ///   * An AFNotTranslated value, if the value is a name of other text that should not be translated.
  ///   * An AFTranslateTemplateValue, if you want to specify a template with other (usually not translatable) values inserted within it
  ///   * Or null, in which case the wid parameter is required, and is used as a translation ID
  /// Note that you can specify string translations as part of the fundamental theme, which is defined in your ...define_core.dart file.
  String translate({AFWidgetID? wid,  Object? text}) {
    return fundamentals.translate(wid: wid, text: text);
  }

  FontWeight? weight(dynamic weight) {
    return fundamentals.weight(weight);
  }

  Widget childDivider({
    Color? color
  }) {
    return Divider(color: color, height: 2);
  }

  AFRichTextBuilder childRichTextBuilder({
    AFWidgetID? wid,
    dynamic styleNormal,
    dynamic styleBold,
    dynamic styleTapable,
    dynamic styleMuted,
  }) {
    final normal = styleText(styleNormal);
    final bold = styleText(styleBold);
    final tapable = styleText(styleTapable);
    final muted = styleText(styleMuted);

    return AFRichTextBuilder(
      theme: fundamentals,
      wid: wid,
      styleNormal: normal,
      styleBold: bold,
      styleTapable: tapable,
      styleMuted: muted
    );
  }

  AFRichTextBuilder childRichTextBuilderOnCard({ 
    AFWidgetID? wid
  }) {

    return childRichTextBuilder(
      wid: wid,
      styleNormal: styleOnCard.bodyMedium,
      styleBold: styleOnCard.bodyLarge,
      styleTapable: styleOnCard.bodyMedium?.copyWith(color: colorTapableText),
      styleMuted: styleOnCard.bodyMedium,
    );
  }

  Color? get colorTapableText { 
    return fundamentals.colorTapableText;
  }

  AFTextBuilder childTextBuilder({
    AFWidgetID? wid,
    dynamic style,
  }) {
    return AFTextBuilder(
      theme: fundamentals,
      wid: wid,
      style: style
    );
  }

  Widget childButtonIcon({
    AFWidgetID? wid,
    required Widget child,
    required AFPressedDelegate onPressed,
    Color? color,
    VisualDensity? visualDensity,
  }) {
    return IconButton(
      visualDensity: visualDensity,
      key: keyForWID(wid),
      icon: child,
      color: color,
      onPressed: onPressed
    );
  }

  Widget childButton({
    AFWidgetID? wid,
    required Widget child,
    required AFPressedDelegate? onPressed,
    Color? color,
    Color? textColor    
  }) {
    final style = TextButton.styleFrom(
      backgroundColor: color,
      foregroundColor: textColor,
    );

    return TextButton(
      key: keyForWID(wid),
      style: style,
      onPressed: onPressed,
      child: child
    );
  }

  /// Create a button that the user is most likely to click.
  Widget childButtonPrimary({
    AFWidgetID? wid,
    required Widget child,
    required AFPressedDelegate? onPressed,
  }) {
    return childButton(
      wid: wid,
      child: child,
      color: colorPrimary,
      
      textColor: colorOnPrimary,
      onPressed: onPressed
    );
  }

  //--------------------------------------------------------------------------------------
  Widget childExtraScrollSpacer({double height = 100}) {
    return SizedBox(width: double.infinity, height: height);
  }

  /// Create a button that the user is most likely to click.
  /// 
  /// @see [translate] for all the ways text can be specified.
  Widget childButtonPrimaryText({
    AFWidgetID? wid,
    Object? text,
    required AFPressedDelegate onPressed,
  }) {
    return childButtonPrimary(
      wid: wid,
      child: childText(text: text),
      onPressed: onPressed
    );
  }

  /// Create a button that the user is most likely to click.
  /// 
  /// @see [translate] for all the ways text can be specified.
  Widget childButtonSecondaryText({
    AFWidgetID? wid,
    Object? text,
    required AFPressedDelegate onPressed,
  }) {
    return childButtonSecondary(
      wid: wid,
      child: childText(text: text),
      onPressed: onPressed
    );
  }


  /// @see [translate] for all the ways text can be specified.
  Widget childButtonFlatText({
    AFWidgetID? wid,
    Object? text,
    required AFPressedDelegate onPressed,
  }) {
    return childButtonFlat(
      wid: wid,
      child: childText(text: text),
      onPressed: onPressed
    );
  }

  /// Create a button that the user is most likely to click.
  Widget childButtonSecondary({
    AFWidgetID? wid,
    required Widget child,
    required AFPressedDelegate onPressed,
  }) {
    return childButton(
      wid: wid,
      child: child,
      color: colorSecondary,
      textColor: colorOnSecondary,
      onPressed: onPressed
    );
  }

  /// Create a button that the user is most likely to click.
  Widget childButtonFlat({
    AFWidgetID? wid,
    required Widget child,
    required AFPressedDelegate onPressed,
  }) {
    return childButton(
      wid: wid,
      child: child,
      onPressed: onPressed
    );
  }


  /// As long as you are calling [AFFunctionalTheme.childScaffold], you don't need
  /// to worry about this, it will be done for you.
  Widget? childDebugDrawerBegin(Widget? beginDrawer) {
    return _createDebugDrawer(beginDrawer, AFScreenPrototype.testDrawerSideBegin);
  }

  /// As long as you are calling [AFFunctionalTheme.childScaffold], you don't need
  /// to worry about this, it will be done for you.
  Widget? childDebugDrawerEnd(Widget? endDrawer) {
    return _createDebugDrawer(endDrawer, AFScreenPrototype.testDrawerSideEnd);
  }

  Widget childCard({ 
    required Widget child,
    AFWidgetID? wid,
    EdgeInsets? margin,
    Color? color,
  }) {
    return Card(
      key: keyForWID(wid),
      color: color,
      child: Container(
        margin: margin,
        child: child,
      )
    );
  }

  Widget childTopTabText({
    AFWidgetID? wid, 
    required String text,
    required bool isSel, 
    required AFPressedDelegate onPressed
  }) {
    final style = isSel ? styleOnPrimary.bodyLarge : styleOnPrimary.bodyMedium;
    final colorButton = isSel ? colorPrimaryDarker : colorPrimary;
    final buttonStyle = TextButton.styleFrom(
      backgroundColor: colorButton,
      textStyle: style,
    );
    return TextButton(
      key: keyForWID(wid),
      style: buttonStyle,
      onPressed: onPressed,
      child: childText(text: text, style: style)
    );
  }

  Widget childTopTab({
    AFWidgetID? wid, 
    required Widget child,
    required bool isSel, 
    required AFPressedDelegate onPressed
  }) {
    final style = isSel ? styleOnPrimary.bodyLarge : styleOnPrimary.bodyMedium;
    final colorButton = isSel ? colorPrimaryDarker : colorPrimary;
    final buttonStyle = TextButton.styleFrom(
      backgroundColor: colorButton,
      textStyle: style,
    );
    return TextButton(
      key: keyForWID(wid),
      style: buttonStyle,
      onPressed: onPressed,
      child: child
    );
  }

  Widget childTopTabContainer({required List<Widget> children,
    Color? color,
    BorderRadius? borderRadius,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: color ?? colorPrimary,
          borderRadius: borderRadius ?? this.borderRadius.standard,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: children
      )
    );
  }  

  Widget childCardColumn(List<Widget> rows, {
    EdgeInsets? padding,
    CrossAxisAlignment? align,
    AFWidgetID? widColumn,
    AFWidgetID? widCard,
    Color? color,
  }) {
    return Card(
      color: color,
      key: keyForWID(widCard),
      child: Container(
        margin: padding,
        child: Column(
          key: keyForWID(widColumn),
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: rows,
        )
      )
    );
  }

  /// As long as you are calling [AFFunctionalTheme.childScaffold], you don't need
  /// to worry about this, it will be done for you.
  Widget? _createDebugDrawer(Widget? drawer, int testDrawerSide) {
    final store = AFibF.g.internalOnlyActiveStore;
    final state = store.state;
    final testState = state.private.testState;
    final activeTestId = testState.activeTestId;
    if(activeTestId != null) {
      final test = AFibF.g.findScreenTestById(activeTestId);
      if(test != null && test.testDrawerSide == testDrawerSide && !AFibF.g.isDemoMode) {
        return AFUIPrototypeDrawer();
      }
    }
    return drawer;
  }

  /// A method used to create a standard scaffold, please use this instead of creating you scaffold
  /// manually with return Scaffold(...
  /// 
  /// This method does a few nice things for you:
  /// *  It automatically attaches the AFib prototype drawer in prototype mode.
  /// 
  /// You will most likely want to create one or more app-specific version of this method in your own app's 
  /// conceptual theme, which might fill in many of the parameters (e.g. appBar) with standard values, rather than 
  /// duplicating them on every screen.
  Widget childScaffold<TBuildContext extends AFBuildContext>({
    Key? key,
    required AFStateProgrammingInterface spi,
    AFConnectedUIBase? contextSource,
    PreferredSizeWidget? appBar,
    Widget? drawer,
    required Widget body,
    Widget? bottomNavigationBar,
    Widget? floatingActionButton,
    Color? backgroundColor,
    FloatingActionButtonLocation? floatingActionButtonLocation,
    FloatingActionButtonAnimator? floatingActionButtonAnimator,
    List<Widget>? persistentFooterButtons,
    Widget? endDrawer,
    Widget? bottomSheet,
    bool? resizeToAvoidBottomPadding,
    bool? resizeToAvoidBottomInset,
    bool primary = true,
    DragStartBehavior drawerDragStartBehavior = DragStartBehavior.start,
    bool extendBody = false,
    bool extendBodyBehindAppBar = false,
    Color? drawerScrimColor, 
    double? drawerEdgeDragWidth, 
    bool drawerEnableOpenDragGesture = true,
    bool endDrawerEnableOpenDragGesture = true    
  }) {

      return Scaffold(
        key: key,
        drawer: childDebugDrawerBegin(drawer),
        body: body,
        appBar: appBar,
        bottomNavigationBar: bottomNavigationBar,
        floatingActionButton: floatingActionButton,
        floatingActionButtonLocation: floatingActionButtonLocation,
        floatingActionButtonAnimator: floatingActionButtonAnimator,
        backgroundColor: backgroundColor,
        persistentFooterButtons: persistentFooterButtons,
        bottomSheet: bottomSheet,
        resizeToAvoidBottomInset: resizeToAvoidBottomInset,
        primary: primary,
        drawerDragStartBehavior: drawerDragStartBehavior,
        extendBody: extendBody,
        extendBodyBehindAppBar: extendBodyBehindAppBar,
        drawerScrimColor: drawerScrimColor,
        drawerEdgeDragWidth: drawerEdgeDragWidth,
        drawerEnableOpenDragGesture: drawerEnableOpenDragGesture,
        endDrawer: childDebugDrawerEnd(endDrawer),
      );
  }

  Widget childSwitch({
    AFWidgetID? wid,
    required bool value,
    required AFOnChangedBoolDelegate onChanged
  }) {
    return Switch(
      key: keyForWID(wid),
      value: value,
      onChanged: onChanged,
      activeTrackColor: colorLighter(colorPrimary),
      activeColor: colorPrimary,
    );
  }

  Widget childChoiceChip({
    AFWidgetID? wid,
    required Widget label,
    required bool selected,
    Color? selectedColor,
    required AFOnChangedBoolDelegate onSelected,
  }) {
    return ChoiceChip(
      key: keyForWID(wid),
      label: label,
      selectedColor: selectedColor,
      selected: selected,
      onSelected: onSelected
    );
  }

  Widget childMargin({
    AFWidgetID? wid, 
    required Widget child,
    required EdgeInsets? margin,  
  }) {
    return Container(
      key: keyForWID(wid),
      margin: margin,
      child: child
    );
  }

  Widget childMarginStandard({
    AFWidgetID? wid, 
    required Widget child,
  }) {
    return Container(
      key: keyForWID(wid),
      margin: margin.standard,
      child: child
    );
  }

  Widget childPadding({
    AFWidgetID? wid, 
    required Widget child,
    EdgeInsets? padding,  
  }) {
    return Container(
      key: keyForWID(wid),
      padding: padding,
      child: child
    );
  }

  /// Create a text field with the specified text.
  /// 
  /// See [AFTextEditingControllers] for an explanation
  /// of how text controllers should be handled.  The [wid] is
  /// used as the id for the specific controller. The [AFTextEditingControllers]
  /// should be created only once, when you first visit a screen, and then
  /// should be passed through via the 'copyWith' method, and then 
  /// disposed of the route parameter is disposed.
  Widget childTextField({
    required AFScreenID screenId,
    required AFWidgetID wid,
    AFTextEditingControllers? controllers,
    AFTextEditingController? controller,
    AFBuildContext? context,
    AFRouteParamWithFlutterState? parentParam,
    required AFOnChangedStringDelegate onChanged,
    String? expectedText,
    bool? enabled,
    bool obscureText = false,
    bool autofocus = false,
    int? minLines,
    int maxLines = 1,
    FocusNode? focusNode,
    InputDecoration? decoration,
    bool autocorrect = true,
    TextAlign textAlign = TextAlign.start,
    TextInputType? keyboardType,
    TextStyle? style,
    Color? cursorColor,
    ValueChanged<String>? onSubmitted,
  }) {
    return AFUITextField(
      screenId: screenId,
      wid: wid,
      enabled: enabled,
      style: style,
      focusNode: focusNode,
      controller: controller,
      controllers: controllers,
      parentParam: parentParam,
      expectedText: expectedText,
      onChanged: onChanged,
      minLines: minLines,
      maxLines: maxLines,
      keyboardType: keyboardType,
      obscureText: obscureText,
      autocorrect: autocorrect,
      autofocus: autofocus,
      textAlign: textAlign,
      decoration: decoration,
      onSubmitted: onSubmitted,
      cursorColor: cursorColor,
    );
  }

  TapGestureRecognizer tapRecognizerFor({
    required AFWidgetID wid,
    AFTapGestureRecognizersHolder? recognizers,
    AFRouteParamWithFlutterState? parentParam,
    required AFPressedDelegate onTap,
  }) {
    assert(recognizers != null || parentParam?.flutterStatePrivate != null, "You must specify either recognizers or parentParam");
    assert(recognizers == null || parentParam == null, "You cannot specify both recognizers and parentParam");
    recognizers ??= parentParam?.flutterState?.tapRecognizers;

    if(recognizers == null) {
      throw AFException("Need to specify recognizers or parentParam");
    }

    final recognizer = recognizers.access(wid);
    recognizer.onTap = onTap;
    return recognizer;
  }

  /// @see [translate] for all the ways text can be specified.
  Text childText({
    Object? text,
    AFWidgetID? wid, 
    dynamic style,
    dynamic textColor,
    dynamic fontSize,
    dynamic fontWeight,
    TextAlign? textAlign,
    TextOverflow? overflow,
    int? maxLines,
    bool? softWrap,
  }) {
    TextStyle? styleS;
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

    var textT = translate(wid: wid, text: text);
    return Text(textT, 
      key: keyForWID(wid),
      style: styleS,
      textAlign: textAlign,
      textScaleFactor: deviceTextScaleFactor,
      overflow: overflow,
      maxLines: maxLines,
      softWrap: softWrap,
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
    return fundamentals.deviceOrientation;
  }

  /// An appoximate form factor for the device.   
  /// 
  /// Since web browsers
  /// can be resized arbitrarily, in the web case this returns the best
  /// approximation in [AFFormFactor].
  AFFormFactor get deviceFormFactor {
    return fundamentals.deviceFormFactor;
  }

  @override
  bool deviceHasFormFactor({
    AFFormFactor? atLeast,
    AFFormFactor? atMost,
    Orientation? withOrientation
  }) {
    return fundamentals.deviceHasFormFactor(atLeast: atLeast, atMost: atMost, withOrientation: withOrientation);
  }


  bool get deviceIsLandscape {
    return deviceOrientation == Orientation.landscape;
  }

  bool get deviceIsPortrait {
    return deviceOrientation == Orientation.portrait;
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

  Size get deviceLogicalSize {
    return fundamentals.device.logicalSize;
  }


  /// The text scale factor for the device.
  double get deviceTextScaleFactor {
    return fundamentals.device.textScaleFactor(fundamentals);
  }

  /// The light/dark mode setting of the device.
  Brightness get deviceBrightness {
    return fundamentals.device.brightness(fundamentals);

  }

  bool get deviceIsDarkMode {
    return deviceBrightness == Brightness.dark;
  }

  bool get deviceIsLightMode {
    return !deviceIsDarkMode;
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
  LocalKey? keyForWID(AFID? wid) {
    return keyForWIDStatic(wid);
  }

  static LocalKey? keyForWIDStatic(AFID? wid) {
    if(wid == null) { return null; }
    return ValueKey<String>(wid.code);
  }

    /// Returns a unique key for the specified widget.
  LocalKey keyForWIDNotNull(AFID wid) {
    var result = keyForWIDStatic(wid);
    return result!;
  }


  Color? color(dynamic idOrColor) {
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

  TextStyle? styleText(dynamic idOrTextStyle) {
    if(idOrTextStyle == null) {
      return null;
    }
    if(idOrTextStyle is TextStyle) {
      return idOrTextStyle;
    }
    return fundamentals.textStyle(idOrTextStyle);
  }

  double? size(dynamic id, { double scale = 1.0 }) {
    if(id is double) {
      return id * scale;
    }
    return fundamentals.size(id, scale: scale);
  }

  double get size1 { 
    return fundamentals.size1;
  }

  double get size2 { 
    return fundamentals.size2;
  }

  double get size3 { 
    return fundamentals.size3;
  }

  double get size4 { 
    return fundamentals.size4;
  }

  double get size5 { 
    return fundamentals.size5;
  }

  Widget? iconStandard(AFUIStandardChoiceDialogIcon icon, { double? size }) {
    if(icon == AFUIStandardChoiceDialogIcon.error) {
      return Icon(Icons.report,
        size: size,
        color: Colors.red,
      );
    } else if(icon == AFUIStandardChoiceDialogIcon.info) {
      return Icon(Icons.info,
        size: size,
        color: Colors.blue,
      );
    } else if(icon == AFUIStandardChoiceDialogIcon.warning) {
      return Icon(Icons.warning,
        size: size,
        color: Colors.yellow[700] ?? Colors.yellow,
      );    
    } else if(icon == AFUIStandardChoiceDialogIcon.question) {
      return Icon(Icons.help,
        size: size,
        color: Colors.blue);
    }
    return null;
  }


  Widget? icon(dynamic id, {
    dynamic iconColor,
    dynamic iconSize
  }) {
    return fundamentals.icon(id, iconColor: iconColor, iconSize: iconSize);
  }

  Widget? iconNavDown({
    dynamic iconColor,
    dynamic iconSize
  }) {
    return icon(AFUIThemeID.iconNavDown, iconColor: iconColor, iconSize: iconSize);
  }

  Widget? iconBack({
    dynamic iconColor,
    dynamic iconSize
  }) {
    return icon(AFUIThemeID.iconBack, iconColor: iconColor, iconSize: iconSize);
  }

  Color get colorSecondary {
    return fundamentals.colorSecondary;
  }

  Color get colorOnSecondary {
    return fundamentals.colorOnPrimary;
  }

  /// Important: the values you are passing in are scale factors on the
  /// value specified by your fundamental theme they are not
  /// absolute measurements.
  /// 
  /// For example, if the default margin is 8.0, and you pass in all: 2,
  /// you will get 16 all the way around.
  EdgeInsets paddingCustom({
    int? horizontal,
    int? vertical,
    int? top,
    int? bottom,
    int? left,
    int? right,
    int? all
  }) {
    return fundamentals.paddingCustom(
      horizontal: horizontal,
      vertical: vertical,
      top: top,
      bottom: bottom,
      left: left,
      right: right,
      all: all
    );
  }

  AFSpacing get margin {
    return fundamentals.margin;
  }

  AFSpacing get contentPadding {
    return fundamentals.marginSpacing;
  }


  AFSpacing get padding {
    return fundamentals.padding;
  }

  AFBorderRadius get borderRadius {
    return fundamentals.borderRadius;
  }

  /// Create a custom margin based on the standard sizes you setup in your fundamental theme.
  ///
  /// The values you are passing in offsets into the 
  /// list of 6 sizes you passed into [AFAppFundamentalThemeAreaBuilder.setAfibFundamentals].
  /// 
  /// The margin is constructed starting from the most general offset (all), and overriding
  /// it with more specific values (horizontal, vertical, then top, left, right, bottom).  So,
  /// using 
  /// ```
  /// final m = t.marginScaledCustom(all: 3, b: 0)
  /// ```
  /// Would give you your standard margin all around, but zero on the bottom. 
  /// 
  /// If a margin side is not specified, it defaults to zero.
  EdgeInsets marginCustom({
    int? all,
    int? horizontal,
    int? vertical,
    int? top,
    int? bottom,
    int? left,
    int? right,
  }) {
    return fundamentals.marginCustom(
      all: all,
      horizontal: horizontal,
      vertical: vertical,
      top: top,
      bottom: bottom,
      left: left,
      right: right
    );
  }

  /// Show the text in a snackbar. 
  /// 
  /// You might prefer [AFBuildContext.showSnackbarText].  This is just
  /// a one line call to that method for discoverability.
  void showSnackbarText(AFStateProgrammingInterface spi, String text) {
    spi.context.showSnackbarText(
        themeOrId: spi.t,
        text: text
    );
  }

  /// See [AFBuildContext.showDialogAFib], this is just a one line call to that method
  /// for discoverability.
  void showDialog<TReturn>({
    required AFStateProgrammingInterface spi,
    required AFNavigatePushAction navigate,
    void Function(TReturn?)? onReturn,
    bool barrierDismissible = true,
    Color? barrierColor,
    bool useSafeArea = true,
    bool useRootNavigator = true,
    RouteSettings? routeSettings
  }) {
    spi.context.showDialogAFib(
      navigate: navigate,
      onReturn: onReturn,
      barrierDismissible: barrierDismissible,
      barrierColor: barrierColor,
      useSafeArea: useSafeArea,
      useRootNavigator: useRootNavigator,
      routeSettings: routeSettings,
    );
  }

  /// See [AFBuildContext.showModalBottomSheetAFib], this is a one line call to that method, here for discoverability.
  void showModalBottomSheet({
    required AFStateProgrammingInterface spi,
    required AFNavigatePushAction navigate,
    AFReturnValueDelegate? onReturn,
    Color? backgroundColor,
    double? elevation,
    ShapeBorder? shape,
    Clip? clipBehavior,
    Color? barrierColor,
    bool isScrollControlled = false,
    bool useRootNavigator = false,
    bool isDismissible = true,
    bool enableDrag = true,
    RouteSettings? routeSettings,  
  }) {
    return spi.context.showModalBottomSheetAFib(
      navigate: navigate,
      onReturn: onReturn,
      backgroundColor: backgroundColor,
      elevation: elevation,
      shape: shape,
      clipBehavior: clipBehavior,
      barrierColor: barrierColor,
      isScrollControlled: isScrollControlled,
      useRootNavigator: useRootNavigator,
      isDismissible: isDismissible,
      enableDrag: enableDrag,
      routeSettings: routeSettings,
    );
  }

  /// See [AFBuildContext.showBottomSheet], this is a one line call to that method, here for discoverability.
  void showBottomSheet({
    required AFStateProgrammingInterface spi,
    required AFNavigatePushAction navigate,
    Color? backgroundColor,
    double? elevation,
    ShapeBorder? shape,
    Clip? clipBehavior,
  }) {
    return spi.context.showBottomSheet(
      navigate: navigate,
      backgroundColor: backgroundColor,
      elevation: elevation,
      shape: shape,
      clipBehavior: clipBehavior,
    );
  }

  Row childRow(List<Widget> children, {
   MainAxisAlignment mainAxisAlignment =  MainAxisAlignment.start
  }) {
    return Row(mainAxisAlignment: mainAxisAlignment, children: children);
  }

  Column childColumn(List<Widget> children, {
   AFWidgetID? wid,
   MainAxisAlignment mainAxisAlignment =  MainAxisAlignment.start,
   CrossAxisAlignment crossAxisAlignment = CrossAxisAlignment.start,
   MainAxisSize mainAxisSize = MainAxisSize.max,
  }) {
    return Column(key: keyForWID(wid),
      mainAxisAlignment: mainAxisAlignment,
      crossAxisAlignment: crossAxisAlignment,
      mainAxisSize: mainAxisSize,children: children,
    );
  }


  /// Create a widget that has the [bottomControls] and [topControls] permenantly
  /// affixed above/below the [main] widget.
  Widget childTopBottomHostedControls(BuildContext context, Widget main, {
    Widget? bottomControls,
    Widget? topControls,
    double topHeight = 0.0
  }) {
    final stackChildren = column();


    stackChildren.add(Positioned(
      key: keyForWID(AFUIWidgetID.positionedCenterHosted),
      top: topHeight, left: 0, bottom: 0, right: 0,
      child: main));

    if(topControls != null) {
      stackChildren.add(Positioned(
        key: keyForWID(AFUIWidgetID.positionedTopHosted),
        top: 0, left:0, right: 0,
        child: topControls
      ));
    }

    if(bottomControls != null) {
      stackChildren.add(Positioned(
        key: keyForWID(AFUIWidgetID.positionedBottomHosted),
        left: 0, right: 0, bottom: 0,
        child: bottomControls
      ));
    }
    return Container(
      key: keyForWID(AFUIWidgetID.contHostedControls),
      child: Stack(children: stackChildren));
  }

  Widget leadingButtonStandardBack(AFStateProgrammingInterface spi, {
    required AFScreenID screen,
    AFWidgetID wid = AFUIWidgetID.buttonBack,
    dynamic iconIdOrWidget = AFUIThemeID.iconBack,
    dynamic iconColor,
    dynamic iconSize,
    String tooltip = "Back",
    bool worksInSingleScreenTest = true,
    AFShouldContinueCheckDelegate? shouldContinueCheck,   
  }) {
    return childButtonStandardBack(spi, 
      screen: screen,
      wid: wid,
      iconIdOrWidget: iconIdOrWidget,
      iconColor: iconColor,
      iconSize: iconSize,
      tooltip: tooltip,
      worksInSingleScreenTest: worksInSingleScreenTest,
      shouldContinueCheck: shouldContinueCheck,
    );
  }

  /// Creates a standard back button, which navigates up the screen hierarchy.
  /// 
  /// The back button can optionally display a dialog which checks whether the user
  /// should continue, see [standardShouldContinueAlertCheck] for more.
  Widget childButtonStandardBack(AFStateProgrammingInterface spi, {
    required AFScreenID screen,
    AFWidgetID wid = AFUIWidgetID.buttonBack,
    dynamic iconIdOrWidget = AFUIThemeID.iconBack,
    dynamic iconColor,
    dynamic iconSize,
    String tooltip = "Back",
    bool worksInSingleScreenTest = true,
    AFShouldContinueCheckDelegate? shouldContinueCheck,   
  }) {
    var ico = icon(iconIdOrWidget, iconColor: iconColor, iconSize: iconSize);
    if(ico == null) throw AFException("Could not create icon");
    return IconButton(
        key: keyForWID(wid),      
        icon: ico,
        tooltip: translate(text: tooltip),
        onPressed: () async {
          if(shouldContinueCheck == null || await shouldContinueCheck() == AFShouldContinue.yesContinue) {
            spi.context.navigatePop(worksInSingleScreenTest: worksInSingleScreenTest);
            spi.context.executeWireframeEvent(wid, null);
          } 
        }
    );
  }
  
  /*
  /// Create a list of connected children.  
  /// 
  /// The calling context must have a [AFRouteParamWithChildren] as its route parameter.   This method
  /// will iterate through all children with route parameters of the specified type, and will call your
  /// render function once for each one.   You must use the widget id passed to you by the render function.
  List<Widget> childrenConnectedRender<TRouteParam extends AFRouteParam>(AFBuildContext context, {
    required AFScreenID screenParent,
    required AFRenderConnectedChildDelegate render
  }) {
    return context.childrenConnectedRender(screenParent: screenParent, render: render);
  }
  */

  /// 
  AFShouldContinueCheckDelegate standardShouldContinueAlertCheck({
    required AFStateProgrammingInterface spi,
    required bool shouldAsk,
    required AFNavigatePushAction navigate
  }) {
    return () {
        final completer = Completer<AFShouldContinue>();

        if(shouldAsk && !AFibD.config.isTestContext) {
          // set up the buttons
          // show the dialog
          spi.context.showDialogAFib<AFShouldContinueRouteParam>(
            navigate: navigate,
            onReturn: (param) {
              if(param != null) {
                final should = param;
                completer.complete(should.shouldContinue);
              }
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
  List<Widget> childrenDivideWidgets(List<Widget> rows, AFWidgetID? widBase, {
    dynamic colorLine,
    dynamic thickness,
    dynamic height,
    dynamic indent

  }) {
    final c = color(colorLine);
    final thick = size(thickness);
    final h = size(height);
    final ind = size(indent);
    final result = column();
    for(var i = 0; i < rows.length; i++) {
      final widget = rows[i];
      result.add(widget);
      if(i+1 < rows.length) {
        var key;
        if(widBase != null) {
          key = keyForWID(widBase.with2("divider", i.toString()));
        }
        result.add(Divider(
          key: key,
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
class AFFunctionalThemeUnused extends AFFunctionalTheme {
  AFFunctionalThemeUnused(AFFundamentalThemeState fundamentals, AFBuildContext context): super(AFUIThemeID.unused, fundamentals, context);
}

/// Captures the current state of the primary theme, and
/// any registered third-party themes.
class AFThemeState {
  final AFFundamentalThemeState fundamentals;

  AFThemeState({
    required this.fundamentals
  });


  factory AFThemeState.create({
    required AFFundamentalThemeState fundamentals,
  }) {

    return AFThemeState(
      fundamentals: fundamentals
    );
  }

  AFFunctionalTheme createFunctionalTheme(AFThemeID themeId, AFBuildContext context) {
    return AFibF.g.coreDefinitions.createFunctionalTheme(themeId, fundamentals, context);
  }

  AFThemeState reviseOverrideThemeValue(AFThemeID id, dynamic value) {
    final revised = fundamentals.reviseOverrideThemeValue(id, value);
    final revisedState = copyWith(
      fundamentals: revised
    );
    AFibD.logThemeAF?.d("Overriding theme value: $id = $value");
    return revisedState;
  }

  AFThemeState reviseRebuildAll() {
    return AFibF.g.initializeThemeState();
  }

  AFThemeState copyWith({
    AFFundamentalThemeState? fundamentals,
     Map<AFThemeID, AFFunctionalTheme>? functionals,
  }) {
    return AFThemeState.create(
      fundamentals: fundamentals ?? this.fundamentals
    );
  }
}