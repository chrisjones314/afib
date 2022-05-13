import 'package:afib/afib_flutter.dart';
import 'package:afib/src/flutter/test/af_test_actions.dart';
import 'package:afib/src/flutter/ui/screen/afui_prototype_list_screen.dart';
import 'package:afib/src/flutter/ui/screen/afui_prototype_wireframes_list_screen.dart';
import 'package:flutter/material.dart';

class AFUIDefaultTheme extends AFFunctionalTheme {
  static const columnWidthsForNumValueTable = {
      0: FixedColumnWidth(20.0),
      1: FlexColumnWidth(),
    };

  AFUIDefaultTheme(AFThemeID id, AFFundamentalThemeState fundamentals): super(id, fundamentals);

  factory AFUIDefaultTheme.create(AFThemeID id, AFFundamentalThemeState fundamentals) {
    return AFUIDefaultTheme(id, fundamentals);
  }


  Color get colorDisabled {
    return Colors.deepOrange;
  }

  @override
  Text childText(dynamic text, {
    AFWidgetID? wid, 
    dynamic style,
    dynamic textColor,
    dynamic fontSize,
    dynamic fontWeight,
    TextAlign? textAlign,
    TextOverflow? overflow,
  }) {
    return super.childText(text,
      wid: wid,
      style: style,
      textColor: textColor,
      fontSize: fontSize,
      fontWeight: fontWeight,
      textAlign: textAlign,
      overflow: overflow);
  }

  Widget testExplanationText(String explanation) {
    return childText(explanation);
  }

  double get resultColumnWidth {
    return 50.0;
  }


