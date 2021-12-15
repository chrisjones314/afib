import 'package:afib/afib_flutter.dart';
import 'package:afib/src/dart/redux/state/stateviews/afui_flexible_state_view.dart';
import 'package:afib/src/flutter/ui/afui_connected_base.dart';
import 'package:flutter/material.dart';

//--------------------------------------------------------------------------------------
@immutable
class AFUIStandardChoiceDialogRouteParam extends AFRouteParam {
  final String alertBody;
  final String alertTitle;
  final List<String> buttonTitles;

  //--------------------------------------------------------------------------------------
  AFUIStandardChoiceDialogRouteParam({
    required this.alertBody,
    required this.alertTitle,
    required this.buttonTitles,
  }): super(id: AFUIScreenID.dialogStandardChoice);
}

//--------------------------------------------------------------------------------------
class AFUIStandardChoiceDialog extends AFUIConnectedDialog<AFUIStandardChoiceDialogRouteParam> {

  //--------------------------------------------------------------------------------------
  AFUIStandardChoiceDialog(): super(AFUIScreenID.dialogStandardChoice);

  //--------------------------------------------------------------------------------------
  static AFNavigatePushAction navigatePush({
    required String alertTitle,
    required String alertBody,
    required List<String> buttonTitles,
  }) {
    return AFNavigatePushAction(
      routeParam: AFUIStandardChoiceDialogRouteParam(
        alertTitle: alertTitle,
        alertBody: alertBody,
        buttonTitles: buttonTitles,
      ),
    );
  }

  //--------------------------------------------------------------------------------------
  @override
  Widget buildDialogWithContext(AFUIBuildContext<AFUIFlexibleStateView, AFUIStandardChoiceDialogRouteParam> context) {
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