import 'package:afib/src/dart/command/af_command.dart';
import 'package:afib/src/dart/command/code_generation/af_code_buffer.dart';

/// An insertion point in a file, with an optional whitespace indentation before each line.
class AFTemplateReplacementPoint extends AFItemWithNamespace {
  final String indent;
  AFTemplateReplacementPoint(String namespace, String key, this.indent): super(namespace, key);
}

enum AFFileTemplateCreationRule {
  createAlways,
  createOnce,
  updateInPlace
}

enum AFSourceTemplateRole {
  code,
  comment,
}

/// A source of template source code. 
/// 
/// It would seem more natural to store the templates as text file resources,
/// but because dart programs are sometimes compiled, you cannot depend on
/// resource files to be present (see https://github.com/dart-archive/resource)
abstract class AFSourceTemplate {
  final AFSourceTemplateRole role;
  
  AFSourceTemplate({ this.role = AFSourceTemplateRole.code });

  bool get isComment { return role == AFSourceTemplateRole.comment; }
  bool get isCode { return role == AFSourceTemplateRole.code; }

  String get template;

  AFCodeBuffer toBuffer() {
    return AFCodeBuffer.fromTemplate(this);
  }

  List<String> createLinesWithOptions(AFCommandContext context, List<String> options) {
    final buffer = toBuffer();
    return buffer.lines;
  }
}

abstract class AFSourceTemplateComment extends AFSourceTemplate {
  AFSourceTemplateComment(): super(role: AFSourceTemplateRole.comment);
}

abstract class AFDynamicSourceTemplate extends AFSourceTemplate {

  final template = "";
  List<String> createLinesWithOptions(AFCommandContext context, List<String> options);
}
