import 'package:afib/afib_flutter.dart';
import 'package:afib/src/flutter/ui/afui_connected_base.dart';
import 'package:afib/src/flutter/ui/stateviews/afui_default_state_view.dart';
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
class AFUIStandardChoiceDialogRouteParam extends AFDialogRouteParam {
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
  }): super(screenId: AFUIScreenID.dialogStandardChoice);
}

class AFUIStandardChoiceDialogSPI extends AFUIDialogSPI<AFUIDefaultStateView, AFUIStandardChoiceDialogRouteParam> {
  const AFUIStandardChoiceDialogSPI(super.context, super.standard);
  
  factory AFUIStandardChoiceDialogSPI.create(AFBuildContext<AFUIDefaultStateView, AFUIStandardChoiceDialogRouteParam> context, AFStandardSPIData standard) {
    return AFUIStandardChoiceDialogSPI(context, standard);
  }    
}

//--------------------------------------------------------------------------------------
class AFUIStandardChoiceDialog extends AFUIConnectedDialog<AFUIStandardChoiceDialogSPI, AFUIDefaultStateView, AFUIStandardChoiceDialogRouteParam> {
  
  static final config = AFUIDefaultDialogConfig<AFUIStandardChoiceDialogSPI, AFUIStandardChoiceDialogRouteParam> (
    spiCreator: AFUIStandardChoiceDialogSPI.create,
  );

  //--------------------------------------------------------------------------------------
  AFUIStandardChoiceDialog(): super(screenId: AFUIScreenID.dialogStandardChoice, config: config);

  //--------------------------------------------------------------------------------------
  static AFNavigatePushAction navigatePush({
    required AFRichTextBuilder title,
    required AFRichTextBuilder? body,
    required AFUIStandardChoiceDialogIcon icon,
    required List<String> buttonTitles
  }) {
    return AFNavigatePushAction(
      launchParam: AFUIStandardChoiceDialogRouteParam(
        title: title,
        body: body,
        icon: icon,
        buttonTitles: buttonTitles,
      ),
    );
  }

  //--------------------------------------------------------------------------------------
  @override
  Widget buildWithSPI(AFUIStandardChoiceDialogSPI spi) {
    final context = spi.context;
    final t = spi.t;

    final rows = t.column();
    
    final icon = t.iconStandard(context.p.icon, size: 30.0);
    final titleCols = t.row();
    if(icon != null) {
      titleCols.add(icon);
    }
    final title = context.p.title;
    final body = context.p.body;

    titleCols.add(Expanded(child: t.childMargin(
      margin: t.margin.h.s3,
      child: title.toRichText(
        maxLines: 11,
        softWrap: true,
      )
    )));

    rows.add(Row(children: titleCols));
    if(body != null) {
      rows.add(t.childMargin(
        margin: const EdgeInsets.fromLTRB(38, 8, 8, 8),
        child: body.toRichText(maxLines: 10,
          softWrap: true)
      ));
    }

    final actions = t.row();
    final buttonTitles = context.p.buttonTitles;
    for(var i = 0; i < buttonTitles.length; i++) {
      final buttonTitle = buttonTitles[i];
      if(i < buttonTitles.length - 1) {
        actions.add(Expanded(
          flex: 1,
          child: t.childMargin(
            margin: t.margin.h.s3,
            child: t.childButtonFlatText(
              text: buttonTitle,
              onPressed:  () {
                spi.onCloseDialog(i);
              },
            )
        )));
      } else {
        actions.add(Expanded(
          flex: 1,
          child: t.childMargin(
            margin: t.margin.h.s3,
            child: t.childButtonPrimaryText(
            text: buttonTitle,
            onPressed:  () {
              spi.onCloseDialog(i);
            },
          )
        )));
      }
    }

    rows.add(t.childMargin(
      margin: t.margin.t.s3,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: actions
    )));

    return Dialog(
      shape: t.shapeStandardDialog,
      backgroundColor: t.colorSurface,
      child: Container(
        margin: t.margin.a.s5,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: rows
        )
      )
    );
  }
}