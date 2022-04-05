import 'package:afib/src/dart/command/af_source_template.dart';

class BuildBodyIntroComment extends AFSourceTemplateComment {
  final String template = '''
  /// This method is called any time your route parameter or any data in your
  /// state view changes.
  /// 
  /// Within this method and its sub-procedures, you will build and return
  /// a single widget representing your screen/widget etc.   The SPI provides
  /// access to all the data you will need:
  /// 
  /// spi.t - the default theme, though you can also access other themes
  ///   via spi.findTheme.
  /// spi.context - a context providing access to your route parameter (context.p)
  ///   and state view (context.s).  Note that generally you will not refence those
  ///   values directly from UI code, but rather will reference SPI member variables
  ///   or accessors which themselves reference the route param and state view values.
  /// 
  /// It also provides methods for all the actions you will need to respond to user 
  /// events
  /// 
  /// spi.update... - update your route parameter, or a root model in your state directly
  /// spi.show... - show dialogs, drawers, bottom sheets, etc.
  /// spi.navigate... -- update your navigational route 
  /// spi.execute... -- execute queries which interact with the outside world (e.g. cloud,
  ///    apis, anything async, and then integrate the results back into your state)
  /// 
  /// Again, mostly these methods will be called from within the SPI itself, rather than
  /// directly from the UI code.  Better UI code would be:
  /// 
  /// ```dart
  /// IconButton(
  ///   ...
  ///   onPressed: spi.onPressedSave
  /// );
  /// ```
  /// Where onPressedHelp would reference context.p or context.s and then call show...
  /// or navigate... or execute... etc.
''';
}
