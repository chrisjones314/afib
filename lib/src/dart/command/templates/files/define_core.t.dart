
import 'package:afib/src/dart/command/af_source_template.dart';

class AFDefineCoreT extends AFSourceTemplate {

  final String template = '''
import 'package:afib/afib_flutter.dart';
[!af_import_statements]

void defineCore(AFCoreDefinitionContext context) {
  defineEventHandlers(context);
  defineInitialState(context);
  defineLibraryProgrammingInterfaces(context);

  [!af_call_ui_functions]
}


void defineEventHandlers(AFCoreDefinitionContext context) {
  context.addDefaultQueryErrorHandler(afDefaultQueryErrorHandler);

  // you can add queries to run at startup.
  // context.addPluginStartupQuery(createMessagingListener);

  // you can add queries which respond to app lifecycle events
  // context.addLifecycleQueryAction((state) => UpdateLifecycleStateQuery(state: state));
  
  // you can add a callback which gets notified anytime a query successfully finishes.
  // context.addQuerySuccessListener(querySuccessListenerDelegate);

}


void defineInitialState(AFCoreDefinitionContext context) {
  context.defineComponentStateInitializer(() => [!af_app_namespace(upper)]State.initial());
}

void defineLibraryProgrammingInterfaces(AFCoreDefinitionContext context) {

}

[!af_declare_ui_functions]


''';
}
