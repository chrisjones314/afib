
import 'package:afib/afib_dart.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

typedef AFDisposableUICreateDelegate<T> = T Function();

class AFDisposableUIHolder<T> {
  Map<dynamic, T> controllers = <dynamic, T>{};
  AFDisposableUICreateDelegate<T> create;
  bool disposed = false;

  AFDisposableUIHolder({
    this.create
  });

  T access(dynamic id) {
    var controller = controllers[id];
    if(controller == null) {
      controller = create();
      controllers[id] = controller;
    }
    return controller;
  }

  void dispose() {
    if(disposed) {
      throw AFException("A disposable UI element was disposed twice!");
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
  AFTextEditingControllersHolder(): super(create: () => TextEditingController());

  TextEditingController syncText(dynamic id, String text) {
    if(text == null) {
      text = "";
    }
    final controller = access(id);
    if(controller.text != text) {
      var restoreSelection;
      if(text.length >= controller.text.length) {
        restoreSelection = controller.selection;
      }
      controller.text = text;
      if(restoreSelection != null) {
        controller.selection = restoreSelection;
      }
    }
    return controller;
  }
}

class AFTapGestureRecognizersHolder extends AFDisposableUIHolder<TapGestureRecognizer> {
  AFTapGestureRecognizersHolder(): super(create: () => TapGestureRecognizer());
}