
import 'dart:io';
import 'package:afib/src/dart/command/af_command.dart';
import 'package:afib/src/dart/utils/afib_d.dart';
import 'package:path/path.dart';

class AFStatementID {
  static const stmtDeclareID = 'declareID';
}

class AFProjectPaths {
  /// File names
  static const pubspecFile = 'pubspec.yaml';
  static const afibConfigFile = 'afib.g.dart';
  static const libFolder = 'lib';
  static const testFolder = 'test';
  static const afibFolder = 'afib';
  static const srcFolder = 'src';
  static const folderCount = 'count';
  static const initializationFolder = 'initialization';
  static const folderProjectStyles = "project_styles";
  static const libPath = [libFolder];
  static const initializationPath = [libFolder, initializationFolder];
  static const pubspecPath = [pubspecFile];
  static const idFile = "id.dart";
  static const idPath = [libFolder, idFile];
  static const afTestFile = "main_afib_test.dart";
  static const afTestPath = [testFolder, afibFolder, afTestFile];
  static const afTestConfigFile = "afib_test_config.g.dart";
  static const afTestConfigPath = [testFolder, afibFolder, afTestConfigFile];
  static const generateFolder = "generate";
  static const folderCore = "core";
  static const folderExample = "example";
  static const folderFiles = "files";
  static const folderEvalDemo = "app-eval-demo";
  static const folderSnippets = "snippets";
  static const folderStarterSignin = "app-starter-signin";
  static const folderStarterMinimal = "app-starter-minimal";
  static const folderStarterSigninFirebase = "app-starter-signin-firebase";
  static const folderTestIntentionalFailTest = "app-test-intentional-fail-test";
  static const pathGenerateCoreFiles = [folderCore, folderFiles];
  static const pathGenerateCoreSnippets = [folderCore, folderSnippets];
  static const pathGenerateExample = [folderExample];
  static const pathGenerateExampleEvalDemoFiles = [folderProjectStyles, folderEvalDemo, folderFiles];
  static const pathGenerateExampleEvalDemoSnippets = [folderProjectStyles, folderEvalDemo, folderSnippets];
  static const pathGenerateStarterMinimalFiles = [folderProjectStyles, folderStarterMinimal, folderFiles];
  static const pathGenerateStarterMinimalSnippets = [folderProjectStyles, folderStarterMinimal, folderSnippets];
  static const pathGenerateStarterSigninFiles = [folderProjectStyles, folderStarterSignin, folderFiles];
  static const pathGenerateStarterSigninSnippets = [folderProjectStyles, folderStarterSignin, folderSnippets];
  static const pathGenerateStarterSigninFirebaseFiles = [folderProjectStyles, folderStarterSigninFirebase, folderFiles];
  static const pathGenerateStarterSigninFirebaseSnippets = [folderProjectStyles, folderStarterSigninFirebase, folderSnippets];
  static const pathGenerateTestIntentionalFailTestFiles = [folderProjectStyles, folderTestIntentionalFailTest, folderFiles];
  static const pathProjectStyles = [folderProjectStyles];

  static List<String>? extraParentFolder;

  static List<String> generateFolderFor(List<String> subpath) {
    final result = subpath.toList();
    result.insert(0, generateFolder);
    final idxLast = result.length - 1;
    final file = result[idxLast];
    final fileWithExtension = "$file.t_dart";
    result[idxLast] = fileWithExtension;
    return result;
  }

  static String generatePathFor(List<String> projectPath) {
    final subpath = generateFolderFor(projectPath);
    final current = AFibD.currentWorkingDirectory;      
    final projectRoot = split(current);
    final projectRootFolders = List<String>.from(projectRoot);
    projectRootFolders.addAll(subpath);
    return joinAll(projectRootFolders);
  }

  static bool generateFileExists(List<String> relativePath) {
    final fullPath = generateFolderFor(relativePath);
    final path = fullPathFor(fullPath);
    return pathExists(path);
  }

  static bool projectFileExists(List<String> relativePath) {
    final path = fullPathFor(relativePath);
    return pathExists(path);
  }

  static bool pathExists(String path) {
    return FileSystemEntity.typeSync(path) != FileSystemEntityType.notFound;
  }

  static String fullPathFor(List<String> relativePath) {
    return createLibraryFriendlyPathFor(relativePath); 
  }

  static String createLibraryFriendlyPathFor(List<String> relativeFolder) {
    final current = AFibD.currentWorkingDirectory;
    final projectRoot = split(current);
    final projectRootFolders = List<String>.from(projectRoot);
    final relativeSrcFolder = List<String>.from(relativeFolder);        
    /*
    if(relativeSrcFolder.first == libFolder && hasLibSrcFolder(projectRootFolders)) {
      if(relativeSrcFolder[1] != srcFolder) {      
        relativeSrcFolder.insert(1, srcFolder);
      }
    }
    */

    projectRootFolders.addAll(relativeSrcFolder);
    return joinAll(projectRootFolders);

  }

  static bool hasLibSrcFolder(List<String> projectRootFolders) {
    final projectRoot = List<String>.from(projectRootFolders);
    projectRoot.addAll([libFolder, srcFolder]);
    final path = joinAll(projectRoot);
    return pathExists(path);
  }

  static bool ensureFolderExistsForFile(List<String> filePath) {
    final temp = List<String>.of(filePath);
    temp.removeLast();
    return ensureFolderExists(temp);
  }

  static bool ensureFolderExists(List<String> filePath) {
    if(!projectFileExists(filePath)) {
      createProjectFolder(filePath);
      return true;
    }
    return false;
  }


  static void createProjectFolder(List<String> projectPath) {
    final path = fullPathFor(projectPath);
    Directory(path).createSync(recursive: true);
  }

  static List<String> createPath(List<String> folders, { required bool underSrc }) {
    final path = List<String>.from(folders);
    if(underSrc && AFibD.config.isLibraryCommand && path[0] == libFolder) {
      path.insert(1, srcFolder);
    }
    return path;
  }

  static List<String> createFile(List<String> folders, String filename, { required bool underSrc }) {
    final path = createPath(folders, underSrc: underSrc);
    path.add(filename);
    return path;
  }



  static String relativePathFor(List<String> projectPath, { bool allowExtra = true}) {
    final temp = <String>[];

    // this is used by the 'new' command, which takes place from one folder below the 
    // project folder, which is where most commands are run.
    final extraParent = extraParentFolder;
    if(allowExtra && extraParent != null) {
      temp.addAll(extraParent);
    }
    temp.addAll(projectPath);

    return joinAll(temp);
  }

  static bool inRootOfAfibProject(AFCommandContext ctx) {
    if(!AFProjectPaths.projectFileExists(AFProjectPaths.pubspecPath)) {
      return false;
    }
    if(ctx.isRootCommand && !AFProjectPaths.projectFileExists(ctx.generator.pathAfibConfig)) {
      return false;
    }

    return true;
  }

}