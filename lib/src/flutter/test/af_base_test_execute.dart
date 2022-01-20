import 'package:afib/id.dart';
import 'package:afib/src/dart/command/af_command_output.dart';
import 'package:afib/src/dart/command/af_standard_configs.dart';
import 'package:afib/src/dart/redux/state/models/af_app_state.dart';
import 'package:afib/src/dart/utils/af_id.dart';
import 'package:afib/src/dart/utils/afib_d.dart';
import 'package:afib/src/flutter/test/af_matchers.dart';
import 'package:afib/src/flutter/test/af_screen_test.dart';
import 'package:afib/src/flutter/test/af_test_stats.dart';
import 'package:colorize/colorize.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart' as flutter_test;
import 'package:logger/logger.dart';
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
  final AFID? section;
  final _errors = <AFTestError>[];
  int pass = 0;
  String? disabled;

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



abstract class AFBaseTestExecute extends AFModelWithCustomID {
  static const testExecuteId = "base_test_execute";
  static const titleColWidth = 60;
  static const resultColWidth = 5;
  static const resultSuffixColWidth = 8;

  AFBaseTestExecute(): super(customStateId: testExecuteId);

  final sectionErrors = <AFID, AFTestErrors>{};
  AFID? currentSection;
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

  void expectWidgetIds(List<Widget> widgets, List<AFWidgetID?> ids, { AFWidgetMapperDelegate? mapper } ) {
    return expect(widgets, hasWidgetIdsWith(ids, mapper: mapper));
  }
  
  void startSection(AFID id, { bool resetSection = false }) {
    currentSection = id;
    var current = sectionErrors[currentSection];
    final curSect = currentSection;
    if(curSect != null && (current == null || resetSection)) {
      current = AFTestErrors(currentSection);
      sectionErrors[curSect] = current;
    }    
  }

  void markDisabled(AFScreenTestBody body) {
    startSection(body.id);
    final disabled = body.disabled;
    assert(disabled != null);
    if(disabled != null) {
      errors.markDisabled(disabled);
    }
    endSection();
  }

  void markDisabledSimple(String disabled) {
    errors.markDisabled(disabled);
  }

  void endSection() {
    currentSection = null;
  }

  Logger? get log {
    return AFibD.log(AFConfigEntryLogArea.test);
  }

  AFBaseTestID get testID;

  AFTestErrors get errors {
    final curSect = currentSection;
    if(curSect != null) {
      final errors = sectionErrors[curSect];
      if(errors != null) {
        return errors;
      }
    }
    return defaultErrors;
  }

  void indentOutput() {}
  void outdentOutput() {}
  void printTestTitle(AFID id) {}
  void printStartTest(AFID id) {}
  void printFinishTestDisabled(AFID id, String disabled) {}
  void printFinishTest(AFID id) {}


  void printPassMessages(AFCommandOutput output, AFTestStats stats) {
    if(sectionErrors.isNotEmpty) {
      final sectionErrorSmoke = sectionErrors.values.where((section) => section.section == AFUIReusableTestID.smoke);
      final sectionErrorReusable = sectionErrors.values.where((section) => section.section != AFUIReusableTestID.smoke);
      if(sectionErrorSmoke.isNotEmpty) {
        _writePassed(output, "${testID.codeId}", sectionErrorSmoke.first, stats);
      }

      if(sectionErrorReusable.isNotEmpty) {
        for(final sectionError in sectionErrorReusable) {
          if(!sectionError.hasErrors) {
            _writePassed(output, "${sectionError.section?.codeId}", sectionError, stats);
          }
        }
      }
    } 
    
    if(!defaultErrors.hasErrors && defaultErrors.pass > 0) {
      _writePassed(output, testID.codeId, defaultErrors, stats);
    }
  }

  void _writePassed(AFCommandOutput output, dynamic testName, AFTestErrors errors, AFTestStats stats) {
    var pass = errors.pass;
    if(errors.disabled != null) {
      writeTestResult(output, 
        title: "$testName:",
        suffix: " Disabled: ${errors.disabled}", 
        color: Styles.YELLOW,
        fill: "."
      );
      stats.addDisabled(1);
    } else {
      writeTestResult(output, 
        title: "$testName:", 
        count: pass, 
        suffix: " passed", 
        color: Styles.GREEN, 
        fill: ".",
        tags: testID.tagsText);
      stats.addPasses(pass);
    }
  }

