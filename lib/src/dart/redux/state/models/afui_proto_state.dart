import 'package:afib/afui_id.dart';
import 'package:afib/src/dart/redux/queries/af_time_update_listener_query.dart';
import 'package:afib/src/dart/redux/state/models/af_app_state.dart';
import 'package:afib/src/dart/redux/state/models/af_test_state.dart';
import 'package:afib/src/dart/redux/state/models/af_time_state.dart';
import 'package:afib/src/dart/utils/af_typedefs_dart.dart';
import 'package:afib/src/flutter/test/af_base_test_execute.dart';
import 'package:afib/src/flutter/test/af_screen_test.dart';
import 'package:flutter/foundation.dart';


mixin AFUIStateModelAccess on AFStateModelAccess {
  AFSingleScreenTests get screenTests { return findType<AFSingleScreenTests>();}
  AFScreenPrototype? get prototype { return findIdOrNull<AFScreenPrototype>(AFUIState.prototypeModel); }
  AFScreenTestContext? get testContext { return findIdOrNull<AFScreenTestContext>(AFBaseTestExecute.testExecuteId); }
  AFSingleScreenTestState get singleScreenTestState { return findType<AFSingleScreenTestState>(); }
  AFTimeState get time { return findType<AFTimeState>(); }
  AFTimeUpdateListenerQuery? get timeQuery { return findIdOrNull<AFTimeUpdateListenerQuery>(AFUIQueryID.time.toString()); }
}

//---------------------------------------------------------------------------------------
@immutable
class AFUIState extends AFFlexibleState with AFUIStateModelAccess {
  static const prototypeModel = "prototype_model";

  //---------------------------------------------------------------------------------------
  static final AFCreateComponentStateDelegate creator = (models) => AFUIState(models);
  AFUIState(Map<String, Object> models): super(models: models, create: creator);

  static AFUIState initialValue() { 
    return AFUIState(AFFlexibleState.createModels([
      ]));
  }
}
  
