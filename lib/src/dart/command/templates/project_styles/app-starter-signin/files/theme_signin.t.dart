

import 'package:afib/src/dart/command/af_project_paths.dart';
import 'package:afib/src/dart/command/af_source_template.dart';
import 'package:afib/src/dart/command/templates/core/files/theme.t.dart';

class StarterSigninThemeSigninT {
  static ThemeT example() {
    return ThemeT(
      templateFileId: "theme_signin",
      templateFolder: AFProjectPaths.pathGenerateStarterSigninFiles,
      embeddedInsertions: AFSourceTemplateInsertions(insertions: {
        AFSourceTemplate.insertExtraImportsInsertion: '''
import 'package:afib_signin/afsi_flutter.dart';
import 'package:flutter/material.dart';
import 'package:${AFSourceTemplate.insertPackagePathInsertion}/ui/widgets/registration_details_widget.dart';
import 'package:${AFSourceTemplate.insertPackagePathInsertion}/${AFSourceTemplate.insertAppNamespaceInsertion}_id.dart';
import 'package:${AFSourceTemplate.insertPackagePathInsertion}/state/root/user_credential_root.dart';
import 'package:${AFSourceTemplate.insertPackagePathInsertion}/state/root/users_root.dart';
''',
        AFSourceTemplate.insertAdditionalMethodsInsertion: '''
@override
Widget? childExtraInputsRegister({
  required AFRouteParamWithFlutterState parentParam,
}) {
  if(context.screenId != AFSIScreenID.register) {
    return null;
  }
  return RegistrationDetailsWidget(
    textTheme: styleOnPrimary,
    colorForeground: Colors.white,
    includeSaveButton: false,
    launchParam: RegistrationDetailsWidget.createLaunchParam(
      screenId: context.screenId,
    )
  );
}

@override
Widget? childExtraSectionsAccountSettings({
  required AFScreenRouteParamWithFlutterState parentParam,
}) {
  final users = context.s.findType<UsersRoot>();
  final userCred = context.s.findType<UserCredentialRoot>();
  final activeUser = users.findById(userCred.userId);

  final rows = column();
  rows.add(childSectionTitle("Change User Settings"));
  rows.add(childMarginStandard(
    child: RegistrationDetailsWidget(
      textTheme: styleOnCard,
      colorForeground: colorOnSurface,
      includeSaveButton: true,
      launchParam: RegistrationDetailsWidgetRouteParam.create(
        screenId: context.screenId, 
        wid: STFBWidgetID.registrationDetails,
        routeLocation: AFRouteLocation.screenHierarchy,
        userToEdit: activeUser,
      )
    )
  ));

  return Card(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: rows
    )
  );
}
''',
      })
    );
  } 

}