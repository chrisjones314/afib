

import 'package:afib/afib_flutter.dart';
import 'package:afib/src/dart/utils/af_exception.dart';
import 'package:afib/src/flutter/core/af_text_field.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';


/// A superclass for actions that either apply data to or extract it from
/// a widget.
abstract class AFWidgetAction {

  bool matches(String actionType, Element element);

}

/// A superclass for actions that apply to a widget based on its runtimeType.
abstract class AFWidgetByTypeAction {
  /// The type of the widget that this can tap on.
  final Type appliesTo;
  final String actionType;
  bool allowMultiple;

  AFWidgetByTypeAction(this.actionType, this.appliesTo, {this.allowMultiple = false});
  Type get appliesToType { return appliesTo; }

  bool matches(String actionT, Element element) {
    final widget = element.widget;
    return (actionType == actionT && widget.runtimeType == this.appliesTo);
  }
}

abstract class AFApplyWidgetAction extends AFWidgetByTypeAction {
  static const applyTap = "apply_tap";
  static const applySetValue = "apply_set_value";

  AFApplyWidgetAction(String actionType, Type appliesTo): super(actionType, appliesTo);

  static bool isTap(String applyType) { return applyType == applyTap; }
  static bool isSetValue(String applyType) { return applyType == applySetValue; }

  /// This applies data to a widget, usually by calling a method
  /// that is part of the widget
  void apply(String applyType, AFWidgetSelector selector, Element elem, dynamic data) {
    if(!applyInternal(applyType, selector, elem, data)) {
      throw AFException("Failed to apply $applyType to selector $selector");
    }
  }

  /// Implementations should override this method, and return false if they fail.
  bool applyInternal(String applyType, AFWidgetSelector selector, Element elem, dynamic data);
}

abstract class AFApplyTapWidgetAction extends AFApplyWidgetAction {
  AFApplyTapWidgetAction(Type appliesTo): super(AFApplyWidgetAction.applyTap, appliesTo);
}

abstract class AFApplySetValueWidgetAction extends AFApplyWidgetAction {
  AFApplySetValueWidgetAction(Type appliesTo): super(AFApplyWidgetAction.applySetValue, appliesTo);
}


abstract class AFExtractWidgetAction extends AFWidgetByTypeAction {
  static const extractPrimary = "extract_primary";

  AFExtractWidgetAction(String actionType, Type appliesTo): super(actionType, appliesTo);

  /// This extracts data from a widget and returns it.
  dynamic extract(String extractType, AFWidgetSelector selector, Element element) {
    final result = extractInternal(extractType, selector, element);
    if(result == null) {
      throw AFException("Could not extract $extractType for $selector");
    }
    return result;
  }

  dynamic extractInternal(String extractType, AFWidgetSelector selector, Element element);

  static bool isPrimary(String extractType) { return extractType == extractPrimary; }

  List<Element> findChildrenWithWidgetType<T>(Element element) {
    final result = List<Element>();
    element.visitChildren((element) { 
      final childWidget = element.widget;
      if(childWidget is T) {
        result.add(element);
      }
    });
    return result;
  }
}

abstract class AFExtractPrimaryWidgetAction extends AFExtractWidgetAction {
  AFExtractPrimaryWidgetAction(Type appliesTo): super(AFExtractWidgetAction.extractPrimary, appliesTo); 
}

class AFFlatButtonAction extends AFApplyTapWidgetAction {

  AFFlatButtonAction(): super(FlatButton);

  /// [data] is ignored.
  @override
  bool applyInternal(String applyType, AFWidgetSelector selector, Element elem, dynamic data) {
    final tapOn = elem.widget;
    if(tapOn is FlatButton) {
      tapOn.onPressed();
      return true;
    } 
    return false;
  }
}

class AFRaisedButtonAction extends AFApplyTapWidgetAction {

  AFRaisedButtonAction(): super(RaisedButton);

  /// [data] is ignored.
  @override
  bool applyInternal(String applyType, AFWidgetSelector selector, Element elem, dynamic data) {
    final tapOn = elem.widget;
    if(tapOn is RaisedButton) {
      tapOn.onPressed();
      return true;
    } 
    return false;
  }
}

class AFRichTextGestureTapAction extends AFApplyTapWidgetAction {

  AFRichTextGestureTapAction(): super(RichText);

  /// [data] is ignored.
  @override
  bool applyInternal(String applyType, AFWidgetSelector selector, Element elem, dynamic data) {
    final tapOn = elem.widget;
    if(!(selector is AFRichTextGestureTapSpecifier)) {
      throw AFException("If you want to tap on text within a RichText widget, you need to specify an AFRichTextGestureTapSpecifier explicitly as your widget specifier.");
    }
    AFRichTextGestureTapSpecifier specifier = selector;
    String containsText = specifier.containsText;   
    if(tapOn is RichText) {
      if(tapIfMatch(tapOn.text, containsText)) {
        return true;            
      }
    } 
    return false;
  }

