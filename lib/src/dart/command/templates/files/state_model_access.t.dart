import 'package:afib/src/dart/command/af_source_template.dart';

class AFStateModelAccessT extends AFSourceTemplate {

  final String template = '''
import 'package:afib/afib_flutter.dart';

mixin [!af_app_namespace(upper)]StateModelAccess on AFStateModelAccess {
}

''';

}



