

import 'package:afib/src/dart/utils/af_exception.dart';
import 'package:afib/src/flutter/core/af_text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';


/// A superclass for actions that either apply data to or extract it from
/// a widget.
abstract class AFWidgetAction {

  bool matches(Element element);

}

abstract class AFWidgetByTypeAction {
  /// The type of the widget that this can tap on.
  Type appliesTo;
  bool allowMultiple;

  AFWidgetByTypeAction(this.appliesTo, {this.allowMultiple = false});
  Type get appliesToType { return appliesTo; }

  bool matches(Element element) {
    final widget = element.widget;
    return (widget.runtimeType == this.appliesTo);
  }

  void throwUnknownAction(String actionType) {
    throw AFException("Error in $runtimeType: The action $actionType is not supported or the targeted widget does not have type $appliesTo");
  }
}

abstract class AFApplyWidgetAction extends AFWidgetByTypeAction {
  static const applyTap = "apply_tap";
  static const applySetValue = "apply_set_value";

  AFApplyWidgetAction(Type appliesTo): super(appliesTo);

  static bool isTap(String applyType) { return applyType == applyTap; }
  static bool isSetValue(String applyType) { return applyType == applySetValue; }

  /// This applies data to a widget, usually by calling a method
  /// that is part of the widget
  void apply(String applyType, Element elem, dynamic data);
}

abstract class AFExtractWidgetAction extends AFWidgetByTypeAction {
  AFExtractWidgetAction(Type appliesTo): super(appliesTo);

  /// This extracts data from a widget and returns it.
  dynamic extract(Element element);



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

class AFFlatButtonAction extends AFApplyWidgetAction {

  AFFlatButtonAction(): super(FlatButton);

  /// [data] is ignored.
  @override
  void apply(String applyType, Element elem, dynamic data) {
    final tapOn = elem.widget;
    if(AFApplyWidgetAction.isTap(applyType) && tapOn is FlatButton) {
      tapOn.onPressed();
    } else {
      throwUnknownAction(applyType);
    }
  }
}

class AFToggleChoiceChip extends AFApplyWidgetAction {
  AFToggleChoiceChip(): super(ChoiceChip);

  /// Note that [data] is ignored, this toggles the chip state.
  @override
  void apply(String applyType, Element element, dynamic data) {
    final widget = element.widget;
    if(AFApplyWidgetAction.isTap(applyType) && widget is ChoiceChip) {
      widget.onSelected(!widget.selected);
    } else {
      throwUnknownAction(applyType);
    }
  }

}

class AFApplyTextTextFieldAction extends AFApplyWidgetAction {

  AFApplyTextTextFieldAction(): super(TextField);

  @override
  void apply(String applyType, Element element, dynamic data) {
    final widget = element.widget;
    if(AFApplyWidgetAction.isSetValue(applyType) && widget is TextField && data is String) {
      widget.onChanged(data);
    } else {
      throwUnknownAction(applyType);
    }
  }
}

class AFApplyTextAFTextFieldAction extends AFApplyWidgetAction {

  AFApplyTextAFTextFieldAction(): super(AFTextField);

  @override
  void apply(String applyType, Element elem, dynamic data) {
    final widget = elem.widget;
    if(AFApplyWidgetAction.isSetValue(applyType) && widget is AFTextField && data is String) {
      widget.onChanged(data);
    } else {
      throwUnknownAction(applyType);
    }
  }
}


class AFExtractTextTextAction extends AFExtractWidgetAction {

  AFExtractTextTextAction(): super(Text);

  @override
  dynamic extract(Element element) {
    final widget = element.widget;
    if(widget is Text) {
      return widget.data;
    }
    return null;
  }
}

class AFExtractTextTextFieldAction extends AFExtractWidgetAction {

  AFExtractTextTextFieldAction(): super(TextField);

  @override
  dynamic extract(Element element) {
    final widget = element.widget;
    if(widget is TextField) {
      if(widget.controller != null) {
        return widget.controller.value.text;
      } 
    }
    return null;
  }
}

class AFExtractTextAFTextFieldAction extends AFExtractWidgetAction {

  AFExtractTextAFTextFieldAction(): super(AFTextField);

  @override
  dynamic extract(Element element) {
    String text;
    final widget = element.widget;
    if(widget is AFTextField) {
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

class AFSelectableChoiceChip extends AFExtractWidgetAction {

  AFSelectableChoiceChip(): super(ChoiceChip);

  @override
  dynamic extract(Element element) {
    final widget = element.widget;
    if(widget is ChoiceChip) {
      return widget.selected;
    }
    return false;
  }

}