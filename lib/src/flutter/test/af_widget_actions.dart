import 'package:afib/afib_command.dart';
import 'package:afib/afib_flutter.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';


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
  static const applyDismiss = "apply_dismiss";

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

abstract class AFScrollTracker {
  final AFWidgetSelector selector;
  final Element element;

  AFScrollTracker(this.selector, this.element);
  bool canScrollMore();
  Future<void> scrollMore();
}

abstract class AFScrollerAction {
  bool matches(Element elem);
  AFScrollTracker createScrollTracker(AFWidgetSelector selector, Element element);
}

class AFScrollableScrollTracker extends AFScrollTracker {

  AFScrollableScrollTracker(AFWidgetSelector selector, Element element): super(selector, element);
  
  bool canScrollMore() {
    final controller = _controller();
    assert(controller != null);
    if(controller != null) {
      return controller.offset < controller.position.maxScrollExtent;
    }
    return false;
  }

  Future<void> scrollMore() async {
    if(!AFibD.config.isWidgetTesterContext) {
      final controller = _controller();
      assert(controller != null);
      if(controller != null) {
        var newPos = controller.offset +  200;
        if(newPos > controller.position.maxScrollExtent) {
          newPos = controller.position.maxScrollExtent;
        }
        await controller.animateTo(newPos, duration: Duration(milliseconds: 500), curve: Curves.ease);
      }
    }
  }

  ScrollController? _controller() {
    if(element.widget is Scrollable) {
      final s = element.widget as Scrollable;
      return s.controller;
    }
    return null;
  }
}

class AFScrollableScrollerAction extends AFScrollerAction {
  bool matches(Element elem) {
    final widget = elem.widget;
    return widget is Scrollable;
  }

  AFScrollTracker createScrollTracker(AFWidgetSelector selector, Element element) {
    return AFScrollableScrollTracker(selector, element);
  }
}



abstract class AFApplyTapWidgetAction extends AFApplyWidgetAction {
  AFApplyTapWidgetAction(Type appliesTo): super(AFApplyWidgetAction.applyTap, appliesTo);
}

abstract class AFApplySetValueWidgetAction extends AFApplyWidgetAction {
  AFApplySetValueWidgetAction(Type appliesTo): super(AFApplyWidgetAction.applySetValue, appliesTo);
}

abstract class AFApplyDismissWidgetAction extends AFApplyWidgetAction {
  AFApplyDismissWidgetAction(Type appliesTo): super(AFApplyWidgetAction.applyDismiss, appliesTo);
}


abstract class AFExtractWidgetAction extends AFWidgetByTypeAction {
  static const extractPrimary = "extract_primary";
  static const extractChildren = "extract_children";

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
  static bool isChildren(String extractType) { return extractType == extractChildren; }

