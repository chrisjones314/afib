
import 'package:afib/src/dart/command/af_project_paths.dart';
import 'package:afib/src/dart/command/af_source_template.dart';
import 'package:afib/src/dart/command/templates/core/snippets/snippet_declare_spi.t.dart';
import 'package:afib/src/dart/command/templates/core/snippets/snippet_extra_imports.t.dart';
import 'package:afib/src/dart/command/templates/core/snippets/snippet_navigate_push.t.dart';
import 'package:afib/src/dart/command/templates/core/snippets/snippet_standard_route_param.t.dart';


class SnippetSignedInDrawerExtraImportsT {
  static SnippetExtraImportsT example() {
    return SnippetExtraImportsT(
      templateFileId: "signed_in_drawer_extra_imports",    
      templateFolder: AFProjectPaths.pathGenerateExampleStartHereSnippets,
      embeddedInsertions: AFSourceTemplateInsertions(insertions: {
        AFSourceTemplate.insertExtraImportsInsertion: '''
import 'package:${AFSourceTemplate.insertPackagePathInsertion}/state/models/referenced_user.dart';
''',
      })
    );
  }
}


class SnippetSignedInDrawerBuildBodyT extends AFSnippetSourceTemplate {
  SnippetSignedInDrawerBuildBodyT(): super(
    templateFileId: "signed_in_drawer_build_body",
    templateFolder: AFProjectPaths.pathGenerateExampleStartHereSnippets,
  );
  
  String get template => '''
    final t = spi.t;
    final rows = t.column();
    
    rows.add(UserAccountsDrawerHeader(
        accountEmail: t.childText(spi.email),
        accountName: t.childText(spi.userName),
        decoration: BoxDecoration(
          color: t.colorSecondary,
        ),
      )
    );

    rows.add(ListTile(
      key: null,
      leading: const Icon(Icons.close),
      onTap: spi.onTapClose,
      title: const Text('Close'),
    ));

    return Drawer(
      key: null,
      child: ListView(
        padding: EdgeInsets.zero,
        children: rows,
      )
    );
''';
}

class SnippetSignedInDrawerBuildWithSPIImplT extends AFSnippetSourceTemplate {
  SnippetSignedInDrawerBuildWithSPIImplT(): super(
    templateFileId: "signed_in_drawer_build_with_spi",
    templateFolder: AFProjectPaths.pathGenerateExampleStartHereSnippets,
  );
  
  String get template => '''
return _buildBody(spi);
''';
}

class SnippetSignedInDrawerSPIT {

  static SnippetDeclareSPIT example() {
    final ei = AFSourceTemplateInsertions(insertions: {
      AFSourceTemplate.insertAdditionalMethodsInsertion: '''
void onTapClose() {
  context.closeDrawer();
}

ReferencedUser? get activeUser {
  final cred = context.s.userCredential;
  return context.s.referencedUsers.find(cred.userId);
}

String get userName {
  final user = activeUser;
  if(user == null) {
    return "Not signed in";
  }
  return "\${user.firstName} \${user.lastName}";
}

String get email {
  final user = activeUser;
  if(user == null) {
    return "";
  }
  return user.email;
}
'''
    });
    return SnippetDeclareSPIT(
      templateFileId: "signed_in_drawer_spi",    
      templateFolder: AFProjectPaths.pathGenerateExampleStartHereSnippets,
      embeddedInsertions: ei,
    );
  }
}


