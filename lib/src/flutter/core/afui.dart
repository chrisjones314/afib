
import 'dart:async';

import 'package:afib/src/dart/redux/actions/af_navigation_actions.dart';
import 'package:afib/src/dart/utils/af_id.dart';
import 'package:afib/src/dart/utils/af_ui_id.dart';
import 'package:afib/src/flutter/screen/af_connected_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

typedef Future<bool> AFShouldContinueCheck();

/// Some very simple user interface utilities.
class AFUI {

  /// Creates an empty widget list which will contain rows of widgets,
  /// used for clarity
  /// 
  /// ### Example
  ///    final rows = AFUI.column();
  ///    // instead of
  ///    final rows = List<Widget>();
  static List<Widget> column() { return List<Widget>(); }

  /// Creates an empty widget list which will contain rows of widgets,
  /// used for clarity
  /// 
  /// ### Example
  ///    final cols = AFUI.row();
  ///    // instead of
  ///    final cols = List<Widget>();
  static List<Widget> row() { return List<Widget>(); }


  static List<TableRow> tableColumn() { return List<TableRow>(); }

  static Key keyForWID(AFWidgetID wid) {
    if(wid == null) { return null; }
    return Key(wid.code);
  }

  static Widget standardBackButton(AFDispatcher dispatcher, {
    AFWidgetID wid = AFUIID.buttonBack,
    IconData icon = Icons.arrow_back,
    String tooltip = "Back",
    AFShouldContinueCheck shouldContinueCheck,   
  }) {
    return IconButton(
        key: AFUI.keyForWID(wid),      
        icon: Icon(Icons.arrow_back),
        tooltip: "Back",
        onPressed: () async {
          if(shouldContinueCheck == null || await shouldContinueCheck()) {
            dispatcher.dispatch(AFNavigatePopAction(id: wid));
          }
        }
    );
  }

  static Row simpleRow(List<Widget> children, {
   MainAxisAlignment mainAxisAlignment =  MainAxisAlignment.start
  }) {
    return Row(children: children,
      mainAxisAlignment: mainAxisAlignment);
  }

  static Column simpleColumn(List<Widget> children, {
   MainAxisAlignment mainAxisAlignment =  MainAxisAlignment.start
  }) {
    return Column(children: children,
      mainAxisAlignment: mainAxisAlignment);
  }

  static standardOKNoticeDialog({
    @required BuildContext context,
    @required String alertTitle,
    @required Widget alertContent,
    String okButtonText = "OK",
  }) {
    final completer = Completer<void>();

      // set up the buttons
      Widget okButton = FlatButton(
        child: Text(okButtonText),
        onPressed:  () {
          Navigator.of(context).pop(); 
          completer.complete();
        },
      );
      // set up the AlertDialog
      AlertDialog alert = AlertDialog(
        title: Text(alertTitle),
        content: alertContent,
        actions: [
          okButton,
        ],
      );

      // show the dialog
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return alert;
        },
      );
  }


  static AFShouldContinueCheck standardShouldContinueAlertCheck({
    @required BuildContext context,
    @required bool shouldAsk,
    bool isTestContext = false,
    String alertTitle = "Discard changes?",
    String alertQuestion = "You made changes did not click save.  Do you want to discard your changes?",
    String stopButtonText = "Cancel",
    String continueButtonText = "Yes, discard changes"
  }) {
    return () {
        final completer = Completer<bool>();

        if(shouldAsk && !isTestContext) {
          // set up the buttons
          Widget cancelButton = FlatButton(
            child: Text(stopButtonText),
            onPressed:  () {
              Navigator.of(context).pop(); 
              completer.complete(false);
            },
          );
          Widget discardChangesButton = FlatButton(
            child: Text(continueButtonText),
            onPressed:  () {
              Navigator.of(context).pop(); 
              completer.complete(true);
            },
          );

          // set up the AlertDialog
          AlertDialog alert = AlertDialog(
            title: Text(alertTitle),
            content: Text(alertQuestion),
            actions: [
              discardChangesButton,
              cancelButton,
            ],
          );

          // show the dialog
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return alert;
            },
          );
        } else {
          completer.complete(true);
        }
        return completer.future;    
    };
  }
}