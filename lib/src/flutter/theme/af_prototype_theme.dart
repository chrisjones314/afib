
import 'package:afib/src/dart/redux/state/af_theme_state.dart';
import 'package:afib/src/flutter/screen/af_connected_screen.dart';
import 'package:afib/src/flutter/test/af_screen_test.dart';
import 'package:flutter/material.dart';

class AFPrototypeTheme extends AFConceptualTheme {
  AFPrototypeTheme(AFFundamentalTheme fundamentals): super(fundamentals: fundamentals);

  Widget testExplanationText(String explanation) {
    return text(explanation);
  }

  Widget buildHeaderCard(AFBuildContext context, String title, List<Widget> rows) {
    final radius = Radius.circular(4.0);
    final content = column();
    content.add(Container(
        padding: paddingScaled(),
        child: Row(
          children: [text(title, style: textOnPrimary.subtitle1)],
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
      child: text("Reusable", style: this.textOnPrimary.bodyText1)
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

}