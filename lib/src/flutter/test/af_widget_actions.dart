

import 'package:afib/src/flutter/core/af_text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';


/// Just a untility to encapsulate how to tap on a particular type of widget.
abstract class AFWidgetByTypeAction {
  /// The type of the widget that this can tap on.
  Type appliesTo;
  bool allowMultiple;

  AFWidgetByTypeAction(this.appliesTo, {this.allowMultiple = false});
  Type get appliesToType { return appliesTo; }
}

abstract class AFApplyWidgetAction extends AFWidgetByTypeAction {
  AFApplyWidgetAction(Type appliesTo): super(appliesTo);

  /// This 'taps on' the widget by calling the method that handles taps. 
  /// For example, for a FlatButton this is onPressed(), while for a 
  /// ChoiceChip this is onSelected.
  void apply(Widget widget, dynamic data);
}

abstract class AFExtractWidgetAction extends AFWidgetByTypeAction {
  AFExtractWidgetAction(Type appliesTo): super(appliesTo);

  /// This 'taps on' the widget by calling the method that handles taps. 
  /// For example, for a FlatButton this is onPressed(), while for a 
  /// ChoiceChip this is onSelected.
  dynamic extract(Element element, Widget widget);
}

class AFTapFlatButton extends AFApplyWidgetAction {

  AFTapFlatButton(): super(FlatButton);

  /// [data] is ignored.
  @override
  void apply(Widget tapOn, dynamic data) {
    if(tapOn is FlatButton) {
      tapOn.onPressed();
    }
  }
}

class AFToggleChoiceChip extends AFApplyWidgetAction {
  AFToggleChoiceChip(): super(ChoiceChip);

  /// Note that [data] is ignored, this toggles the chip state.
  @override
  void apply(Widget tapOn, dynamic data) {
    if(tapOn is ChoiceChip) {
      tapOn.onSelected(!tapOn.selected);
    }
  }

}

class AFApplyTextTextFieldAction extends AFApplyWidgetAction {

  AFApplyTextTextFieldAction(): super(TextField);

  @override
  void apply(Widget widget, dynamic data) {
    if(widget is TextField && data is String) {
      widget.onChanged(data);
    }
  }
}

class AFApplyTextAFTextFieldAction extends AFApplyWidgetAction {

  AFApplyTextAFTextFieldAction(): super(AFTextField);

  @override
  void apply(Widget widget, dynamic data) {
    if(widget is AFTextField && data is String) {
      widget.onChanged(data);
    }
  }
}


class AFExtractTextTextAction extends AFExtractWidgetAction {

  AFExtractTextTextAction(): super(Text);

  @override
  dynamic extract(Element element, Widget widget) {
    if(widget is Text) {
      return widget.data;
    }
    return null;
  }
}

class AFExtractTextTextFieldAction extends AFExtractWidgetAction {

  AFExtractTextTextFieldAction(): super(TextField);

  @override
  dynamic extract(Element element, Widget widget) {
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
  dynamic extract(Element element, Widget widget) {
    String text;
    if(widget is AFTextField) {
      // find text field child.
      element.visitChildren((element) { 
        final childWidget = element.widget;
        if(childWidget is TextField) {
          text = childWidget.controller.value.text; 
        }
      });
    }
    return text;
  }
}

class AFSelectableChoiceChip extends AFExtractWidgetAction {

  AFSelectableChoiceChip(): super(ChoiceChip);

  @override
  dynamic extract(Element element, Widget widget) {
    if(widget is ChoiceChip) {
      return widget.selected;
    }
    return false;
  }

}