

import 'package:afib/src/dart/command/af_project_paths.dart';
import 'package:afib/src/dart/command/af_source_template.dart';
import 'package:afib/src/dart/command/templates/core/files/queries.t.dart';

class QueryForgotPasswordFirebaseStarterT extends SimpleQueryT {
  QueryForgotPasswordFirebaseStarterT({
    required Object insertExtraImports,
    required Object insertStartImpl,
    required Object insertFinishImpl,
    required Object insertAdditionalMethods,
  }): super(
    templateFileId: "query_forgot_password",
    templateFolder: AFProjectPaths.pathGenerateStarterSigninFirebaseFiles,
    insertExtraImports: insertExtraImports,
    insertStartImpl: insertStartImpl,
    insertFinishImpl: insertFinishImpl,
    insertAdditionalMethods: insertAdditionalMethods,
  );

  factory QueryForgotPasswordFirebaseStarterT.example() {
    return QueryForgotPasswordFirebaseStarterT(
      insertExtraImports: '''
import 'package:afib/afib_flutter.dart';
import 'package:${AFSourceTemplate.insertPackagePathInsertion}/state/${AFSourceTemplate.insertAppNamespaceInsertion}_state.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:afib_signin/afsi_flutter.dart';
import 'package:${AFSourceTemplate.insertPackagePathInsertion}/${AFSourceTemplate.insertAppNamespaceInsertion}_id.dart';
''',
      insertStartImpl: '''
FirebaseAuth.instance.sendPasswordResetEmail(
  email: email)
.then((result) {
  context.onSuccess(AFUnused.unused);
}).catchError((err) {
  context.onError(AFQueryError.createMessage(err.message));
});
''',
      insertFinishImpl: '''
context.showDialogInfoText(
  themeOrId: ${AFSourceTemplate.insertAppNamespaceInsertion.upper}ThemeID.defaultTheme, 
  title: "Password Reset Sent",
  body: "Please check your email for password reset instructions."
);

final lpi = context.accessLPI<AFSIManipulateStateLPI>(AFSILibraryProgrammingInterfaceID.manipulateState);
lpi.updateResetPasswordScreenStatus(status: AFSISigninStatus.ready, message: "Password reset requested.");
''',
      insertAdditionalMethods: '''
@override
void finishAsyncWithError(AFFinishQueryErrorContext context) {    
  final lpi = context.accessLPI<AFSIManipulateStateLPI>(AFSILibraryProgrammingInterfaceID.manipulateState);
  lpi.updateRegisterScreenStatus(status: AFSISigninStatus.error, message: context.e.message);
}
''',
    );
  }



  
}