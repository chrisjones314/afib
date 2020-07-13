

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
  static const initializationFolder = 'initialization';
  static const libPath = [libFolder];
  static const initializationPath = [libFolder, initializationFolder];
  static const afibConfigPath = [libFolder, initializationFolder, afibConfigFile];
  static const pubspecPath = [pubspecFile];
  static const idFile = "id.dart";
  static const idPath = [libFolder, idFile];

  static List<String> extraParentFolder;

  static bool projectFileExists(List<String> relativePath) {
    final path = fullPathFor(relativePath);
    return FileSystemEntity.typeSync(path) != FileSystemEntityType.notFound;
  }

  static String fullPathFor(List<String> relativePath) {
    Directory current = Directory.current;  
    List<String> projectRoot = split(current.path);
    List<String> temp = List<String>.from(projectRoot);
    // this is used by the 'new' command, which takes place from one folder below the 
    // project folder, which is where most commands are run.
    if(extraParentFolder != null) {
      temp.addAll(extraParentFolder);
    }

    temp.addAll(relativePath);
    String path = joinAll(temp);
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

  static void setExtraParentFolder(List<String> folder) {
    extraParentFolder = folder;
  }

  static void createProjectFolder(List<String> projectPath) {
    String path = fullPathFor(projectPath);
    Directory(path).createSync(recursive: true);
  }

  static String relativePathFor(List<String> projectPath, { bool allowExtra = true}) {
    List<String> temp = List<String>();

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