import 'package:afib/afib_dart.dart';
import 'package:afib/src/dart/redux/state/af_app_state.dart';
import 'package:afib/src/dart/utils/af_route_param.dart';
import 'package:afib/src/dart/utils/af_unused.dart';
import 'package:afib/src/flutter/af.dart';
import 'package:afib/src/flutter/screen/af_connected_screen.dart';
import 'package:flutter/material.dart';

//--------------------------------------------------------------------------------------
class AFTestDrawerData extends AFStoreConnectorData1<AFUnused> {
  AFTestDrawerData(): 
    super();
}

//--------------------------------------------------------------------------------------
class AFTestDrawer extends AFConnectedWidget<AFAppState, AFTestDrawerData, AFRouteParamUnused> {
  
  //--------------------------------------------------------------------------------------
  AFTestDrawer(): super(null);

  //--------------------------------------------------------------------------------------
  @override
  AFTestDrawerData createData(AFAppState state) {
    return AFTestDrawerData();
  }

  //--------------------------------------------------------------------------------------
  @override
  Widget buildWithContext(AFBuildContext<AFTestDrawerData, AFRouteParamUnused> context) {
    return _buildDrawer(context);
  }

  //--------------------------------------------------------------------------------------
  Widget _buildDrawer(AFBuildContext<AFTestDrawerData, AFRouteParamUnused> context) {
    List<Widget> tiles = new List<Widget>();

    tiles.add(DrawerHeader(
        child: Center(
          child: Text("AFib Debug Drawer"),
        ),
        decoration: BoxDecoration(
          color: Colors.lightBlue,
        ),
    ));
    
    tiles.add(ListTile(
        leading: Icon(Icons.arrow_back),
        title: Text('Back'),
        onTap: () {
          Navigator.pop(context.c);
          context.dispatch(AFNavigatePopAction());
        }));

    return Drawer(      
      child: ListView(
        padding: EdgeInsets.zero,
        children: tiles,
    ));
  }

  //--------------------------------------------------------------------------------------
  void _testVisitingChildren(int depth, Element c) {
    c.visitChildElements((element) {
      Widget w = element.widget;
      StringBuffer sb = StringBuffer();
      for(int i = 0; i < depth; i++) {
        sb.write("  ");
      }
      sb.write(w.runtimeType.toString());
      if(w.key != null) {
        sb.write(": ");
        sb.write(w.key);
      }
      AF.logger.fine(sb.toString());
      _testVisitingChildren(depth+1, element);
     });
  }  
}