  Widget childCardHeader(AFBuildContext context, AFWidgetID? wid, dynamic title, List<Widget> rows, { EdgeInsets? margin }) {
    final radius = Radius.circular(4.0);
    final content = column();
    content.add(Container(
      margin: margin,
        padding: padding.standard,
        child: Row(
          children: [childText(title, style: styleOnPrimary.subtitle1)],
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.only(topLeft: radius, topRight: radius),
          color: colorPrimary,
        ),
      )
    );

    content.addAll(childrenDivideWidgets(rows, wid));


    return Card(
      key: this.keyForWID(wid),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: content),
    );  
  }


  Widget createReusableTag() {
    return Container(
      padding: padding.a.standard,
      decoration: BoxDecoration(
        color: colorPrimary,
        borderRadius: BorderRadius.circular(4.0),
      ),
      child: childText("Reusable", style: this.styleOnPrimary.bodyText1)
    );
  }    

  Widget createTestListTile(AFStateProgrammingInterface spi, AFScreenPrototype prototype, {
    String? title,
    String? subtitle,
    AFPressedDelegate? onTap,
  }) {
    final titleText = title ?? prototype.displayId.code;
    final cols = row();
    cols.add(Expanded(child: childText(titleText, overflow: TextOverflow.fade)));
    if(prototype.hasReusable) {
      cols.add(createReusableTag());
    }

    final titleRow = Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: cols
    );
    final tagsText = this.childTextBuilder();
    if(subtitle != null) {
      tagsText.write(subtitle);
    } else {
      tagsText.write("tags: ");
      tagsText.write(prototype.id.tagsText);
    }
    final onPressed = onTap ?? () {
      spi.context.dispatch(AFNavigateSetParamAction(
        param: AFUIPrototypeDrawerRouteParam.createOncePerScreen(AFUIPrototypeDrawerRouteParam.viewTest),
        children: null,
        route: AFNavigateRoute.routeGlobalPool
      ));
      spi.context.dispatch(AFUpdateActivePrototypeAction(prototypeId: prototype.id));
      prototype.startScreen(spi.context.d, spi.flutterContext, AFibF.g.testData);
      
    };
    return childListTileNavDown(
      wid: prototype.id,
      title: titleRow,
      subtitle: tagsText.create(),
      onTap: onPressed
    );
  }

  Widget childListTileNavDown({
    AFID? wid,
    Widget? title,
    Widget? subtitle,
    AFPressedDelegate? onTap,
  }) {
    return Container(
      key: keyForWID(wid),
      child: ListTile(
        title: title,
        subtitle: subtitle,
        dense: true,
        trailing: Icon(Icons.chevron_right),
        onTap: onTap,
      ));
  }

  Widget buildPrototypeScaffold(dynamic title, List<Widget> rows, { Widget? leading }) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(        
            leading: leading,
            automaticallyImplyLeading: false,
            title: this.childText(title)
          ),
          SliverList(
            delegate: SliverChildListDelegate(rows),)
      ])    
    );
  }

  Widget buildErrorsSection(List<String> errors) {
    var content;
    if(errors.isNotEmpty) {
      final headerColsErrors = row();
      headerColsErrors.add(testResultTableValue("#", TextAlign.left, showError: true));
      headerColsErrors.add(testResultTableValue("Errors", TextAlign.left, showError: true));
      
      final tableRowsErrors = childrenTable();
      tableRowsErrors.add(TableRow(children: headerColsErrors));

      for(var i = 0; i < errors.length; i++) {
        final error = stripErrorPath(errors[i]);
        final errorCols = row();
        errorCols.add(testResultTableErrorLine(childText((i+1).toString()), i));
        errorCols.add(testResultTableErrorLine(childText(error), i));
        tableRowsErrors.add(TableRow(children: errorCols));
      }

      final columnWidths = columnWidthsForNumValueTable;
      content = Table(children: tableRowsErrors, columnWidths: columnWidths);
    } else {
      content = Container(
        decoration: BoxDecoration(
          color: Colors.green,
          borderRadius: borderRadiusScaled(),
        ),
        padding: padding.standard,
        child: childText("All Tests Passed", textColor: Colors.white, fontSize: 15.0, fontWeight: FontWeight.bold, textAlign: TextAlign.center)
      );
    }

    return Container(
      margin: margin.t.s3,
      child: content,
    );
  }

  Widget testResultTableHeader(String text, TextAlign textAlign) {
    return Container(
      padding: padding.standard,
      color: colorPrimary,
      child: childText(text, textColor: colorOnPrimary, textAlign: textAlign)
    );
  }

  Widget testResultTableErrorLine(Widget text, int row) {
    final color = (row % 2 == 0) ? Colors.white : Colors.grey[350];
    return Container(
      padding: padding.a.standard,
      color: color,
      child: text
    );
  }

  Widget testResultTableValue(String text, TextAlign textAlign, {
    bool showError = false
  }) {
    var color;
    var colorText;
    if(showError) {
      color = colorError;
      colorText = colorOnError;
    }
    return Container(
      color: color,
      padding: padding.standard,
      child: childText(text, textColor: colorText, textAlign: textAlign)
    );
  }

  String stripErrorPath(String err) {
    final idx = err.lastIndexOf('/');
    if(idx < 0) {
      return err;
    }
    return err.substring(idx+1);
  }

  void buildLibraryPrototypeNav({
    required AFStateProgrammingInterface spi,
    required List<Widget> rows,
    required AFLibraryTestHolder tests,
  }) {
    final prototypes = <AFScreenPrototype>[];
    prototypes.addAll(tests.afWidgetTests.all);
    prototypes.addAll(tests.afDialogTests.all);
    prototypes.addAll(tests.afBottomSheetTests.all);
    prototypes.addAll(tests.afDrawerTests.all);
    prototypes.addAll(tests.afScreenTests.all);
    
    rows.add(childTestNavDown(
      spi: spi,
      title: AFUITranslationID.screenPrototypes,
      tests: prototypes,
    ));

    rows.add(childListNav(title: AFUITranslationID.wireframes, onPressed: () {
      spi.context.navigatePush(AFUIPrototypeWireframesListScreen.navigatePush());
    }));

  }

  Widget childTestNavDown({
    AFStateProgrammingInterface? spi,
    dynamic title, 
    List<AFScreenPrototype>? tests
  }) {
    if(spi == null || tests == null) throw AFException("Context or tests are null");
    return childListNav(
      title: title,
      onPressed: () {
        spi.context.navigatePush(AFUIPrototypeTestScreen.navigatePush(tests, title));
    });    
  }

  Widget childListNav({
    dynamic title,
    AFPressedDelegate? onPressed,
  }) {
    return _createKindRow(title, onPressed);
  }


  Widget _createKindRow(dynamic text, void Function()? onTap) {
    return ListTile(
      title: childText(text),
      dense: true,
      trailing: icon(AFUIThemeID.iconNavDown),
      onTap: onTap
    );
  }
}