
import 'package:afib/afib_command.dart';

class AFRequireCommand extends AFCommand { 
  final argIntegrateCode = "integrate-code";
  final name = "require";
  final description = "Require that a library is in the pubspec/integrated, used mainly in project styles.";


  String get usage {
    return '''
$usageHeader
  $nameOfExecutable $name <library name>

$descriptionHeader
  $description

$optionsHeader
  --$argIntegrateCode <code> - If specifies, checks that the specified library code exists in AFib's list of libraries, meaning the 'integrate' command has been run for that library.

''';
  }

  @override
  Future<void> execute(AFCommandContext context) async {
    // load in the pubspec.
    final pubspec = context.loadPubspec();

    final args = context.parseArguments(command: this, unnamedCount: 1, named: {
      argIntegrateCode: "",
    });

    final integrateCode = args.accessNamed(argIntegrateCode);

    final desiredPackage = args.accessUnnamedFirst;
    final reqMsg = StringBuffer(desiredPackage);
    if(integrateCode.isNotEmpty) {
      reqMsg.write(" (integrated $integrateCode)");
    }
    
    context.output.writeTwoColumns(col1: "require ", col2: reqMsg.toString());

    final import = pubspec.dependencies[desiredPackage];
    if(import == null) {
      throw AFCommandError(error: "You must update your pubspec's dependencies section to include $desiredPackage.  See pub.dev for its latest version and install instructions.");
    }
   
  }
}