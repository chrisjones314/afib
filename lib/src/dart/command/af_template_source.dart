
/// An insertion point in a file, with an optional whitespace indentation before each line.
class AFTemplateInsertionPoint {
  final String indent;
  final String key;
  AFTemplateInsertionPoint(this.indent, this.key);
}

/// A source of template source code. 
/// 
/// It would seem more natural to store the templates as text file resources,
/// but because dart programs are sometimes compiled, you cannot depend on
/// resource files to be present (see https://github.com/dart-archive/resource)
abstract class AFTemplateSource {

  String template();

  List<AFTemplateInsertionPoint> findInsertionPoints() {
    String t = template();
    RegExp exp = new RegExp(r"([ \t]*?)\[!(.*?)!\]");
    Iterable<RegExpMatch> matches = exp.allMatches(t);
    final result = List<AFTemplateInsertionPoint>();
    for(final match in matches) {
      result.add(AFTemplateInsertionPoint(match.group(1), match.group(2)));
    }
    return result;
  }

}