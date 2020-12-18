
import 'package:afib/src/dart/redux/state/af_theme_state.dart';
import 'package:afib/src/flutter/screen/af_connected_screen.dart';
import 'package:afib/src/flutter/test/af_screen_test.dart';
import 'package:flutter/material.dart';

class AFPrototypeTheme extends AFConceptualTheme {
  static const columnWidthsForNumValueTable = {
      0: FixedColumnWidth(20.0),
      1: FlexColumnWidth(),
    };

  AFPrototypeTheme(AFFundamentalTheme fundamentals): super(fundamentals: fundamentals);

  Widget testExplanationText(String explanation) {
    return text(explanation);
  }

  double get resultColumnWidth {
    return 50.0;
  }

  Widget buildHeaderCard(AFBuildContext context, String title, List<Widget> rows) {
    final radius = Radius.circular(4.0);
    final content = column();
    content.add(Container(
        padding: paddingScaled(),
        child: Row(
          children: [text(title, style: styleOnPrimary.subtitle1)],
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.only(topLeft: radius, topRight: radius),
          color: colorPrimary,
        ),
      )
    );

    content.addAll(ListTile.divideTiles(
      context: context.c,
      tiles: rows,
    ));

    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: content),
    );  
  }


  Widget createReusableTag() {
    return Container(
      padding: paddingScaled(all: 0.5),
      decoration: BoxDecoration(
        color: colorPrimary,
        borderRadius: BorderRadius.circular(4.0),
      ),
      child: text("Reusable", style: this.styleOnPrimary.bodyText1)
    );
  }    

  Widget createTestListTile(AFDispatcher dispatcher, AFScreenPrototypeTest instance) {
    final titleText = instance.id.code;
    final cols = row();
    cols.add(text(titleText));
    if(instance.hasReusable) {
      cols.add(createReusableTag());
    }

    final titleRow = Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: cols
    );
    final tagsText = this.textBuilder();
    tagsText.write("tags: ");
    tagsText.write(instance.id.tagsText);
    return Container(
      key: Key(instance.id.code),
      child: ListTile(
        title: titleRow,
        subtitle: tagsText.create(),
        dense: true,
        trailing: Icon(Icons.chevron_right),
        onTap: () {
          instance.startScreen(dispatcher);
        }
    ));
  }

  Widget buildPrototypeScaffold(dynamic title, List<Widget> rows, { Widget leading }) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(        
            leading: leading,
            automaticallyImplyLeading: false,
            title: this.text(title)
          ),
          SliverList(
            delegate: SliverChildListDelegate(rows),)
      ])    
    );
  }

  Widget buildErrorsSection(AFBuildContext context, List<String> errors) {
    var content;
    if(errors.isNotEmpty) {
      final headerColsErrors = row();
      headerColsErrors.add(testResultTableValue(context, "#", TextAlign.left, showError: true));
      headerColsErrors.add(testResultTableValue(context, "Errors", TextAlign.left, showError: true));
      
      final tableRowsErrors = tableColumn();
      tableRowsErrors.add(TableRow(children: headerColsErrors));

      for(var i = 0; i < errors.length; i++) {
        final error = stripErrorPath(errors[i]);
        final errorCols = row();
        errorCols.add(testResultTableErrorLine(context, text((i+1).toString()), i));
        errorCols.add(testResultTableErrorLine(context, text(error), i));
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
        padding: paddingScaled(),
        child: text("All Tests Passed", textColor: Colors.white, fontSize: 15.0, fontWeight: FontWeight.bold, textAlign: TextAlign.center)
      );
    }

    return Container(
      margin: marginScaled(horizontal: 0, top: 1),
      child: content,
    );
  }

  Widget testResultTableHeader(AFBuildContext context, String text, TextAlign textAlign) {
    final t = context.t;
    return Container(
      padding: t.paddingScaled(),
      color: t.colorPrimary,
      child: t.text(text, textColor: t.colorOnPrimary, textAlign: textAlign)
    );
  }

  Widget testResultTableErrorLine(AFBuildContext context, Widget text, int row) {
    final color = (row % 2 == 0) ? Colors.white : Colors.grey[350];
    return Container(
      padding: context.t.paddingScaled(all: 0.5),
      color: color,
      child: text
    );
  }

  Widget testResultTableValue(AFBuildContext context, String text, TextAlign textAlign, {
    bool showError = false
  }) {
    final t = context.t;
    var color;
    var colorText;
    if(showError) {
      color = t.colorError;
      colorText = t.colorOnError;
    }
    return Container(
      color: color,
      padding: t.paddingScaled(),
      child: t.text(text, textColor: colorText, textAlign: textAlign)
    );
  }

  String stripErrorPath(String err) {
    final idx = err.lastIndexOf('/');
    if(idx < 0) {
      return err;
    }
    return err.substring(idx+1);
  }

}