
import 'package:afib/src/dart/command/af_project_paths.dart';
import 'package:afib/src/dart/command/af_source_template.dart';
import 'package:afib/src/dart/command/templates/core/snippets/snippet_declare_spi.t.dart';
import 'package:afib/src/dart/command/templates/core/snippets/snippet_extra_imports.t.dart';
import 'package:afib/src/dart/command/templates/core/snippets/snippet_navigate_push.t.dart';
import 'package:afib/src/dart/command/templates/core/snippets/snippet_standard_route_param.t.dart';


class SnippetStartupScreenExtraImports {
  static SnippetExtraImportsT example() {
    return SnippetExtraImportsT(
      templateFileId: "startup_screen_extra_imports",    
      templateFolder: AFProjectPaths.pathGenerateExampleStartHereSnippets,
      embeddedInsertions: AFSourceTemplateInsertions(insertions: {
        AFSourceTemplate.insertExtraImportsInsertion: '''
import 'package:${AFSourceTemplate.insertPackagePathInsertion}/ui/screens/counter_management_screen.dart';
import 'package:${AFSourceTemplate.insertPackagePathInsertion}/ui/drawers/signed_in_drawer.dart';

''',
      })
    );
  }
}


class SnippetStartupScreenRouteParamT {

  static SnippetStandardRouteParamT example() {
    return SnippetStandardRouteParamT(
      templateFileId: "startup_screen_route_param",
      templateFolder: AFProjectPaths.pathGenerateExampleStartHereSnippets,
      embeddedInsertions: AFSourceTemplateInsertions(insertions: {
        AFSourceTemplate.insertMemberVariablesInsertion: '''
static const lyrics = <String>[
  "It is a truth universally acknowledged,\\nthat a single man\\nin possession of a good fortune,",
  "must be in want of a wife.",
  "However little known the feelings or views\\nof such a man may be\\non his first entering a neighbourhood,", 
  "this truth is so well fixed in the minds\\nof the surrounding families,\\nthat he is considered the rightful property",
  "of some one or other of their daughters.",
  "“My dear Mr. Bennet,”\\nsaid his lady to him one day,\\n“have you heard that Netherfield Park is let at last?”",
  "Mr. Bennet replied that he had not.",
  "“But it is,” returned she;\\n“for Mrs. Long has just been here,\\nand she told me all about it.”",
  "Mr. Bennet made no answer.",
  "“Do you not want to know who has taken it?”\\ncried his wife impatiently.",
  "“YOU want to tell me,\\nand I have no objection to hearing it.”",
  "This was invitation enough..."
];
final int lineNumber;
''',
        AFSourceTemplate.insertConstructorParamsInsertion: '{ required this.lineNumber, }',
        AFSourceTemplate.insertCreateParamsInsertion: "{ int lineNumber = 0 }",
        AFSourceTemplate.insertCreateParamsCallInsertion: "lineNumber: lineNumber",
        AFSourceTemplate.insertCopyWithParamsInsertion: "{ int? lineNumber }",
        AFSourceTemplate.insertCopyWithCallInsertion: "lineNumber: lineNumber ?? this.lineNumber,",
        AFSourceTemplate.insertAdditionalMethodsInsertion: '''
String get textCurrentLyric {
  final idx = lineNumber % lyrics.length;
  return lyrics[idx];
}

StartupScreenRouteParam reviseNextLyric() {
  return copyWith(lineNumber: lineNumber+1);
}
'''
      })
    );
  }

}

class SnippetStartupScreenNavigatePushT {

  static SnippetNavigatePushT example() {
    return SnippetNavigatePushT(
      templateFileId: "startup_screen_navigate_push",
      templateFolder: AFProjectPaths.pathGenerateExampleStartHereSnippets,
      embeddedInsertions: const AFSourceTemplateInsertions(insertions: {
        SnippetNavigatePushT.insertParamDecl: '{ int lineNumber = 0 }',
        SnippetNavigatePushT.insertParamCall: 'lineNumber: lineNumber,',
      })
    );
  }
}

