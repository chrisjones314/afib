import 'package:afib/afib_command.dart';
import 'package:afib/src/dart/command/commands/af_typedefs_command.dart';
import 'package:afib/src/dart/utils/af_typedefs_dart.dart';
import 'package:afib/src/dart/utils/afib_d.dart';


/// Initialize afib comamnds that are used from the application-specific
/// commamd
void _afRegisterAppCommands(AFCommandAppExtensionContext definitions) {
  definitions.registerStandardCommands();
}

void _afRegisterBootstrapCommands(AFCommandAppExtensionContext definitions) {
  definitions.registerBootstrapCommands();
}

/// The function called from the afib_bootstrap command.
Future<void> afBootstrapCommandMain(AFDartParams paramsD, AFArgs args) async {
  await _afCommandMain(paramsD, args, "afib_bootstrap", "Command used to create new afib projects", null, null, [
    _afRegisterBootstrapCommands
  ], null);
}

/// A wrapper which sets up AFib's global state for use in commands, prior to call the main AFib function.
void afCommandStartup(Future<void> Function() onRun) async {
  AFibD.registerGlobals();
  await onRun();
}

/// The function called from your bin/xxx_afib.dart file.
Future<void> afAppCommandMain({
  required AFArgs args, 
  required AFDartParams paramsDart, 
  required AFExtendBaseDelegate installBase, 
  required AFExtendCommandsDelegate installCommand, 
  required AFExtendBaseDelegate installBaseLibrary, 
  required AFExtendCommandsLibraryDelegate installCommandLibrary
}) async {
  await _afCommandMain(paramsDart, args, "afib", "App-specific afib command", installBase, installBaseLibrary, [
    _afRegisterAppCommands,
    installCommand
  ], installCommandLibrary);
}

/// The main function called from the bin/xxx_afib.dart command of a library.
Future<void> afLibraryCommandMain({ 
  required AFDartParams paramsDart, 
  required AFArgs args, 
  required AFExtendBaseDelegate installBase, 
  required AFExtendBaseDelegate installBaseLibrary, 
  required AFExtendCommandsDelegate installCommand, 
  required AFExtendCommandsLibraryDelegate installCommandLibrary
}) async {
  AFibD.config.setIsLibraryCommand(isLib: true);
  await _afCommandMain(paramsDart, args, "afib", "App-specific afib command", installBase, installBaseLibrary, [
    _afRegisterAppCommands,
    installCommand,
  ], installCommandLibrary);
}

Future<void> _afCommandMain(AFDartParams paramsD, AFArgs argsIn, String cmdName, String cmdDescription, AFExtendBaseDelegate? initBase, AFExtendBaseDelegate? initBaseLibrary, List<AFExtendCommandsDelegate> inits, AFExtendCommandsLibraryDelegate? initExtend) async {
  final definitions = AFCommandAppExtensionContext(paramsD: paramsD, commands: AFCommandRunner(cmdName, cmdDescription));
  final baseContext = AFBaseExtensionContext();

  if(initBase != null) {
    initBase(baseContext);
  }
  if(initBaseLibrary != null) {
    initBaseLibrary(baseContext);
  }

  // initialize the stuff that is accessible from dart/the command line.
  AFibD.initialize(paramsD);

  for(final init in inits) {
    init(definitions);
  }
  if(initExtend != null) {
    initExtend(definitions);
  }

  final generator = AFCodeGenerator(definitions: definitions);
  final packagePath = generator.packagePath(AFibD.config.packageName);
  final coreInsertions = AFSourceTemplateInsertions.createCore(packagePath: packagePath);

  final context = AFCommandContext.withArguments(
    output: AFCommandOutput(),
    definitions: definitions,
    generator: generator,
    arguments: argsIn,
    packagePath: packagePath,
    coreInsertions: coreInsertions,
    globalTemplateOverrides: null,
  );

  context.startCommand();
  
  await definitions.execute(context);
}