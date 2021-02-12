// @dart=2.9
import 'package:afib/src/dart/utils/af_id.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

class AFTextEditingControllersHolder  {
  final Map<AFWidgetID, TextEditingController> controllers;
  AFTextEditingControllersHolder(this.controllers);


  TextEditingController access(AFWidgetID wid) {
    return controllers[wid];
  }

  String textFor(AFWidgetID wid) {
    final controller = controllers[wid];
    return controller.text;
  }

  void reviseN(Map<AFWidgetID, String> values) {
    for(final wid in values.keys) {
      final value = values[wid];
      var controller = controllers[wid];
      if(controller == null) {
        controller = TextEditingController(text: value);
        controllers[wid] = controller;
      }
      if(controller.text != value) {
        controller.text = value;
      }
    }
  }

  void reviseOne(AFWidgetID wid, String value) {
    var controller = controllers[wid];
    if(controller == null) {
      controller = TextEditingController(text: value);
      controllers[wid] = controller;
    }
    if(controller.text != value) {
      controller.text = value;
    }
  }

  static AFTextEditingControllersHolder createN(Map<AFWidgetID, String> values) {
    final initial = AFTextEditingControllersHolder(<AFWidgetID, TextEditingController>{});
    initial.reviseN(values);
    return initial;
  }

  static AFTextEditingControllersHolder createOne(AFWidgetID wid, String value) {
    final initial = AFTextEditingControllersHolder(<AFWidgetID, TextEditingController>{});
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