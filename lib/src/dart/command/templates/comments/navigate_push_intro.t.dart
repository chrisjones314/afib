
import 'package:afib/src/dart/command/af_source_template.dart';

class NavigatePushIntroComment extends AFSourceTemplateComment {
  final String template = '''
  /// From an event in another screen, you can navigate to this screen
  /// using spi.navigatePush(StartupScreen.navigatePush());
  /// You will add parameters to this method to populate your route param
  /// with appropriate initial values as you navigate to the screen.
  /// 
  /// Even if you visit the screen in exactly one place in your code,
  /// this method is also called from test code which navigates to the screen.
  /// This method allows you to consolidate standard initialization of the route parameter,
  /// rather than having is sprinkled in muliple places.
''';
}
