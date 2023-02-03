

import 'package:afib/src/dart/command/af_project_paths.dart';
import 'package:afib/src/dart/command/af_source_template.dart';
import 'package:afib/src/dart/command/templates/core/files/lpi.t.dart';
import 'package:afib/src/dart/command/templates/project_styles/app-starter-signin/files/signin_actions_lpi.t.dart';

class SigninStarterSigninFirebaseActionsLPIT {

   static LPIT example() {
    return SigninStarterSigninActionsLPIT.custom(
      templateFileId: "starter_signin_actions_lpi",
      templateFolder: AFProjectPaths.pathGenerateStarterSigninFirebaseFiles,
      extraImports: '''
import 'package:${AFSourceTemplate.insertPackagePathInsertion}/query/simple/change_email_query.dart';
import 'package:${AFSourceTemplate.insertPackagePathInsertion}/query/simple/change_password_query.dart';
import 'package:${AFSourceTemplate.insertPackagePathInsertion}/query/simple/reset_password_query.dart';
import 'package:${AFSourceTemplate.insertPackagePathInsertion}/query/simple/validate_account_query.dart';
import 'package:${AFSourceTemplate.insertPackagePathInsertion}/state/${AFSourceTemplate.insertAppNamespaceInsertion}_state.dart';
import 'package:${AFSourceTemplate.insertPackagePathInsertion}/query/simple/delete_account_query.dart';
''',
      additionalMethods: '''
@override
void onResetPassword(String email) {
  context.executeQuery(ResetPasswordQuery(email: email, onSuccess: (successCtx) {
    successCtx.showDialogInfoText(
      themeOrId: ${AFSourceTemplate.insertAppNamespaceInsertion.upper}ThemeID.defaultTheme, 
      title: "Sent Password Reset",
      body: "Please check your email for password reset instructions."
    );
  })); 
}

@override 
void onChangePassword(String currentPassword, String newPassword) {
  final ${AFSourceTemplate.insertAppNamespaceInsertion}State = context.accessComponentState<${AFSourceTemplate.insertAppNamespaceInsertion.upper}State>();
  final activeUser = ${AFSourceTemplate.insertAppNamespaceInsertion}State.userCredential;

  // first, we need to validate that the password was correct.
  context.executeQuery(ValidateAccountQuery(
    email: activeUser.storedEmail,
    password: currentPassword,
    onSuccess: (validateCtx) {
      final user = validateCtx.r;
      validateCtx.executeQuery(ChangePasswordQuery(
        user: user,
        newPassword: newPassword,
        onSuccess: (changedCtx) {
          final lpi = changedCtx.accessLPI<AFSIManipulateStateLPI>(AFSILibraryProgrammingInterfaceID.manipulateState);
          lpi.updateAccountSettingsChangePasswordStatus(status: AFSISigninStatus.ready, message: "Successfully changed password.");
        }
      ));

    },
    onError: (errContext) {
      final lpi = errContext.accessLPI<AFSIManipulateStateLPI>(AFSILibraryProgrammingInterfaceID.manipulateState);
      lpi.updateAccountSettingsChangePasswordStatus(status: AFSISigninStatus.ready, message: errContext.e.message);
    }
  ));
  
}

@override 
void onChangeEmail(String currentPassword, String newEmail) {
  final ${AFSourceTemplate.insertAppNamespaceInsertion}State = context.accessComponentState<${AFSourceTemplate.insertAppNamespaceInsertion.upper}State>();
  final activeUser = ${AFSourceTemplate.insertAppNamespaceInsertion}State.userCredential;

  // first, we need to validate that the password was correct.
  context.executeQuery(ValidateAccountQuery(
    email: activeUser.storedEmail,
    password: currentPassword,
    onSuccess: (validateCtx) {
      final user = validateCtx.r;
      validateCtx.executeQuery(ChangeEmailQuery(
        user: user,
        newEmail: newEmail,
        onSuccess: (changedCtx) {
          final lpi = changedCtx.accessLPI<AFSIManipulateStateLPI>(AFSILibraryProgrammingInterfaceID.manipulateState);
          lpi.updateAccountSettingsChangeEmailStatus(status: AFSISigninStatus.ready, message: "Successfully changed email.");
        }
      ));

    },
    onError: (errContext) {
      final lpi = errContext.accessLPI<AFSIManipulateStateLPI>(AFSILibraryProgrammingInterfaceID.manipulateState);
      lpi.updateAccountSettingsChangeEmailStatus(status: AFSISigninStatus.ready, message: errContext.e.message);
    }
  ));
}

@override
void onDeleteAccount(String confirmText) {
  final ${AFSourceTemplate.insertAppNamespaceInsertion}State = context.accessComponentState<${AFSourceTemplate.insertAppNamespaceInsertion.upper}State>();
  final activeUser = ${AFSourceTemplate.insertAppNamespaceInsertion}State.userCredential;
  context.log?.d("Starting validate");

  // Note: there is a lot of complexity here.  I do not find this to be typical of AFib, it is 
  // driven by the fact that we need to be very careful about the order in which we perform the 
  // various steps of deleting the account.

  // first, we need to validate that the password was correct.
  context.executeQuery(ValidateAccountQuery(
    email: activeUser.storedEmail,
    password: confirmText,
    onSuccess: (validateCtx) {
      context.log?.d("Validate succeeded");
      // then, go ahead and shutdown all listener queries, as we don't want updates during the course of the 
      // deletion process.
      context.executeShutdownAllActiveQueries();
      context.log?.d("Shutdown All active queries.");

      // then, we need to navigate to the processing delete page.
      context.navigateReplaceAll(ProcessAccountDeletionScreen.navigateReplaceAll());
      context.log?.d("navigated to Process page.");

      // then, we need to pause significantly to make sure the navigation completes.  
      context.executeDeferredCallback(${AFSourceTemplate.insertAppNamespaceInsertion.upper}QueryID.deferredAccountDelete, const Duration(seconds: 1), (context) { 
        context.log?.d("finished delay, processing delete");
        // then, issue a query which does the account deletion.
        context.executeQuery(DeleteAccountQuery(
          user: validateCtx.r, 
          onSuccess: (deleteCtx) {
            deleteCtx.log?.d("Finished delete successfully");
            // when the query finishes, reset our state to the initial state
            deleteCtx.executeResetToInitialState();

            context.log?.d("Change Status to complete");
            // and then navigate to the signin page in its ready state.

            // show the completed button.
            final lpi = deleteCtx.accessLPI<AFSIManipulateStateLPI>(AFSILibraryProgrammingInterfaceID.manipulateState);
            lpi.updateProcessDeleteAcountScreenStatus(status: AFSISigninStatus.ready, message: "Your account was deleted.");            
          }
        ));
      });
    }, onError: (errContext) {
      final lpi = errContext.accessLPI<AFSIManipulateStateLPI>(AFSILibraryProgrammingInterfaceID.manipulateState);
      lpi.updateStartDeleteAcountScreenStatus(status: AFSISigninStatus.error, message: errContext.e.message);
    }
  ));
}
''',
   );
  }
 
}