  List<Element> findChildrenWithWidgetType<T>(Element element) {
    final result = <Element>[];
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

abstract class AFExtractChildrenWidgetAction extends AFExtractWidgetAction {
  AFExtractChildrenWidgetAction(Type appliesTo): super(AFExtractWidgetAction.extractChildren, appliesTo); 
}

class AFTextButtonAction extends AFApplyTapWidgetAction {

  AFTextButtonAction(): super(TextButton);

  /// [data] is ignored.
  @override
  bool applyInternal(String applyType, AFWidgetSelector selector, Element elem, dynamic data) {
    final tapOn = elem.widget;
    if(tapOn is TextButton && tapOn.onPressed != null) {
      tapOn.onPressed?.call();
      return true;
    } 
    return false;
  }
}

class AFOutlinedButtonAction extends AFApplyTapWidgetAction {

  AFOutlinedButtonAction(): super(OutlinedButton);

  /// [data] is ignored.
  @override
  bool applyInternal(String applyType, AFWidgetSelector selector, Element elem, dynamic data) {
    final tapOn = elem.widget;
    if(tapOn is OutlinedButton) {
      tapOn.onPressed?.call();
      return true;
    } 
    return false;
  }
}



class AFSwitchTapAction extends AFApplyTapWidgetAction {

  AFSwitchTapAction(): super(Switch);

  /// [data] is ignored.
  @override
  bool applyInternal(String applyType, AFWidgetSelector selector, Element elem, dynamic data) {
    final tapOn = elem.widget;
    if(tapOn is Switch) {
      tapOn.onChanged?.call(!tapOn.value);
      return true;
    } 
    return false;
  }
}


class AFCheckboxTapAction extends AFApplyTapWidgetAction {

  AFCheckboxTapAction(): super(Checkbox);

  /// [data] is ignored.
  @override
  bool applyInternal(String applyType, AFWidgetSelector selector, Element elem, dynamic data) {
    final tapOn = elem.widget;
    if(tapOn is Checkbox) {
      final value = tapOn.value ?? false;
      tapOn.onChanged?.call(!value);
      return true;
    } 
    return false;
  }
}


class AFListTileTapAction extends AFApplyTapWidgetAction {

  AFListTileTapAction(): super(ListTile);

  /// [data] is ignored.
  @override
  bool applyInternal(String applyType, AFWidgetSelector selector, Element elem, dynamic data) {
    final tapOn = elem.widget;
    if(tapOn is ListTile) {
      tapOn.onTap?.call();
      return true;
    } 
    return false;
  }
}

class AFDismissibleSwipeAction extends AFApplyDismissWidgetAction {

  AFDismissibleSwipeAction(): super(Dismissible);

  /// [data] is ignored.
  @override
  bool applyInternal(String applyType, AFWidgetSelector selector, Element elem, dynamic data) {
    final swipeOn = elem.widget;
    if(swipeOn is Dismissible) {
      swipeOn.onDismissed?.call(swipeOn.direction);
      return true;
    } 
    return false;
  }
}

class AFGestureDetectorTapAction extends AFApplyTapWidgetAction {

  AFGestureDetectorTapAction(): super(GestureDetector);

  /// [data] is ignored.
  @override
  bool applyInternal(String applyType, AFWidgetSelector selector, Element elem, dynamic data) {
    final tapOn = elem.widget;
    if(tapOn is GestureDetector) {
      tapOn.onTap?.call();
      return true;
    } 
    return false;
  }
}

class AFIconButtonAction extends AFApplyTapWidgetAction {

  AFIconButtonAction(): super(IconButton);

  /// [data] is ignored.
  @override
  bool applyInternal(String applyType, AFWidgetSelector selector, Element elem, dynamic data) {
    final tapOn = elem.widget;
    if(tapOn is IconButton) {
      tapOn.onPressed?.call();
      return true;
    } 
    return false;
  }
}

class AFRaisedButtonAction extends AFApplyTapWidgetAction {

  AFRaisedButtonAction(): super(ElevatedButton);

  /// [data] is ignored.
  @override
  bool applyInternal(String applyType, AFWidgetSelector selector, Element elem, dynamic data) {
    final tapOn = elem.widget;
    if(tapOn is ElevatedButton) {
      tapOn.onPressed?.call();
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
    final specifier = selector;
    final containsText = specifier.containsText;   
    if(tapOn is RichText) {
      if(tapIfMatch(tapOn.text, containsText)) {
        return true;            
      }
    } 
    return false;
  }

  bool tapIfMatch(InlineSpan span, String containsText) {
    if(span is TextSpan) {
      final spanText = span.text;
      if(spanText != null && spanText.contains(containsText) && span.recognizer != null) {
        final recognizer = span.recognizer;
        if(recognizer is TapGestureRecognizer) {
          recognizer.onTap?.call();
          return true;
        }
      }

      if(span.children == null) {
        return false;
      }

      final spanChildren = span.children;
      if(spanChildren != null) {
        for(final child in spanChildren) {
          if(tapIfMatch(child, containsText)) {
            return true;
          }
        }
      }
    }
    return false;
  }
}


class AFTapChoiceChip extends AFApplyTapWidgetAction {
  AFTapChoiceChip(): super(ChoiceChip);

  /// Note that [data] is ignored, this toggles the chip state.
  @override
  bool applyInternal(String applyType, AFWidgetSelector selector, Element element, dynamic data) {
    final widget = element.widget;
    if(widget is ChoiceChip) {
      widget.onSelected?.call(!widget.selected);
      return true;
    } 
    return false;
  }

}

class AFSetChoiceChip extends AFApplySetValueWidgetAction {
  AFSetChoiceChip(): super(ChoiceChip);

  /// Note that [data] is ignored, this toggles the chip state.
  @override
  bool applyInternal(String applyType, AFWidgetSelector selector, Element element, dynamic data) {
    final widget = element.widget;
    if(widget is ChoiceChip) {
      bool isSel = data;
      if(widget.selected != isSel) {
        widget.onSelected?.call(isSel);
      }
      return true;
    } 
    return false;
  }

}

class AFSetSwitchValueAction extends AFApplySetValueWidgetAction {
  AFSetSwitchValueAction(): super(Switch);

  /// Note that [data] is ignored, this toggles the chip state.
  @override
  bool applyInternal(String applyType, AFWidgetSelector selector, Element element, dynamic data) {
    final widget = element.widget;
    if(widget is Switch) {
      bool isSel = data;
      if(widget.value != isSel) {
        widget.onChanged?.call(isSel);
      }
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
      widget.onSelectedItemChanged?.call(data);
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
      final widCont = widget.controller;
      if(widCont != null) {
        widCont.text = data;
      }
      widget.onChanged?.call(data);
      return true;
    } 
    return false;
  }
}

class AFApplySliderAction extends AFApplySetValueWidgetAction {

  AFApplySliderAction(): super(Slider);

  @override
  bool applyInternal(String applyType, AFWidgetSelector selector, Element elem, dynamic data) {
    final widget = elem.widget;
    if(widget is Slider && data is double) {
      widget.onChanged?.call(data);
      return true;
    } 
    return false;
  }
}

class AFExtractColumnChildrenAction extends AFExtractChildrenWidgetAction {
  AFExtractColumnChildrenAction(): super(Column);

  @override
  dynamic extractInternal(String extractType, AFWidgetSelector selector, Element element) {
    final widget = element.widget;
    if(AFExtractWidgetAction.isChildren(extractType) && widget is Column) {
      return widget.children;
    } 
    return null;
  }
}

class AFExtractWidgetListAction extends AFExtractChildrenWidgetAction {
  AFExtractWidgetListAction(): super(AFUIWidgetListWrapper);

  @override
  dynamic extractInternal(String extractType, AFWidgetSelector selector, Element element) {
    final widget = element.widget;
    if(AFExtractWidgetAction.isChildren(extractType) && widget is AFUIWidgetListWrapper) {
      return widget.children;
    } 
    return null;
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

class AFExtractSliderAction extends AFExtractPrimaryWidgetAction {

  AFExtractSliderAction(): super(Slider);

  @override
  dynamic extractInternal(String extractType, AFWidgetSelector selector, Element element) {
    final widget = element.widget;
    if(AFExtractWidgetAction.isPrimary(extractType) && widget is Slider) {
      return widget.value;
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
        return widget.controller?.value.text;
      } 
    } 
    return null;
  }
}

class AFExtractRichTextAction extends AFExtractPrimaryWidgetAction {

  AFExtractRichTextAction(): super(RichText);

  @override
  dynamic extractInternal(String extractType, AFWidgetSelector selector, Element element) {
    final widget = element.widget;
    if(AFExtractWidgetAction.isPrimary(extractType) && widget is RichText) {
      final composed = StringBuffer();
      _populateFromSpan(composed, widget.text);
      return composed.toString();
    } 
    return null;
  }

  void _populateFromSpan(StringBuffer dest, InlineSpan span) {
    if(span is TextSpan) {
      if(span.text != null) {
        dest.write(span.text);
      }
      final spanChildren = span.children;
      if(spanChildren != null) {
        for(final child in spanChildren) {
          _populateFromSpan(dest, child);
        }
      }
    }
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

class AFSwitchExtractor extends AFExtractPrimaryWidgetAction {

  AFSwitchExtractor(): super(Switch);

  @override
  dynamic extractInternal(String extractType, AFWidgetSelector selector, Element element) {
    final widget = element.widget;
    if(AFExtractWidgetAction.isPrimary(extractType) && widget is Switch) {
      return widget.value;
    } 
    return false;
  }

}
