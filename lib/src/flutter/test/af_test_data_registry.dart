import 'package:afib/src/flutter/utils/af_typedefs_flutter.dart';


/// Used to register atomic test data values.
/// 
/// An atomic value is any kind of test data object that does not 
/// have a pointer to another test data object.  Note that atomic values 
/// can have references to other test data objects (e.g. a unique id), they
/// just cannot have pointers to instantiated objects.
///  
/// If you have test data which contains pointers to other test data
/// objects then you should register them
/// using [registerComposites].   That method hands you an 
/// [AFCompositeTestDataRegistry], which allows you to look up other previously
/// defined atomic values. 
/// 
/// The distinction between atomic and composite test data values is only important
/// if you intend to create a wireframe, as the wireframe mechanism uses the test 
/// data as a kind of 'poor mans state management system' to allow you to quickly
/// build a robust prototype.
/// 
/// One common case where you should register composites is in the [AFStateView] referenced in your
/// single screen prototypes and wireframes.  AFStateView will typically contain pointers to other
/// test data objects.  You should register them using [registerComposites] so that when you change an
/// atomic value, AFib can recalculate all the [AFStateView] instances used in your wireframe to reflect
/// that new value.
/// 
/// If you have an aggregating object, like a todo list, which contains a list or set of 
/// pointers to other test data objects (the todos).  Then typically you should store the bare list of todo unique ids (e.g
/// List<String>) as an atomic value and the parent object that contains the list of todos as a composite object.
/// In order to add a todo, you would register the todo itself as an atomic value, then add its unique id
/// to the atomic list.   When AFib recalculates the composite data, your parent todo list object will 
/// initialize itself from the atomic list of ids, and will automtically pick up the new todo that is part of that 
/// list.
abstract class AFAtomicTestDataRegistry {
  final Map<dynamic, dynamic> testData;
  static int uniqueIdBase = 1;
  static List<String> createdTestIds = <String>[];
  
  AFAtomicTestDataRegistry({
    required this.testData
  });

  void registerAtomic(dynamic id, dynamic data) {
    testData[id] = data;
  }

  static String get uniqueId {
    final result = uniqueIdBase.toString();
    uniqueIdBase++;
    return result;
  }  

  void registerComposites(AFTestDataCompositeGeneratorDelegate register);

}


/// A registry of test data objects which can include composite objects referring
/// to other test data objects.
class AFCompositeTestDataRegistry extends AFAtomicTestDataRegistry {
  final List<AFTestDataCompositeGeneratorDelegate> generators;

  AFCompositeTestDataRegistry({
    required Map<dynamic, dynamic> testData, 
    required this.generators
  }): super(testData: testData);

  factory AFCompositeTestDataRegistry.create() {
    return AFCompositeTestDataRegistry(testData: <dynamic, dynamic>{}, generators: <AFTestDataCompositeGeneratorDelegate>[]);
  }

  void registerComposites(AFTestDataCompositeGeneratorDelegate generator) {
    generators.add(generator);
    generator(this);
  }

  void registerComposite(dynamic id, dynamic data) {
    registerAtomic(id, data);
  }

  static String? filterTestId(dynamic candidate) {
    if(candidate is String) {
      return candidate;
    }
    return null;
  }



  AFCompositeTestDataRegistry cloneForWireframe() {
    return AFCompositeTestDataRegistry(
      testData: Map<dynamic, dynamic>.from(testData),
      generators: generators,
    );
  }

  void regenerate() {
    for(final gen in generators) {
      gen(this);
    }
  }

  /// Find a test data object by its id, but if the id is not a string,
  /// just return it.
  /// 
  /// If the id you pass in is not a string, then the object you pass in 
  /// as the id will be returned as the result.   This allows you to
  /// implement parameterized tests where you can pass in either an
  /// instance of the object you want, or an id for an intestance of that object
  /// in the test data registry.
  dynamic f(dynamic id) {
    if(id is String) {
      final result = testData[id];
      return result ?? id;
    } 
    return id;
  }

  /// See the shortened version [f].
  dynamic find(dynamic id) {
    return f(id);
  }

  dynamic findStateViews(dynamic id) {
    if(id is String || id is int) {
      return f(id);
    } else if(id is List) {
      return findList(id);
    } else {
      return id;
    }
  }

  List<TData> findList<TData>(List<dynamic> ids) {
    final list = <TData>[];
    for(final id in ids) {
      TData data = f(id);
      list.add(data);
    }
    return list;
  }

}