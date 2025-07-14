
import 'package:afib/src/dart/command/af_project_paths.dart';
import 'package:afib/src/dart/command/af_source_template.dart';
import 'package:afib/src/dart/command/templates/core/snippets/snippet_declare_spi.t.dart';
import 'package:afib/src/dart/command/templates/core/snippets/snippet_extra_imports.t.dart';


class SnippetSigninStarterHomePageScreenExtraImportsT {
  static SnippetExtraImportsT example() {
    return SnippetExtraImportsT(
      templateFileId: "home_page_screen_extra_imports",    
      templateFolder: AFProjectPaths.pathGenerateStarterSigninSnippets,
      embeddedInsertions: AFSourceTemplateInsertions(insertions: {
        AFSourceTemplate.insertExtraImportsInsertion: '''
import 'package:${AFSourceTemplate.insertPackagePathInsertion}/query/simple/signout_query.dart';
import 'package:${AFSourceTemplate.insertPackagePathInsertion}/state/models/user.dart';
import 'package:${AFSourceTemplate.insertPackagePathInsertion}/ui/drawers/signed_in_menu_drawer.dart';
import 'package:${AFSourceTemplate.insertPackagePathInsertion}/ui/widgets/signed_in_bottom_nav_bar_widget.dart';
import 'package:afib_signin/afsi_flutter.dart';
''',
      })
    );
  }
}

class SnippetSigninStarterHomePageScreenBuildBodyT extends AFSnippetSourceTemplate {
  SnippetSigninStarterHomePageScreenBuildBodyT(): super(
    templateFileId: "home_page_screen_build_body",
    templateFolder: AFProjectPaths.pathGenerateStarterSigninSnippets,
  );
  
  @override
  String get template => '''
final t = spi.t;
final rows = t.column();
rows.add(AFUIAlphaWarningWidget());

rows.add(t.childMarginStandard(
  child: t.childText(text: "Signed In", 
    textAlign: TextAlign.center, 
    style: t.styleOnCard.titleLarge)
));

final tableRows = t.columnTable();
final activeUser = spi.activeUser;
tableRows.add(_createDetailRow(spi, wid: ${AFSourceTemplate.insertAppNamespaceInsertion.upper}WidgetID.textUserId, label: "userId", value: spi.userId));
tableRows.add(_createDetailRow(spi, wid: ${AFSourceTemplate.insertAppNamespaceInsertion.upper}WidgetID.textEmail, label: "email", value: activeUser.email));
tableRows.add(_createDetailRow(spi, wid: ${AFSourceTemplate.insertAppNamespaceInsertion.upper}WidgetID.textFirstName, label: "first", value: activeUser.firstName));
tableRows.add(_createDetailRow(spi, wid: ${AFSourceTemplate.insertAppNamespaceInsertion.upper}WidgetID.textLastName, label: "last", value: activeUser.lastName));
tableRows.add(_createDetailRow(spi, wid: ${AFSourceTemplate.insertAppNamespaceInsertion.upper}WidgetID.textZipCode, label: "zip", value: activeUser.zipCode));
final columnWidths = {
  0: const FixedColumnWidth(100),
  1: const FlexColumnWidth(),
};

rows.add(Table(
  columnWidths: columnWidths,
  children: tableRows,
));

rows.add(Container(
  margin: t.margin.standard,
  padding: t.padding.standard,
  decoration: BoxDecoration(
    color: Colors.grey[300],
    borderRadius: t.borderRadius.standard,
  ),
  child: t.childText(text: "Use the menu icon at the lower left to access the drawer, with additional functionality including signout, account settings, and delete your account.")
));

return ListView(
  children: [
    t.childCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: rows
      )
    )
  ]
);
''';
}

class SnippetSigninStarterHomePageScreenSPIT {

  static SnippetDeclareSPIT example() {
    const ei = AFSourceTemplateInsertions(insertions: {
      AFSourceTemplate.insertAdditionalMethodsInsertion: '''
String get userId {
  return context.s.userCredential.userId;
}

String get storedEmail {
  return context.s.userCredential.storedEmail;
}

User get activeUser {
  final result = context.s.users.findById(userId);
  if(result == null) {
    throw AFException("No active user?");
  }
  return result;
}

void onPressedSignout() {
  context.executeQuery(SignoutQuery(storedEmail: storedEmail));
}

void onPressedEditAccountSettings() {
  context.navigatePush(AccountSettingsScreen.navigatePush());
}

void onPressedDeleteAccount() {
  // navigate to the default delete page, which is where the user actually does the deletion.
  context.navigatePush(StartDeleteAccountScreen.navigatePush(confirmText: ""));
}

'''
    });
    return SnippetDeclareSPIT(
      templateFileId: "home_page_screen_spi",    
      templateFolder: AFProjectPaths.pathGenerateStarterSigninSnippets,
      embeddedInsertions: ei,
    );
  }
}


