

import 'package:afib/src/dart/command/af_project_paths.dart';
import 'package:afib/src/dart/command/af_source_template.dart';
import 'package:afib/src/dart/command/templates/core/files/queries.t.dart';
import 'package:afib/src/dart/command/templates/project_styles/app-starter-signin/files/query_signout.t.dart';

class QuerySigninSignoutStarterFirebaseT extends SimpleQueryT {
  QuerySigninSignoutStarterFirebaseT({
    required Object insertExtraImports,
    required Object insertStartImpl,
    required Object insertFinishImpl,
    required Object insertAdditionalMethods,
  }): super(
    templateFileId: "query_signout",
    templateFolder: AFProjectPaths.pathGenerateStarterSigninFirebaseFiles,
    insertExtraImports: insertExtraImports,
    insertStartImpl: insertStartImpl,
    insertFinishImpl: insertFinishImpl,
    insertAdditionalMethods: insertAdditionalMethods,
  );

  factory QuerySigninSignoutStarterFirebaseT.example() {
    return QuerySigninSignoutStarterFirebaseT(
      insertExtraImports: '''
import 'package:afib/afib_flutter.dart';
import 'package:${AFSourceTemplate.insertPackagePathInsertion}/${AFSourceTemplate.insertAppNamespaceInsertion}_id.dart';
import 'package:${AFSourceTemplate.insertPackagePathInsertion}/state/${AFSourceTemplate.insertAppNamespaceInsertion}_state.dart';
import 'package:${AFSourceTemplate.insertPackagePathInsertion}/state/root/user_credential_root.dart';
import 'package:afib_signin/afsi_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';
''',
      insertStartImpl: QuerySigninSignoutStarterT.insertStartImplSignout,
      insertFinishImpl: QuerySigninSignoutStarterT.createFinishImpl("FirebaseAuth.instance.signOut();"),
      insertAdditionalMethods: AFSourceTemplate.empty
    );
  }



  
}