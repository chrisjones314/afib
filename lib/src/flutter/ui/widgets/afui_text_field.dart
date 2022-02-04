

//--------------------------------------------------------------------------------------
import 'package:afib/afib_flutter.dart';
import 'package:afib/src/flutter/ui/afui_connected_base.dart';
import 'package:afib/src/flutter/ui/stateviews/afui_default_state_view.dart';
import 'package:afib/src/flutter/ui/theme/afui_default_theme.dart';
import 'package:flutter/material.dart';

//--------------------------------------------------------------------------------------
class AFUITextFieldSPI extends AFUIWidgetSPI<AFUIDefaultStateView, AFRouteParamUnused> {
  AFUITextFieldSPI(AFBuildContext<AFUIDefaultStateView, AFRouteParamUnused> context, AFScreenID screenId, AFID wid, AFUIDefaultTheme theme, AFWidgetParamSource paramSource): super(context, screenId, wid, paramSource, theme);
  factory AFUITextFieldSPI.create(AFBuildContext<AFUIDefaultStateView, AFRouteParamUnused> ctx, AFUIDefaultTheme theme, AFScreenID screenId, AFID wid, AFWidgetParamSource paramSource) {
    return AFUITextFieldSPI(ctx, screenId, wid, theme, paramSource);
  }

}

//--------------------------------------------------------------------------------------
@immutable
class AFUITextField extends StatelessWidget {
  /*
  static final config = AFUIDefaultWidgetConfig<AFUITextFieldSPI, AFRouteParamUnused> (
    spiCreator: AFUITextFieldSPI.create
  );
  */
  final AFScreenID screenId;
  final AFWidgetID wid;
  final bool? enabled;
  final bool obscureText;
  final bool autofocus;
  final InputDecoration? decoration;
  final bool autocorrect;
  final TextAlign textAlign;
  final TextInputType? keyboardType;
  final FocusNode? focusNode;
  final TextStyle? style;
  final Color? cursorColor;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final String Function(String)? normalizeValue;
  final AFTextEditingController? controller;
  final AFTextEditingControllers? controllers;

  
  //--------------------------------------------------------------------------------------
  AFUITextField({
    required this.screenId,
    required this.wid,
    this.controller,
    this.controllers,
    this.enabled,
    this.obscureText = false,
    this.autofocus = false,
    this.decoration,
    this.autocorrect = true,
    this.textAlign = TextAlign.start,
    this.keyboardType,
    this.focusNode,
    this.style,
    this.cursorColor,
    this.onSubmitted,
    this.onChanged,
    this.normalizeValue,
  }) {
    assert(controller != null || controllers != null, "You must specify either controller or controllers");
    assert(controller == null || controllers == null, "You should not specify both controller and controllers, its ambigous");
  }

  AFTextEditingController get effectiveController {
    var result = controller;
    if(result == null) {
      result = controllers?.access(wid);
    }
    if(result == null) {
      throw AFException("Missing text controller for $wid");
    }
    return result;
  }

  //--------------------------------------------------------------------------------------
  @override
  Widget build(BuildContext c) {
    final cont = effectiveController;
    return TextField(
      key: AFFunctionalTheme.keyForWIDStatic(wid),
      enabled: enabled,
      style: style,
      controller: cont.controller,
      onChanged: (val) {
        var normalized = val;
        final normalize = normalizeValue;
        if(normalize != null) {
          normalized = normalize(val);
        }
        if(val != normalized) {
          cont.update(normalized);
        }
        final oc = onChanged;
        if(oc != null) {
          oc(normalized);
        }
      },        
      keyboardType: keyboardType,
      obscureText: obscureText,
      autocorrect: autocorrect,
      autofocus: autofocus,
      textAlign: textAlign,
      decoration: decoration,
      focusNode: focusNode,
      onSubmitted: onSubmitted,
      cursorColor: cursorColor,
    );
  }

}