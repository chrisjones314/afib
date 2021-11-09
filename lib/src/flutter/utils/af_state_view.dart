import 'package:afib/afib_flutter.dart';
import 'package:afib/src/dart/utils/af_unused.dart';
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

  AFStateView({
    required this.first, 
    required this.second, 
    required this.third, 
    required this.fourth
  });

  static AFStateView unused() {
    return AFStateView(
      first: AFUnused.unused,
      second: AFUnused.unused,
      third: AFUnused.unused,
      fourth: AFUnused.unused
    );
  }

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

@immutable 
class AFStateViewUnused extends AFStateView<AFUnused, AFUnused, AFUnused, AFUnused> {
  AFStateViewUnused(): super(first: AFUnused.unused, second: AFUnused.unused, third: AFUnused.unused, fourth: AFUnused.unused);
}

/// A version of [AFStateView] which allows for more type parameters.
@immutable
class AFStateViewExtended<TV1, TV2, TV3, TV4, TV5, TV6, TV7, TV8> extends AFStateView<TV1, TV2, TV3, TV4> {
  final TV5 fifth;
  final TV6 sixth;
  final TV7 seventh;
  final TV8 eighth;

  AFStateViewExtended({
    required TV1 first, 
    required TV2 second, 
    required TV3 third, 
    required TV4 fourth, 
    required this.fifth, 
    required this.sixth, 
    required this.seventh, 
    required this.eighth}):
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

/// A version of [AFStateView] which allows for more type parameters.
@immutable
class AFStateViewExtended2<TV1, TV2, TV3, TV4, TV5, TV6, TV7, TV8, TV9, TV10, TV11, TV12> extends AFStateViewExtended<TV1, TV2, TV3, TV4, TV5, TV6, TV7, TV8> {
  final TV9 ninth;
  final TV10 tenth;
  final TV11 eleventh;
  final TV12 twelfth;

  AFStateViewExtended2({
    required TV1 first, 
    required TV2 second, 
    required TV3 third, 
    required TV4 fourth, 
    required TV5 fifth, 
    required TV6 sixth, 
    required TV7 seventh, 
    required TV8 eighth,
    required this.ninth,
    required this.tenth,
    required this.eleventh,
    required this.twelfth,
    }):
    super(
      first: first, 
      second: second, 
      third: third, 
      fourth: fourth,
      fifth: fifth,
      sixth: sixth,
      seventh: seventh,
      eighth: eighth,
  );

  bool operator==(dynamic o) {
    final result = (o is AFStateViewExtended2<TV1, TV2, TV3, TV4, TV5, TV6, TV7, TV8, TV9, TV10, TV11, TV12> 
      && first == o.first && second == o.second && third == o.third && fourth == o.fourth
      && fifth == o.fifth && sixth == o.sixth && seventh == o.seventh && eighth == o.eighth
      && ninth == o.ninth && tenth == o.tenth && eleventh == o.eleventh && twelfth == o.twelfth);
    return result;
  }

