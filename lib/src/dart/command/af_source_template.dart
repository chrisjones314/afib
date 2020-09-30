
import 'package:afib/afib_command.dart';
import 'package:afib/src/dart/utils/af_exception.dart';

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

/// A source of template source code. 
/// 
/// It would seem more natural to store the templates as text file resources,
/// but because dart programs are sometimes compiled, you cannot depend on
/// resource files to be present (see https://github.com/dart-archive/resource)
abstract class AFSourceTemplate extends AFItemWithNamespace {

  AFSourceTemplate(String namespace, String key): super(namespace, key);

  String get template;

  List<AFTemplateReplacementPoint> findReplacementPoints() {
    final t = template;
    final exp = RegExp(r"([ \t]*?)AFRP\((.*?)\)");
    final matches = exp.allMatches(t);
    final result = <String, AFTemplateReplacementPoint>{};
    for(final match in matches) {
      final indent = match.group(1);
      var id = match.group(2);
      var namespace = AFConfigEntries.afNamespace;
      if(id.contains(AFConfigEntries.afNamespaceSeparator)) {
        final parsed = id.split(AFConfigEntries.afNamespaceSeparator);
        if(parsed.length != 2) {
          throw AFException("Expected identifier to have syntax namespace:key, found $id");
        }
        namespace = parsed[0];
        id = parsed[1];
      }

      if(!result.containsKey(id)) {
        result[id] = AFTemplateReplacementPoint(namespace, id, indent);
      }
    }
    return List<AFTemplateReplacementPoint>.of(result.values);
  }

}

abstract class AFFileSourceTemplate extends AFSourceTemplate {
  final AFFileTemplateCreationRule creationRule;
  AFFileSourceTemplate(String namespace, String key, this.creationRule): super(namespace, key);

}

abstract class AFStatementSourceTemplate extends AFSourceTemplate {
  AFStatementSourceTemplate(String namespace, String key): super(namespace, key);
}

class AFOneLineStatementSourceTemplate extends AFStatementSourceTemplate {
  final String line;
  AFOneLineStatementSourceTemplate(String namespace, String key, this.line): super(namespace, key);

  @override
  String get template {
    return line;
  }
}