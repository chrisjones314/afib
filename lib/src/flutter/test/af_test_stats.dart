

import 'package:afib/src/dart/utils/af_id.dart';
import 'package:afib/src/flutter/test/af_base_test_execute.dart';

class AFTestStats {
  int pass = 0;
  int fail = 0;
  int disabled = 0;
  final failedTests = <AFID>[];

  void addPasses(int p) { pass += p; }
  void addErrors(AFTestErrors errors) { 
    fail += errors.errorCount; 
    for(final error in errors.errors) {
      if(!failedTests.contains(error.testID)) {
        failedTests.add(error.testID);
      }
    }
  }
  void addDisabled(int d) { disabled += d; }

  bool get hasErrors { return fail > 0; }
  int get totalPasses => pass;
  int get totalErrors => fail;
  int get totalDisabled => disabled;
  bool get isEmpty { return pass == 0 && fail == 0 && disabled == 0; }

  void mergeIn(AFTestStats other) {
    pass += other.pass;
    fail += other.fail;
    disabled += other.disabled;
    failedTests.addAll(other.failedTests);
  }


}