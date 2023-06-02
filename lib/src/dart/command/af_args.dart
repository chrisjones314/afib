import 'package:colorize/colorize.dart';

/// The set of arguments specified for an AFib command.
/// 
/// Mainly you would use [setDebugArgs] from your main function as an easy way to specfy debug arguments.
/// 
/// Otherwise, you should prefer [AFCommandContext.parseArguments] for accessing argument values.
class AFArgs {
  List<String> args;
  AFArgs(this.args);

  AFArgs reviseAddArg(String arg) {
    final revised = args.toList();
    revised.add(arg);
    return AFArgs(revised);
  }

  AFArgs reviseAddArgs(List<String> args) {
    final revised = args.toList();
    revised.addAll(args);
    return AFArgs(revised);
  }

  /// Create from a list of arguments
  factory AFArgs.create(List<String> args) {
    return AFArgs(List<String>.of(args));
  }

  /// Create from a string, which is parsed into distinct arguments.
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

  /// Reset the arguments to those specified in revised.
  /// 
  /// This is useful during dubugging, if you prefer not to use VS Code's configuration files.  It allows
  /// you to type a set of arguments in a string, just as you would on the command line.
  /// 
  /// For example, in your project's bin/xxx_afib.dart, you could use:
  /// 
  /// ```dart
  ///   args.setDebugArgs("generate query TestQuery --result-type String")
  /// ```
  /// 
  /// To debug the command that generates a query.
  void setDebugArgs(String revised) {
    final result = StringBuffer();
    result.writeln("********* ATTENTION: USING DEBUG ARGUMENTS: '$revised' ******************************");
    final colorized = Colorize(result.toString()).apply(Styles.YELLOW);    
    // ignore: avoid_print
    print(colorized);

    final parsed = parseArgs(revised);
    args = <String>[];
    args.addAll(parsed);
  }

  static String _cleanEdgeQuotes(String source) {
    var result = source;
    if(result.startsWith('"')) {
      result = result.substring(1);
    }
    if(result.endsWith('"')) {
      result = result.substring(0, result.length - 1);
    }
    return result;
  }

  /// Parses a string into a list of string arguments.
  static List<String> parseArgs(String revised) {
    final raw = revised.trim().split(RegExp(r"[ \t]"));
    final result = <String>[];
    var i = 0;
    while(i < raw.length) {
      final current = raw[i++];
      final buffer = StringBuffer();      
      if(current.startsWith('"')) {
        buffer.write(_cleanEdgeQuotes(current));
        while(i < raw.length) {
          final next = raw[i++];
          if(next.endsWith('"')) {
            buffer.write(" ${_cleanEdgeQuotes(next)}");
            break;
          } else {
            buffer.write(" $next");
          }
        }
        result.add(buffer.toString());
      } else {
        result.add(current);
      }
    }
    return result;
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