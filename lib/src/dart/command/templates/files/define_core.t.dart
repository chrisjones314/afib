
import 'package:afib/src/dart/command/af_source_template.dart';

class AFDefineCoreT extends AFSourceTemplate {

  final String template = '''
import 'package:afib/afib_flutter.dart';
[!af_import_statements]

void defineCore(AFCoreDefinitionContext context) {
  defineInitialState(context);
  defineLibraryProgrammingInterfaces(context);

  [!af_call_ui_functions]
}

void defineInitialState(AFCoreDefinitionContext context) {
  context.defineComponentStateInitializer(() => [!af_app_namespace(upper)]State.initial());
}

void defineLibraryProgrammingInterfaces(AFCoreDefinitionContext context) {

}

[!af_declare_ui_functions]

''';
}
