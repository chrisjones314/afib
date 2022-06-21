import 'package:afib/afib_command.dart';
import 'package:afib/src/dart/command/commands/af_typedefs_command.dart';
import 'package:afib/src/dart/utils/afib_d.dart';
import 'package:afib/src/flutter/utils/af_typedefs_flutter.dart';
import 'package:afib/src/flutter/utils/afib_f.dart';
import 'package:flutter/material.dart';

void afMainFirstStartup() {
  WidgetsFlutterBinding.ensureInitialized();
}

void afMainWrapper(Function() onReady) {
  WidgetsFlutterBinding.ensureInitialized();
  AFibD.registerGlobals();
  onReady();
}


/// [afMainApp] handles startup, execution, and shutdown sequence for an afApp
void afMainApp({
  required AFDartParams paramsDart, 
  AFExtendBaseDelegate? installBase,
  AFExtendBaseDelegate? installBaseLibrary,
  required AFExtendAppDelegate installCoreApp, 
  AFExtendLibraryUIDelegate? installCoreLibrary, 
  required AFExtendTestDelegate installTest
}) {
  final baseContext = AFBaseExtensionContext();
  if(installBase != null) {
    installBase(baseContext);
  }
  if(installBaseLibrary != null) {
    installBaseLibrary(baseContext);
  }
  AFibD.initialize(paramsDart);

  final context = AFibF.context;


  installCoreApp(context);
  installTest(context.test);
  if(installCoreLibrary != null) {
    installCoreLibrary(context.thirdParty);
  }


  AFibF.initialize(context, AFConceptualStore.appStore);
  
  final createApp = AFibF.g.createApp;
  if(createApp == null) throw AFException("Missing create app function");
  final app = createApp();
  app.afBeforeRunApp();
  runApp(app);
  app.afAfterRunApp();

}