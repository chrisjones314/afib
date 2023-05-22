
import 'package:afib/src/dart/command/af_project_paths.dart';
import 'package:afib/src/dart/command/af_source_template.dart';
import 'package:afib/src/dart/command/templates/core/snippets/snippet_declare_spi.t.dart';
import 'package:afib/src/dart/command/templates/core/snippets/snippet_extra_imports.t.dart';
import 'package:afib/src/dart/command/templates/core/snippets/snippet_screen_member_variable_decls.t.dart';
import 'package:afib/src/dart/command/templates/core/snippets/snippet_widget_params_constructor.t.dart';


class SnippetRegistrationDetailsWidgetExtraImportsT {
  static SnippetExtraImportsT example() {
    return SnippetExtraImportsT(
      templateFileId: "registration_details_widget_extra_imports",    
      templateFolder: AFProjectPaths.pathGenerateStarterSigninSnippets,
      embeddedInsertions: AFSourceTemplateInsertions(insertions: {
        AFSourceTemplate.insertExtraImportsInsertion: '''
import 'package:afib_signin/afsi_flutter.dart';
import 'package:flutter/material.dart';
import 'package:${AFSourceTemplate.insertPackagePathInsertion}/${AFSourceTemplate.insertAppNamespaceInsertion}_id.dart';
import 'package:${AFSourceTemplate.insertPackagePathInsertion}/state/stateviews/${AFSourceTemplate.insertAppNamespaceInsertion}_default_state_view.dart';
import 'package:${AFSourceTemplate.insertPackagePathInsertion}/ui/${AFSourceTemplate.insertAppNamespaceInsertion}_connected_base.dart';
import 'package:${AFSourceTemplate.insertPackagePathInsertion}/query/simple/write_one_user_query.dart';
import 'package:${AFSourceTemplate.insertPackagePathInsertion}/state/models/user.dart';

''',
      })
    );
  }
}


class SnippetRegistrationDetailsMemberVariablesDeclT {

  static SnippetScreenMemberVariableDeclsT example() {
    return SnippetScreenMemberVariableDeclsT(
      templateFileId: "screen_member_variable_decls",
      templateFolder: AFProjectPaths.pathGenerateStarterSigninSnippets,
      embeddedInsertions: AFSourceTemplateInsertions(insertions: {
        SnippetScreenMemberVariableDeclsT.insertDecls: '''
final Color? colorForeground;
final TextTheme? textTheme;
final bool includeSaveButton;
'''
      })
    );
  }


}



class SnippetRegistrationDetailsWidgetParamsConstructorT {

  static SnippetWidgetParamsConstructorT example() {
    return SnippetWidgetParamsConstructorT(
      templateFileId: "widget_params_constructor",
      templateFolder: AFProjectPaths.pathGenerateStarterSigninSnippets,
      embeddedInsertions: AFSourceTemplateInsertions(insertions: {
        SnippetWidgetParamsConstructorT.insertExtraConstructorParams: '''
this.textTheme,
this.colorForeground,
this.includeSaveButton = true,
'''
      })
    );
  }


}

class SnippetRegistrationDetailsWidgetRouteParamT extends AFSnippetSourceTemplate {


  SnippetRegistrationDetailsWidgetRouteParamT(): 
    super(
      templateFileId: 'registration_details_widget_route_param',
      templateFolder: AFProjectPaths.pathGenerateStarterSigninSnippets,
    );

