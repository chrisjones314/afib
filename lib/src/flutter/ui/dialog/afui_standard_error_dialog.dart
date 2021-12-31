
/*
import 'package:afib/afib_flutter.dart';
import 'package:afib/src/dart/redux/state/stateviews/afui_prototype_state_view.dart';
import 'package:afib/src/flutter/ui/afui_connected_base.dart';
import 'package:flutter/material.dart';

enum AFAlertDialogType {
  info,
  warning,
  error,
}

//--------------------------------------------------------------------------------------
@immutable
class AFUIStandardAlertDialogRouteParam extends AFRouteParam {
  final String message;

  //--------------------------------------------------------------------------------------
  AFUIStandardAlertDialogRouteParam({
    required this.message
  }): super(id: AFUIScreenID.dialogStandardAlert);

  //--------------------------------------------------------------------------------------
  factory AFUIStandardAlertDialogRouteParam.createOncePerScreen(String message) {
    return AFUIStandardAlertDialogRouteParam(message: message);
  }
}

//--------------------------------------------------------------------------------------
class AFUIStandardAlertDialog extends AFUIDefaultConnectedDialog<AFUIStandardAlertDialogRouteParam> {

  //--------------------------------------------------------------------------------------
  AFUIStandardAlertDialog(): super(AFUIScreenID.dialogStandardAlert);

  //--------------------------------------------------------------------------------------
  static AFNavigatePushAction navigatePush(String message) {
    return AFNavigatePushAction(
      routeParam: AFUIStandardAlertDialogRouteParam.createOncePerScreen(message)
    );
  }

  //--------------------------------------------------------------------------------------
  @override
  Dialog buildDialogWithContext(AFUIBuildContext<AFUIPrototypeStateView, AFUIStandardAlertDialogRouteParam> context) {
    final t = context.t;
    final rows = t.column();
    
    rows.add(Icon(Icons.report,
      size: 80.0,
      color: Colors.red,
    ));

    rows.add(t.childText("An unexpected error occcured, please wait a few minutes and try again.", style: t.styleOnCard.bodyText1));
    rows.add(t.childText("If the error persists, please report this message to customer support: '${context.p.message}'."));

    final buttonStyle = TextButton.styleFrom(
      primary: t.colorPrimary,
      textStyle: TextStyle(color: t.colorOnPrimary),
    );

    rows.add(TextButton(
      key: t.keyForWID(AFUIWidgetID.buttonCancel),
      style: buttonStyle,
      child: t.childText("Close"),
      onPressed: () {
        context.closeDialog(context.p);
      },
    ));

    return Dialog(
      child: Container(
        height: 300,
        margin: t.margin.a.s5,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: rows
        )
      )
    );
  }


}
*/