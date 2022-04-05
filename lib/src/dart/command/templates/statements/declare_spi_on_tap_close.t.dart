


import 'package:afib/src/dart/command/af_source_template.dart';

class DeclareSPIOnTapCloseImplT extends AFSourceTemplate {
  final String template = '''
    void onTapClose() {
      close[!af_control_type_suffix]();
    }
''';
}
