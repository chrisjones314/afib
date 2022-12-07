
import 'package:afib/src/dart/command/af_source_template.dart';


class DefineCoreUIFunctionsT extends AFSourceTemplate {
  static const insertFundamentalThemeInitCall = AFSourceTemplateInsertion("query_type");

  String get template => '''
void defineFunctionalThemes(AFCoreDefinitionContext context) {
}

void defineScreens(AFCoreDefinitionContext context) {
  context.defineStartupScreen(${insertAppNamespaceUpper}ScreenID.startup, () => StartupScreenRouteParam.create());
}  

void defineFundamentalTheme(AFFundamentalDeviceTheme device, AFComponentStates appState, AF${insertLibKind}FundamentalThemeAreaBuilder primary) {
  $insertFundamentalThemeInitCall
}
''';
}

class DefineCoreCallUIFunctionsT extends AFSourceTemplate {
  final String template = '''
  defineFunctionalThemes(context);
  defineScreens(context);
''';
}

class DefineCoreT extends AFCoreFileSourceTemplate {
  static const insertCallUIFunctions = AFSourceTemplateInsertion("call_ui_functions");
  static const insertDeclareUIFunctions = AFSourceTemplateInsertion("declare_ui_functions");

  DefineCoreT(): super(
    templateFileId: "define_core",
  );

  String get template => '''
import 'package:flutter/material.dart';
import 'package:afib/afib_flutter.dart';

void defineCore(AFCoreDefinitionContext context) {
  defineEventHandlers(context);
  defineInitialState(context);
  defineLibraryProgrammingInterfaces(context);

  $insertCallUIFunctions
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
  context.defineComponentStateInitializer(() => ${insertAppNamespaceUpper}State.initial());
}

void defineLibraryProgrammingInterfaces(AFCoreDefinitionContext context) {

}

$insertDeclareUIFunctions

''';
}
