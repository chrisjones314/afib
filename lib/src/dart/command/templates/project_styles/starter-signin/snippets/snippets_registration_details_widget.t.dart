
import 'package:afib/src/dart/command/af_project_paths.dart';
import 'package:afib/src/dart/command/af_source_template.dart';
import 'package:afib/src/dart/command/templates/core/snippets/snippet_declare_spi.t.dart';
import 'package:afib/src/dart/command/templates/core/snippets/snippet_extra_imports.t.dart';
import 'package:afib/src/dart/command/templates/core/snippets/snippet_navigate_push.t.dart';
import 'package:afib/src/dart/command/templates/core/snippets/snippet_standard_route_param.t.dart';


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
''',
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
  final String firstName;
  final String lastName;
  final String zipCode;
  
  RegistrationDetailsWidgetRouteParam({
    required AFScreenID screenId,
    required AFWidgetID wid,
    required this.firstName,
    required this.lastName,
    required this.zipCode,
    required AFRouteLocation routeLocation,
    required AFFlutterRouteParamState flutterState,
  }): super(screenId: screenId, wid: wid, routeLocation: routeLocation, flutterState: flutterState);

  factory RegistrationDetailsWidgetRouteParam.create({
    required AFScreenID screenId,
    required AFWidgetID wid,
    required AFRouteLocation routeLocation,
  }) {
    const firstName = "";
    const lastName = "";
    const zipCode = "";

    final textControllers = AFTextEditingControllers.createN({
      ${insertAppNamespaceUpper}WidgetID.textFirstName: firstName,
      ${insertAppNamespaceUpper}WidgetID.textLastName: lastName,
      ${insertAppNamespaceUpper}WidgetID.textZipCode: zipCode,
    });

    final flutterState = AFFlutterRouteParamState(
      textControllers: textControllers,
    );

    return RegistrationDetailsWidgetRouteParam(
      screenId: screenId,
      wid: wid, 
      firstName: firstName,
      lastName: lastName,
      zipCode: zipCode,
      routeLocation: routeLocation,
      flutterState: flutterState,
    );
  }

  RegistrationDetailsWidgetRouteParam copyWith({
    AFScreenID? screenId,
    AFWidgetID? wid,
    AFRouteLocation? routeLocation,
    String? firstName,
    String? lastName,
    String? zipCode,
  }) {
    return RegistrationDetailsWidgetRouteParam(
      screenId: screenId ?? this.screenId,
      wid: wid ?? this.wid,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      zipCode: zipCode ?? this.zipCode,
      routeLocation: routeLocation ?? this.routeLocation,
      flutterState: flutterStateGuaranteed,
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
final styleOnPrimary = t.styleOnPrimary;
final rows = t.column();
rows.add(t.childMargin(
  margin: t.margin.v.standard,
  child: t.childTextField(
    screenId: context.screenId,
    wid: ${AFSourceTemplate.insertAppNamespaceInsertion.upper}WidgetID.textFirstName,
    parentParam: context.p,
    expectedText: context.p.firstName,
    style: styleOnPrimary.bodyText2,
    decoration: t.decorationTextInput(
      text: ${AFSourceTemplate.insertAppNamespaceInsertion.upper}WidgetID.textFirstName,
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
    expectedText: context.p.lastName,
    style: styleOnPrimary.bodyText2,
    decoration: t.decorationTextInput(
      text: ${AFSourceTemplate.insertAppNamespaceInsertion.upper}WidgetID.textLastName,
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
    expectedText: context.p.zipCode,
    style: styleOnPrimary.bodyText2,
    decoration: t.decorationTextInput(
      text: ${AFSourceTemplate.insertAppNamespaceInsertion.upper}WidgetID.textZipCode,
    ),
    onChanged: spi.onChangedZipCode
  )
));

return Column(
  children: rows
);
''';
}

class SnippetRegistrationDetailsWidgetSPIT {

  static SnippetDeclareSPIT example() {
    final ei = AFSourceTemplateInsertions(insertions: {
      AFSourceTemplate.insertAdditionalMethodsInsertion: '''
AFSIDefaultTheme get themeSignin {
  return t.accessTheme(AFSIThemeID.defaultTheme);    
}

void onChangedFirstName(String firstName) {
  context.updateTextField(${AFSourceTemplate.insertAppNamespaceInsertion.upper}WidgetID.textFirstName, firstName);
  final revised = context.p.copyWith(firstName: firstName);
  context.updateRouteParam(revised);
}

void onChangedLastName(String lastName) {
  context.updateTextField(${AFSourceTemplate.insertAppNamespaceInsertion.upper}WidgetID.textLastName, lastName);
  final revised = context.p.copyWith(lastName: lastName);
  context.updateRouteParam(revised);
}

void onChangedZipCode(String zipCode) {
  context.updateTextField(${AFSourceTemplate.insertAppNamespaceInsertion.upper}WidgetID.textZipCode, zipCode);
  final revised = context.p.copyWith(zipCode: zipCode);
  context.updateRouteParam(revised);
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


