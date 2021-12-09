import 'package:afib/afib_flutter.dart';
import 'package:afib/src/flutter/ui/af_prototype_base.dart';
import 'package:flutter/material.dart';

//--------------------------------------------------------------------------------------
@immutable
class AFStandardChoiceDialogRouteParam extends AFRouteParam {
  final String alertBody;
  final String alertTitle;
  final List<String> buttonTitles;

  //--------------------------------------------------------------------------------------
  AFStandardChoiceDialogRouteParam({
    required this.alertBody,
    required this.alertTitle,
    required this.buttonTitles,
  }): super(id: AFUIScreenID.dialogStandardChoice);
}

//--------------------------------------------------------------------------------------
class AFStandardChoiceDialog extends AFUIConnectedDialog<AFStateView, AFStandardChoiceDialogRouteParam> {

  //--------------------------------------------------------------------------------------
  AFStandardChoiceDialog(): super(AFUIScreenID.dialogStandardChoice);

  //--------------------------------------------------------------------------------------
  static AFNavigatePushAction navigatePush({
    required String alertTitle,
    required String alertBody,
    required List<String> buttonTitles,
  }) {
    return AFNavigatePushAction(
      routeParam: AFStandardChoiceDialogRouteParam(
        alertTitle: alertTitle,
        alertBody: alertBody,
        buttonTitles: buttonTitles,
      ),
    );
  }

  //--------------------------------------------------------------------------------------
  @override
  AFStateView createStateView(AFBuildStateViewContext<AFAppStateArea?, AFStandardChoiceDialogRouteParam> context) {
    return AFStateView.unused();
  }

  //--------------------------------------------------------------------------------------
  @override
  Widget buildDialogWithContext(AFUIBuildContext<AFStateView, AFStandardChoiceDialogRouteParam> context) {
    final t = context.t;
    final actions = t.row();
    final buttonTitles = context.p.buttonTitles;
    for(var i = 0; i < buttonTitles.length; i++) {
      final buttonTitle = buttonTitles[i];
      if(i < buttonTitles.length - 1) {
        actions.add(t.childButtonFlatText(
          text: buttonTitle,
          onPressed:  () {
            context.closeDialog(buttonTitle);
          },
        ));
      } else {
        actions.add(t.childButtonPrimaryText(
          text: buttonTitle,
          onPressed:  () {
            context.closeDialog(buttonTitle);
          },
        ));
      }
    }

    // set up the AlertDialog
    return AlertDialog(
      title: t.childText(context.p.alertTitle),
      content: t.childText(context.p.alertBody),
      actions: actions,
    );   
  }
}