class SnippetStartupScreenAdditionalMethodsT extends AFSnippetSourceTemplate {
  SnippetStartupScreenAdditionalMethodsT(): super(
    templateFileId: "startup_screen_additional_methods",
    templateFolder: AFProjectPaths.pathGenerateExampleStartHereSnippets,
  );
  
  String get template => '''
Widget _buildManageCountCard(StartupScreenSPI spi) {
  final  t = spi.t;
  final rows = t.column();
  t.buildStateCount(rows: rows, clickCount: spi.clickCountState);

  rows.add(t.childSingleRowButton(
    button: t.childButtonPrimaryText(
      text: "Manage Count", 
      onPressed: spi.onPressedManageCount
    )
  ));

  return t.childStandardCard(rows);
}

Widget _buildLyricsCard(StartupScreenSPI spi) {
  final t = spi.t;
  final rows = t.column();
  t.buildCardHeader(rows: rows, title: "Pride & Predjudice, Jane Austen", subtitle: "(route parameter)");

  rows.add(Container(
    margin: t.margin.bigger,
    height: (t.styleOnCard.bodyText2?.fontSize ?? 12.0) * 4.0,
    child: t.childText(spi.textCurrentLyric)
  ));

  rows.add(t.childSingleRowButton(
    button: t.childButtonPrimaryText(
      text: "I have no objection to hearing it.", 
      onPressed: spi.onPressedIHaveNoObjection
    )
  ));


  return t.childStandardCard(rows);
}

''';
}

class SnippetStartupScreenBuildBodyT extends AFSnippetSourceTemplate {
  SnippetStartupScreenBuildBodyT(): super(
    templateFileId: "startup_screen_build_body",
    templateFolder: AFProjectPaths.pathGenerateExampleStartHereSnippets,
  );
  
  String get template => '''
    final t = spi.t;
    final rows = t.column();

    rows.add(AFUIWelcomeWidget());
    rows.add(_buildManageCountCard(spi));
    rows.add(_buildLyricsCard(spi));

    return ListView(
      children: rows
    );
''';
}

class SnippetStartupScreenBuildWithSPIImplT extends AFSnippetSourceTemplate {
  SnippetStartupScreenBuildWithSPIImplT(): super(
    templateFileId: "startup_screen_build_with_spi",
    templateFolder: AFProjectPaths.pathGenerateExampleStartHereSnippets,
  );
  
  String get template => '''
final t = spi.t;

final buttonDrawer = AFBuilder<StartupScreenSPI>(
  spiParent: spi,
  config: config,
  builder: (spiUnder) {
    return  IconButton(
        icon: const Icon(Icons.menu),
        onPressed: spiUnder.onPressedMenu
    );
  }
) ;

final body = _buildBody(spi);
return t.childScaffold<AFBuildContext<${AFSourceTemplate.insertAppNamespaceInsertion.upper}DefaultStateView, StartupScreenRouteParam>>(
  spi: spi,
  body: body,
  drawer: SignedInDrawer(),
  appBar: AppBar(
      title: t.childText("${AFSourceTemplate.insertPackageNameInsertion.spaces}"),
      leading: buttonDrawer,
  )
);
''';
}

class SnippetStartupScreenSPIT {

  static SnippetDeclareSPIT example() {
    final ei = AFSourceTemplateInsertions(insertions: {
      AFSourceTemplate.insertAdditionalMethodsInsertion: '''
String get textCurrentLyric {
  return context.p.textCurrentLyric;
}

int get clickCountState {
  return context.s.countHistory.totalCount;
}

void onPressedMenu() {
  context.showLeftSideDrawer();
}

void onPressedManageCount() {
  context.navigatePush(CounterManagementScreen.navigatePush(clickCount: 0));
}

void onPressedIHaveNoObjection() {
  context.updateRouteParam(context.p.reviseNextLyric());
}
'''
    });
    return SnippetDeclareSPIT(
      templateFileId: "startup_screen_spi",    
      templateFolder: AFProjectPaths.pathGenerateExampleStartHereSnippets,
      embeddedInsertions: ei,
    );
  }
}


