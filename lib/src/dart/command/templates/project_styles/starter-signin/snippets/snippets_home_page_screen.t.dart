
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

rows.add(t.childMarginStandard(
  child: t.childText("userId: \${spi.userId}")
));

rows.add(t.childMarginStandard(
  child: t.childText("email: \${spi.storedEmail}")
));

rows.add(t.childMarginStandard(
  child: t.childButtonPrimaryText(
    text: "Sign Out", 
    onPressed: spi.onPressedSignout
  )
));

return ListView(
  children: [
    t.childCard(
      child: Column(children: rows)
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

void onPressedSignout() {
  context.executeQuery(SignoutQuery(storedEmail: storedEmail));
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


