
import 'package:afib/src/dart/utils/af_id.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

typedef AFDisposableUICreateDelegate<T> = T Function();

class AFDisposableUIHolder<T> {
  Map<AFWidgetID, T> controllers = <AFWidgetID, T>{};
  AFDisposableUICreateDelegate<T> creator;
  bool disposed = false;

  AFDisposableUIHolder({
    this.creator
  });

  T access(AFWidgetID wid) {
    var controller = controllers[wid];
    if(controller == null) {
      controller = creator();
      controllers[wid] = controller;
    }
    return controller;
  }

  void dispose() {
    if(disposed) {
      //throw AFException("A disposable UI element was disposed twice!");
      return;
    }
    disposed = true;
    for(final controller in controllers.values) {
      dynamic d = controller;
      d.dispose();
    }
    controllers.clear();
  }
}


class AFTextEditingControllersHolder extends AFDisposableUIHolder<TextEditingController>  {
  AFTextEditingControllersHolder(): super(creator: create);

  TextEditingController syncText(AFWidgetID wid, String text) {
    final controller = access(wid);
    if(text != null) {
      if(controller.text != text) {
        var restoreSelection;
        if(text.length >= controller.text.length) {
          restoreSelection = controller.selection;
        }
        if(controller.text != text) {
          controller.text = text;
        }
        if(restoreSelection != null) {
          controller.selection = restoreSelection;
        }
      }
    }
    return controller;
  }

  static TextEditingController create() {
    return TextEditingController();
  }
}

class AFTapGestureRecognizersHolder extends AFDisposableUIHolder<TapGestureRecognizer> {
  AFTapGestureRecognizersHolder(): super(creator: create);

  static TapGestureRecognizer create() {
    return TapGestureRecognizer();
  }
}