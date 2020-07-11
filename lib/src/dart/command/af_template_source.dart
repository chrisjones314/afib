
/// An insertion point in a file, with an optional whitespace indentation before each line.
class AFTemplateReplacementPoint {
  final String indent;
  final String key;
  AFTemplateReplacementPoint(this.indent, this.key);
}

enum AFTemplateSourceCreationRule {
  createAlways,
  createOnce,
  updateInPlace
}

/// A source of template source code. 
/// 
/// It would seem more natural to store the templates as text file resources,
/// but because dart programs are sometimes compiled, you cannot depend on
/// resource files to be present (see https://github.com/dart-archive/resource)
abstract class AFTemplateSource {
  final AFTemplateSourceCreationRule creationRule;

  AFTemplateSource(this.creationRule);

  String template();

  List<AFTemplateReplacementPoint> findReplacementPoints() {
    String t = template();
    RegExp exp = new RegExp(r"([ \t]*?)AfibReplacementPoint\((.*?)\)");
    Iterable<RegExpMatch> matches = exp.allMatches(t);
    final result = List<AFTemplateReplacementPoint>();
    for(final match in matches) {
      result.add(AFTemplateReplacementPoint(match.group(1), match.group(2)));
    }
    return result;
  }

}