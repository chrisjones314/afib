
import 'package:afib/afib_dart.dart';
import 'package:afib/src/dart/redux/state/af_theme_state.dart';
import 'package:afib/src/flutter/screen/af_connected_screen.dart';
import 'package:afib/src/flutter/test/af_screen_test.dart';
import 'package:flutter/material.dart';

class AFPrototypeTheme extends AFConceptualTheme {
    AFPrototypeTheme(AFFundamentalTheme fundamentals): super(fundamentals: fundamentals, primaryThemeArea: AFPrimaryThemeID.prototypeTheme);

    Widget createSectionHeader(String title) {
      final background = color(AFPrimaryThemeID.colorPrimary);
      final foreground = textStyle(AFPrimaryThemeID.styleTextOnPrimary);
      return Card(
        color: background,
        child: Container(
          margin: EdgeInsets.all(8.0),
          child: Text(
            title,
            style: foreground
          )
        )
      );
    }

    Widget createReusableTag() {
      final background = color(AFPrimaryThemeID.colorPrimary);
      final foreground = textStyle(AFPrimaryThemeID.styleTextOnPrimary);
      return Container(
        margin: EdgeInsets.fromLTRB(8.0, 16.0, 0, 0),
        padding: EdgeInsets.symmetric(horizontal: 8.0),
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(4.0),
        ),
        child: Text("Reusable", style: foreground)
      );
    }    

  Widget createTestCard(AFDispatcher dispatcher, AFScreenPrototypeTest instance) {
    final titleText = instance.title ?? instance.id.code;
    final cols = row();
    cols.add(Text(titleText));
    if(instance.isReusable) {
      cols.add(createReusableTag());
    }

    final titleRow = Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: cols
    );
    return Card(
      key: Key(instance.id.code),
      child: ListTile(
        title: titleRow,
        subtitle: Text(instance.id.code),
        dense: true,
        trailing: Icon(Icons.chevron_right),
        onTap: () {
          instance.startScreen(dispatcher);
        }
    ));
  }

}