  static void printPrototypeIntro(AFCommandOutput output, String title) {
    writeTestResult(output, 
      title: title
    );
  }

  static void printTotalPass(AFCommandOutput output, String title, int pass, { Stopwatch? stopwatch, Styles style = Styles.GREEN, String suffix = "passed" }) {
    final suffixFull = StringBuffer(" $suffix");
    if(stopwatch != null) {
      suffixFull.write(" (in ");
      final total = stopwatch.elapsedMilliseconds / 1000.0;
      suffixFull.write(total.toStringAsFixed(2));
      suffixFull.write("s)");
    }
    writeTestResult(output, 
      title: title, 
      count: pass, 
      suffix: suffixFull.toString(), 
      color: style,
      titleAlign: AFOutputAlignment.alignRight);
  }

  int printFailMessages(AFCommandOutput output) {
    if(errors.hasErrors) {
      writeTestResult(output, 
        title: "${testID.code}:", 
        count: errors.errorCount, 
        suffix: " failed", 
        color: Styles.RED, 
        tags: testID.tagsText);
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
      writeTestResult(output, 
        title: title, 
        count: fail, 
        suffix: " failed", 
        color: Styles.RED, tags: "");
  }

  static void printTitleColumn(AFCommandOutput output, String title, { String fill = " ", AFOutputAlignment titleAlign = AFOutputAlignment.alignLeft } ) {
    output.startColumn(alignment: titleAlign, width: titleColWidth, fill: fill);
    output.write(title);
  }

  static void printResultColumn(AFCommandOutput output, { int? count, String? suffix, Styles? color }) {
    output.startColumn(alignment: AFOutputAlignment.alignRight, color: color, width: resultColWidth);
    if(count != null) {
      output.write(count.toString());
    }
    output.startColumn(alignment: AFOutputAlignment.alignLeft, color: color, width: resultSuffixColWidth);
    if(suffix != null) {
      output.write(suffix);
    }
  }

  static void printErrors(AFCommandOutput output, List<AFTestError> errors) {
    for(final error in errors) {
      output.startColumn(alignment: AFOutputAlignment.alignLeft, color: Styles.RED);
      output.write(error.description);
      output.endLine();
    }
  }

  static void writeTestResult(AFCommandOutput output, { 
    required String title, 
    int? count, 
    String suffix = "",  
    Styles? color, 
    String? tags,
    String fill = " ",
    AFOutputAlignment titleAlign = AFOutputAlignment.alignLeft, 
  }) {
    printTitleColumn(output, title, titleAlign: titleAlign, fill: fill);
    printResultColumn(output, count: count, suffix: suffix, color: color);
    if(tags != null) {
      output.startColumn(alignment: AFOutputAlignment.alignLeft);
      output.write(tags);
    }
    output.endLine();
  }

  bool addPassIf({required bool test}) {
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

  static void writeSeparatorLine(AFCommandOutput output) {
    final count = titleColWidth;
    final line = StringBuffer();
    for(var i = 0; i < count; i++) {
      line.write("-");
    }
    output.writeLine(line.toString());
  }

}

void printPrototypeStart(AFCommandOutput output, AFPrototypeID id) {
  AFBaseTestExecute.printPrototypeIntro(output, id.toString());
}


void printTestKind(AFCommandOutput output, String kind) {
  AFBaseTestExecute.writeSeparatorLine(output);
  output.writeLine("Afib $kind Tests:");
  AFBaseTestExecute.writeSeparatorLine(output);
}


void printTestResult(AFCommandOutput output, String kind, AFBaseTestExecute context, AFTestStats stats) {
   context.printPassMessages(output, stats);
}

void printTestTotal(AFCommandOutput output, List<AFBaseTestExecute> baseContexts, AFTestStats stats) {
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