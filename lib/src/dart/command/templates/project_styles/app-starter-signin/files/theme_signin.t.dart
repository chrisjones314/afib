

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
''',
        AFSourceTemplate.insertAdditionalMethodsInsertion: '''
@override
Widget? childExtraInputs({
  required SigninScreenRouteParam parentParam,
}) {
  if(context.screenId != AFSIScreenID.register) {
    return null;
  }
  return RegistrationDetailsWidget(launchParam: RegistrationDetailsWidget.createLaunchParam(
    screenId: context.screenId,
  ));
}
''',
      })
    );
  } 

}