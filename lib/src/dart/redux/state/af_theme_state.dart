
import 'dart:ui';

import 'package:afib/afib_dart.dart';
import 'package:afib/src/dart/utils/af_id.dart';
import 'package:afib/src/flutter/core/afui.dart';
import 'package:flutter/material.dart';

/// Consolidating base class for [AFFundamentalTheme] and [AFConceptualTheme]
class AFTheme {

}

/// These are fundamental values for theming derived from the device
/// and operating system itself.
class AFFundamentalDeviceTheme {
  final Brightness brightness;
  final bool alwaysUse24HourFormat;
  final WindowPadding padding;
  final WindowPadding viewInsets;
  final WindowPadding viewPadding;
  final Locale locale;
  final Size physicalSize;
  final double textScaleFactor;

  AFFundamentalDeviceTheme({
    @required this.brightness,
    @required this.alwaysUse24HourFormat,
    @required this.padding,
    @required this.viewInsets,
    @required this.viewPadding,
    @required this.locale,
    @required this.physicalSize,
    @required this.textScaleFactor,
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
      brightness: brightness,
      alwaysUse24HourFormat: alwaysUse24,
      padding: padding,
      viewInsets: viewInsets,
      viewPadding: viewPadding,
      locale: locale,
      physicalSize: physicalSize,
      textScaleFactor: textScaleFactor);
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

/// Allows different parties to contribute fundamental values
/// to a theme which are can be manipulated via the prototype 
/// drawer.
@immutable
class AFFundamentalThemeArea {
  final AFThemeID id;
  final values = <AFThemeID, AFFundamentalThemeValue>{};

  AFFundamentalThemeArea({
    @required this.id
  });

  void supplementMissingFrom(AFFundamentalThemeArea other) {
    for(final value in other.values.values) {
      if(!values.containsKey(value.id)) {
        values[value.id] = value;
      }
    }    
  }

  Color color(AFThemeID id) {
    return findValue(id);
  }

  dynamic findValue(AFThemeID id) {
    final val = values[id];
    if(val != null) {
      return val.value;
    }
    return null;
  }

  void setValues(Map<AFThemeID, dynamic> toSet) {
    toSet.forEach((id, val) {
      values[id] = AFFundamentalThemeValue(id: id, value: val);
    });
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
  final AFFundamentalThemeArea primary;
  final ThemeData themeData;
  final areas = <AFThemeID, AFFundamentalThemeArea>{};
  
  AFFundamentalTheme({
    @required this.device,
    @required this.primary,
    @required this.themeData
  });  

  void addArea(AFFundamentalThemeArea area) {
    final id = area.id;
    if(areas.containsKey(id)) {
      final existing = areas[id];
      existing.supplementMissingFrom(area);
    } else {
      areas[id] = area;
    }
  }

  Color color(AFThemeID id, { AFThemeID area }) {
    return findValue(id, area);
  }

  TextStyle textStyle(AFThemeID id, { AFThemeID area }) {
    return findValue(id, area);
  }

  dynamic findValue(AFThemeID id, AFThemeID area) {
    final areaObj = areas[area];
    var color = areaObj?.findValue(id);
    if(color == null) {
      color = primary.findValue(id);
    }
    return color;
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
  final AFThemeID primaryThemeArea;
  AFConceptualTheme({
    @required this.fundamentals, 
    @required this.primaryThemeArea
  });

  /// A utility for creating a list of widgets in a row.   
  /// 
  /// This allows for a readable syntax like:
  /// ```dart
  /// final cols = row();
  /// ```
  List<Widget> row() { return <Widget>[]; }

  /// A utikity for creating a list of widgets in a column.
  /// 
  /// This allows for a reasonable syntax like:
  /// ```dart
  /// final rows = column();
  /// ```
  List<Widget> column() { return <Widget>[]; }


  /// Returns a unique key for the specified widget.
  Key keyForWID(AFWidgetID wid) {
    return AFUI.keyForWID(wid);
  }

  Color color(AFThemeID id) {
    return fundamentals.color(id, area: primaryThemeArea);
  }

  TextStyle textStyle(AFThemeID id) {
    return fundamentals.textStyle(id, area: primaryThemeArea);
  }

}

/// Can be used as a template parameter when you don't want a theme.
class AFConceptualThemeUnused extends AFConceptualTheme {
  AFConceptualThemeUnused(AFFundamentalTheme fundamentals): super(fundamentals: fundamentals, primaryThemeArea: AFPrimaryThemeID.fundamentalTheme);
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