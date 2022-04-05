


import 'package:afib/src/dart/command/af_source_template.dart';

class DeclareSPIOnPressedCloseImplT extends AFSourceTemplate {
  final String template = '''
    void onPressedClose() {
      close[!af_control_type_suffix](null);
    }
''';
}
