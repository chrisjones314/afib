
//--------------------------------------------------------------------------------------
import 'package:flutter/widgets.dart';

import '../../../afib_flutter.dart';

//--------------------------------------------------------------------------------------
class AFStartupScreenWrapper extends StatefulWidget {
  const AFStartupScreenWrapper({Key key}) : super(key: key);

  //--------------------------------------------------------------------------------------
  @override
  _AFStartupScreenState createState() => _AFStartupScreenState();

}

typedef AFOnLifecycleEvent = void Function(AppLifecycleState newState);

//--------------------------------------------------------------------------------------
class AFLifecycleEventHandler extends WidgetsBindingObserver {
  final AFOnLifecycleEvent eventHandler;

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

    if(AFibF.createLifecycleQueryAction != null) {
      WidgetsBinding.instance.addObserver(
        AFLifecycleEventHandler(eventHandler: (state) {
          AFibF.internalOnlyStore.dispatch(AFibF.createLifecycleQueryAction(state));
        })
      );
    }


    // Kick off the app by firing a query.  In a typical app this might check the user's
    // logged in status while a splash screen displays.
    AFibF.internalOnlyStore.dispatch(AFibF.createStartupQueryAction());
  }

  //--------------------------------------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    final builder = AFibF.screenMap.initialScreenBuilder;
    return builder(context);
  }
}
