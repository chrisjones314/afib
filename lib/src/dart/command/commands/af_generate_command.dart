import 'package:afib/src/dart/command/af_command.dart';
import 'package:args/args.dart' as args;

/*
class AFInsertionPoint {
  final String id;
  AFInsertionPoint(this.id);

  factory AFInsertionPoint.create(String id) {
    return AFInsertionPoint(id);
  }

  String get fullText {
    return buildFullText(id, forRegex: false);
  }

  String get codeText {
    return buildCodeText(id);
  }

  RegExp get replaceRegexFor {
    final source = StringBuffer();
    source.write("//\\s+");
    source.write(buildFullText(id, forRegex: true));
    source.write(".*");
    return RegExp(source.toString());
  }

  String findIndentFor(String content) {
    final source = StringBuffer();
    source.write("([\t ]*)//\\s+");
    source.write(buildFullText(id, forRegex: true));
    final re = RegExp(source.toString());
    final matches = re.allMatches(content);
    if(matches.isEmpty) {
      throw AFException("Expected to find pattern $re");
    }
    final first = matches.first;
    return first.group(1);
  }

  static String buildFullText(String id, { bool forRegex }) {
    final kind = "${id[0].toUpperCase()}${id.substring(1)}ID";
    final reSource = StringBuffer();
    reSource.write("AFibInsertionPoint");
    reSource.write(forRegex ? "\\(" : "(");
    reSource.write(kind);
    reSource.write(forRegex ? "\\)" : ")");
    return reSource.toString();
  }

  static String buildCodeText(String id) {
    final sb = StringBuffer();
    sb.write("// ");
    sb.write(buildFullText(id, forRegex: false));
    sb.write(" - Do not Delete.");
    return sb.toString();
  }
}
*/


class AFGenerateParentCommand extends AFCommand {
  final name = "generate";
  final description = "Generate AFib source code for screens, queries, models, and more";

  @override
  void registerArguments(args.ArgParser args) {
  }

  @override
  void execute(AFCommandContext ctx) {

  }
}


abstract class AFGenerateSubcommand extends AFCommand {

}

