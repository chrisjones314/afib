import 'dart:io';

import 'package:afib/src/dart/command/af_command.dart';
import 'package:afib/src/dart/command/commands/af_create_command.dart';
import 'package:afib/src/dart/command/commands/af_require_command.dart';

/// Parent for commands executed through the afib command line app.
class AFSmoketestCommand extends AFCommand { 
  static const argWorkingFolder = "working-folder";
  static const msgSmoketestPass = "SMOKETEST PASS";
  static const msgSmoketestFail = "SMOKETEST FAIL";
  @override
  final String name = "smoketest";
  @override
  final String description = "A command used to smoke test AFib itself, used in continuous integration";

  AFSmoketestCommand();

  @override
  String get usage {
    return '''
$usageHeader
  afib_bootstrap.dart smoketest --$argWorkingFolder /folder/for/test/output --${AFRequireCommand.argLocalAFib} /path/to/local/afib/projects

$descriptionHeader
  $description

$optionsHeader
  --$argWorkingFolder - Specify the folder in which the resultant test projects should be created.
  --${AFRequireCommand.argLocalAFib} - Specify the local path of afib projects, the version of afib you wish to test
''';
  }

  @override
  Future<void> run(AFCommandContext ctx) async {
    // override this to avoid 'error not in root of project'
    await execute(ctx);
  }

  Future<Process> _runProcess(AFCommandContext context, String cmd, List<String> params, { bool echoOutput = false }) async {
    context.output.writeTwoColumns(col1: "execute ", col2: "$cmd ${params.join(' ')}");

    var process = await Process.start(cmd, params);
    if(echoOutput) {
      stdout.addStream(process.stdout);
      stderr.addStream(process.stderr);      
    }
    return process;
  }

  void _setCurrentDirectory(AFCommandContext context, Directory workingDirectory) {
    context.output.writeTwoColumns(col1: "cwd ", col2: workingDirectory.toString());
    Directory.current = workingDirectory;
  } 

  Future<bool> _createAndTestAFibProject(AFCommandContext context, {
    required Directory workingDirectory,
    required String pathBootstrap,
    required String packageName,
    required String packageCode,
    required String projectStyle,
    required String localAfib,
    bool requiresIntegrate = false,
  }) async {
    final output = context.output;
    _setCurrentDirectory(context, workingDirectory);
    // if the destination folder already exists, then show an error.
    final packageFolder = Directory("${workingDirectory.path}${Platform.pathSeparator}$packageName");
    if(packageFolder.existsSync()) {
      output.writeErrorLine("The folder already exists $packageFolder");
      return false;
    }

    // create the flutter  project
    output.writeTwoColumns(col1: "create ", col2: packageName);
    final processFlutterCreate = await _runProcess(context, "flutter", ["create", packageName]);
    final exitFlutterCreate = await processFlutterCreate.exitCode;
    output.writeTwoColumns(col1: "exit code ", col2: exitFlutterCreate.toString());
    if(exitFlutterCreate != 0) {
      output.writeTwoColumnsError(col2: "Create failed with exit code $exitFlutterCreate");
      return false;
    }

    // make the working directory in the flutter project
    _setCurrentDirectory(context, packageFolder);

    // convert it to an afib project.
    output.writeTwoColumns(col1: "convert ", col2: "$packageName/$packageCode/$projectStyle");
    final processAFibCreate = await _runProcess(context, "dart", [
      pathBootstrap, "create", "app", 
      "--${AFCreateAppCommand.argPackageName}", packageName, 
      "--${AFCreateAppCommand.argPackageCode}", packageCode,
      "--${AFCreateAppCommand.argProjectStyle}", projectStyle, 
      "--${AFCommand.argCurrentWorkingDirectory}", packageFolder.path,
      "--${AFRequireCommand.argAutoInstall}", "true",
      "--${AFRequireCommand.argLocalAFib}", localAfib,
    ], echoOutput: true);
    final exitAFibCreate = await processAFibCreate.exitCode;
    output.writeTwoColumns(col1: "exit code ", col2: exitAFibCreate.toString());
    if(exitAFibCreate != 0) {
      output.writeTwoColumnsError(col2: "Convert failed with exit code $exitAFibCreate");
      return false;
    }

    final projectCmd = "bin/${packageCode}_afib.dart";

    // this project style requires a second integration step.
    if(requiresIntegrate) {
      final processIntegrate = await _runProcess(context, "dart", [
        projectCmd,
        "integrate", 
        "project-style",
        projectStyle,
      ], echoOutput: true);
      final exitIntegrate = await processIntegrate.exitCode;
      if(exitIntegrate != 0) {
        output.writeTwoColumnsError(col2: "Integrate failed with exit code $exitIntegrate");
        return false;
      }
    }

    // run the test command.
    final processTest = await _runProcess(context, "dart", [
      projectCmd,
      "test", 
    ], echoOutput: true);
    final exitTest = await processTest.exitCode;
    if(exitTest != 0) {
      output.writeTwoColumnsError(col2: "Tests failed with exit code $exitAFibCreate");
      return false;
    }
    output.writeTwoColumns(col1: "pass ", col2: projectStyle);
    return true;
  }

