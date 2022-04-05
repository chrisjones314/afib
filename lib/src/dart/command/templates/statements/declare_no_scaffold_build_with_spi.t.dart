import 'package:afib/src/dart/command/af_source_template.dart';

class DeclareNoScaffoldBuildWithSPIImplT extends AFSourceTemplate {
  final String template = '''
    return _buildBody(spi);
''';
}

 