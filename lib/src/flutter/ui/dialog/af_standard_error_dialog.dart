
import 'package:afib/afib_flutter.dart';
import 'package:afib/src/flutter/ui/af_prototype_base.dart';
import 'package:flutter/material.dart';

//--------------------------------------------------------------------------------------
@immutable
class AFStandardErrorDialogRouteParam extends AFRouteParam {
  final String message;

  //--------------------------------------------------------------------------------------
  AFStandardErrorDialogRouteParam({this.message});

  //--------------------------------------------------------------------------------------
  factory AFStandardErrorDialogRouteParam.createOncePerScreen(String message) {
    return AFStandardErrorDialogRouteParam(message: message);
  }
}

//--------------------------------------------------------------------------------------
class AFStandardErrorDialog extends AFProtoConnectedDialog<AFStateView, AFStandardErrorDialogRouteParam> {

  //--------------------------------------------------------------------------------------
  AFStandardErrorDialog(): super(AFUIScreenID.dialogStandardError);

  //--------------------------------------------------------------------------------------
  static AFNavigateAction navigatePush(String message) {
    return AFNavigatePushAction(
      screen: AFUIScreenID.dialogStandardError,
      param: AFStandardErrorDialogRouteParam.createOncePerScreen(message)
    );
  }

  //--------------------------------------------------------------------------------------
  @override
  AFStateView createStateView(AFAppStateArea state, AFStandardErrorDialogRouteParam param) {
    return AFStateView.unused();
  }

  //--------------------------------------------------------------------------------------
  @override
  Dialog buildDialogWithContext(AFProtoBuildContext<AFStateView, AFStandardErrorDialogRouteParam> context) {
    final t = context.t;
    final rows = t.column();
    
    rows.add(Icon(Icons.report,
      size: 80.0,
      color: Colors.red,
    
    ));

    rows.add(t.childText("An unexpected error occcured, please wait a few minutes and try again.", style: t.styleOnCard.bodyText1));
    rows.add(t.childText("If the error persists, please report this message to customer support: '${context.p.message}'."));

    rows.add(FlatButton(
      key: t.keyForWID(AFUIWidgetID.buttonCancel),
      child: t.childText("Close"),
      color: t.colorPrimary,
      textColor: t.colorOnPrimary,
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