  bool tapIfMatch(InlineSpan span, String containsText) {
    if(span is TextSpan) {
      if(span.text != null && span.text.contains(containsText) && span.recognizer != null) {
        GestureRecognizer recognizer = span.recognizer;
        if(recognizer is TapGestureRecognizer) {
          recognizer.onTap();
          return true;
        }
      }

      if(span.children == null) {
        return false;
      }

      for(final child in span.children) {
        if(tapIfMatch(child, containsText)) {
          return true;
        }
      }
    }
    return false;
  }
}


class AFToggleChoiceChip extends AFApplyTapWidgetAction {
  AFToggleChoiceChip(): super(ChoiceChip);

  /// Note that [data] is ignored, this toggles the chip state.
  @override
  bool applyInternal(String applyType, AFWidgetSelector selector, Element element, dynamic data) {
    final widget = element.widget;
    if(widget is ChoiceChip) {
      widget.onSelected(!widget.selected);
      return true;
    } 
    return false;
  }

}

class AFApplyCupertinoPicker extends AFApplySetValueWidgetAction {
  AFApplyCupertinoPicker(): super(CupertinoPicker);

  /// Note that [data] is ignored, this toggles the chip state.
  @override
  bool applyInternal(String applyType, AFWidgetSelector selector, Element element, dynamic data) {
    final widget = element.widget;
    if(widget is CupertinoPicker) {
      widget.onSelectedItemChanged(data);
      return true;
    } 
    return false;
  }

}

class AFApplyTextTextFieldAction extends AFApplySetValueWidgetAction {

  AFApplyTextTextFieldAction(): super(TextField);

  @override
  bool applyInternal(String applyType, AFWidgetSelector selector, Element element, dynamic data) {
    final widget = element.widget;
    if(widget is TextField && data is String) {
      widget.onChanged(data);
      return true;
    } 
    return false;
  }
}

class AFApplyTextAFTextFieldAction extends AFApplySetValueWidgetAction {

  AFApplyTextAFTextFieldAction(): super(AFTextField);

  @override
  bool applyInternal(String applyType, AFWidgetSelector selector, Element elem, dynamic data) {
    final widget = elem.widget;
    if(widget is AFTextField && data is String) {
      widget.onChanged(data);
      return true;
    } 
    return false;
  }
}


class AFExtractTextTextAction extends AFExtractPrimaryWidgetAction {

  AFExtractTextTextAction(): super(Text);

  @override
  dynamic extractInternal(String extractType, AFWidgetSelector selector, Element element) {
    final widget = element.widget;
    if(AFExtractWidgetAction.isPrimary(extractType) && widget is Text) {
      return widget.data;
    } 
    return null;
  }
}

class AFExtractTextTextFieldAction extends AFExtractPrimaryWidgetAction {

  AFExtractTextTextFieldAction(): super(TextField);

  @override
  dynamic extractInternal(String extractType, AFWidgetSelector selector, Element element) {
    final widget = element.widget;
    if(AFExtractWidgetAction.isPrimary(extractType) && widget is TextField) {
      if(widget.controller != null) {
        return widget.controller.value.text;
      } 
    } 
    return null;
  }
}

class AFExtractTextAFTextFieldAction extends AFExtractPrimaryWidgetAction {

  AFExtractTextAFTextFieldAction(): super(AFTextField);

  @override
  dynamic extractInternal(String extractType, AFWidgetSelector selector, Element element) {
    String text;
    final widget = element.widget;
    if(AFExtractWidgetAction.isPrimary(extractType) && widget is AFTextField) {
      List<Element> children = this.findChildrenWithWidgetType<TextField>(element);
      if(children.length != 1) {
        throw AFException("AFTextField doesn't have one TextField child?");
      }

      Element elem = children.first;
      final childWidget = elem.widget;
      if(childWidget is TextField) {
        text = childWidget.controller.value.text; 
      }
    } 
    return text;
  }
}

class AFSelectableChoiceChip extends AFExtractPrimaryWidgetAction {

  AFSelectableChoiceChip(): super(ChoiceChip);

  @override
  dynamic extractInternal(String extractType, AFWidgetSelector selector, Element element) {
    final widget = element.widget;
    if(AFExtractWidgetAction.isPrimary(extractType) && widget is ChoiceChip) {
      return widget.selected;
    } 
    return false;
  }

}