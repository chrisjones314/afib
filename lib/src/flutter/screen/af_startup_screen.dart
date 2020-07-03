
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

//--------------------------------------------------------------------------------------
class _AFStartupScreenState extends State<AFStartupScreenWrapper> {
  //--------------------------------------------------------------------------------------
  @override
  void initState() {
    super.initState();

    // Kick off the app by firing a query.  In a typical app this might check the user's
    // logged in status while a splash screen displays.
    AFibF.store.dispatch(AFibF.createStartupQueryAction());
  }

  //--------------------------------------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    WidgetBuilder builder = AFibF.screenMap.initialScreenBuilder;
    return builder(context);
  }
}
