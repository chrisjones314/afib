
/// Utility for accessing arguments to an afib command. 
/// 
/// All methods ignore the command name itself, which is already implied
/// within the command.  For example 'afib environment production' has one
/// argument, production.
class AFArgs {
  List<String> args;
  AFArgs(this.args);

  /// The name of the command that was executed.
  String get command {
    return args[0];
  }

  /// The number of arguments to the command (not including the command itself)
  int get count {
    if(args.length == 0)
      return 0;
    return args.length - 1;
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

  /// The second argument to the command (not including the command itself)
  String get second {
    return at(1);
  }

  /// The third argument to the command (not including the command itself)
  String get third {
    return at(2);
  }

}