import 'package:afib/src/dart/utils/af_route_param.dart';
import 'package:afib/src/dart/utils/af_unused.dart';
import 'package:afib/src/flutter/utils/af_dispatcher.dart';
import 'package:meta/meta.dart';
import 'package:quiver/core.dart';

/// Utility class used to capture the aspects of the global state
/// that are used by/impact a particular screen or widget.
/// 
/// The widget only needs to be re-rendered if data in its state view
/// changed (or its route param, or conceptual theme change).  
@immutable
class AFStateView<TV1, TV2, TV3, TV4> {
  final TV1 first;
  final TV2 second;
  final TV3 third;
  final TV4 fourth;

  AFStateView({this.first, this.second, this.third, this.fourth});

  /// Because store connector data is always recreated, it is 
  /// important to implement deep equality so that the screen won't be re-rendered
  /// each time if the data has not changed.
  bool operator==(dynamic o) {
    final result = (o is AFStateView<TV1, TV2, TV3, TV4> && first == o.first && second == o.second && third == o.third && fourth == o.fourth);
    return result;
  }

  int get hashCode {
    return hash4(first.hashCode, second.hashCode, third.hashCode, fourth.hashCode);
  }

}

/// A version of [AFStateView] which allows for more type parameters.
@immutable
class AFStateViewExtended<TV1, TV2, TV3, TV4, TV5, TV6, TV7, TV8> extends AFStateView<TV1, TV2, TV3, TV4> {
  final TV5 fifth;
  final TV6 sixth;
  final TV7 seventh;
  final TV8 eighth;

  AFStateViewExtended({TV1 first, TV2 second, TV3 third, TV4 fourth, this.fifth, this.sixth, this.seventh, this.eighth}):
    super(first: first, second: second, third: third, fourth: fourth);

  bool operator==(dynamic o) {
    final result = (o is AFStateViewExtended<TV1, TV2, TV3, TV4, TV5, TV6, TV7, TV8> 
      && first == o.first && second == o.second && third == o.third && fourth == o.fourth
      && fifth == o.fifth && sixth == o.sixth && seventh == o.seventh && eighth == o.eighth);
    return result;
  }

  int get hashCode {
    final start = super.hashCode;
    final next = hash4(fifth?.hashCode, sixth?.hashCode, seventh?.hashCode, eighth?.hashCode);
    return hash2(start, next);
  }
}

/// Use this if you don't use any data from the state to render your screen.
@immutable 
class AFStateViewUnused extends AFStateView<AFUnused, AFUnused, AFUnused, AFUnused> {
  AFStateViewUnused({AFDispatcher dispatcher, AFRouteParam param}): super();
}

/// Use this version of [AFStateView] if you only need one piece of data from the store.
@immutable 
class AFStateView1<TV1> extends AFStateView<TV1, AFUnused, AFUnused, AFUnused> {
  AFStateView1({AFDispatcher dispatcher, AFRouteParam param, TV1 first}): super(first: first);
}

/// Use this version of [AFStateView] if you need two pieces of data from the store.
@immutable 
class AFStateView2<TV1, TV2> extends AFStateView<TV1, TV2, AFUnused, AFUnused> {
  AFStateView2({AFDispatcher dispatcher, AFRouteParam param, TV1 first, TV2 second}): super(first: first, second: second);
}

/// Use this version of [AFStateView] if you need three pieces of data from the store.
@immutable 
class AFStateView3<TV1, TV2, TV3> extends AFStateView<TV1, TV2, TV3, AFUnused> {
  AFStateView3({AFDispatcher dispatcher, AFRouteParam param, TV1 first, TV2 second, TV3 third}): super(first: first, second: second, third: third);
}

/// Use this version of [AFStateView] if you need four pieces of data from the store.
@immutable 
class AFStateView4<TV1, TV2, TV3, TV4> extends AFStateView<TV1, TV2, TV3, TV4> {
  AFStateView4({TV1 first, TV2 second, TV3 third, TV4 fourth}): super(first: first, second: second, third: third, fourth: fourth);
}

/// User this version of [AFStateViewExtended] if you need five pieces of data from the store.
class AFStateView5<TV1, TV2, TV3, TV4, TV5> extends AFStateViewExtended<TV1, TV2, TV3, TV4, TV5, AFUnused, AFUnused, AFUnused> {
  AFStateView5({TV1 first, TV2 second, TV3 third, TV4 fourth, TV5 fifth}): super(first: first, second: second, third: third, fourth: fourth, fifth: fifth);

}

class AFStateView6<TV1, TV2, TV3, TV4, TV5, TV6> extends AFStateViewExtended<TV1, TV2, TV3, TV4, TV5, TV6, AFUnused, AFUnused> {
  AFStateView6({TV1 first, TV2 second, TV3 third, TV4 fourth, TV5 fifth, TV6 sixth}): super(first: first, second: second, third: third, fourth: fourth, fifth: fifth, sixth: sixth);
}

class AFStateView7<TV1, TV2, TV3, TV4, TV5, TV6, TV7> extends AFStateViewExtended<TV1, TV2, TV3, TV4, TV5, TV6, TV7, AFUnused> {
  AFStateView7({TV1 first, TV2 second, TV3 third, TV4 fourth, TV5 fifth, TV6 sixth, TV7 seventh}): super(first: first, second: second, third: third, fourth: fourth, fifth: fifth, sixth: sixth, seventh: seventh);
}

class AFStateView8<TV1, TV2, TV3, TV4, TV5, TV6, TV7, TV8> extends AFStateViewExtended<TV1, TV2, TV3, TV4, TV5, TV6, TV7, TV8> {
  AFStateView8({TV1 first, TV2 second, TV3 third, TV4 fourth, TV5 fifth, TV6 sixth, TV7 seventh, TV8 eighth}): super(first: first, second: second, third: third, fourth: fourth, fifth: fifth, sixth: sixth, seventh: seventh, eighth: eighth);
}

