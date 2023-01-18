
import 'package:afib/src/dart/command/af_project_paths.dart';
import 'package:afib/src/dart/command/af_source_template.dart';
import 'package:afib/src/dart/command/templates/core/snippets/snippet_declare_spi.t.dart';
import 'package:afib/src/dart/command/templates/core/snippets/snippet_extra_imports.t.dart';
import 'package:afib/src/dart/command/templates/core/snippets/snippet_navigate_push.t.dart';
import 'package:afib/src/dart/command/templates/core/snippets/snippet_standard_route_param.t.dart';


class SnippetHomePageScreenExtraImports {
  static SnippetExtraImportsT example() {
    return SnippetExtraImportsT(
      templateFileId: "home_page_screen_extra_imports",    
      templateFolder: AFProjectPaths.pathGenerateExampleEvalDemoSnippets,
      embeddedInsertions: AFSourceTemplateInsertions(insertions: {
        AFSourceTemplate.insertExtraImportsInsertion: '''
import 'package:${AFSourceTemplate.insertPackagePathInsertion}/ui/screens/counter_management_screen.dart';
import 'package:${AFSourceTemplate.insertPackagePathInsertion}/ui/drawers/signed_in_drawer.dart';
''',
      })
    );
  }
}


class SnippetHomePageScreenRouteParamT {

  static SnippetStandardRouteParamT example() {
    return SnippetStandardRouteParamT(
      templateFileId: "home_page_screen_route_param",
      templateFolder: AFProjectPaths.pathGenerateExampleEvalDemoSnippets,
      embeddedInsertions: AFSourceTemplateInsertions(insertions: {
        AFSourceTemplate.insertCreateParamsInsertion: AFSourceTemplate.empty,
        AFSourceTemplate.insertAdditionalMethodsInsertion: '''

static const stanzas = <String>[
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

String get textCurrentStanza {
  final idx = lineNumber % stanzas.length;
  return stanzas[idx];
}

HomePageScreenRouteParam reviseNextStanza() {
  return copyWith(lineNumber: lineNumber+1);
}
'''
      })
    );
  }

}

class SnippetHomePageScreenNavigatePushT {

  static SnippetNavigatePushT example() {
    return SnippetNavigatePushT(
      templateFileId: "home_page_screen_navigate_push",
      templateFolder: AFProjectPaths.pathGenerateExampleEvalDemoSnippets,
      embeddedInsertions: const AFSourceTemplateInsertions(insertions: {
        SnippetNavigatePushT.insertNavigatePushParamDecl: '{ int lineNumber = 0 }',
        SnippetNavigatePushT.insertNavigatePushParamCall: 'lineNumber: lineNumber,',
      })
    );
  }
}

class SnippetHomePageScreenAdditionalMethodsT extends AFSnippetSourceTemplate {
  SnippetHomePageScreenAdditionalMethodsT(): super(
    templateFileId: "home_page_screen_additional_methods",
    templateFolder: AFProjectPaths.pathGenerateExampleEvalDemoSnippets,
  );
  
  String get template => '''
Widget _buildManageCountCard(HomePageScreenSPI spi) {
  final  t = spi.t;
  final rows = t.column();
  t.buildStateCount(rows: rows, clickCount: spi.clickCountState);

  rows.add(t.childSingleRowButton(
    button: t.childButtonPrimaryText(
      wid: ${insertAppNamespaceUpper}WidgetID.buttonManageCount,
      text: "Manage Count", 
      onPressed: spi.onPressedManageCount
    )
  ));

  return t.childStandardCard(rows);
}

Widget _buildStanzasCard(HomePageScreenSPI spi) {
  final t = spi.t;
  final rows = t.column();
  t.buildCardHeader(rows: rows, title: "Pride & Predjudice, Jane Austen", subtitle: "(route parameter)");

  rows.add(Container(
    margin: t.margin.bigger,
    height: (t.styleOnCard.bodyText2?.fontSize ?? 12.0) * 4.0,
    child: t.childText(
      wid: ${insertAppNamespaceUpper}WidgetID.textCurrentStanza,
      spi.textCurrentStanza
    )
  ));

  rows.add(t.childSingleRowButton(
    button: t.childButtonPrimaryText(
      wid: ${insertAppNamespaceUpper}WidgetID.buttonIHaveNoObjection,
      text: "I have no objection to hearing it.", 
      onPressed: spi.onPressedIHaveNoObjection
    )
  ));


  return t.childStandardCard(rows);
}

''';
}

class SnippetHomePageScreenBuildBodyT extends AFSnippetSourceTemplate {
  SnippetHomePageScreenBuildBodyT(): super(
    templateFileId: "home_page_screen_build_body",
    templateFolder: AFProjectPaths.pathGenerateExampleEvalDemoSnippets,
  );
  
  String get template => '''
    final t = spi.t;
    final rows = t.column();

    rows.add(AFUIWelcomeWidget());
    rows.add(_buildManageCountCard(spi));
    rows.add(_buildStanzasCard(spi));

    return ListView(
      children: rows
    );
''';
}

class SnippetHomePageScreenBuildWithSPIImplT extends AFSnippetSourceTemplate {
  SnippetHomePageScreenBuildWithSPIImplT(): super(
    templateFileId: "home_page_screen_build_with_spi",
    templateFolder: AFProjectPaths.pathGenerateExampleEvalDemoSnippets,
  );
  
  String get template => '''
final t = spi.t;

final buttonDrawer = AFBuilder<HomePageScreenSPI>(
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
return t.childScaffold<AFBuildContext<${AFSourceTemplate.insertAppNamespaceInsertion.upper}DefaultStateView, HomePageScreenRouteParam>>(
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

class SnippetHomePageScreenSPIT {

  static SnippetDeclareSPIT example() {
    final ei = AFSourceTemplateInsertions(insertions: {
      AFSourceTemplate.insertAdditionalMethodsInsertion: '''
String get textCurrentStanza {
  return context.p.textCurrentStanza;
}

int get clickCountState {
  return context.s.countHistoryItems.totalCount;
}

void onPressedMenu() {
  context.showLeftSideDrawer();
}

void onPressedManageCount() {
  context.navigatePush(CounterManagementScreen.navigatePush(clickCount: 0));
}

void onPressedIHaveNoObjection() {
  context.updateRouteParam(context.p.reviseNextStanza());
}
'''
    });
    return SnippetDeclareSPIT(
      templateFileId: "home_page_screen_spi",    
      templateFolder: AFProjectPaths.pathGenerateExampleEvalDemoSnippets,
      embeddedInsertions: ei,
    );
  }
}


