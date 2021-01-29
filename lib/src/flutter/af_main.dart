
import 'package:afib/afib_command.dart';
import 'package:afib/src/dart/redux/state/af_app_state.dart';
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
  onReady();
}


/// [afMain] handles startup, execution, and shutdown sequence for an afApp
void afMain<TState extends AFAppStateArea>(AFDartParams paramsD, AFExtendAppDelegate extendApp, AFExtendThirdPartyDelegate extendThirdParty, AFExtendTestDelegate extendTest) {
  AFibD.initialize(paramsD);

  final context = AFAppExtensionContext();
  extendApp(context);
  extendTest(context.test);
  if(extendThirdParty != null) {
    extendThirdParty(context.thirdParty);
  }

  AFibF.initialize<TState>(context);
  
  final app = AFibF.g.createApp();
  app.afBeforeRunApp();
  runApp(app);
  app.afAfterRunApp();

}