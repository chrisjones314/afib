
import 'package:afib/afib_flutter.dart';
import 'package:afib/src/dart/command/af_command_output.dart';
import 'package:afib/src/dart/utils/af_id.dart';
import 'package:afib/src/flutter/test/af_screen_test.dart';
import 'package:afib/src/flutter/test/af_test_stats.dart';
import 'package:colorize/colorize.dart';
import 'package:flutter/material.dart';
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
  final AFID section;
  final _errors = <AFTestError>[];
  int pass = 0;
  String disabled;

  AFTestErrors(this.section);

  List<AFTestError> get errors { return _errors; }
  bool get hasErrors { return _errors.isNotEmpty; }
  int get errorCount { return _errors.length; }
  void markDisabled(String msg) {
    disabled = msg;
  }

  void addPass() {
    pass++;
  }

  void addError(AFTestError err) {
    _errors.add(err);
  }

}



abstract class AFBaseTestExecute {

  final sectionErrors = <AFID, AFTestErrors>{};
  AFID currentSection;
  AFTestErrors defaultErrors = AFTestErrors(null);

  void expect(dynamic value, flutter_test.Matcher matcher, {int extraFrames = 0}) {
    final matchState = <dynamic, dynamic>{};
    if(!addPassIf(test: matcher.matches(value, matchState))) {
      final matchDesc = matcher.describe(flutter_test.StringDescription());
      final desc = "Expected $matchDesc, found $value";
      final stackFrames = extraFrames + 2;
      addError(desc, stackFrames);
    }
  }

  void expectWidgetIds(List<Widget> widgets, List<AFWidgetID> ids, { AFWidgetMapperDelegate mapper } ) {
    return expect(widgets, hasWidgetIdsWith(ids, mapper: mapper));
  }
  
  void startSection(AFScreenTestBody body) {
    currentSection = body.sectionId;
    var current = sectionErrors[currentSection];
    if(current == null) {
      current = AFTestErrors(currentSection);
      sectionErrors[currentSection] = current;
    }    
  }

  void markDisabled(AFScreenTestBody body) {
    startSection(body);
    errors.markDisabled(body.disabled);
    endSection(body);
  }

  void markDisabledSimple(String disabled) {
    errors.markDisabled(disabled);
  }

  void endSection(AFScreenTestBody body) {
    currentSection = null;
  }

  AFTestID get testID;

  AFTestErrors get errors {
    if(currentSection != null) {
      return sectionErrors[currentSection];
    }
    return defaultErrors;
  }

  void printPassMessages(AFCommandOutput output, AFTestStats stats) {
    if(sectionErrors.isNotEmpty) {
      final sectionErrorSmoke = sectionErrors.values.where((section) => section.section == AFUITestID.smokeTest);
      final sectionErrorReusable = sectionErrors.values.where((section) => section.section != AFUITestID.smokeTest);
      if(sectionErrorSmoke.isNotEmpty) {
        _writePassed(output, "$testID/s", sectionErrorSmoke.first, stats);
      }

      if(sectionErrorReusable.isNotEmpty) {
        for(final sectionError in sectionErrorReusable) {
          if(!sectionError.hasErrors) {
            _writePassed(output, "${sectionError.section}/r", sectionError, stats);
          }
        }
      }
    } 
    
    if(!defaultErrors.hasErrors && defaultErrors.pass > 0) {
      _writePassed(output, testID, defaultErrors, stats);
    }
  }

  void _writePassed(AFCommandOutput output, dynamic testName, AFTestErrors errors, AFTestStats stats) {
    var pass = errors.pass;
    if(errors.disabled != null) {
      _writeTestResult(output, "$testName:", null, " Disabled: ${errors.disabled}", Styles.YELLOW);
      stats.addDisabled(1);
    } else {
      _writeTestResult(output, "$testName:", pass, " passed", Styles.GREEN, tags: testID.tagsText);
      stats.addPasses(pass);
    }
  }

  static void printTotalPass(AFCommandOutput output, String title, int pass, { Stopwatch stopwatch, Styles style = Styles.GREEN, String suffix = "passed" }) {
    final suffixFull = StringBuffer(" $suffix");
    if(stopwatch != null) {
      suffixFull.write(" (in ");
      final total = stopwatch.elapsedMilliseconds / 1000.0;
      suffixFull.write(total.toStringAsFixed(2));
      suffixFull.write("s)");
    }
    _writeTestResult(output, "$title:", pass, suffixFull.toString(), style);
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

  static void printTotalFail(AFCommandOutput output, String title, int fail) {
      _writeTestResult(output, title, fail, " failed", Styles.RED, tags: "");
  }

  static void _writeTestResult(AFCommandOutput output, String title, int count, String suffix, Styles color, { String tags }) {
    output.startColumn(alignment: AFOutputAlignment.alignRight, width: 48);
    output.write(title);
    output.startColumn(alignment: AFOutputAlignment.alignRight, color: color, width: 5);
    if(count != null) {
      output.write(count.toString());
    }
    output.startColumn(alignment: AFOutputAlignment.alignLeft, color: color, width: 8);
    if(suffix != null) {
      output.write(suffix);
    }
    if(tags != null) {
      output.startColumn(alignment: AFOutputAlignment.alignLeft);
      output.write(tags);
    }
    output.endLine();
  }

  bool addPassIf({bool test}) {
    if(test) {
      errors.addPass();
    }
    return test;
  }    

  void addError(String desc, int depth) {
    final err = AFBaseTestExecute.composeError(desc, depth);
    errors.addError(AFTestError(testID, err));
  }

  static String composeError(String desc, int depth) {
    final frames = Trace.current().frames;
    var depthActual = depth+1;
    if(depthActual >= frames.length) {
      depthActual = frames.length-1;
    }
    final f = frames[depthActual];
    final loc = "${f.library}:${f.line}";

    final err = "$loc: $desc";
    return err;
  }

}

void printTestResult(AFCommandOutput output, String kind, AFBaseTestExecute context, AFTestStats stats) {
  if(stats.isEmpty) {
    output.writeSeparatorLine();
    output.writeLine("Afib $kind Tests:");
  }

   context.printPassMessages(output, stats);
}

void printTestTotal(AFCommandOutput output, String kind, List<AFBaseTestExecute> baseContexts, AFTestStats stats) {
  if(stats.isEmpty) {
    return;
  }

  final totalPass = stats.totalPasses;
  AFBaseTestExecute.printTotalPass(output, "TOTAL", totalPass);

  var totalErrors = 0;
  for(var context in baseContexts) {
    totalErrors += context.printFailMessages(output);
  }
  stats.addErrors(totalErrors);
}

/*
void printTestResults(AFCommandOutput output, String kind, List<AFBaseTestExecute> baseContexts, AFTestStats stats) {
  if(baseContexts.isEmpty) {
    return;
  }
  output.writeSeparatorLine();
  output.writeLine("Afib $kind Tests:");

  var totalPass = 0;
  for(var context in baseContexts) {
    totalPass += context.printPassMessages(output);
  }
  AFBaseTestExecute.printTotalPass(output, "TOTAL", totalPass);
  stats.addPasses(totalPass);

  var totalErrors = 0;
  for(var context in baseContexts) {
    totalErrors += context.printFailMessages(output);
  }
  stats.addErrors(totalErrors);
}
*/