import 'package:afib/id.dart';
import 'package:afib/src/dart/utils/af_id.dart';
import 'package:meta/meta.dart';

/// Can be used in cases where no route param is necessary

/// Base class for transient data associated with an [AFScreen], and stored
/// in the [AFRoute]
@immutable
class AFRouteParam {
  // a screen or widget id this route parameter is associated with.
  final AFID id;

  const AFRouteParam({
    required this.id
  });

  bool matchesScreen(AFScreenID screen) {
    return false;
  }

  AFScreenID? get effectiveScreenId {
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

  String toString() {
    return runtimeType.toString();
  }
}

/// Used internally in test cases where we need to substitute a different screen id,
/// for the original screen id in a route param passed to a test.   You can call 
/// unwrap to get the original route param of the correct type.
@immutable
class AFRouteParamWrapper extends AFRouteParam {
  final AFRouteParam original;

  AFRouteParamWrapper({
    required AFID screenId,
    required this.original,
  }): super(id: screenId);
  
  AFRouteParam unwrap() { return original; }
}


class AFRouteParamUnused extends AFRouteParam {
  static const unused = AFRouteParamUnused(id: AFUIScreenID.unused);

  const AFRouteParamUnused({ required AFScreenID id} ): super(id: id);

  factory AFRouteParamUnused.create({
    required AFScreenID id
  }) {
    return AFRouteParamUnused(id: id);
  }
}

class AFRouteParamChild {
  final AFID widgetId;
  final AFRouteParam param;
  
  AFRouteParamChild({
    required this.widgetId,
    required this.param,
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

/*
/// A utility to build AFRouteParamWithChildren
class AFRouteParamWithChildrenBuilder {
  final AFRouteParamChild primary;
  final children = <AFRouteParamChild>[];
  final activeSort = <Type, dynamic>{};

  AFRouteParamWithChildrenBuilder(this.primary);

  factory AFRouteParamWithChildrenBuilder.create(AFScreenID screen, AFRouteParam param) {
    return AFRouteParamWithChildrenBuilder(AFRouteParamChild(widgetId: screen, param: param));
  }

  void add(AFWidgetID wid, AFRouteParam child) {
    children.add(AFRouteParamChild(
      widgetId: wid,
      param: child
    ));
  }

  void sortBy({
    required Type typeToSort,
    required dynamic sort
  }) {
    activeSort[typeToSort] = sort;
  }

  AFRouteParamWithChildren toParam() {
    return AFRouteParamWithChildren(children: children, primary: primary, activeSort: activeSort);
  }
}

/// Used in cases where a parent screen has children which 
/// are independently connected to the store.
@immutable
class AFRouteParamWithChildren extends AFRouteParam {
  final AFRouteParamChild primary;
  final List<AFRouteParamChild> children;
  final Map<Type, dynamic> activeSort;
    
  AFRouteParamWithChildren({
    required this.primary,
    required this.children,
    required this.activeSort,
  });

  static AFRouteParamWithChildrenBuilder createBuilder(AFScreenID screen, AFRouteParam param) { return AFRouteParamWithChildrenBuilder.create(screen, param); }

  TRouteParam primaryParam<TRouteParam extends AFRouteParam>() { return primary.param as TRouteParam; }

  AFRouteParam? findByWidget(AFID wid) {
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
      if(child.param is TChildParam) {
        count++;
      }
    }
    return count;
  }

  AFRouteParamWithChildren revisePrimary(AFRouteParam param) {
    return copyWith(primary: primary.reviseParam(param));
  }

  List<TChildParam> paramsOfType<TChildParam extends AFRouteParam>() {
    final result = <TChildParam>[];
    for(final child in children) {
      final param = child.param;
      if(param is TChildParam) {
        result.add(param);
      }
    }
    return result;
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

  AFRouteParamWithChildren reviseSortChildren(Type typeToSort, AFTypedSortDelegate sort) {
    final revisedSort = Map<Type, dynamic>.from(this.activeSort);
    revisedSort[typeToSort] = sort;
    return copyWith(activeSort: revisedSort);
  }
  

  List<AFRouteParamChild> _sortChildren(Type typeToSort, AFTypedSortDelegate sort, List<AFRouteParamChild> currentChildren) {
    final toSort = <AFRouteParamChild>[];
    final notSort = <AFRouteParamChild>[];
    for(final child in currentChildren) {
      if(child.param.runtimeType == typeToSort) {
        toSort.add(child);
      } else {
        notSort.add(child);
      }
    }
    
    toSort.sort((l, r) {
      return sort(l.param, r.param);
    });

    notSort.addAll(toSort);
    return notSort;
  }

  AFRouteParamWithChildren reviseChild(AFID wid, AFRouteParam revised) {
    if(wid == primary.widgetId || wid.endsWith(AFUIWidgetID.afibPassthroughSuffix)) {
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
    AFRouteParamChild? primary,
    List<AFRouteParamChild>? children,
    Map<Type, dynamic>? activeSort
  }) {
    var currentChildren = children ?? this.children;
    final currentSort = activeSort ?? this.activeSort;
    if(currentSort.isNotEmpty) {
      currentSort.forEach( (typeToSort, sorter) {
        currentChildren = _sortChildren(typeToSort, sorter, currentChildren);
      });
    }

    return AFRouteParamWithChildren(
      primary: primary ?? this.primary,
      children: currentChildren,
      activeSort: currentSort,
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
    final op = o;
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

      if(c.param != co.param) {
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
*/