  String get template => '''
class RegistrationDetailsWidgetRouteParam extends AFWidgetRouteParamWithFlutterState {
  final User user;
  final AFSISigninStatus status;
  final String statusMessage;
  
  RegistrationDetailsWidgetRouteParam({
    required AFScreenID screenId,
    required AFWidgetID wid,
    required this.user,
    required this.status,
    required this.statusMessage,
    required AFRouteLocation routeLocation,
    required AFFlutterRouteParamState flutterState,
  }): super(screenId: screenId, wid: wid, routeLocation: routeLocation, flutterState: flutterState);

  factory RegistrationDetailsWidgetRouteParam.create({
    required AFScreenID screenId,
    required AFWidgetID wid,
    required AFRouteLocation routeLocation,
    User? userToEdit
  }) {
    userToEdit ??= User(
      id: AFDocumentIDGenerator.createNewId("user"),
      email: "",
      firstName: "",
      lastName: "",
      zipCode: "",
    );

    final textControllers = AFTextEditingControllers.createN({
      ${AFSourceTemplate.insertAppNamespaceInsertion.upper}WidgetID.textFirstName: userToEdit.firstName,
      ${AFSourceTemplate.insertAppNamespaceInsertion.upper}WidgetID.textLastName: userToEdit.lastName,
      ${AFSourceTemplate.insertAppNamespaceInsertion.upper}WidgetID.textZipCode: userToEdit.zipCode,
    });

    final flutterState = AFFlutterRouteParamState(
      textControllers: textControllers,
    );

    return RegistrationDetailsWidgetRouteParam(
      screenId: screenId,
      wid: wid, 
      user: userToEdit,
      status: AFSISigninStatus.ready,
      statusMessage: "",
      routeLocation: routeLocation,
      flutterState: flutterState,
    );
  }

  RegistrationDetailsWidgetRouteParam reviseStatus(AFSISigninStatus status, String message) {
    return copyWith(status: status, statusMessage: message);
  }

  RegistrationDetailsWidgetRouteParam reviseUser(User user) {
    return copyWith(user: user);
  }


  RegistrationDetailsWidgetRouteParam copyWith({
    AFScreenID? screenId,
    AFWidgetID? wid,
    AFRouteLocation? routeLocation,
    User? user,
    AFSISigninStatus? status,
    String? statusMessage,
  }) {
    return RegistrationDetailsWidgetRouteParam(
      screenId: screenId ?? this.screenId,
      wid: wid ?? this.wid,
      user: user ?? this.user,
      routeLocation: routeLocation ?? this.routeLocation,
      flutterState: flutterStateGuaranteed,
      status: status ?? this.status,
      statusMessage: statusMessage ?? this.statusMessage,
    );
  }
}
''';
}

class SnippetRegistrationDetailsWidgetAdditionalMethodsT extends AFSnippetSourceTemplate {
  SnippetRegistrationDetailsWidgetAdditionalMethodsT(): super(
    templateFileId: "registration_details_widget_additional_methods",
    templateFolder: AFProjectPaths.pathGenerateStarterSigninSnippets,
  );
  
  String get template => '''

// normally, the launch param would come from the parent screen's SPI, which is accessible from both
// the UI code that creates the widget, and the state test code that executes it.  But, the parent screen
// here is from a third-party library, AFSI, which knows nothing about this widget, so we create it in a
// static method called from both places.
static RegistrationDetailsWidgetRouteParam createLaunchParam({
  required AFScreenID screenId,
}) {
  return RegistrationDetailsWidgetRouteParam.create(
    screenId: screenId, 
    wid: ${insertAppNamespaceUpper}WidgetID.widgetRegistrationDetails, 
    routeLocation: AFRouteLocation.screenHierarchy
  );
}

''';
}

class SnippetRegistrationDetailsWidgetBuildBodyT extends AFSnippetSourceTemplate {
  SnippetRegistrationDetailsWidgetBuildBodyT(): super(
    templateFileId: "registration_details_widget_build_body",
    templateFolder: AFProjectPaths.pathGenerateStarterSigninSnippets,
  );
  
