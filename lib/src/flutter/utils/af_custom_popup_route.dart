//--------------------------------------------------------------------------------------
import 'package:afib/src/flutter/utils/af_bottom_popup_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

typedef Widget AFRouteWidgetBuilder(BuildContext ctx, AFCustomPopupRoute route);

class AFCustomPopupRoute<T> extends PopupRoute<T> {

  //final FilterChangedCallback onChanged;
  //final FilterChangedCallback onConfirm;
  final AFBottomPopupTheme theme;
  final AFRouteWidgetBuilder childBuilder;
  //final DFSearchRouteParam param;

  AFCustomPopupRoute({
    //this.onChanged,
    //this.onConfirm,
    //this.param,
    @required this.barrierLabel,
    @required this.childBuilder,
    @required this.theme,
    RouteSettings settings,
  })  : super(settings: settings);


  @override
  Duration get transitionDuration => const Duration(milliseconds: 200);

  @override
  bool get barrierDismissible => true;

  @override
  final String barrierLabel;

  @override
  Color get barrierColor => Colors.black54;

  AnimationController _animationController;

  @override
  AnimationController createAnimationController() {
    assert(_animationController == null);
    _animationController =
        BottomSheet.createAnimationController(navigator.overlay);
    return _animationController;
  }

  @override
  Widget buildPage(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation) {

    Widget bottomSheet = new MediaQuery.removePadding(
      context: context,
      removeTop: true,
      child: childBuilder(context, this),
    );
    ThemeData inheritTheme = Theme.of(context, shadowThemeOnly: true);
    if (inheritTheme != null) {
      bottomSheet = new Theme(data: inheritTheme, child: bottomSheet);
    }
    return bottomSheet;
  }
}

