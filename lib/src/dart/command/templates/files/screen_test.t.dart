import 'package:afib/src/dart/command/af_source_template.dart';

class AFScreenTestT extends AFSourceTemplate {

  final String template = '''
import 'package:afib/afib_flutter.dart';
import 'package:[!af_package_name]/[!af_app_namespace]_id.dart';

void define[!af_screen_name]Prototypes(AFUIPrototypeDefinitionContext context) {
  _define[!af_screen_name]PrototypeInitial(context);
}

void _define[!af_screen_name]PrototypeInitial(AFUIPrototypeDefinitionContext context) {  
  [!af_declare_create_prototype]

  prototype.defineSmokeTest( 
    body: (e) async {
  });
}
''';
}