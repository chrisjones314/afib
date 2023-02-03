
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
  
  String get template => '''
final t = spi.t;
final rows = t.column();
rows.add(t.childMarginStandard(
  child: t.childText("Signed In", 
    textAlign: TextAlign.center, 
    style: t.styleOnCard.headline6)
));

final tableRows = t.columnTable();
final activeUser = spi.activeUser;
tableRows.add(_createDetailRow(spi, label: "userId", value: spi.userId));
tableRows.add(_createDetailRow(spi, label: "email", value: activeUser.email));
tableRows.add(_createDetailRow(spi, label: "first", value: activeUser.firstName));
tableRows.add(_createDetailRow(spi, label: "last", value: activeUser.lastName));
tableRows.add(_createDetailRow(spi, label: "zip", value: activeUser.zipCode));
final columnWidths = {
  0: const FixedColumnWidth(100),
  1: const FlexColumnWidth(),
};

rows.add(Table(
  columnWidths: columnWidths,
  children: tableRows,
));

rows.add(t.childMargin(
  margin: t.margin.h.standard,
  child: t.childButtonPrimaryText(
    text: "Sign Out", 
    onPressed: spi.onPressedSignout
  )
));

rows.add(t.childMargin(
  margin: t.margin.h.standard,
  child: t.childButtonPrimaryText(
    text: "Edit Account Settings", 
    onPressed: spi.onPressedEditAccountSettings
  )
));

rows.add(t.childMargin(
  margin: t.marginCustom(all: 3, top: 5),
  child: t.childButtonPrimaryText(
    text: "Delete Your Account", 
    onPressed: spi.onPressedDeleteAccount
  )
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
    final ei = AFSourceTemplateInsertions(insertions: {
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
  
  String get template => '''
TableRow _createDetailRow(HomePageScreenSPI spi, { required String label, required String value }) {
  final t = spi.t;
  final cols = t.row();
  cols.add(t.childMargin(
    margin: t.marginCustom(vertical: 3, right: 3),
    child: t.childText("\$label:", textAlign: TextAlign.right)
  ));
  cols.add(t.childMargin(
    margin: t.margin.v.standard,
    child: t.childText(value, style: t.styleOnCard.bodyText1)
  ));
  return TableRow(children: cols);
}
''';
}
