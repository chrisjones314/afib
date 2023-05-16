
import 'package:afib/src/dart/command/af_project_paths.dart';
import 'package:afib/src/dart/command/af_source_template.dart';
import 'package:afib/src/dart/command/templates/core/snippets/snippet_declare_spi.t.dart';
import 'package:afib/src/dart/command/templates/core/snippets/snippet_extra_imports.t.dart';


class SnippetSigninStarterSignedInMenuDrawerExtraImportsT {
  static SnippetExtraImportsT example() {
    return SnippetExtraImportsT(
      templateFileId: "signed_in_menu_drawer_extra_imports",    
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

class SnippetSigninStarterSignedInMenuDrawerBuildBodyT extends AFSnippetSourceTemplate {
  SnippetSigninStarterSignedInMenuDrawerBuildBodyT(): super(
    templateFileId: "signed_in_menu_drawer_build_body",
    templateFolder: AFProjectPaths.pathGenerateStarterSigninSnippets,
  );
  
  String get template => '''
final t = spi.t;
final rows = t.column();

rows.add(UserAccountsDrawerHeader(
  accountEmail: t.childText(text: spi.activeUser.email),
  accountName: t.childText(text: spi.activeUser.fullName),
  decoration: BoxDecoration(
    color: t.colorSecondary,
  ),
));

rows.add(ListTile(
  leading: const Icon(Icons.account_box),
  title: const Text('Account Settings'),
  onTap: spi.onPressedEditAccountSettings,
));

rows.add(ListTile(
  leading: const Icon(Icons.exit_to_app),
  title: const Text('Sign Out'),
  onTap: spi.onPressedSignout,
));

rows.add(ListTile(
  key: t.keyForWID(${AFSourceTemplate.insertAppNamespaceInsertion.upper}WidgetID.standardClose),
  leading: const Icon(Icons.close_sharp),
  title: const Text('Close'),
  onTap: spi.onCloseDrawer,
));

return Drawer(
  key: null,
  child: ListView(
    padding: t.padding.none,
    children: rows,
  )
);
''';
}

class SnippetSigninStarterSignedInMenuDrawerSPIT {

  static SnippetDeclareSPIT example() {
    final ei = AFSourceTemplateInsertions(insertions: {
      AFSourceTemplate.insertAdditionalMethodsInsertion: '''
User get activeUser => context.s.activeUser;

void onPressedSignout() {
  onCloseDrawer();
  context.executeQuery(SignoutQuery(storedEmail: activeUser.email));
}

void onPressedEditAccountSettings() {
  onCloseDrawer();
  context.navigatePush(AccountSettingsScreen.navigatePush());
}
'''
    });
    return SnippetDeclareSPIT(
      templateFileId: "signed_in_menu_drawer_spi",    
      templateFolder: AFProjectPaths.pathGenerateStarterSigninSnippets,
      embeddedInsertions: ei,
    );
  }
}

