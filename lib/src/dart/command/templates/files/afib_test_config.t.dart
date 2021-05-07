

import 'package:afib/src/dart/command/af_source_template.dart';

class AFTestConfigT extends AFSourceTemplate {

  @override
  final String template = '''
AFRP(import_afib_command)

// This file is overwritten each time you run the your xx_afib test command.
// 
// If you'd like to debug a specific test, just manually enter the test id the
// enabledTestList array below, and then debug from the main function in your test/afib/afib_test.dart.

void configureTests(AFConfig config) {
  AFRP(configuration_entries)
}
''';
}
