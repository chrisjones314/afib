
import 'package:afib/src/flutter/utils/af_bottom_popup_theme.dart';
import 'package:flutter/widgets.dart';

class AFBottomPopupLayout extends SingleChildLayoutDelegate {
  final double progress;
  final int itemCount;
  final AFBottomPopupTheme theme;
  final double bottomPadding;

  AFBottomPopupLayout(this.progress, this.theme,
      {this.itemCount, this.bottomPadding = 0});


  @override
  BoxConstraints getConstraintsForChild(BoxConstraints constraints) {
    double maxHeight = theme.containerHeight;
    if (theme.showTitleActions) {
      maxHeight += theme.titleHeight;
    }

    return new BoxConstraints(
        minWidth: constraints.maxWidth,
        maxWidth: constraints.maxWidth,
        minHeight: 0.0,
        maxHeight: maxHeight + bottomPadding);
  }

  @override
  Offset getPositionForChild(Size size, Size childSize) {
    double height = size.height - childSize.height * progress;
    return new Offset(0.0, height);
  }

  @override
  bool shouldRelayout(AFBottomPopupLayout oldDelegate) {
    return progress != oldDelegate.progress;
  }
}
