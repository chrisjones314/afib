
import 'package:afib/afib_flutter.dart';
import 'package:afib/src/dart/utils/af_typedefs_dart.dart';
import 'package:meta/meta.dart';

class AFFlutterParams<AppState> {
  final AFInitScreenMapDelegate         initScreenMap;
  final AFInitializeAppStateDelegate       initialAppState;
  final AFCreateStartupQueryActionDelegate createStartupQueryAction;
  final AFCreateLifecycleQueryAction createLifecycleQueryAction;
  final AFCreateAFAppDelegate createApp;
  final AFInitTestDataDelegate initTestData;
  final AFInitUnitTestsDelegate initUnitTests;
  final AFInitStateTestsDelegate initStateTests;
  final AFInitWidgetTestsDelegate initWidgetTests;
  final AFInitScreenTestsDelegate initScreenTests;
  final AFAppReducerDelegate<AppState>  appReducer;
  final AFInitWorkflowStateTestsDelegate initWorkflowStateTests;
  
  AFFlutterParams({
    @required this.initScreenMap,
    @required this.initialAppState,
    @required this.createStartupQueryAction,
    @required this.createLifecycleQueryAction,
    @required this.createApp,
    @required this.initTestData,
    @required this.initUnitTests,
    @required this.initWidgetTests,
    @required this.initStateTests,
    @required this.initScreenTests,
    @required this.initWorkflowStateTests,
    this.appReducer
  });
}