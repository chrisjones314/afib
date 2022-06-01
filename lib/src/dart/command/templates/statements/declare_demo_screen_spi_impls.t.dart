


import 'package:afib/src/dart/command/af_source_template.dart';

class DeclareDemoScreenSPIImplsT extends AFSourceTemplate {
  final String template = '''
  /// One of the main roles of this SPI is to present a simplified view of your 
  /// business data to the UI, moving filtering and other business logic out of 
  /// the UI code, and into a class which will be easily accessible from state tests
  /// without actually building the UI.
  /// 
  /// Note that you can do this in accessors, like this, or by adding final variables
  /// and initializing them in the factory method above.
  int get clickCount {
    return context.p.clickCount;
  }

  /// The second main role is to move event handling logiic out of the UI and into 
  /// a business logic.
  void onIncrementCount() {
    /// Note that the route parameter is immutable, so we must make a copy of it when we 
    /// change it.  Although this is a trivial example, I like to add revise... methods 
    /// to the route parameter which achieve specific conceptual goals.  It makes it easy to find
    /// the existing revise methods when I pick up the code later.
    final revised = context.p.reviseIncrementClickCount();
    context.updateRouteParam(revised);
  }
''';
}
