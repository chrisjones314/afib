

import 'package:afib/src/dart/command/af_project_paths.dart';
import 'package:afib/src/dart/command/af_source_template.dart';
import 'package:afib/src/dart/command/templates/core/files/queries.t.dart';
import 'package:afib/src/dart/command/templates/project_styles/app-starter-signin/files/query_check_signin.t.dart';

class QueryCheckSigninSigninFirebaseStarterT extends SimpleQueryT {
  QueryCheckSigninSigninFirebaseStarterT({
    required Object super.insertExtraImports,
    required Object super.insertStartImpl,
    required Object super.insertFinishImpl,
    required Object super.insertAdditionalMethods,
    required super.insertMemberVariables,
    required super.insertConstructorParams,
  }): super.withMemberVariables(
    templateFileId: "query_check_signin",
    templateFolder: AFProjectPaths.pathGenerateStarterSigninFirebaseFiles,
  );

  factory QueryCheckSigninSigninFirebaseStarterT.example() {
    return QueryCheckSigninSigninFirebaseStarterT(
      insertExtraImports: '''
import 'dart:async';
import 'package:afib/afib_flutter.dart';
import 'package:${AFSourceTemplate.insertPackagePathInsertion}/state/${AFSourceTemplate.insertAppNamespaceInsertion}_state.dart';
import 'package:${AFSourceTemplate.insertPackagePathInsertion}/state/root/user_credential_root.dart';
import 'package:${AFSourceTemplate.insertPackagePathInsertion}/ui/screens/home_page_screen.dart';
import 'package:${AFSourceTemplate.insertPackagePathInsertion}/query/simple/signin_query.dart';
import 'package:afib_signin/afsi_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart' as fba;
''',
      insertStartImpl: '''
subscription = fba.FirebaseAuth.instance.authStateChanges().listen((user) { 
  final result = SigninQuery.convertCredential(user);
  context.onSuccess(result);
});
''',
      insertMemberVariables: '''
StreamSubscription? subscription;
''',
      insertConstructorParams: '''
this.subscription,
''',
      insertFinishImpl: QueryCheckSigninSigninStarterT.insertFinishImplSignin,
      insertAdditionalMethods: '''
@override
void shutdown() {
  subscription?.cancel();
  subscription = null;
}
'''
    );
  }



  
}