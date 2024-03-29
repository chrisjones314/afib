
import 'package:afib/src/dart/command/af_project_paths.dart';
import 'package:afib/src/dart/command/af_source_template.dart';
import 'package:afib/src/dart/command/templates/core/snippets/snippet_declare_spi.t.dart';
import 'package:afib/src/dart/command/templates/core/snippets/snippet_extra_imports.t.dart';


class SnippetSignedInDrawerExtraImportsT {
  static SnippetExtraImportsT example() {
    return SnippetExtraImportsT(
      templateFileId: "signed_in_drawer_extra_imports",    
      templateFolder: AFProjectPaths.pathGenerateExampleEvalDemoSnippets,
      embeddedInsertions: AFSourceTemplateInsertions(insertions: {
        AFSourceTemplate.insertExtraImportsInsertion: '''
import 'package:${AFSourceTemplate.insertPackagePathInsertion}/state/models/user.dart';
''',
      })
    );
  }
}


class SnippetSignedInDrawerBuildBodyT extends AFSnippetSourceTemplate {
  SnippetSignedInDrawerBuildBodyT(): super(
    templateFileId: "signed_in_drawer_build_body",
    templateFolder: AFProjectPaths.pathGenerateExampleEvalDemoSnippets,
  );
  
  @override
  String get template => '''
    final t = spi.t;
    final rows = t.column();
    
    rows.add(UserAccountsDrawerHeader(
        accountEmail: t.childText(text: spi.email),
        accountName: t.childText(text: spi.userName),
        decoration: BoxDecoration(
          color: t.colorSecondary,
        ),
      )
    );

    rows.add(ListTile(
      key: t.keyForWID(${insertAppNamespaceUpper}WidgetID.standardClose),
      leading: const Icon(Icons.close),
      onTap: spi.onCloseDrawer,
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
    templateFolder: AFProjectPaths.pathGenerateExampleEvalDemoSnippets,
  );
  
  @override
  String get template => '''
return _buildBody(spi);
''';
}

class SnippetSignedInDrawerSPIT {

  static SnippetDeclareSPIT example() {
    const ei = AFSourceTemplateInsertions(insertions: {
      AFSourceTemplate.insertAdditionalMethodsInsertion: '''
User? get activeUser {
  final cred = context.s.userCredential;
  return context.s.users.findById(cred.userId);
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
      templateFolder: AFProjectPaths.pathGenerateExampleEvalDemoSnippets,
      embeddedInsertions: ei,
    );
  }
}


