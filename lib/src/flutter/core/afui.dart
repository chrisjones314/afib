
import 'package:afib/src/dart/utils/af_id.dart';
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
    return Key(wid.code);
  }


}