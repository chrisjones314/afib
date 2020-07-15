
/// Utility for accessing arguments to an afib command. 
/// 
/// All methods ignore the command name itself, which is already implied
/// within the command.  For example 'afib environment production' has one
/// argument, production.
class AFArgs {
  List<String> args;
  AFArgs(this.args);

  // create args that are modifiable.
  factory AFArgs.create(List<String> args) {
    return AFArgs(List<String>.of(args));
  }

  /// The name of the command that was executed.
  String get command {
    return args[0];
  }

  /// True if the arguments have a first argument, which is the command argument.
  bool get hasCommand {
    return args.length >= 1;
  }

  /// The number of arguments to the command (not including the command itself)
  int get count {
    if(args.length == 0)
      return 0;
    return args.length - 1;
  }

  /// returns true if there are no arguments past the command itself.
  bool get isEmpty {
    return count == 0;
  }

  void addArg(String arg) {
    args.add(arg);
  }

  void debugResetTo(String arguments) {
    print("USING DEBUG ARGUMENTS $arguments");
    List<String> parsed = arguments.split(new RegExp(r"[ \t]"));
    args.clear();
    args.addAll(parsed);
  }

  /// The nth space-separated argument (not including the command itself)
  String at(int i) {
    final idx = i+1;
    // ignore the command itself.
    if(idx >= args.length) {
      return null;
    }
    return args[idx];
  }

  /// The first argument to the command (not including the command itself)
  String get first {
    return at(0);
  }

  // Return a list of arguments starting after the command, or at the nth
  // element if [start] is specified
  List<String> listFrom({int start = 0}) {
    return args.sublist(start+1);
  }


  /// The second argument to the command (not including the command itself)
  String get second {
    return at(1);
  }

  /// The third argument to the command (not including the command itself)
  String get third {
    return at(2);
  }

}