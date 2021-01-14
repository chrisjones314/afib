
import 'package:afib/afib_command.dart';
import 'package:afib/src/dart/redux/state/af_app_state.dart';
import 'package:afib/src/dart/utils/afib_d.dart';
import 'package:afib/src/flutter/af_app_ui_library.dart';
import 'package:afib/src/flutter/af_main.dart';
import 'package:afib/src/flutter/core/af_app_extension_context.dart';
import 'package:afib/src/flutter/ui/theme/af_default_fundamental_theme.dart';
import 'package:afib/src/flutter/utils/af_typedefs_flutter.dart';

/// [afMain] handles startup, execution, and shutdown sequence for an afApp
void afMainUILibrary<TState extends AFAppStateArea>(AFDartParams paramsD, AFExtendUILibraryDelegate extendApp, AFExtendTestDelegate extendTest) {
  final contextLibrary = AFUILibraryExtensionContext();
  extendApp(contextLibrary);

  final paramsProto = paramsD.forceEnvironment(AFEnvironment.prototype);
  AFibD.initialize(paramsProto);

  final extendAppFull = (context) {
    context.fromUILibrary(contextLibrary,
      createApp: () => AFAppUILibrary(),
      initFundamentalThemeArea: initAFDefaultFundamentalThemeArea,
    );
  };

  afMain<TState>(paramsProto, extendAppFull, null, extendTest);
}