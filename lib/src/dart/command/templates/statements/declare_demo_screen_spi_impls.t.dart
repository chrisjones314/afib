


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
  int get clickCountParam {
    return context.p.clickCount;
  }

  /// The difference between
  int get clickCountState {
    return context.s.countInState.count;
  }

  /// The second main role is to move event handling logic out of the UI and into 
  /// a business logic object.   This SPI will be accessible from state tests, so you can
  /// manipulate the state from 'almost' the UI level in your tests, without actually building
  /// your UI.
  void onIncrementParamCount() {
    /// Note that the route parameter is immutable, so we must make a copy of it when we 
    /// change it.  Although this is a trivial example, I like to add revise... methods 
    /// to the route parameter which achieve specific conceptual goals.  It makes it easy to find
    /// the existing revise methods when I pick up the code later.
    final revised = context.p.reviseIncrementClickCount();
    context.updateRouteParam(revised);
  }

  void onIncrementStateCount() {
    /// The state is also immutable.   You will always update state objects at the root of your
    /// state, so if you have nested data structures you will need to chase changes up your 
    /// hierarchy until you get to a root object in your state.
    /// 
    /// Specifying <HCState> as a type parameter is necessary because third parties can also 
    /// contribute state, so you need to say which component's state you are updating.
    final revised = context.s.countInState.reviseIncrementCount();
    context.updateComponentRootStateOne<HCState>(revised);
  }
''';
}
