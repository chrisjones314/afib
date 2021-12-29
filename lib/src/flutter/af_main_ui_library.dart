import 'package:afib/src/dart/command/af_command_enums.dart';
import 'package:afib/src/dart/command/commands/af_typedefs_command.dart';
import 'package:afib/src/dart/redux/state/models/af_app_state.dart';
import 'package:afib/src/dart/utils/af_dart_params.dart';
import 'package:afib/src/dart/utils/af_id.dart';
import 'package:afib/src/flutter/af_app_ui_library.dart';
import 'package:afib/src/flutter/af_main.dart';
import 'package:afib/src/flutter/core/af_app_extension_context.dart';
import 'package:afib/src/flutter/ui/theme/af_default_fundamental_theme.dart';
import 'package:afib/src/flutter/utils/af_typedefs_flutter.dart';

/// [afMain] handles startup, execution, and shutdown sequence for an afApp
void afMainUILibrary<TState extends AFFlexibleState>(AFLibraryID id, AFDartParams paramsD, AFExtendBaseDelegate extendBase, AFExtendBaseDelegate extendBaseThirdParty, AFExtendUILibraryDelegate extendApp, AFExtendTestDelegate extendTest) {
  final contextLibrary = AFUILibraryExtensionContext(id: id);
  extendApp(contextLibrary);

  final paramsProto = paramsD.forceEnvironment(AFEnvironment.prototype);
 
  final extendAppFull = (context) {
    context.fromUILibrary(contextLibrary,
      createApp: () => AFAppUILibrary(),
      initFundamentalThemeArea: initAFDefaultFundamentalThemeArea,
    );
  };

  afMain<TState>(paramsProto, extendBase, extendBaseThirdParty, extendAppFull, null, extendTest);
}