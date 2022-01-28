import 'package:afib/id.dart';
import 'package:afib/src/dart/redux/actions/af_route_actions.dart';
import 'package:afib/src/dart/utils/af_route_param.dart';
import 'package:afib/src/flutter/core/af_app_extension_context.dart';
import 'package:afib/src/flutter/ui/afui_connected_base.dart';
import 'package:afib/src/flutter/ui/screen/af_connected_screen.dart';
import 'package:afib/src/flutter/ui/stateviews/afui_prototype_state_view.dart';
import 'package:afib/src/flutter/utils/afib_f.dart';
import 'package:flutter/material.dart';


/// Parameter uses to filter the tests shown on the screen.
@immutable
class AFUIPrototypeThirdPartyHomeParam extends AFRouteParam {
  final AFUILibraryExtensionContext libraryContext;

  AFUIPrototypeThirdPartyHomeParam({required this.libraryContext}): super(id: AFUIScreenID.screenPrototypeThirdPartyHome);
  
  factory AFUIPrototypeThirdPartyHomeParam.create(AFUILibraryExtensionContext context) {
    return AFUIPrototypeThirdPartyHomeParam(libraryContext: context);
  }
}

class AFUIPrototypeThirdPartyHomeScreenSPI extends AFUIScreenDefaultSPI<AFUIPrototypeStateView, AFUIPrototypeThirdPartyHomeParam> {
  AFUIPrototypeThirdPartyHomeScreenSPI(AFUIBuildContext<AFUIPrototypeStateView, AFUIPrototypeThirdPartyHomeParam> context, AFConnectedUIBase screen): super(context, screen);
  factory AFUIPrototypeThirdPartyHomeScreenSPI.create(AFUIBuildContext<AFUIPrototypeStateView, AFUIPrototypeThirdPartyHomeParam> context, AFConnectedUIBase screen) {
    return AFUIPrototypeThirdPartyHomeScreenSPI(context, screen);
  }
}

/// A screen used internally in prototype mode to render screens and widgets with test data,
/// and display them in a list.
class AFUIPrototypeThirdPartyHomeScreen extends AFUIDefaultConnectedScreen<AFUIPrototypeThirdPartyHomeScreenSPI, AFUIPrototypeThirdPartyHomeParam>{
  AFUIPrototypeThirdPartyHomeScreen(): super(AFUIScreenID.screenPrototypeThirdPartyHome, AFUIPrototypeThirdPartyHomeScreenSPI.create);

  static AFNavigatePushAction navigatePush(AFUILibraryExtensionContext libraryContext) {
    return AFNavigatePushAction(
      routeParam: AFUIPrototypeThirdPartyHomeParam.create(libraryContext));
  }

  @override
  Widget buildWithContext(AFUIPrototypeThirdPartyHomeScreenSPI spi) {
    return _buildThirdParty(spi.context);
  }

  /// 
  Widget _buildThirdParty(AFUIBuildContext<AFUIPrototypeStateView, AFUIPrototypeThirdPartyHomeParam> context) {
    final t = context.t;
    final libraryContext = context.p.libraryContext;
    final libraryName = libraryContext.id.name;
    
    final libraryTests = AFibF.g.libraryTests(libraryContext.id);
    
    final cardRows = t.column();
    if(libraryTests != null) {
      t.buildTestNavDownAll(
        context: context,
        tests: libraryTests,
        rows: cardRows,
      );
    }
    
    final rows = t.column();
    rows.add(t.childCardHeader(context, AFUIWidgetID.cardTestHomeHeader, "Prototypes and Tests", cardRows, margin: t.margin.b.s3));
    final leading = t.childButtonStandardBack(context, screen: screenId);
    return t.buildPrototypeScaffold(libraryName, rows, leading: leading);
  }
}
