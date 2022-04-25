



import 'package:afib/src/dart/command/af_source_template.dart';

class AFLPIT extends AFSourceTemplate {

  final String template = '''
import 'package:afib/afib_flutter.dart';

class [!af_lpi_type] extends [!af_lpi_parent_type] {

  [!af_lpi_type](AFLibraryProgrammingInterfaceID id, AFDispatcher dispatcher, AFPublicState state): super(id, dispatcher, state);

  factory [!af_lpi_type].create(AFLibraryProgrammingInterfaceID id, AFDispatcher dispatcher, AFPublicState state) {
    return [!af_lpi_type](id, dispatcher, state);
  }
}
''';

}






