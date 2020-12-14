
import 'dart:ui';

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

/// These are fundamental values for theming derived from the
/// app itself, and from the [AFFundamentalDeviceTheme].
abstract class AFFundamentalAppTheme {
  final ThemeData flutterTheme;

  AFFundamentalAppTheme({
    @required this.flutterTheme
  });
}


/// Fundamental values that contribute to theming in the app.
/// 
/// All the [AFConceptualTheme] instances below should derive
/// their behavior from the fundamental values provided 
/// by this class.
class AFFundamentalTheme {
  final AFFundamentalDeviceTheme device;
  final AFFundamentalAppTheme app;

  AFFundamentalTheme({
    @required this.device,
    @required this.app,
  });
  
  factory AFFundamentalTheme.create(AFFundamentalAppTheme app) {
    return AFFundamentalTheme(
      device: AFFundamentalDeviceTheme.create(),
      app: app,
    );
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

}

/// Captures the current state of the primary theme, and
/// any registered third-party themes.
class AFThemeState {
  final AFFundamentalTheme fundamentals;
  final Map<String, AFConceptualTheme> conceptual;  

  AFThemeState({
    @required this.fundamentals,
    @required this.conceptual
  });
}