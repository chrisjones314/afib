
import 'dart:io';
import 'package:afib/src/dart/command/af_command_output.dart';
import 'package:afib/src/dart/utils/af_id.dart';
import 'package:colorize/colorize.dart';
import 'package:flutter_test/flutter_test.dart' as flutter_test;
import 'package:stack_trace/stack_trace.dart';

class AFTestError {
  final AFID testID;
  final String description;
  AFTestError(this.testID, this.description);

  String toString() {
    return description;
  }
}

class AFTestErrors {
  final _errors = List<AFTestError>();
  int pass = 0;

  List<AFTestError> get errors { return _errors; }
  bool get hasErrors { return _errors.isNotEmpty; }
  int get errorCount { return _errors.length; }

  void addPass() {
    pass++;
  }

  void addError(AFTestError err) {
    _errors.add(err);
  }
}



abstract class AFBaseTestExecute {

  final _errors = AFTestErrors();

  void expect(dynamic value, flutter_test.Matcher matcher) {
    final matchState = Map();
    if(!addPassIf(matcher.matches(value, matchState))) {
      final matchDesc = matcher.describe(flutter_test.StringDescription());
      final desc = "Expected $matchDesc, found $value";
      addError(desc, 2);
    }
  }

  AFTestID get testID;

  void addError(String desc, int depth) {
    String err = composeError(desc, depth);
    _errors.addError(AFTestError(testID, err));
  }

  int printPassMessages(AFCommandOutput output) {
    if(!_errors.hasErrors) {
      _writeTestResult(output, "${testID.code}:", _errors.pass, " passed", Styles.GREEN);
    }
    return _errors.pass;
  }

  static void printTotalPass(AFCommandOutput output, int pass) {
      _writeTestResult(output, "TOTAL:", pass, " passed", Styles.GREEN);
  }

  int printFailMessages(AFCommandOutput output) {
    if(_errors.hasErrors) {
      _writeTestResult(output, "${testID.code}:", _errors.errorCount, " failed", Styles.RED);
      output.indent();
      for(var error in _errors.errors) {
         output.writeLine(error.toString());
      }
      output.outdent();
      return _errors.errorCount;
    }
    return 0;
  }

  static void _writeTestResult(AFCommandOutput output, String code, int count, String suffix, Styles color) {
    output.startColumn(alignment: AFOutputAlignment.alignRight, width: 35);
    output.write(code);
    output.startColumn(alignment: AFOutputAlignment.alignRight, color: color, width: 5);
    output.write(count.toString());
    output.startColumn(alignment: AFOutputAlignment.alignLeft, color: color);
    output.write(suffix);
    output.endLine();
  }

  bool addPassIf(bool test) {
    if(test) {
      _errors.addPass();
    }
    return test;
  }

  static String composeError(String desc, int depth) {
    final List<Frame> frames = Trace.current().frames;
    final Frame f = frames[depth+1];
    final loc = "${f.library}:${f.line}";

    final err = loc + ": " + desc;
    return err;
  }

}

int printTestResults(AFCommandOutput output, String kind, List<AFBaseTestExecute> baseContexts) {
  stdout.writeln("------------------------------");
  output.writeLine("Afib $kind Tests:");
  output.indent();

  int totalPass = 0;
  for(var context in baseContexts) {
    totalPass += context.printPassMessages(output);
  }
  AFBaseTestExecute.printTotalPass(output, totalPass);

  int totalErrors = 0;
  for(var context in baseContexts) {
    totalErrors += context.printFailMessages(output);
  }
  stdout.writeln("------------------------------");
  return totalErrors;
}