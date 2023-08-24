
import 'package:afib/afib_command.dart';

/// Any class that ends in "T" is a source template used in code generation.
class DefineCoreUIFunctionsT extends AFSourceTemplate {
  static const insertFundamentalThemeInitCall = AFSourceTemplateInsertion("query_type");

  @override
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
  @override
  final String template = '''
  defineFunctionalThemes(context);
  defineScreens(context);
''';
}

class DefineCoreT extends AFFileSourceTemplate {
  static const insertCallUIFunctions = AFSourceTemplateInsertion("call_ui_functions");
  static const insertDeclareUIFunctions = AFSourceTemplateInsertion("declare_ui_functions");
  static const insertAddStateViewAugmentor = AFSourceTemplateInsertion("add_state_view_augmentor");

  DefineCoreT({
    required String templateFileId,
    required List<String> templateFolder,
    required AFSourceTemplateInsertions? embeddedInsertions,
  }): super(
    templateFileId: templateFileId,
    templateFolder: templateFolder,
    embeddedInsertions: embeddedInsertions,
  );

  factory DefineCoreT.core() {
    return DefineCoreT(
      templateFileId: "define_core",
      templateFolder: AFProjectPaths.pathGenerateCoreFiles,
      embeddedInsertions: const AFSourceTemplateInsertions(insertions: {
        insertAddStateViewAugmentor: AFSourceTemplate.empty,
        AFSourceTemplate.insertExtraImportsInsertion: AFSourceTemplate.empty,
      })
    );
  }

  @override
  String get template => '''
import 'package:flutter/material.dart';
import 'package:afib/afib_flutter.dart';
${AFSourceTemplate.insertExtraImportsInsertion}
import 'package:$insertPackagePath/state/stateviews/${insertAppNamespace}_default_state_view.dart';

// ignore_for_file: unnecessary_import

void defineCore(AFCoreDefinitionContext context) {
  defineEventHandlers(context);
  defineInitialState(context);
  defineLibraryProgrammingInterfaces(context);

  $insertCallUIFunctions
}


void defineEventHandlers(AFCoreDefinitionContext context) {
  context.addDefaultQueryErrorHandler((err) {
    // AFIB_TODO: If you are getting an error dialog, and you want to set a breakpoint showing where it has been thrown,
    // this is a good place to do it.
    afDefaultQueryErrorHandler(err);
  });

  // you can add queries to run at startup.
  // context.addPluginStartupQuery(createMessagingListener);

  // you can add queries which respond to app lifecycle events
  // context.addLifecycleQueryAction((state) => UpdateLifecycleStateQuery(state: state));
  
  // you can add a callback which gets notified anytime a query successfully finishes.
  // context.addQuerySuccessListener(querySuccessListenerDelegate);

  // you can add code the places extra state data into a third party state view.
  // you can then access the data from within overrides of that third party's theme, 
  // using context.s.findType<YourType>() (assuming you put)
  // context.addStateViewAugmentationHandler<AFSIDefaultStateView>((context, result) { 
  //    final ${insertAppNamespace}State = context.accessComponentState<${insertAppNamespaceUpper}State>();
  //    result.add(${insertAppNamespace}State.yourType);
  // });

  $insertAddStateViewAugmentor

}


void defineInitialState(AFCoreDefinitionContext context) {
  context.defineComponentStateInitializer(() => ${insertAppNamespaceUpper}State.initial());

  context.defineComponentStateCreator<${insertAppNamespaceUpper}State>(${insertAppNamespaceUpper}State.create);

  context.defineStateViewCreator<${insertAppNamespaceUpper}DefaultStateView>(${insertAppNamespaceUpper}DefaultStateView.create);
}

void defineLibraryProgrammingInterfaces(AFCoreDefinitionContext context) {

}

$insertDeclareUIFunctions

''';
}
