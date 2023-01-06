
import 'package:afib/afib_command.dart';
import 'package:afib/src/dart/command/commands/af_create_command.dart';
import 'package:afib/src/dart/command/templates/af_code_regexp.dart';
import 'package:afib/src/dart/command/templates/core/snippets/snippet_call_install.t.dart';
import 'package:afib/src/dart/command/templates/core/snippets/snippet_import_from_package.t.dart';

class AFIntegrateCommand extends AFCommand { 
  final name = "integrate";
  final description = "integrate a third-party library, or the second part of a project style";
  static const kindLibrary = "library";
  static const kindProjectStyle = "project-style";


  String get usage {
    return '''
$usageHeader
  $nameOfExecutable $name [$kindLibrary|$kindProjectStyle your-style] [--options] 

$descriptionHeader
  $kindLibrary - Integrates an afib-aware third party library's commands, tests and UI
  $kindProjectStyle - Applys the second half of a project-style that references 3rd party components, and consequently
    cannot complete its work via afib-bootstrap

$optionsHeader
  $kindLibrary
    --${AFCreateAppCommand.argPackageName} - the package name for the library, e.g. afib_signin
    --${AFCreateAppCommand.argPackageCode} - the 3-5 letter all lowercase code the library uses.  This value
      is declared in the library's xxx_config.g.dart file, it is not a
      value that you get to choose.  For example, for afib_signin it is AFSI.
      The library's installation instructions should tell you this value.
  $kindProjectStyle
    The name of the project style you wish to integrate (internally, runs the project style with the "-integrate" suffix)
''';
  }

  @override
  Future<void> execute(AFCommandContext context) async {
    final args = context.parseArguments(
      command: this, 
      named: {
        AFCreateAppCommand.argPackageName: "",
        AFCreateAppCommand.argPackageCode: "",
      }
    );

    final kind = args.accessUnnamedFirst;
    if(kind == kindLibrary) {
      await _integrateLibrary(context, args);
    } else if(kind == kindProjectStyle) {
      await _integrateProjectStyle(context, args);
    } else {
      throwUsageError("Unknown integration type $kind");
    }

  }

  Future<void> _integrateProjectStyle(AFCommandContext context, AFCommandArgumentsParsed args) async {
    final baseProjectStyle = args.accessUnnamedSecond;
    final projectStyle = "$baseProjectStyle${AFCreateAppCommand.integrateSuffix}";
    context.output.writeTwoColumns(col1: "integrate ", col2: "project-style=$projectStyle");
    final stylePath = AFProjectPaths.pathProjectStyles.toList();
    stylePath.add(projectStyle);


    final allInsertions = context.coreInsertions.reviseAugment({
      AFSourceTemplate.insertProjectStyleInsertion: baseProjectStyle,
    });
    final fileProjectStyle = context.readProjectStyle(stylePath, insertions: allInsertions.insertions);
    final lines = AFCommandContext.consolidateProjectStyleLines(context, fileProjectStyle.buffer.lines);
  context.setProjectStyle(projectStyle);
    context.setProjectStyleGlobalOverrides(AFCommandContext.findProjectStyleGlobalOverrides(context, lines));
    final buffer = AFCodeBuffer(projectPath: <String>[], lines: lines, modified: false, extraImports: <String>[]);
    buffer.performInsertions(context, allInsertions);

    await _executeProjectStyle(context, buffer.lines);
  }

  Future<void> _integrateLibrary(AFCommandContext context, AFCommandArgumentsParsed args) async {
    final packageName = args.accessNamed(AFCreateAppCommand.argPackageName);
    final packageCode = args.accessNamed(AFCreateAppCommand.argPackageCode);
    verifyNotEmpty(packageName, "You must specify --${AFCreateAppCommand.argPackageName}");
    verifyNotEmpty(packageCode, "You must specify --${AFCreateAppCommand.argPackageCode}");

    _verifyPubspecContains(context, packageName);

    final generator = context.generator;

    // create a package import for this 
    final importFlutter = SnippetImportFromPackageT().toBuffer(context, insertions: {
      AFSourceTemplate.insertPackageNameInsertion: packageName,
      AFSourceTemplate.insertPackagePathInsertion: "${packageCode}_flutter.dart",
    });

    final importCommand = SnippetImportFromPackageT().toBuffer(context, insertions: {
      AFSourceTemplate.insertPackageNameInsertion: packageName,
      AFSourceTemplate.insertPackagePathInsertion: "${packageCode}_command.dart",
    });

    // extend base
    _extendFile(context, 
      importCode: importCommand, 
      pathExtendFile: generator.pathInstallLibraryBase,
      startExtendRegex: AFCodeRegExp.startExtendLibraryBase,
      packageCode: packageCode,
      installKind: "Base",
    );

    // extend command
    _extendFile(context, 
      importCode: importCommand, 
      pathExtendFile: generator.pathInstallLibraryCommand,
      startExtendRegex: AFCodeRegExp.startExtendLibraryCommand,
      packageCode: packageCode,
      installKind: "Command",
    );


    // extend UI
    _extendFile(context, 
      importCode: importFlutter, 
      pathExtendFile: generator.pathInstallLibraryCore,
      startExtendRegex: AFCodeRegExp.startExtendLibraryUI,
      packageCode: packageCode,
      installKind: "Core",
    );

    context.generator.finalizeAndWriteFiles(context);
  }

  Future<void> _executeProjectStyle(AFCommandContext context, List<String> lines) async {

    for(final line in lines) {
      final simpleLine = AFCommandContext.simplifyProjectStyleCommand(line);
      context.output.writeTwoColumns(col1: "execute ", col2: "$simpleLine");
      if(!line.startsWith("echo")) {
        await context.executeSubCommand(line, null);
      }
    }

    context.generator.finalizeAndWriteFiles(context);

    for(final line in lines) {
      if(line.startsWith("echo")) {
        await context.executeSubCommand(line, null);
      }
    }
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
    fileExtendBase.importAll(ctx, importCode.lines);
    
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