
import 'package:flutter_test/flutter_test.dart' as flutter_test;

abstract class AFBaseTestExecute {

  void expect(dynamic value, flutter_test.Matcher matcher) {
    final matchState = Map();
    if(!addPassIf(matcher.matches(value, matchState))) {
      final matchDesc = matcher.describe(flutter_test.StringDescription());
      final desc = "Expected $matchDesc, found $value";
      addError(desc, 1);
    }
  }

  bool addPassIf(bool test);
  void addError(String err, int depth);

}