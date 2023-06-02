

//--------------------------------------------------------------------------------------
import 'package:afib/afib_command.dart';
import 'package:afib/afib_flutter.dart';
import 'package:afib/src/flutter/ui/afui_connected_base.dart';
import 'package:afib/src/flutter/ui/stateviews/afui_default_state_view.dart';
import 'package:flutter/material.dart';

//--------------------------------------------------------------------------------------
class AFUITextFieldSPI extends AFUIWidgetSPI<AFUIDefaultStateView, AFRouteParamUnused> {
  AFUITextFieldSPI(AFBuildContext<AFUIDefaultStateView, AFRouteParamUnused> context, AFStandardSPIData standard): super(context, standard);
factory AFUITextFieldSPI.create(AFBuildContext<AFUIDefaultStateView, AFRouteParamUnused> context, AFStandardSPIData standard) {
    return AFUITextFieldSPI(context, standard);
  }

}

//--------------------------------------------------------------------------------------
@immutable
class AFUITextField extends StatelessWidget {
  static const errOnlyOneTextOwner = "You should pass in only one of controllers, controller or parentParam";

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
  final int? minLines;
  final int maxLines;
  final Color? cursorColor;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final String Function(String)? normalizeValue;
  final AFTextEditingController? controller;
  final AFTextEditingControllers? controllers;
  final AFRouteParamWithFlutterState? parentParam;

  
  //--------------------------------------------------------------------------------------
  AFUITextField({
    required this.screenId,
    required this.wid,
    String? expectedText,
    this.controller,
    this.controllers,
    this.parentParam,
    this.enabled,
    this.obscureText = false,
    this.autofocus = false,
    this.decoration,
    this.autocorrect = true,
    this.textAlign = TextAlign.start,
    this.keyboardType,
    this.focusNode,
    this.style,
    this.minLines,
    this.maxLines = 1,
    this.cursorColor,
    this.onSubmitted,
    this.onChanged,
    this.normalizeValue,
  }) {
    var textController;
    if(controller != null) {
      assert(controllers == null && parentParam == null, errOnlyOneTextOwner);
      textController = controller;
    } else if(controllers != null) {
      assert(controller == null && parentParam == null, errOnlyOneTextOwner);
      textController = controllers?.access(wid);
    } else if(parentParam != null) {
      final flutterState = parentParam?.flutterState;
      assert(flutterState != null, "If you pass in a parent param, it must be one of the AF...RouteParamWithFlutterState variants");
      assert(controller == null && controllers == null, errOnlyOneTextOwner);
      textController = flutterState?.textControllers?.access(wid);
    } else {
      assert(false, "You must pass in controller, or controllers, or parentParam");
    }
    
    assert(textController != null, "You must register the text controller for $wid in your route parameter using AFTextEditingControllersHolder.createN or createOne");
    assert(textController?.controller != null);
    if(expectedText != null) {
      assert(textController?.text == expectedText, '''The text value in the text controller was different from the value you passed into 
  childTextField was different from the value in the text controller for $wid ('$expectedText' != '${textController?.text}').  This can happen if you
  normalize or change the value of the text field in your code.  It can also happen in state testing, when you call methods that update the 
  value that would be in a text field.  In either case, you can resolve the problem by calling AFTextControllersHolder.update in the method
  of your SPI that is called with the normalized value, or that is called from the test.  That method is idempotent, it does nothing if called
  with the value that is already in the text field.
  ''');
    }

  }

  AFTextEditingController get effectiveController {
    var result = controller;
    if(result == null) {
      result = controllers?.access(wid);
    }
    if(result == null) {
      result = parentParam?.flutterState?.textControllers?.access(wid);
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
      minLines: minLines,
      maxLines: maxLines,
      decoration: decoration,
      focusNode: focusNode,
      onSubmitted: onSubmitted,
      cursorColor: cursorColor,
    );
  }

}