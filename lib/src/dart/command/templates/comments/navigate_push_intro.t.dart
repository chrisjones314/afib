
import 'package:afib/src/dart/command/af_source_template.dart';

class NavigatePushIntroComment extends AFSourceTemplateComment {
  final String template = '''
  /// From an event in another screen, you can navigate to this screen
  /// using spi.navigatePush([!af_screen_name].navigatePush());
  /// You will add parameters to this method to populate your route param
  /// with appropriate initial values as you navigate to the screen.
  /// 
  /// Over time, this method will be useful because you are likely to add
  /// route parameter state which is better initialized here than
  /// duplicating the initialization across the potentially multiple
  /// places this method is called.
''';
}
