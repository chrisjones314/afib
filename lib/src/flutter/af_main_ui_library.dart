import 'package:afib/src/dart/command/af_command_enums.dart';
import 'package:afib/src/dart/command/commands/af_typedefs_command.dart';
import 'package:afib/src/dart/utils/af_dart_params.dart';
import 'package:afib/src/dart/utils/af_id.dart';
import 'package:afib/src/flutter/af_app_ui_library.dart';
import 'package:afib/src/flutter/af_main.dart';
import 'package:afib/src/flutter/core/af_app_extension_context.dart';
import 'package:afib/src/flutter/ui/theme/af_default_fundamental_theme.dart';
import 'package:afib/src/flutter/utils/af_typedefs_flutter.dart';
import 'package:afib/src/flutter/utils/afib_f.dart';

/// [afMainApp] handles startup, execution, and shutdown sequence for an afApp
void afMainUILibrary({
  required AFLibraryID id, 
  required AFDartParams paramsDart, 
  required AFExtendBaseDelegate installBase, 
  required AFExtendBaseDelegate installBaseLibrary, 
  required AFExtendCoreLibraryDelegate installCoreLibrary, 
  required AFExtendTestDelegate installTest
}) {
  final appContext = AFibF.context;

  final contextLibrary = AFCoreLibraryExtensionContext(id: id, app: appContext.thirdParty);
  installCoreLibrary(contextLibrary);

  final paramsProto = paramsDart.forceEnvironment(AFEnvironment.prototype);
 
  // ignore: omit_local_variable_types
  final AFExtendAppDelegate extendAppFull = (context) {
    context.fromUILibrary(contextLibrary,
      createApp: () => AFAppUILibrary(),
      defineFundamentalTheme: defineAFDefaultFundamentalTheme,
    );
  };

  afMainApp(
    paramsDart: paramsProto, 
    installBase: installBase,
    installBaseLibrary: installBaseLibrary,
    installCoreApp: extendAppFull,
    installTest: installTest,
    appContext: appContext,
  );
}