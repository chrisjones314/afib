import 'package:afib/src/dart/utils/af_id.dart';
import 'package:afib/src/flutter/test/af_base_test_execute.dart';


class AFUnitTestContext extends AFUnitTestExecute {
  final AFUnitTest test;
  AFUnitTestContext(this.test);

  AFTestID get testID => this.test.id;

}

typedef void ProcessCalcTest(AFUnitTestExecute e);

abstract class AFUnitTestExecute extends AFBaseTestExecute {

}


class AFUnitTest {
  final AFTestID id;
  final ProcessCalcTest fnTest;

  AFUnitTest(this.id, this.fnTest);

  void execute(AFUnitTestContext context) {
    fnTest(context);    
  }

}

class AFUnitTests {
  final tests = List<AFUnitTest>();

  void addTest(AFTestID id, ProcessCalcTest fnTest) {
    tests.add(AFUnitTest(id, fnTest));
  }
}
