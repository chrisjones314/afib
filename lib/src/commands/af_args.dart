import 'package:meta/meta.dart';

/// Utility for accessing arguments to an afib command. 
/// 
/// All methods ignore the command name itself, which is already implied
/// within the command.  For example 'afib environment production' has one
/// argument, production.
class AFArgs {
  List<String> args;
  AFArgs(this.args);

  /// The number of arguments to the command (not including the command itself)
  int get count {
    if(args.length == 0)
      return 0;
    return args.length - 1;
  }

  /// The first argument to the command (not including the command itself)
  String get first {
    return args[1];
  }

  /// The second argument to the command (not including the command itself)
  String get second {
    return args[2];
  }

  /// The third argument to the command (not including the command itself)
  String get third {
    return args[3];
  }

}