  String get template => '''
final context = spi.context;
final t = spi.themeSignin;
final styleText = textTheme ?? t.styleOnPrimary;
final rows = t.column();
final colorFore = colorForeground ?? t.colorOnSurface;
rows.add(t.childMargin(
  margin: t.margin.v.standard,
  child: t.childTextField(
    screenId: context.screenId,
    wid: ${AFSourceTemplate.insertAppNamespaceInsertion.upper}WidgetID.textFirstName,
    parentParam: context.p,
    expectedText: context.p.user.firstName,
    style: styleText.bodyMedium,
    decoration: t.decorationTextInput(
      text: ${AFSourceTemplate.insertAppNamespaceInsertion.upper}WidgetID.textFirstName,
      colorForeground: colorFore,
    ),
    onChanged: spi.onChangedFirstName
  )
));

rows.add(t.childMargin(
  margin: t.margin.v.standard,
  child: t.childTextField(
    screenId: context.screenId,
    wid: ${AFSourceTemplate.insertAppNamespaceInsertion.upper}WidgetID.textLastName,
    parentParam: context.p,
    expectedText: context.p.user.lastName,
    style: styleText.bodyMedium,
    decoration: t.decorationTextInput(
      text: ${AFSourceTemplate.insertAppNamespaceInsertion.upper}WidgetID.textLastName,
      colorForeground: colorFore,
    ),
    onChanged: spi.onChangedLastName
  )
));

rows.add(t.childMargin(
  margin: t.margin.v.standard,
  child: t.childTextField(
  screenId: context.screenId,
    wid: ${AFSourceTemplate.insertAppNamespaceInsertion.upper}WidgetID.textZipCode,
    parentParam: context.p,
    expectedText: context.p.user.zipCode,
    style: styleText.bodyMedium,
    decoration: t.decorationTextInput(
      text: ${AFSourceTemplate.insertAppNamespaceInsertion.upper}WidgetID.textZipCode,
      colorForeground: colorFore,
    ),
    onChanged: spi.onChangedZipCode
  )
));

if(includeSaveButton) {
  final tSignin = spi.themeSignin;
  rows.add(tSignin.childStatusMessage(spi.status, spi.statusMessage,
    textTheme: t.styleOnCard));

  rows.add(t.childMargin(
    margin: t.margin.t.standard,
    child: t.childButtonPrimaryText(
      wid: ${AFSourceTemplate.insertAppNamespaceInsertion.upper}WidgetID.buttonSaveUserDetails,
      text: "Save User Settings", 
      onPressed: spi.onPressedSaveUserDetails,
    )
  ));
}

return Column(
  crossAxisAlignment: CrossAxisAlignment.stretch,
  children: rows
);
''';
}

class SnippetRegistrationDetailsWidgetSPIT {

  static SnippetDeclareSPIT example() {
    final ei = AFSourceTemplateInsertions(insertions: {
      AFSourceTemplate.insertAdditionalMethodsInsertion: '''
AFSIDefaultTheme get themeSignin => t.accessTheme(AFSIThemeID.defaultTheme);    
AFSISigninStatus get status => context.p.status;
String get statusMessage => context.p.statusMessage;

User? get activeUser {
  final userCred = context.s.userCredential;
  final users = context.s.users;
  final user = users.findById(userCred.userId);
  return user;
}

void onChangedFirstName(String firstName) {
  context.updateTextField(${AFSourceTemplate.insertAppNamespaceInsertion.upper}WidgetID.textFirstName, firstName);
  final revised = context.p.user.copyWith(firstName: firstName);
  _reviseUser(revised);
}

void _reviseUser(User revisedUser) {
  final revised = context.p.reviseUser(revisedUser);
  context.updateRouteParam(revised);
}

void onChangedLastName(String lastName) {
  context.updateTextField(${AFSourceTemplate.insertAppNamespaceInsertion.upper}WidgetID.textLastName, lastName);
  final revised = context.p.user.copyWith(lastName: lastName);
  _reviseUser(revised);
}

void onChangedZipCode(String zipCode) {
  context.updateTextField(${AFSourceTemplate.insertAppNamespaceInsertion.upper}WidgetID.textZipCode, zipCode);
  final revised = context.p.user.copyWith(zipCode: zipCode);
  _reviseUser(revised);
}

void onPressedSaveUserDetails() {
  final revisedStarted = context.p.reviseStatus(AFSISigninStatus.loading, "Saving user settings...");
  context.updateRouteParam(revisedStarted);
  context.executeQuery(WriteOneUserQuery(user: context.p.user, onSuccess: (successCtx) {
    final revisedFinished = revisedStarted.reviseStatus(AFSISigninStatus.ready, "Saved user settings.");
    context.updateRouteParam(revisedFinished);
  }));
}
'''
    });
    return SnippetDeclareSPIT(
      templateFileId: "registration_details_widget_spi",    
      templateFolder: AFProjectPaths.pathGenerateStarterSigninSnippets,
      embeddedInsertions: ei,
    );
  }
}


