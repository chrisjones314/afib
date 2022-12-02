import 'package:colorize/colorize.dart';

/// Utility for accessing arguments to an afib command. 
/// 
/// All methods ignore the command name itself, which is already implied
/// within the command.  For example 'afib environment production' has one
/// argument, production.
class AFArgs {
  List<String> args;
  AFArgs(this.args);

  AFArgs reviseAddArg(String arg) {
    final revised = args.toList();
    revised.add(arg);
    return AFArgs(revised);
  }

  // create args that are modifiable.
  factory AFArgs.create(List<String> args) {
    return AFArgs(List<String>.of(args));
  }

  factory AFArgs.createFromString(String arguments) {
    return AFArgs(parseArgs(arguments));
  }


  /// The name of the command that was executed.
  String get command {
    return args[0];
  }

  /// True if the arguments have a first argument, which is the command argument.
  bool get hasCommand {
    return args.isNotEmpty;
  }

  /// The number of arguments to the command (not including the command itself)
  int get count {
    if(args.isEmpty) {
      return 0;
    }
    return args.length - 1;
  }

  /// returns true if there are no arguments past the command itself.
  bool get isEmpty {
    return count == 0;
  }

  void addArg(String arg) {
    args.add(arg);
  }

  void setDebugArgs(String revised) {
    final result = StringBuffer();
    result.writeln("********* ATTENTION: USING DEBUG ARGUMENTS: '$revised' ******************************");
    final colorized = Colorize(result.toString()).apply(Styles.YELLOW);    
    print(colorized);

    final parsed = parseArgs(revised);
    args = <String>[];
    args.addAll(parsed);
  }

  static List<String> parseArgs(String revised) {
    return revised.trim().split(RegExp(r"[ \t]"));
  }

  /// The nth space-separated argument (not including the command itself)
  String? at(int i) {
    final idx = i+1;
    // ignore the command itself.
    if(idx >= args.length) {
      return null;
    }
    return args[idx];
  }

  /// The first argument to the command (not including the command itself)
  String? get first {
    return at(0);
  }

  // Return a list of arguments starting after the command, or at the nth
  // element if [start] is specified
  List<String> listFrom({int start = 0}) {
    return args.sublist(start+1);
  }


  /// The second argument to the command (not including the command itself)
  String? get second {
    return at(1);
  }

  /// The third argument to the command (not including the command itself)
  String? get third {
    return at(2);
  }

}