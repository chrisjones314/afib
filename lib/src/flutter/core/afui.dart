
import 'package:afib/src/dart/redux/actions/af_navigation_actions.dart';
import 'package:afib/src/dart/utils/af_id.dart';
import 'package:afib/src/dart/utils/af_ui_id.dart';
import 'package:afib/src/flutter/screen/af_connected_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

/// Some very simple user interface utilities.
class AFUI {

  /// Creates an empty widget list which will contain rows of widgets,
  /// used for clarity
  /// 
  /// ### Example
  ///    final col = AFUI.column();
  ///    // instead of
  ///    final col = List<Widget>();
  static List<Widget> column() { return List<Widget>(); }
  

  /// Creates an empty widget list which will contain rows of widgets,
  /// used for clarity
  /// 
  /// ### Example
  ///    final row = AFUI.row();
  ///    // instead of
  ///    final row = List<Widget>();
  static List<Widget> row() { return List<Widget>(); }

  static Key testKey(AFWidgetID wid) {
    if(wid == null) { return null; }
    return Key(wid.code);
  }

  static Key prodKey(AFWidgetID wid) {
    return Key(wid.code);
  }

  static Key key3(String a, String b, String c) {
    final full = a + "_" + b + "_" + c;
    return Key(full);
  }

  static Widget standardBackButton(AFDispatcher dispatcher, {
    AFWidgetID wid = AFUIID.buttonBack,
    IconData icon = Icons.arrow_back,
    String tooltip = "Back"
  }) {
    return IconButton(
        key: AFUI.prodKey(wid),      
        icon: Icon(Icons.arrow_back),
        tooltip: "Back",
        onPressed: () {
          dispatcher.dispatch(AFNavigatePopAction(id: wid));
        }
    );
  }
}