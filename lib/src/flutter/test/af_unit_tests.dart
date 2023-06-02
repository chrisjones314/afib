import 'package:afib/src/dart/utils/af_id.dart';
import 'package:afib/src/flutter/test/af_base_test_execute.dart';
import 'package:afib/src/flutter/test/af_test_stats.dart';
import 'package:afib/src/flutter/utils/af_typedefs_flutter.dart';


class AFUnitTestContext extends AFUnitTestExecute {
  final AFUnitTest test;
  AFUnitTestContext(this.test);

  AFBaseTestID get testID => this.test.id;

  void finishAndUpdateStats(AFTestStats stats) {
    stats.addPasses(errors.pass);
    stats.addErrors(errors);
  }

}

abstract class AFUnitTestExecute extends AFBaseTestExecute {

}


class AFUnitTest {
  final AFBaseTestID id;
  final AFUnitTestBodyExecuteDelegate fnTest;

  AFUnitTest(this.id, this.fnTest);

  void execute(AFUnitTestContext context) {
    fnTest(context);    
  }

}

class AFUnitTests {
  final tests = <AFUnitTest>[];

  void addTest(AFBaseTestID id, AFUnitTestBodyExecuteDelegate fnTest) {
    tests.add(AFUnitTest(id, fnTest));
  }
}
