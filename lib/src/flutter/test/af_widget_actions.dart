

import 'package:afib/afib_flutter.dart';
import 'package:afib/src/dart/utils/af_exception.dart';
import 'package:afib/src/flutter/core/af_text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';


/// A superclass for actions that either apply data to or extract it from
/// a widget.
abstract class AFWidgetAction {

  bool matches(String actionType, Element element);

}

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

  void throwUnknownAction(String actionType) {
    throw AFException("Error in $runtimeType: The action $actionType is not supported or the targeted widget does not have type $appliesTo");
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
  void apply(String applyType, Element elem, dynamic data);
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
  dynamic extract(String extractType, Element element);

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
  void apply(String applyType, Element elem, dynamic data) {
    final tapOn = elem.widget;
    if(tapOn is FlatButton) {
      tapOn.onPressed();
    } 
  }
}

class AFRaisedButtonAction extends AFApplyTapWidgetAction {

  AFRaisedButtonAction(): super(RaisedButton);

  /// [data] is ignored.
  @override
  void apply(String applyType, Element elem, dynamic data) {
    final tapOn = elem.widget;
    if(tapOn is RaisedButton) {
      tapOn.onPressed();
    } 
  }
}


class AFToggleChoiceChip extends AFApplyTapWidgetAction {
  AFToggleChoiceChip(): super(ChoiceChip);

  /// Note that [data] is ignored, this toggles the chip state.
  @override
  void apply(String applyType, Element element, dynamic data) {
    final widget = element.widget;
    if(widget is ChoiceChip) {
      widget.onSelected(!widget.selected);
    } 
  }

}

class AFApplyTextTextFieldAction extends AFApplySetValueWidgetAction {

  AFApplyTextTextFieldAction(): super(TextField);

  @override
  void apply(String applyType, Element element, dynamic data) {
    final widget = element.widget;
    if(widget is TextField && data is String) {
      widget.onChanged(data);
    } 
  }
}

class AFApplyTextAFTextFieldAction extends AFApplySetValueWidgetAction {

  AFApplyTextAFTextFieldAction(): super(AFTextField);

  @override
  void apply(String applyType, Element elem, dynamic data) {
    final widget = elem.widget;
    if(widget is AFTextField && data is String) {
      widget.onChanged(data);
    } 
  }
}


class AFExtractTextTextAction extends AFExtractPrimaryWidgetAction {

  AFExtractTextTextAction(): super(Text);

  @override
  dynamic extract(String extractType, Element element) {
    final widget = element.widget;
    if(AFExtractWidgetAction.isPrimary(extractType) && widget is Text) {
      return widget.data;
    } else {
      throwUnknownAction(extractType);
    }
    return null;
  }
}

class AFExtractTextTextFieldAction extends AFExtractPrimaryWidgetAction {

  AFExtractTextTextFieldAction(): super(TextField);

  @override
  dynamic extract(String extractType, Element element) {
    final widget = element.widget;
    if(AFExtractWidgetAction.isPrimary(extractType) && widget is TextField) {
      if(widget.controller != null) {
        return widget.controller.value.text;
      } 
    } else {
      throwUnknownAction(extractType);
    }
    return null;
  }
}

class AFExtractTextAFTextFieldAction extends AFExtractPrimaryWidgetAction {

  AFExtractTextAFTextFieldAction(): super(AFTextField);

  @override
  dynamic extract(String extractType, Element element) {
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
    } else {
      throwUnknownAction(extractType);
    }
    return text;
  }
}

class AFSelectableChoiceChip extends AFExtractPrimaryWidgetAction {

  AFSelectableChoiceChip(): super(ChoiceChip);

  @override
  dynamic extract(String extractType, Element element) {
    final widget = element.widget;
    if(AFExtractWidgetAction.isPrimary(extractType) && widget is ChoiceChip) {
      return widget.selected;
    } else {
      throwUnknownAction(extractType);
    }
    return false;
  }

}