import 'package:afib/src/dart/command/af_source_template.dart';

class DeclareScreenBuildBodyImplT extends AFSourceTemplate {
  final String template = '''
    final t = spi.t;
    return Center(child: t.childText(uiTitle));
''';
}

 