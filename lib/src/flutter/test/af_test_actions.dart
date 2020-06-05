

import 'package:afib/src/flutter/test/af_screen_test.dart';

/// Place a test context in the store, so that it can be referenced
/// by both the screen and the debug drawer
class AFAddTestContextAction {
    final AFScreenTestContext context;

    AFAddTestContextAction(this.context);
}