class SnippetHomeScreenAdditionalMethodsT extends AFSnippetSourceTemplate {
  SnippetHomeScreenAdditionalMethodsT(): super(
    templateFileId: "home_page_screen_additional_methods",
    templateFolder: AFProjectPaths.pathGenerateStarterSigninSnippets,
  );
  
  @override
  String get template => '''
TableRow _createDetailRow(HomePageScreenSPI spi, { required AFWidgetID wid, required String label, required String value }) {
  final t = spi.t;
  final cols = t.row();
  cols.add(t.childMargin(
    margin: t.marginCustom(vertical: 3, right: 3),
    child: t.childText(text: "\$label:", textAlign: TextAlign.right)
  ));
  cols.add(t.childMargin(
    margin: t.margin.v.standard,
    child: t.childText(
      text: value, 
      style: t.styleOnCard.bodyLarge,
      wid: wid
    )
  ));
  return TableRow(children: cols);
}
''';
}

class SnippetHomeScreenBuildWithSPIImplT extends AFSnippetSourceTemplate {
  SnippetHomeScreenBuildWithSPIImplT({
    required super.templateFolder,
    required super.embeddedInsertions,
  }): super(
    templateFileId: "screen_build_with_spi_impl"
  );

  factory SnippetHomeScreenBuildWithSPIImplT.example() {
    return SnippetHomeScreenBuildWithSPIImplT(
      templateFolder: AFProjectPaths.pathGenerateStarterSigninSnippets,
      embeddedInsertions: null,
    );
  }

  @override
  String get template => '''
final t = spi.t;
final body = _buildBody(spi);
return t.childScaffold(
  spi: spi,
  body: body,
  drawer: SignedInMenuDrawer(),
  appBar: AppBar(
    title: t.childText(text: "Home Page Screen"),
    
    // IMPORTANT: Don't let Flutter automatically add its own back button, as that 
    // will get out of sync with AFib's route state.   Instead you must use
    // leading: t.leadingButtonStandardBack..., which is done by default for you 
    // in most cases.
    automaticallyImplyLeading: false,
  ),
  bottomNavigationBar: SignedInBottomNavBarWidget(
    launchParam: SignedInBottomNavBarWidgetRouteParam.create(
      screenId: screenId, 
      wid: ${AFSourceTemplate.insertAppNamespaceInsertion.upper}WidgetID.navBarBottom, 
      routeLocation: AFRouteLocation.screenHierarchy
    ),
  )
);
''';
}

class SnippetHomePageScreenSmokeTest extends AFSnippetSourceTemplate {

  SnippetHomePageScreenSmokeTest(): super(
    templateFileId: "home_screen_smoke_test",
    templateFolder: AFProjectPaths.pathGenerateStarterSigninSnippets,
  );

  @override
  List<String> get extraImports => [
  "import 'package:flutter/material.dart';",
  "import 'package:${AFSourceTemplate.insertPackagePathInsertion}/state/models/user.dart';"
];

  @override
  String get template => '''
// stfbStateFullLogin is signed in as the west coast user by default.
final userWest = context.find<User>(${insertAppNamespaceUpper}TestDataID.userWestCoast);

// this is a shortcut, not the use of the existing flutter comparators under ft.
// e.matchTextEquals would have been more concise in this case.   The intent over time
// is for e.match... to provide a very fat interface of matching functions for all Flutter's
// native widgets.
await e.matchText(${insertAppNamespaceUpper}WidgetID.textFirstName, ft.equals(userWest.firstName));
await e.matchText(${insertAppNamespaceUpper}WidgetID.textLastName, ft.equals(userWest.lastName));

// this is unnecessary, but shows how you could validate a custom widget more directly.
// Note that custom widgets can handled in a more general way by registering widget applicators
// and extractors (and that AFib UI libraries can do this for you).  See AFTestExtensionContext.registerApplicator
// and AFTestExtensionContext.registerExtractor for details.
final widgetZip = await e.matchWidget<Text>(${insertAppNamespaceUpper}WidgetID.textZipCode);

// note that e.expect is the ONLY CALL THAT DOES NOT REQUIRE AWAIT.  Otherwise, you must always
// start every e.something statement with await.  If you don't, your test code is going to execute out of order
// in unpredictable ways and its going to be very confusing.
e.expect(widgetZip?.data, ft.equals(userWest.zipCode));

// Note that this particular test does not include any 
// e.apply...
// calls, but that those can be used to manipulate widgets.   
''';

}
