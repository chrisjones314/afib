
import 'dart:io';
import 'package:afib/afib_command.dart';


class AFRequireCommand extends AFCommand { 
  static const argAutoInstall = "auto-install";
  static const argLocalAFib = "local-afib";
  static const argIntegrateCode = "integrate-code";
  @override
  final name = "require";
  @override
  final description = "Require that a library is in the pubspec/integrated, used mainly in project styles.";


  @override
  String get usage {
    return '''
$usageHeader
  $nameOfExecutable $name <library name>

$descriptionHeader
  $description

$optionsHeader
  --$argIntegrateCode <code> - If specifies, checks that the specified library code exists in AFib's list of libraries, meaning the 'integrate' command has been run for that library.
  --$argLocalAFib <path> - If specified, adds AFib dependencies at the local path, rather than adding them from pub.dev
  --$argAutoInstall [true|false] - If true, automatically installs required dependencies without asking

''';
  }

  Future<Process> _runProcess(String cmd, List<String> params) async {
    var process = await Process.start(cmd, params);
    stdout.addStream(process.stdout);
    stderr.addStream(process.stderr);      
    return process;
  }

  @override
  Future<void> execute(AFCommandContext context) async {
    // load in the pubspec.
    final pubspec = context.loadPubspec();

    final args = context.parseArguments(command: this, unnamedCount: 1, named: {
      argIntegrateCode: "",
      argAutoInstall: "false",
      argLocalAFib: "",
    });

    final integrateCode = args.accessNamed(argIntegrateCode);
    final autoInstall = args.accessNamedFlag(argAutoInstall);
    final localAFib = args.accessNamed(argLocalAFib);
    final desiredPackage = args.accessUnnamedFirst;
    final desiredPackages = desiredPackage.split(",");
    final missing = <String>[];

    for(final pkg in desiredPackages) {
      final pkgTrim = pkg.trim();
      final import = pubspec.dependencies[pkgTrim];
      if(import == null) {
        missing.add(pkgTrim);
      }
    }

    if(missing.isNotEmpty) {
      context.output.writeLine("You are the following packages required by this project style: ");
      for(final miss in missing) {
        context.output.writeLine("  $miss");
      }
      if(!autoInstall) {
        context.output.writeLine("Would you AFib to add them using flutter pub add? (y/n)");
        int val = stdin.readByteSync();
        while(val != 121 && val != 110) {
          context.output.writeLine("Please type y or n");
        }
        if(val == 110) {
          throw AFCommandError(error: "Aborted due to missing dependencies.");
        }
      }

      for(final miss in missing) {
        context.output.writeTwoColumns(col1: "run ", col2: "flutter pub add $miss");
        var addText = miss;
        var addCmd = "flutter";
        if(localAFib.isNotEmpty && miss.startsWith("afib")) {
          // 'afib:{"path":"/Users/chrisjones/projects/afib/afib"}'
          addText = "$miss:{\"path\":\"$localAFib${Platform.pathSeparator}$miss\"}";
          addCmd = "dart";
        }

        var process = await _runProcess(addCmd, ['pub', 'add', addText]);
        var exitCode = await process.exitCode;
        if(exitCode != 0) {
          throw AFException("The command 'flutter pub add $addText' failed with exit code $exitCode");
        }
      }

      context.output.writeTwoColumns(col1: "run ", col2: "flutter pub get");
      var process = await _runProcess('flutter', ['pub', 'get']);
      var exitCode = await process.exitCode;
      if(exitCode != 0) {
        throw AFException("The command 'flutter pub get' failed with exit code $exitCode");
      }
    }

    final reqMsg = StringBuffer(desiredPackage);
    if(integrateCode.isNotEmpty) {
      reqMsg.write(" (integrated $integrateCode)");
    }
    
    context.output.writeTwoColumns(col1: "require ", col2: reqMsg.toString());

   
  }
}