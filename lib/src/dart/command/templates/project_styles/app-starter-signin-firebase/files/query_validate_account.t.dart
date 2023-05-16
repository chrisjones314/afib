

import 'package:afib/src/dart/command/af_project_paths.dart';
import 'package:afib/src/dart/command/af_source_template.dart';
import 'package:afib/src/dart/command/templates/core/files/queries.t.dart';

class QueryValidateAccountT extends SimpleQueryT {
  QueryValidateAccountT({
    required Object insertExtraImports,
    required Object insertStartImpl,
    required Object insertFinishImpl,
    required Object insertAdditionalMethods,
  }): super(
    templateFileId: "query_validate_for_delete_account",
    templateFolder: AFProjectPaths.pathGenerateStarterSigninFirebaseFiles,
    insertExtraImports: insertExtraImports,
    insertStartImpl: insertStartImpl,
    insertFinishImpl: insertFinishImpl,
    insertAdditionalMethods: insertAdditionalMethods,
  );

  factory QueryValidateAccountT.example() {
    return QueryValidateAccountT(
      insertExtraImports: '''
import 'package:afib_signin/afsi_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart' as fba;
''',
      insertStartImpl: '''
fba.FirebaseAuth.instance.signInWithEmailAndPassword(
  email: email,
  password: password)
.then((result) {
  final user = result.user;
  if(user == null) {
    context.onError(AFQueryError.createMessage("Signin failed."));
    return;
  }
  context.onSuccess(user);
}).catchError((err) {
  context.onError(AFQueryError.createMessage(err.message));
});
''',
      insertFinishImpl: AFSourceTemplate.empty,
      insertAdditionalMethods: AFSourceTemplate.empty,
    );
  }



  
}