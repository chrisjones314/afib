
import 'package:afib/afib_command.dart';
import 'package:afib/src/dart/command/templates/af_code_regexp.dart';
import 'package:afib/src/dart/command/templates/core/snippets/snippet_import_from_package.t.dart';
import 'package:afib/src/dart/command/templates/core/snippets/snippet_call_install.t.dart';

class AFInstallCommand extends AFCommand { 
  final name = "install";
  final description = "Install a third-party library";


  String get usage {
    return '''
$usageHeader
  $nameOfExecutable $name otherpackagename OPC

$descriptionHeader
  Integrates an afib-aware third party library's commands, tests and UI

$optionsHeader

  otherpackagename - the package name for the library, e.g. afib_signin
  OPC - the 3-5 letter all lowercase code the library uses.  This value
    is declared in the libraries ...afib_config.g.dart file, it is not a
    value that you get to choose.  For example, for afib_signin it is AFSI.
    The library's installation instructions should tell you this value.
''';
  }

  @override
  void execute(AFCommandContext ctx) {
    final unnamed = ctx.rawArgs;
    if(unnamed.length != 2) {
      throwUsageError("Please specify two arguments");
    }

    final packageName = unnamed[0];
    final packageCode = unnamed[1];

    _verifyPubspecContains(ctx, packageName);

    final generator = ctx.generator;

    // create a package import for this 
    final importFlutter = SnippetImportFromPackageT().toBuffer(ctx, insertions: {
      AFSourceTemplate.insertPackageNameInsertion: packageName,
      AFSourceTemplate.insertPackagePathInsertion: "${packageCode}_flutter.dart",
    });

    final importCommand = SnippetImportFromPackageT().toBuffer(ctx, insertions: {
      AFSourceTemplate.insertPackageNameInsertion: packageName,
      AFSourceTemplate.insertPackagePathInsertion: "${packageCode}_command.dart",
    });

    // extend base
    _extendFile(ctx, 
      importCode: importCommand, 
      pathExtendFile: generator.pathInstallLibraryBase,
      startExtendRegex: AFCodeRegExp.startExtendLibraryBase,
      packageCode: packageCode,
      installKind: "Base",
    );

    // extend command
    _extendFile(ctx, 
      importCode: importCommand, 
      pathExtendFile: generator.pathInstallLibraryCommand,
      startExtendRegex: AFCodeRegExp.startExtendLibraryCommand,
      packageCode: packageCode,
      installKind: "Command",
    );


    // extend UI
    _extendFile(ctx, 
      importCode: importFlutter, 
      pathExtendFile: generator.pathInstallLibraryCore,
      startExtendRegex: AFCodeRegExp.startExtendLibraryUI,
      packageCode: packageCode,
      installKind: "Core",
    );

    generator.finalizeAndWriteFiles(ctx);
  }


  void _extendFile(AFCommandContext ctx, {
    required AFCodeBuffer importCode,
    required List<String> pathExtendFile,
    required RegExp startExtendRegex,
    required String packageCode,
    required String installKind,
  }) {
    final generator = ctx.generator;
    final fileExtendBase = generator.modifyFile(ctx, pathExtendFile);
    fileExtendBase.addImports(ctx, importCode.lines);
    
    final call = ctx.createSnippet(SnippetCallInstallT(), insertions: {
      SnippetCallInstallT.insertPackageCode: packageCode,
      SnippetCallInstallT.insertInstallKind: installKind,
    });
    fileExtendBase.addLinesAfter(ctx, startExtendRegex, call.lines);
  }


  AFGeneratedFile _verifyPubspecContains(AFCommandContext ctx, String packageName) {
    final generator = ctx.generator;
    final pathPubspec = generator.pathPubspecYaml;
    if(!generator.fileExists(pathPubspec)) {
      throw AFCommandError(error: "The file ${pathPubspec.last} must exist in the folder from which you are running this command");
    }

    final filePubspec = generator.modifyFile(ctx, pathPubspec);
    final pubspec = filePubspec.loadPubspec();

    final import = pubspec.dependencies[packageName];
    if(import == null) {
      throw AFCommandError(error: "You must update your pubspec's dependencies section to include $packageName and do a 'flutter pub get' before using integrate");
    }
    
    return filePubspec;
  }

}