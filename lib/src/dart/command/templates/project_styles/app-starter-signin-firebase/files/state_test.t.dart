

import 'package:afib/src/dart/command/af_project_paths.dart';
import 'package:afib/src/dart/command/af_source_template.dart';
import 'package:afib/src/dart/command/templates/project_styles/app-starter-signin/files/state_test.t.dart';

class StarterSigninFirebaseStateTestT {

  static StarterSigninStateTestT example() {
    return StarterSigninStateTestT(
      templateFileId: "state_test",
      templateFolder: AFProjectPaths.pathGenerateStarterSigninFirebaseFiles,
      checkSigninQuery: "CheckSigninListenerQuery",
      readUserQuery: "ReadOneUserListenerQuery",
      extraImports: '''
import 'package:${AFSourceTemplate.insertPackagePathInsertion}/query/listener/check_signin_listener_query.dart';
import 'package:${AFSourceTemplate.insertPackagePathInsertion}/query/listener/read_one_user_listener_query.dart';
''',

    );
  }

}