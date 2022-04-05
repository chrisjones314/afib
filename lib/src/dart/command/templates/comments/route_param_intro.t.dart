import 'package:afib/src/dart/command/af_source_template.dart';

class RouteParamIntroComment extends AFSourceTemplateComment {
  final String template = '''
/// Your route parameter should contain transient data about the state 
/// of a specific screen or widget.   For example, it might contain information
/// about whether a particular UI element is expanded or not, or which tab or 
/// view is showing.   It will also often contain references to model objects
/// which are being actively modifed on the screen or widget.
''';
}