  int get hashCode {
    final start = super.hashCode;
    final next = hash4(fifth?.hashCode, sixth?.hashCode, seventh?.hashCode, eighth?.hashCode);
    final next2 = hash4(ninth?.hashCode, tenth?.hashCode, eleventh?.hashCode, twelfth?.hashCode);
    return hash3(start, next, next2);
  }
}

/// Use this version of [AFStateView] if you only need one piece of data from the store.
@immutable 
class AFStateView1<TV1> extends AFStateView<TV1, AFUnused, AFUnused, AFUnused> {
  AFStateView1({
    required TV1 first
  }): super(first: first, second: AFUnused.unused, third: AFUnused.unused, fourth: AFUnused.unused);
}

/// Use this version of [AFStateView] if you need two pieces of data from the store.
@immutable 
class AFStateView2<TV1, TV2> extends AFStateView<TV1, TV2, AFUnused, AFUnused> {
  AFStateView2({
    required TV1 first, 
    required TV2 second
  }): super(first: first, second: second, third: AFUnused.unused, fourth: AFUnused.unused);
}

/// Use this version of [AFStateView] if you need three pieces of data from the store.
@immutable 
class AFStateView3<TV1, TV2, TV3> extends AFStateView<TV1, TV2, TV3, AFUnused> {
  AFStateView3({
    required TV1 first, 
    required TV2 second, 
    required TV3 third
  }): super(first: first, second: second, third: third, fourth: AFUnused.unused);
}

/// Use this version of [AFStateView] if you need four pieces of data from the store.
@immutable 
class AFStateView4<TV1, TV2, TV3, TV4> extends AFStateView<TV1, TV2, TV3, TV4> {
  AFStateView4({
    required TV1 first, 
    required TV2 second, 
    required TV3 third, 
    required TV4 fourth
  }): super(first: first, second: second, third: third, fourth: fourth);
}

/// User this version of [AFStateViewExtended] if you need five pieces of data from the store.
class AFStateView5<TV1, TV2, TV3, TV4, TV5> extends AFStateViewExtended<TV1, TV2, TV3, TV4, TV5, AFUnused, AFUnused, AFUnused> {
  AFStateView5({
    required TV1 first, 
    required TV2 second, 
    required TV3 third, 
    required TV4 fourth, 
    required TV5 fifth
  }): super(first: first, second: second, third: third, fourth: fourth, fifth: fifth, sixth: AFUnused.unused, seventh: AFUnused.unused, eighth: AFUnused.unused);

}

class AFStateView6<TV1, TV2, TV3, TV4, TV5, TV6> extends AFStateViewExtended<TV1, TV2, TV3, TV4, TV5, TV6, AFUnused, AFUnused> {
  AFStateView6({
    required TV1 first, 
    required TV2 second, 
    required TV3 third, 
    required TV4 fourth, 
    required TV5 fifth, 
    required TV6 sixth
  }): super(first: first, second: second, third: third, fourth: fourth, fifth: fifth, sixth: sixth, seventh: AFUnused.unused, eighth: AFUnused.unused);
}

class AFStateView7<TV1, TV2, TV3, TV4, TV5, TV6, TV7> extends AFStateViewExtended<TV1, TV2, TV3, TV4, TV5, TV6, TV7, AFUnused> {
  AFStateView7({
    required TV1 first, 
    required TV2 second, 
    required TV3 third, 
    required TV4 fourth, 
    required TV5 fifth, 
    required TV6 sixth, 
    required TV7 seventh
  }): super(first: first, second: second, third: third, fourth: fourth, fifth: fifth, sixth: sixth, seventh: seventh, eighth: AFUnused.unused);
}

class AFStateView8<TV1, TV2, TV3, TV4, TV5, TV6, TV7, TV8> extends AFStateViewExtended<TV1, TV2, TV3, TV4, TV5, TV6, TV7, TV8> {
  AFStateView8({
    required TV1 first, 
    required TV2 second, 
    required TV3 third, 
    required TV4 fourth, 
    required TV5 fifth, 
    required TV6 sixth, 
    required TV7 seventh, 
    required TV8 eighth
  }): super(first: first, second: second, third: third, fourth: fourth, fifth: fifth, sixth: sixth, seventh: seventh, eighth: eighth);
}

class AFStateView9<TV1, TV2, TV3, TV4, TV5, TV6, TV7, TV8, TV9> extends AFStateViewExtended2<TV1, TV2, TV3, TV4, TV5, TV6, TV7, TV8, TV9, AFUnused, AFUnused, AFUnused> {
  AFStateView9({
    required TV1 first, 
    required TV2 second, 
    required TV3 third, 
    required TV4 fourth, 
    required TV5 fifth, 
    required TV6 sixth, 
    required TV7 seventh, 
    required TV8 eighth,
    required TV9 ninth,
  }): super(
    first: first, 
    second: second, 
    third: third, 
    fourth: fourth, 
    fifth: fifth, 
    sixth: sixth, 
    seventh: seventh, 
    eighth: eighth, 
    ninth: ninth,
    tenth: AFUnused.unused,
    eleventh: AFUnused.unused,
    twelfth: AFUnused.unused,
  );
}

class AFStateView10<TV1, TV2, TV3, TV4, TV5, TV6, TV7, TV8, TV9, TV10> extends AFStateViewExtended2<TV1, TV2, TV3, TV4, TV5, TV6, TV7, TV8, TV9, TV10, AFUnused, AFUnused> {
  AFStateView10({
    required TV1 first, 
    required TV2 second, 
    required TV3 third, 
    required TV4 fourth, 
    required TV5 fifth, 
    required TV6 sixth, 
    required TV7 seventh, 
    required TV8 eighth,
    required TV9 ninth,
    required TV10 tenth,
  }): super(
    first: first, 
    second: second, 
    third: third, 
    fourth: fourth, 
    fifth: fifth, 
    sixth: sixth, 
    seventh: seventh, 
    eighth: eighth, 
    ninth: ninth,
    tenth: tenth,
    eleventh: AFUnused.unused,
    twelfth: AFUnused.unused,
  );
}

class AFStateView11<TV1, TV2, TV3, TV4, TV5, TV6, TV7, TV8, TV9, TV10, TV11> extends AFStateViewExtended2<TV1, TV2, TV3, TV4, TV5, TV6, TV7, TV8, TV9, TV10, TV11, AFUnused> {
  AFStateView11({
    required TV1 first, 
    required TV2 second, 
    required TV3 third, 
    required TV4 fourth, 
    required TV5 fifth, 
    required TV6 sixth, 
    required TV7 seventh, 
    required TV8 eighth,
    required TV9 ninth,
    required TV10 tenth,
    required TV11 eleventh,
  }): super(
    first: first, 
    second: second, 
    third: third, 
    fourth: fourth, 
    fifth: fifth, 
    sixth: sixth, 
    seventh: seventh, 
    eighth: eighth, 
    ninth: ninth,
    tenth: tenth,
    eleventh: eleventh,
    twelfth: AFUnused.unused,
  );
}

class AFStateView12<TV1, TV2, TV3, TV4, TV5, TV6, TV7, TV8, TV9, TV10, TV11, TV12> extends AFStateViewExtended2<TV1, TV2, TV3, TV4, TV5, TV6, TV7, TV8, TV9, TV10, TV11, TV12> {
  AFStateView12({
    required TV1 first, 
    required TV2 second, 
    required TV3 third, 
    required TV4 fourth, 
    required TV5 fifth, 
    required TV6 sixth, 
    required TV7 seventh, 
    required TV8 eighth,
    required TV9 ninth,
    required TV10 tenth,
    required TV11 eleventh,
    required TV12 twelfth,
  }): super(
    first: first, 
    second: second, 
    third: third, 
    fourth: fourth, 
    fifth: fifth, 
    sixth: sixth, 
    seventh: seventh, 
    eighth: eighth, 
    ninth: ninth,
    tenth: tenth,
    eleventh: eleventh,
    twelfth: twelfth,
  );
}



