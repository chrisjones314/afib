

import 'dart:io';
import 'package:path/path.dart';

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

  static bool projectFileExists(List<String> relativePath) {
    final path = projectPathFor(relativePath);
    return FileSystemEntity.typeSync(path) != FileSystemEntityType.notFound;
  }

  static String projectPathFor(List<String> relativePath) {
    Directory current = Directory.current;  
    List<String> projectRoot = split(current.path);
    List<String> temp = List<String>.from(projectRoot);
    temp.addAll(relativePath);
    String path = joinAll(temp);
    return path;
  }

  static String pathFor(List<String> comps) {
    return joinAll(comps);
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