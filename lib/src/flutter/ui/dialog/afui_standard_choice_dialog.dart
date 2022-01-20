import 'package:afib/afib_flutter.dart';
import 'package:afib/src/flutter/ui/afui_connected_base.dart';
import 'package:afib/src/flutter/ui/stateviews/afui_prototype_state_view.dart';
import 'package:flutter/material.dart';

enum AFUIStandardChoiceDialogIcon {
  none,
  question,
  info,
  warning,
  error,
}

//--------------------------------------------------------------------------------------
@immutable
class AFUIStandardChoiceDialogRouteParam extends AFRouteParam {
  final AFUIStandardChoiceDialogIcon icon;
  final AFRichTextBuilder? body;
  final AFRichTextBuilder title;
  final List<String> buttonTitles;

  //--------------------------------------------------------------------------------------
  AFUIStandardChoiceDialogRouteParam({
    required this.icon,
    required this.body,
    required this.title,
    required this.buttonTitles,
  }): super(id: AFUIScreenID.dialogStandardChoice);
}

class AFUIStandardChoiceDialogSPI extends AFUIDefaultSPI<AFUIPrototypeStateView, AFUIStandardChoiceDialogRouteParam> {
  AFUIStandardChoiceDialogSPI(AFUIBuildContext<AFUIPrototypeStateView, AFUIStandardChoiceDialogRouteParam> context, AFConnectedUIBase screen): super(context, screen);
  factory AFUIStandardChoiceDialogSPI.create(AFUIBuildContext<AFUIPrototypeStateView, AFUIStandardChoiceDialogRouteParam> context, AFConnectedUIBase screen) {
    return AFUIStandardChoiceDialogSPI(context, screen);
  }
}

//--------------------------------------------------------------------------------------
class AFUIStandardChoiceDialog extends AFUIDefaultConnectedDialog<AFUIStandardChoiceDialogSPI, AFUIStandardChoiceDialogRouteParam> {

  //--------------------------------------------------------------------------------------
  AFUIStandardChoiceDialog(): super(AFUIScreenID.dialogStandardChoice, AFUIStandardChoiceDialogSPI.create);

  //--------------------------------------------------------------------------------------
  static AFNavigatePushAction navigatePush({
    required AFRichTextBuilder title,
    required AFRichTextBuilder? body,
    required AFUIStandardChoiceDialogIcon icon,
    required List<String> buttonTitles
  }) {
    return AFNavigatePushAction(
      routeParam: AFUIStandardChoiceDialogRouteParam(
        title: title,
        body: body,
        icon: icon,
        buttonTitles: buttonTitles,
      ),
    );
  }

  //--------------------------------------------------------------------------------------
  @override
  Widget buildDialogWithContext(AFUIStandardChoiceDialogSPI spi) {
    final context = spi.context;
    final t = context.t;

    final rows = t.column();
    
    final icon = t.iconStandard(context.p.icon, size: 30.0);
    final titleCols = t.row();
    if(icon != null) {
      titleCols.add(icon);
    }
    final title = context.p.title;
    final body = context.p.body;

    titleCols.add(t.childMargin(
      margin: t.margin.h.s3,
      child: title.toRichText()
    ));

    rows.add(Row(children: titleCols));
    if(body != null) {
      rows.add(t.childMargin(
        margin: EdgeInsets.fromLTRB(38, 8, 8, 8),
        child: body.toRichText()
      ));
    }

    final actions = t.row();
    final buttonTitles = context.p.buttonTitles;
    for(var i = 0; i < buttonTitles.length; i++) {
      final buttonTitle = buttonTitles[i];
      if(i < buttonTitles.length - 1) {
        actions.add(t.childMargin(
          margin: t.margin.h.s3,
          child: t.childButtonFlatText(
            text: buttonTitle,
            onPressed:  () {
              context.closeDialog(i);
            },
        )));
      } else {
        actions.add(t.childMargin(
          margin: t.margin.h.s3,
          child: t.childButtonPrimaryText(
          text: buttonTitle,
          onPressed:  () {
            context.closeDialog(i);
          },
        )));
      }
    }

    rows.add(t.childMargin(
      margin: t.margin.t.s3,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: actions
    )));

    return Dialog(
      child: Container(
        margin: t.margin.a.s5,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: rows
        )
      )
    );
  }
}