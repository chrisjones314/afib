
import 'package:afib/afib_command.dart';
import 'package:afib/src/dart/command/templates/core/files/unit_test.t.dart';

class AFUnitTestFailBody extends AFSourceTemplate {
  @override
  String get template => '''
    e.expect("MISMATCH", ft.equals("INTENTIONAL FAIL"));
  ''';
}

class UnitTestIntentionalFail {
  static UnitTestT template() {
    return UnitTestT(
      templateFileId: "unit_test_intentional_fail", 
      templateFolder: AFProjectPaths.pathGenerateTestIntentionalFailTestFiles,
      testCode: AFUnitTestFailBody(),
    );
  }

}