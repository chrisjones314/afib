

import 'package:afib/src/dart/redux/state/models/af_theme_state.dart';
import 'package:afib/src/dart/utils/af_id.dart';
import 'package:flutter/material.dart';

class AFUIWidgetListWrapper extends StatelessWidget {
  final List<Widget> children;
  final Widget child;

  AFUIWidgetListWrapper({
    AFWidgetID? wid,
    required this.children,
    required this.child,
  }): super(key: AFFunctionalTheme.keyForWIDStatic(wid));

  @override
  Widget build(BuildContext context) {
    return child;
  }

  
}