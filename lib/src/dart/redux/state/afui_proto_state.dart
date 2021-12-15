import 'package:afib/src/dart/redux/state/af_app_state.dart';
import 'package:afib/src/dart/redux/state/af_test_state.dart';
import 'package:afib/src/dart/utils/af_typedefs_dart.dart';
import 'package:afib/src/flutter/test/af_base_test_execute.dart';
import 'package:afib/src/flutter/test/af_screen_test.dart';
import 'package:flutter/foundation.dart';


mixin AFUIPrototypeStateModelAccess on AFStateModelAccess {
  AFSingleScreenTests get screenTests { return findModel<AFSingleScreenTests>();}
  AFScreenPrototype? get prototype { return findIdOrNull<AFScreenPrototype>(AFUIPrototypeState.prototypeModel); }
  AFScreenTestContext? get testContext { return findIdOrNull<AFScreenTestContext>(AFBaseTestExecute.testExecuteId); }
  AFSingleScreenTestState get testState { return findModel<AFSingleScreenTestState>(); }
}

//---------------------------------------------------------------------------------------
@immutable
class AFUIPrototypeState extends AFFlexibleState with AFUIPrototypeStateModelAccess {
  static const prototypeModel = "prototype_model";

  //---------------------------------------------------------------------------------------
  static final AFCreateComponentStateDelegate creator = (models) => AFUIPrototypeState(models);
  AFUIPrototypeState(Map<String, Object> models): super(models: models, create: creator);

  static AFUIPrototypeState initialValue() { 
    return AFUIPrototypeState(AFFlexibleState.createModels([
      ]));
  }
}
  
