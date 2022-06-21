import 'package:afib/src/dart/command/af_command_enums.dart';
import 'package:afib/src/dart/command/commands/af_typedefs_command.dart';
import 'package:afib/src/dart/utils/af_dart_params.dart';
import 'package:afib/src/dart/utils/af_id.dart';
import 'package:afib/src/flutter/af_app_ui_library.dart';
import 'package:afib/src/flutter/af_main.dart';
import 'package:afib/src/flutter/core/af_app_extension_context.dart';
import 'package:afib/src/flutter/ui/theme/af_default_fundamental_theme.dart';
import 'package:afib/src/flutter/utils/af_typedefs_flutter.dart';

/// [afMainApp] handles startup, execution, and shutdown sequence for an afApp
void afMainUILibrary({
  required AFLibraryID id, 
  required AFDartParams paramsDart, 
  required AFExtendBaseDelegate installBase, 
  required AFExtendBaseDelegate installBaseLibrary, 
  required AFExtendUILibraryDelegate installCoreLibrary, 
  required AFExtendTestDelegate installTest
}) {
  final contextLibrary = AFCoreLibraryExtensionContext(id: id);
  installCoreLibrary(contextLibrary);

  final paramsProto = paramsDart.forceEnvironment(AFEnvironment.prototype);
 
  final extendAppFull = (context) {
    context.fromUILibrary(contextLibrary,
      createApp: () => AFAppUILibrary(),
      defineFundamentalThemeArea: defineAFDefaultFundamentalThemeArea,
    );
  };

  afMainApp(
    paramsDart: paramsProto, 
    installBase: installBase,
    installBaseLibrary: installBaseLibrary,
    installApp: extendAppFull,
    installTest: installTest
  );
}