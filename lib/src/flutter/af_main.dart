import 'package:afib/afib_command.dart';
import 'package:afib/src/dart/command/commands/af_typedefs_command.dart';
import 'package:afib/src/dart/redux/state/models/af_app_state.dart';
import 'package:afib/src/dart/utils/af_exception.dart';
import 'package:afib/src/dart/utils/afib_d.dart';
import 'package:afib/src/flutter/core/af_app_extension_context.dart';
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


/// [afMain] handles startup, execution, and shutdown sequence for an afApp
void afMain<TState extends AFFlexibleState>({
  required AFDartParams paramsD, 
  AFExtendBaseDelegate? extendBase,
  AFExtendBaseDelegate? extendThirdPartyBase,
  required AFExtendAppDelegate extendApp, 
  AFExtendThirdPartyUIDelegate? extendThirdPartyUI, 
  required AFExtendTestDelegate extendTest
}) {
  final baseContext = AFBaseExtensionContext();
  if(extendBase != null) {
    extendBase(baseContext);
  }
  if(extendThirdPartyBase != null) {
    extendThirdPartyBase(baseContext);
  }
  AFibD.initialize(paramsD);

  final context = AFAppExtensionContext();


  extendApp(context);
  extendTest(context.test);
  if(extendThirdPartyUI != null) {
    extendThirdPartyUI(context.thirdParty);
  }


  AFibF.initialize<TState>(context);
  
  final createApp = AFibF.g.createApp;
  if(createApp == null) throw AFException("Missing create app function");
  final app = createApp();
  app.afBeforeRunApp();
  runApp(app);
  app.afAfterRunApp();

}