



import 'package:afib/src/dart/command/af_source_template.dart';

class AFLPIT extends AFSourceTemplate {

  final String template = '''
import 'package:afib/afib_flutter.dart';

class [!af_lpi_type] extends [!af_lpi_parent_type] {

  [!af_lpi_type](AFLibraryProgrammingInterfaceID id, AFLibraryProgrammingInterfaceContext context): super(id, context);

  factory [!af_lpi_type].create(AFLibraryProgrammingInterfaceID id, AFLibraryProgrammingInterfaceContext context) {
    return [!af_lpi_type](id, context);
  }
}
''';

}






