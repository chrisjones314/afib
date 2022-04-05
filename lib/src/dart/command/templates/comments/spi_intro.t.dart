import 'package:afib/src/dart/command/af_source_template.dart';

class SPIIntroComment extends AFSourceTemplateComment {
  final String template = '''
/// This state programming interface has two roles:
/// 
/// -- it exposes the data consumed by the screen in a simple format.  You can do this
///    using 'get' accessors, or by creating final member variables, and initializing them
///    within the factory method.  Your goal should be to make the UI code as simple and
///    logic-less as possible, as all the data preparation has been done in the SPI
/// 
/// -- it exposes methods which handle the business logic associated with UI events.
/// 
/// The SPI is the level at which state-based testing occurs, so keeping business logic
/// in the SPI rather than embedded in the UI code itself will make your code more testable.
''';
}
