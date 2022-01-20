import 'package:afib/src/dart/redux/state/models/af_theme_state.dart';
import 'package:afib/src/dart/utils/af_id.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart' as ft;

class _AFHasWidgetId extends ft.Matcher {
  final AFWidgetID _expected;

  const _AFHasWidgetId(this._expected);

  @override
  bool matches(dynamic item, Map matchState) {
    var itemWidget;
    if (item is Widget) {
      itemWidget = item;
    } else if (item is Element) {
      itemWidget = item.widget;
    }

    final key = itemWidget.key;
    final matchKey = AFFunctionalTheme.keyForWIDStatic(_expected);
    return key == matchKey;
  }

  @override
  ft.Description describe(ft.Description description) {
      return description.add('has widget id ').addDescriptionOf(_expected);
  }

  @override
  ft.Description describeMismatch(
      dynamic item, ft.Description mismatchDescription, Map matchState, bool verbose) {
    if (item is Widget || item is Element) {
      return super.describeMismatch(item, mismatchDescription, matchState, verbose);
    } else {
      return mismatchDescription.add('is not a widget or an element');
    }
  }
}


class _AFHasWidgetIds extends ft.Matcher {
  final List<AFWidgetID?> _expected;

  const _AFHasWidgetIds(this._expected);

  @override
  bool matches(dynamic item, Map matchState) {
    var listWidget;
    if (item is List<Widget>) {
      listWidget = item;
    } 

    if(listWidget.length != _expected.length) {
      return false;
    }

    for(var i = 0; i < listWidget.length; i++) {
      final actualWidget = listWidget[i];
      final expectedKey = AFFunctionalTheme.keyForWIDStatic(_expected[i]);
      if(actualWidget.key != expectedKey) {
        return false;
      }
    }
    return true;
  }

  @override
  ft.Description describe(ft.Description description) {
      return description.add('has widget ids ').addDescriptionOf(_expected);
  }

  @override
  ft.Description describeMismatch(
      dynamic item, ft.Description mismatchDescription, Map matchState, bool verbose) {
    if (item is List<Widget>) {
      return super.describeMismatch(item, mismatchDescription, matchState, verbose);
    } else {
      return mismatchDescription.add('is not a list of widgets');
    }
  }
}

typedef AFWidgetMapperDelegate = AFWidgetID Function(dynamic);

ft.Matcher hasWidgetId(AFWidgetID expected) => _AFHasWidgetId(expected);
ft.Matcher hasOneWidgetId(AFWidgetID expected) => _AFHasWidgetIds([expected]);
ft.Matcher hasWidgetIds(List<AFWidgetID> expected) => _AFHasWidgetIds(expected);
ft.Matcher hasWidgetIdsWith(List<dynamic> expected, { AFWidgetMapperDelegate? mapper }) {
    if(mapper != null ) {
      return _AFHasWidgetIds(expected.map(mapper).toList());
    } else {
      return _AFHasWidgetIds(expected as List<AFWidgetID?>);
    }
}