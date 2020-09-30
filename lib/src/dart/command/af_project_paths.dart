

import 'dart:io';
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
  static const initializationFolder = 'initialization';
  static const libPath = [libFolder];
  static const initializationPath = [libFolder, initializationFolder];
  static const afibConfigPath = [libFolder, initializationFolder, afibConfigFile];
  static const pubspecPath = [pubspecFile];
  static const idFile = "id.dart";
  static const idPath = [libFolder, idFile];
  static const afTestFile = "afib_test.dart";
  static const afTestPath = [testFolder, afibFolder, afTestFile];
  static const afTestConfigFile = "afib_test_config.g.dart";
  static const afTestConfigPath = [testFolder, afibFolder, afTestConfigFile];

  static List<String> extraParentFolder;

  static bool projectFileExists(List<String> relativePath) {
    final path = fullPathFor(relativePath);
    return FileSystemEntity.typeSync(path) != FileSystemEntityType.notFound;
  }

  static String fullPathFor(List<String> relativePath) {
    final current = Directory.current;  
    final projectRoot = split(current.path);
    final temp = List<String>.from(projectRoot);
    // this is used by the 'new' command, which takes place from one folder below the 
    // project folder, which is where most commands are run.
    if(extraParentFolder != null) {
      temp.addAll(extraParentFolder);
    }

    temp.addAll(relativePath);
    final path = joinAll(temp);
    return path;
  }

  static bool ensureFolderExistsForFile(List<String> filePath) {
    final temp = List<String>.of(filePath);
    temp.removeLast();
    if(!projectFileExists(temp)) {
      createProjectFolder(temp);
      return true;
    }
    return false;
  }

  static void createProjectFolder(List<String> projectPath) {
    final path = fullPathFor(projectPath);
    Directory(path).createSync(recursive: true);
  }

  static String relativePathFor(List<String> projectPath, { bool allowExtra = true}) {
    final temp = <String>[];

    // this is used by the 'new' command, which takes place from one folder below the 
    // project folder, which is where most commands are run.
    if(allowExtra && extraParentFolder != null) {
      temp.addAll(extraParentFolder);
    }
    temp.addAll(projectPath);

    return joinAll(temp);
  }

  static bool get inRootOfAfibProject {
    if(!AFProjectPaths.projectFileExists(AFProjectPaths.pubspecPath)) {
      return false;
    }
    if(!AFProjectPaths.projectFileExists(AFProjectPaths.afibConfigPath)) {
      return false;
    }

    return true;
  }

}