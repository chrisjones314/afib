import 'package:afib/src/dart/command/af_source_template.dart';

class BuildWithSPIComment extends AFSourceTemplateComment {
  final String template = '''
  /// Because Flutter's scaffold provides a bunch of basic style/theme data, 
  /// you almost certainly want one.   You can use it to add many material UI 
  /// conventions easily, or by default you can start from an empty screen which will
  /// fill with whatever is returned by 'buildBody'.
''';
}