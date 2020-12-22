
import 'dart:async';

import 'package:afib/src/dart/redux/actions/af_navigation_actions.dart';
import 'package:afib/src/dart/utils/af_id.dart';
import 'package:afib/src/dart/utils/af_ui_id.dart';
import 'package:afib/src/flutter/screen/af_connected_screen.dart';
import 'package:afib/src/flutter/utils/af_typedefs_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

/// Some very simple user interface utilities.
class AFUI {
  static const shouldStop = 1;
  static const shouldContinue = 2;

  /// Creates an empty widget list which will contain rows of widgets,
  /// used for clarity
  /// 
  /// ### Example
  ///    final rows = AFUI.column();
  ///    // instead of
  ///    final rows = List<Widget>();
  static List<Widget> column() { return <Widget>[]; }

  /// Creates an empty widget list which will contain rows of widgets,
  /// used for clarity
  /// 
  /// ### Example
  ///    final cols = AFUI.row();
  ///    // instead of
  ///    final cols = List<Widget>();
  static List<Widget> row() { return <Widget>[]; }


  static List<TableRow> tableColumn() { return <TableRow>[]; }

  static Key keyForWID(AFWidgetID wid) {
    if(wid == null) { return null; }
    return Key(wid.code);
  }

  static Widget standardBackButton(AFDispatcher dispatcher, {
    AFWidgetID wid = AFUIWidgetID.buttonBack,
    IconData icon = Icons.arrow_back,
    String tooltip = "Back",
    AFShouldContinueCheckDelegateObsolete shouldContinueCheck,   
  }) {
    return IconButton(
        key: AFUI.keyForWID(wid),      
        icon: Icon(Icons.arrow_back),
        tooltip: "Back",
        onPressed: () async {
          if(shouldContinueCheck == null || await shouldContinueCheck() == shouldContinue) {
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

  static void standardOKNoticeDialog({
    @required AFBuildContext context,
    @required String alertTitle,
    @required Widget alertContent,
    String okButtonText = "OK",
  }) {
      // set up the buttons
      Widget okButton = FlatButton(
        child: Text(okButtonText),
        onPressed:  () {
          context.dispatch(AFNavigatePopNavigatorOnlyAction());
        },
      );
      // set up the AlertDialog
      final alert = AlertDialog(
        title: Text(alertTitle),
        content: alertContent,
        actions: [
          okButton,
        ],
      );

      // show the dialog
      showDialog(
        context: context.c,
        builder: (context) {
          return alert;
        },
      );
  }


  static AFShouldContinueCheckDelegateObsolete standardShouldContinueAlertCheck({
    @required AFBuildContext context,
    @required bool shouldAsk,
    bool isTestContext = false,
    String alertTitle = "Discard changes?",
    String alertQuestion = "You made changes did not click save.  Do you want to discard your changes?",
    String stopButtonText = "Cancel",
    String continueButtonText = "Yes, discard changes"
  }) {
    return () {
        final completer = Completer<int>();

        if(shouldAsk && !isTestContext) {
          // set up the buttons
          Widget cancelButton = FlatButton(
            child: Text(stopButtonText),
            onPressed:  () {
              context.dispatch(AFNavigatePopNavigatorOnlyAction());
              completer.complete(AFUI.shouldStop);
            },
          );
          Widget discardChangesButton = FlatButton(
            child: Text(continueButtonText),
            onPressed:  () {
              context.dispatch(AFNavigatePopNavigatorOnlyAction());
              completer.complete(AFUI.shouldContinue);
            },
          );

          // set up the AlertDialog
          final alert = AlertDialog(
            title: Text(alertTitle),
            content: Text(alertQuestion),
            actions: [
              discardChangesButton,
              cancelButton,
            ],
          );

          // show the dialog
          showDialog(
            context: context.c,
            builder: (context) {
              return alert;
            },
          );
        } else {
          completer.complete(AFUI.shouldContinue);
        }
        return completer.future;    
    };
  }
}