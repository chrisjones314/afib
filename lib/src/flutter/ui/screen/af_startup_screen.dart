//--------------------------------------------------------------------------------------
import 'package:afib/src/dart/command/af_command_enums.dart';
import 'package:afib/src/dart/redux/queries/af_start_specific_prototype_query.dart';
import 'package:afib/src/dart/utils/af_exception.dart';
import 'package:afib/src/dart/utils/afib_d.dart';
import 'package:afib/src/flutter/utils/af_typedefs_flutter.dart';
import 'package:afib/src/flutter/utils/afib_f.dart';
import 'package:flutter/widgets.dart';

//--------------------------------------------------------------------------------------
class AFStartupScreenWrapper extends StatefulWidget {
  const AFStartupScreenWrapper({Key? key}) : super(key: key);

  //--------------------------------------------------------------------------------------
  @override
  _AFStartupScreenState createState() => _AFStartupScreenState();

}

//--------------------------------------------------------------------------------------
class AFLifecycleEventHandler extends WidgetsBindingObserver {
  final AFOnLifecycleEventDelegate eventHandler;

  AFLifecycleEventHandler({
    required this.eventHandler
  });

  @override
  Future<void> didChangeAppLifecycleState(AppLifecycleState state) async {
    this.eventHandler(state);
  }
}

//--------------------------------------------------------------------------------------
class _AFStartupScreenState extends State<AFStartupScreenWrapper> {
  //--------------------------------------------------------------------------------------
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addObserver(AFibF.g.widgetsBindingObserver);

    final storeDisp = AFibF.g.internalOnlyActiveDispatcher;
    if(AFibD.config.requiresPrototypeData) {
      // if this is not the general prototype mode, then fire a startup query which 
      // loads that specific prototype.
      if(AFibD.config.environment != AFEnvironment.prototype) {
        storeDisp.dispatch(AFStartSpecificPrototypeQuery());
      }
    } else {
      // Kick off the app by firing a query.  In a typical app this might check the user's
      // logged in status while a splash screen displays.
      AFibF.g.dispatchStartupQueries(storeDisp);
    }
  }

  //--------------------------------------------------------------------------------------
  @override 
  void dispose() {
    super.dispose();
  }


  //--------------------------------------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    final builder = AFibF.g.screenMap.initialScreenBuilder;
    if(builder == null) throw AFException("Error missing initial screen builder");
    return builder(context);
  }
}
