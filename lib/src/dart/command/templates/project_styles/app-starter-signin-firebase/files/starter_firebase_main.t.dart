
import 'package:afib/src/dart/command/af_project_paths.dart';
import 'package:afib/src/dart/command/af_source_template.dart';
import 'package:afib/src/dart/command/templates/core/files/main.t.dart';

class StarterSigninFirebaseMainT {

  static MainT example() {
    return MainT(
      templateFileId: "main",
      templateFolder: AFProjectPaths.pathGenerateStarterSigninFirebaseFiles,
      mainImpl: null,
      insertExtraImports: '''
import 'package:firebase_core/firebase_core.dart';
import 'package:${AFSourceTemplate.insertPackagePathInsertion}/firebase_options.dart';
''',
      beforeMain: 'Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform).then( (app) {',
      afterMain: '});'
    );
  }


}