  @override
  Future<void> execute(AFCommandContext context) async {
    final pathBootstrap = Platform.script.toFilePath();
    // create a folder at a specific location
    
    // run afib-bootstrap to create a minimal app

    // verify that the minimal app's tests succeed.

    // report results in some sort of digestable format
    final args = context.parseArguments(
      command: this,
      unnamedCount: 0,
      named: {
        argWorkingFolder: "",
        AFRequireCommand.argLocalAFib: "",
      });

    final workingFolder = args.accessNamed(argWorkingFolder);
    final localAfib = args.accessNamed(AFRequireCommand.argLocalAFib);
    verifyNotEmpty(workingFolder, "You must specify --$argWorkingFolder");
    verifyNotEmpty(localAfib, "You must specify --${AFRequireCommand.argLocalAFib}");
    final workingDirectoryBase = Directory(workingFolder);
    if(!workingDirectoryBase.existsSync()) {
      context.output.writeErrorLine("The working folder must exist ($workingFolder)");
      return;
    }

    // create a subfolder for the output.
    final now = DateTime.now();

    final subfolder = "st_${now.day}_${now.month}_${now.year}_${now.hour}_${now.minute}_${now.second}";
    final workingDirectory = Directory("$workingFolder${Platform.pathSeparator}$subfolder");
    workingDirectory.createSync();
    if(!workingDirectory.existsSync()) {
      context.output.writeErrorLine("Failed to create folder $workingDirectory");
      return;
    }


    context.output.writeTwoColumns(col1: "smoketest ", col2: workingFolder);
    //var passed = true;
    var passed = await _createAndTestAFibProject(context,
      workingDirectory: workingDirectory,
      pathBootstrap: pathBootstrap,
      packageName: "smoketest_minimal",
      packageCode: "stmin",
      projectStyle: AFCreateAppCommand.projectStyleStarterMinimal,
      localAfib: localAfib,
    );


     passed &= await _createAndTestAFibProject(context,
      workingDirectory: workingDirectory,
      pathBootstrap: pathBootstrap,
      packageName: "smoketest_demo",
      packageCode: "demo",
      projectStyle: AFCreateAppCommand.projectStyleEvalDemo,
      localAfib: localAfib,
    );

     passed &= await _createAndTestAFibProject(context,
      workingDirectory: workingDirectory,
      pathBootstrap: pathBootstrap,
      packageName: "smoketest_signin",
      packageCode: "sign",
      projectStyle: AFCreateAppCommand.projectStyleSignin,
      localAfib: localAfib,
      requiresIntegrate: true,
    );

     passed &= await _createAndTestAFibProject(context,
      workingDirectory: workingDirectory,
      pathBootstrap: pathBootstrap,
      packageName: "smoketest_signinfb",
      packageCode: "sifb",
      projectStyle: AFCreateAppCommand.projectStyleSigninFirebase,
      localAfib: localAfib,
      requiresIntegrate: true,
    );

    /*
    // disabling this for now as its presence is kind of confusing.
    var expectedFailCreatePassed = await _createAndTestAFibProject(context,
      workingDirectory: workingDirectory,
      pathBootstrap: pathBootstrap,
      packageName: "smoketest_failcreate",
      packageCode: "facr",
      projectStyle: AFCreateAppCommand.projectStyleTestIntentionalFailCreate,
      localAfib: localAfib,
    );

    if(expectedFailCreatePassed) {
      context.output.writeTwoColumnsError(col1: "ERROR ", col2: "Intentional failure during create was not detected");
      passed = false;
    }
 
    var expectedFailTestPassed = await _createAndTestAFibProject(context,
      workingDirectory: workingDirectory,
      pathBootstrap: pathBootstrap,
      packageName: "smoketest_failtest",
      packageCode: "smft",
      projectStyle: AFCreateAppCommand.projectStyleTestIntentionalFailTest,
      localAfib: localAfib,
    );

    if(expectedFailTestPassed) {
      context.output.writeTwoColumnsError(col1: "ERROR ", col2: "Intentional failure during test was not detected");
      passed = false;
    }
    */
    
    if(passed) {
      context.output.writeTwoColumns(col1: "pass ", col2: msgSmoketestPass);
    } else {
      context.output.writeTwoColumnsError(col2: msgSmoketestFail);
    }

  }
}