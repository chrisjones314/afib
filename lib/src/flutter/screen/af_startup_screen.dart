
//--------------------------------------------------------------------------------------
import 'package:afib/src/flutter/utils/af_typedefs_flutter.dart';
import 'package:afib/src/flutter/utils/afib_f.dart';
import 'package:flutter/widgets.dart';

//--------------------------------------------------------------------------------------
class AFStartupScreenWrapper extends StatefulWidget {
  const AFStartupScreenWrapper({Key key}) : super(key: key);

  //--------------------------------------------------------------------------------------
  @override
  _AFStartupScreenState createState() => _AFStartupScreenState();

}

//--------------------------------------------------------------------------------------
class AFLifecycleEventHandler extends WidgetsBindingObserver {
  final AFOnLifecycleEventDelegate eventHandler;

  AFLifecycleEventHandler({
    this.eventHandler
  });

  @override
  Future<Null> didChangeAppLifecycleState(AppLifecycleState state) async {
    this.eventHandler(state);
  }
}


//--------------------------------------------------------------------------------------
class _AFStartupScreenState extends State<AFStartupScreenWrapper> {
  //--------------------------------------------------------------------------------------
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addObserver(
      AFLifecycleEventHandler(eventHandler: (state) {
        AFibF.g.dispatchLifecycleActions(AFibF.g.storeDispatcherInternalOnly, state);
      })
    );

    // Kick off the app by firing a query.  In a typical app this might check the user's
    // logged in status while a splash screen displays.
    AFibF.g.dispatchStartupActions(AFibF.g.storeDispatcherInternalOnly);
  }

  //--------------------------------------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    final builder = AFibF.g.screenMap.initialScreenBuilder;
    return builder(context);
  }
}
