import 'package:afib/src/dart/utils/af_exception.dart';
import 'package:afib/src/dart/utils/af_id.dart';
import 'package:meta/meta.dart';
import 'package:quiver/core.dart';

/// Base class for transient data associated with an [AFScreen], and stored
/// in the [AFRoute]
@immutable
class AFRouteParam {
  AFRouteParam();

  bool matchesScreen(AFScreenID screen) {
    return false;
  }

  AFScreenID get effectiveScreenId {
    return null;
  }

  AFRouteParam paramFor(AFScreenID screen) {
    return this;
  }

  /// Called when the param is permenantly destroyed.
  /// 
  /// This is used to that you can put things with persistent state,
  /// like TapGestureRecognizer, in your route parameter, and then clean
  /// it up when the screen goes away.
  void dispose() {

  }
}

/// Can be used in cases where no route param is necessary
class AFRouteParamUnused extends AFRouteParam {
  
}

class AFRouteParamChild {
  final AFWidgetID widgetId;
  final AFRouteParam param;
  
  AFRouteParamChild({
    @required this.widgetId,
    @required this.param,
  });
  
  AFRouteParamChild reviseParam(AFRouteParam revised) {
    return AFRouteParamChild(
      widgetId: this.widgetId,
      param: revised
    );
  }

  void dispose() {
    param.dispose();
  }
}

/// A utility to build AFRouteParamWithChildren
class AFRouteParamWithChildrenBuilder {
  AFRouteParamChild primary;
  final children = <AFRouteParamChild>[];

  void setPrimary(AFWidgetID wid, AFRouteParam child) {
    primary = AFRouteParamChild(
      widgetId: wid,
      param: child
    );
  }

  void add(AFWidgetID wid, AFRouteParam child) {
    children.add(AFRouteParamChild(
      widgetId: wid,
      param: child
    ));
  }

  AFRouteParamWithChildren create() {
    return AFRouteParamWithChildren(children: children, primary: primary);
  }
}


/// Used in cases where a parent screen has children which 
/// are independently connected to the store.
@immutable
class AFRouteParamWithChildren extends AFRouteParam {
  final AFRouteParamChild primary;
  final List<AFRouteParamChild> children;
  
  AFRouteParamWithChildren({
    @required this.primary,
    @required this.children
  });

  static AFRouteParamWithChildrenBuilder createBuilder() { return AFRouteParamWithChildrenBuilder(); }

  AFRouteParam findByWidget(AFWidgetID wid) {
    if(wid == primary.widgetId) {
      return primary.param;
    }

    for(final child in children) {
      if(child.widgetId == wid) {
        return child.param;
      }
    }
    return null;
  }

  int countOfChildren<TChildParam extends AFRouteParam>() {
    var count = 0;
    for(final child in children) {
      if(child is TChildParam) {
        count++;
      }
    }
    return count;
  }

  AFRouteParamWithChildren reviseRemoveChild(AFWidgetID wid) {
    final revisedChildren = List<AFRouteParamChild>.from(this.children);
    revisedChildren.removeWhere( (item) => item.widgetId == wid );
    return copyWith(children: revisedChildren);        
  }

  AFRouteParamWithChildren reviseAddChild(AFWidgetID wid, AFRouteParam newParam) {
    final revisedChildren = List<AFRouteParamChild>.from(this.children);
    revisedChildren.add(AFRouteParamChild(widgetId: wid, param: newParam));
    return copyWith(children: revisedChildren);
  }

  AFRouteParamWithChildren reviseChild(AFWidgetID wid, AFRouteParam revised) {
    if(wid == primary.widgetId) {
      return copyWith(primary: primary.reviseParam(revised));
    }
    for(var i = 0; i < children.length; i++) {
      final child = children[i];
      if(child.widgetId == wid) {
        final revisedChildren = List<AFRouteParamChild>.from(this.children);
        revisedChildren[i] = child.reviseParam(revised);
        return copyWith(children: revisedChildren);
      }
    }

    throw AFException("Did not find child widget $wid in order to update param");
  }


  AFRouteParamWithChildren copyWith({
    AFRouteParamChild primary,
    List<AFRouteParamChild> children
  }) {
    return AFRouteParamWithChildren(
      primary: primary ?? this.primary,
      children: children ?? this.children
    );
  }

  int get hashCode {
    return hash2(primary.hashCode, hashObjects(children));
  }

  /// Because the child widgets are rendered independently of the parent, this equality
  /// tests only whehter the primary (parent widget's parameter has changed, or if the
  /// count of the child widgets or their ids have changed.
  bool operator==(dynamic o) {
    if(o is! AFRouteParamWithChildren) {
      return false;
    } 
    final AFRouteParamWithChildren op = o;
    if(o.primary != op.primary) {
      return false;
    }

    if(children.length != op.children.length) {
      return false;
    }

    for(var i = 0; i < children.length; i++) {
      final c = children[i];
      final co = op.children[i];
      if(c.widgetId != co.widgetId) {
        return false;
      }
    }    

    return true;
  }


  void dispose() {
    for(final child in this.children) {
      child.dispose();
    }
  }
}