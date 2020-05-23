
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

    // tell redux to check the login status.
    AF.store.dispatch(AF.createStartupQueryAction());
  }

  //--------------------------------------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    WidgetBuilder builder = AF.screenMap.initialScreenBuilder;
    return builder(context);
  }
}
