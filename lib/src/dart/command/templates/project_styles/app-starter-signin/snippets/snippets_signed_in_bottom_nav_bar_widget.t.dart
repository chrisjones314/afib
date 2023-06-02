
import 'package:afib/src/dart/command/af_project_paths.dart';
import 'package:afib/src/dart/command/af_source_template.dart';
import 'package:afib/src/dart/command/templates/core/snippets/snippet_declare_spi.t.dart';
import 'package:afib/src/dart/command/templates/core/snippets/snippet_extra_imports.t.dart';

class SnippetSigninStarterSignedInBottomNavBarExtraImportsT {
  static SnippetExtraImportsT example() {
    return SnippetExtraImportsT(
      templateFileId: "signed_in_bottom_nav_bar_extra_imports",    
      templateFolder: AFProjectPaths.pathGenerateStarterSigninSnippets,
      embeddedInsertions: const AFSourceTemplateInsertions(insertions: {
        AFSourceTemplate.insertExtraImportsInsertion: '''
''',
      })
    );
  }
}

class SnippetSigninStarterSignedInBottomNavBarBuildBodyT extends AFSnippetSourceTemplate {
  SnippetSigninStarterSignedInBottomNavBarBuildBodyT(): super(
    templateFileId: "signed_in_bottom_nav_bar_build_body",
    templateFolder: AFProjectPaths.pathGenerateStarterSigninSnippets,
  );
  
  @override
  String get template => '''
final t = spi.t;
final cols = t.row();

cols.add(t.childButtonIcon(
  child: const Icon(Icons.menu), 
  onPressed: spi.onPressedMenuDrawer
));
return BottomAppBar(
  child: Row(children: cols),
);
''';
}

class SnippetSigninStarterSignedInBottomNavBarSPIT {

  static SnippetDeclareSPIT example() {
    const ei = AFSourceTemplateInsertions(insertions: {
      AFSourceTemplate.insertAdditionalMethodsInsertion: '''
void onPressedMenuDrawer() {
  context.showLeftSideDrawer();
}
'''
    });
    return SnippetDeclareSPIT(
      templateFileId: "signed_in_bottom_nav_bar_spi",    
      templateFolder: AFProjectPaths.pathGenerateStarterSigninSnippets,
      embeddedInsertions: ei,
    );
  }
}

