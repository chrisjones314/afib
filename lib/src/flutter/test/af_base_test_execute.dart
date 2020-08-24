
import 'package:afib/src/dart/command/af_command_output.dart';
import 'package:afib/src/dart/utils/af_id.dart';
import 'package:afib/src/flutter/test/af_test_stats.dart';
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

  final errors = AFTestErrors();

  void expect(dynamic value, flutter_test.Matcher matcher, {int extraFrames = 0}) {
    final matchState = Map();
    if(!addPassIf(matcher.matches(value, matchState))) {
      final matchDesc = matcher.describe(flutter_test.StringDescription());
      final desc = "Expected $matchDesc, found $value";
      final int stackFrames = extraFrames + 2;
      addError(desc, stackFrames);
    }
  }

  AFTestID get testID;

  int printPassMessages(AFCommandOutput output) {
    if(!errors.hasErrors) {
      _writeTestResult(output, "${testID.code}:", errors.pass, " passed", Styles.GREEN, tags: testID.tagsText);
    }
    return errors.pass;
  }

  static void printTotalPass(AFCommandOutput output, String title, int pass) {
      _writeTestResult(output, "$title:", pass, " passed", Styles.GREEN);
  }

  int printFailMessages(AFCommandOutput output) {
    if(errors.hasErrors) {
      _writeTestResult(output, "${testID.code}:", errors.errorCount, " failed", Styles.RED, tags: testID.tagsText);
      output.indent();
      for(var error in errors.errors) {
         output.writeLine(error.toString());
      }
      output.outdent();
      return errors.errorCount;
    }
    return 0;
  }

  static void _writeTestResult(AFCommandOutput output, String title, int count, String suffix, Styles color, { String tags }) {
    output.startColumn(alignment: AFOutputAlignment.alignRight, width: 35);
    output.write(title);
    output.startColumn(alignment: AFOutputAlignment.alignRight, color: color, width: 5);
    output.write(count.toString());
    output.startColumn(alignment: AFOutputAlignment.alignLeft, color: color, width: 8);
    output.write(suffix);
    if(tags != null) {
      output.startColumn(alignment: AFOutputAlignment.alignLeft);
      output.write(tags);
    }
    output.endLine();
  }

  bool addPassIf(bool test) {
    if(test) {
      errors.addPass();
    }
    return test;
  }    

  void addError(String desc, int depth) {
    String err = AFBaseTestExecute.composeError(desc, depth);
    errors.addError(AFTestError(testID, err));
  }

  static String composeError(String desc, int depth) {
    final List<Frame> frames = Trace.current().frames;
    final Frame f = frames[depth+1];
    final loc = "${f.library}:${f.line}";

    final err = loc + ": " + desc;
    return err;
  }

}

void printTestResults(AFCommandOutput output, String kind, List<AFBaseTestExecute> baseContexts, AFTestStats stats) {
  if(baseContexts.isEmpty) {
    return;
  }
  output.writeSeparatorLine();
  output.writeLine("Afib $kind Tests:");

  int totalPass = 0;
  for(var context in baseContexts) {
    totalPass += context.printPassMessages(output);
  }
  AFBaseTestExecute.printTotalPass(output, "TOTAL", totalPass);
  stats.addPasses(totalPass);

  int totalErrors = 0;
  for(var context in baseContexts) {
    totalErrors += context.printFailMessages(output);
  }
  stats.addErrors(totalErrors);
}