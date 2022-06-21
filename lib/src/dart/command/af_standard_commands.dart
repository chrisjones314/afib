import 'package:afib/afib_command.dart';
import 'package:afib/src/dart/command/commands/af_typedefs_command.dart';
import 'package:afib/src/dart/command/commands/af_version_command.dart';
import 'package:afib/src/dart/utils/af_typedefs_dart.dart';
import 'package:afib/src/dart/utils/afib_d.dart';
import 'package:args/args.dart' as args;

/// Initialize commands that are used only from the afib command
/// line app itself (e.g. new).
void afRegisterAfibOnlyCommands(AFCommandAppExtensionContext commands) {
  commands.defineCommand(AFVersionCommand());
  //commands.register(AFNewProjectCommand());
}

/// Initialize afib comamnds that are used from the application-specific
/// commamd
void afRegisterAppCommands(AFCommandAppExtensionContext definitions) {
  definitions.registerStandardCommands();
}

void afRegisterBootstrapCommands(AFCommandAppExtensionContext definitions) {
  definitions.registerBootstrapCommands();
}

/// Used to initialize and execute commands available via afib_bootstrap
Future<void> afBootstrapCommandMain(AFDartParams paramsD, AFArgs args) async {
  await _afCommandMain(paramsD, args.args, "afib_bootstrap", "Command used to create new afib projects", null, null, [
    afRegisterBootstrapCommands
  ], null);
}

void afCommandStartup(Future<void> Function() onRun) async {
  AFibD.registerGlobals();
  await onRun();
}

Future<void> afAppCommandMain({
  required AFArgs args, 
  required AFDartParams paramsDart, 
  required AFExtendBaseDelegate installBase, 
  required AFExtendCommandsDelegate installCommand, 
  required AFExtendBaseDelegate installBaseLibrary, 
  required AFExtendCommandsLibraryDelegate installCommandLibrary
}) async {
  await _afCommandMain(paramsDart, args.args, "afib", "App-specific afib command", installBase, installBaseLibrary, [
    afRegisterAppCommands,
    installCommand
  ], installCommandLibrary);
}

Future<void> afLibraryCommandMain({ 
  required AFDartParams paramsDart, 
  required AFArgs args, 
  required AFExtendBaseDelegate installBase, 
  required AFExtendBaseDelegate installBaseLibrary, 
  required AFExtendCommandsDelegate installCommand, 
  required AFExtendCommandsLibraryDelegate installCommandLibrary
}) async {
  AFibD.config.setIsLibraryCommand(isLib: true);
  await _afCommandMain(paramsDart, args.args, "afib", "App-specific afib command", installBase, installBaseLibrary, [
    afRegisterAppCommands,
    installCommand,
  ], installCommandLibrary);
}

Future<void> _afCommandMain(AFDartParams paramsD, List<String> argsIn, String cmdName, String cmdDescription, AFExtendBaseDelegate? initBase, AFExtendBaseDelegate? initBaseLibrary, List<AFExtendCommandsDelegate> inits, AFExtendCommandsLibraryDelegate? initExtend) async {
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

  final parsed = args.ArgParser.allowAnything();
  final arguments = parsed.parse(argsIn);

  final ctx = AFCommandContext(
    output: AFCommandOutput(),
    definitions: definitions,
    generator: AFCodeGenerator(definitions: definitions),
    arguments: arguments,
  );
  
  /*
  final afibConfig = AFConfig();
  if(paramsD != null) {
    final configCmd = commands.findConfigCommand();
    configCmd.initAfibDefaults(afibConfig);
    paramsD.initAfib(afibConfig);
  }
  */

  await definitions.execute(ctx);
}