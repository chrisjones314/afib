import 'package:afib/src/dart/utils/af_exception.dart';
import 'package:afib/src/dart/utils/af_id.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

class AFTextEditingController  {
  final AFWidgetID wid;
  final TextEditingController controller;
  AFTextEditingController(this.wid, this.controller);

  factory AFTextEditingController.create(AFWidgetID wid, String text) {
    return AFTextEditingController(wid, TextEditingController(text: text)); 
  }

  void update(String text) {
    if(controller.text != text) {
      controller.text = text;
      controller.selection = TextSelection.collapsed(offset: text.length);
    }
  }

  void select(int start, int end, {
    TextAffinity affinity = TextAffinity.downstream
  }) {
    final sel = TextSelection(baseOffset: start, extentOffset: end, affinity: affinity);
    if(!controller.isSelectionWithinTextBounds(sel)) {
      throw AFException("Text selection from $start to $end is out of range for ${controller.text}");
    }
    controller.selection = sel;
  }

  String get text {
    return controller.text;
  }

  void clear() {
    controller.clear();
  }

  void stopComposing() {
    controller.clearComposing();
  }

  void dispose() {
    controller.dispose();
  }
}


class AFTextEditingControllers  {
  final Map<AFWidgetID, AFTextEditingController> controllers;
  AFTextEditingControllers(this.controllers);

  AFTextEditingController? access(AFWidgetID wid) {
    return controllers[wid];
  }

  void update(AFWidgetID wid, String text) {
    final controller = controllers[wid];
    if(controller == null) {
      throw AFException("No controller regisered for $wid");
    }
    controller.update(text);
  }

  String textFor(AFWidgetID wid) {
    final controller = controllers[wid];
    if(controller == null) { throw AFException("Missing text controller for wid $wid"); }
    return controller.text;
  }

  void reviseN(Map<AFWidgetID, String> values) {
    for(final wid in values.keys) {
      final value = values[wid];
      if(value == null) {
        continue;
      }
      var controller = controllers[wid];
      if(controller == null) {
        controller = AFTextEditingController.create(wid, value);
        controllers[wid] = controller;
      } else {
        controller.update(value);
      }
    }
  }

  void reviseOne(AFWidgetID wid, String value) {
    var controller = controllers[wid];
    if(controller == null) {
      controller = AFTextEditingController(wid, TextEditingController(text: value));
      controllers[wid] = controller;
    } else {
      controller.update(value);
    }
  }

  static AFTextEditingControllers createN(Map<AFWidgetID, String> values) {
    final initial = AFTextEditingControllers(<AFWidgetID, AFTextEditingController>{});
    initial.reviseN(values);
    return initial;
  }

  static AFTextEditingControllers createOne(AFWidgetID wid, String value) {
    final initial = AFTextEditingControllers(<AFWidgetID, AFTextEditingController>{});
    initial.reviseOne(wid, value);
    return initial;
  }
  
  void dispose() {
    for(final controller in controllers.values) {
      dynamic d = controller;
      d.dispose();
    }
    controllers.clear();
  }

}

class AFTapGestureRecognizersHolder  {
  final controllers = <AFWidgetID, TapGestureRecognizer>{};
  AFTapGestureRecognizersHolder();

  TapGestureRecognizer access(AFWidgetID wid) {
    var controller = controllers[wid];
    if(controller == null) {
      controller = TapGestureRecognizer();
      controllers[wid] = controller;
    }
    return controller;
  }

  void dispose() {
    for(final controller in controllers.values) {
      dynamic d = controller;
      d.dispose();
    }
    controllers.clear();
  }

  static TapGestureRecognizer create() {
    return TapGestureRecognizer();
  }
}