import 'package:afib/afui_id.dart';
import 'package:afib/src/dart/redux/actions/af_route_actions.dart';
import 'package:afib/src/dart/utils/af_id.dart';
import 'package:afib/src/dart/utils/af_route_param.dart';
import 'package:afib/src/flutter/core/af_app_extension_context.dart';
import 'package:afib/src/flutter/ui/afui_connected_base.dart';
import 'package:afib/src/flutter/ui/screen/af_connected_screen.dart';
import 'package:afib/src/flutter/ui/stateviews/afui_default_state_view.dart';
import 'package:afib/src/flutter/ui/theme/afui_default_theme.dart';
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

class AFUIPrototypeThirdPartyHomeScreenSPI extends AFUIScreenSPI<AFUIDefaultStateView, AFUIPrototypeThirdPartyHomeParam> {
  AFUIPrototypeThirdPartyHomeScreenSPI(AFBuildContext<AFUIDefaultStateView, AFUIPrototypeThirdPartyHomeParam> context, AFScreenID screenId, AFUIDefaultTheme theme): super(context, screenId, theme, );
  
  factory AFUIPrototypeThirdPartyHomeScreenSPI.create(AFBuildContext<AFUIDefaultStateView, AFUIPrototypeThirdPartyHomeParam> context, AFUIDefaultTheme theme, AFScreenID screenId) {
    return AFUIPrototypeThirdPartyHomeScreenSPI(context, screenId, theme,
    );
  }
}

/// A screen used internally in prototype mode to render screens and widgets with test data,
/// and display them in a list.
class AFUIPrototypeThirdPartyHomeScreen extends AFUIConnectedScreen<AFUIPrototypeThirdPartyHomeScreenSPI, AFUIDefaultStateView, AFUIPrototypeThirdPartyHomeParam> {

  static final config =  AFUIDefaultScreenConfig<AFUIPrototypeThirdPartyHomeScreenSPI, AFUIPrototypeThirdPartyHomeParam> (
    spiCreator: AFUIPrototypeThirdPartyHomeScreenSPI.create,
  );

  AFUIPrototypeThirdPartyHomeScreen(): super(screenId: AFUIScreenID.screenPrototypeThirdPartyHome, config: config);

  static AFNavigatePushAction navigatePush(AFUILibraryExtensionContext libraryContext) {
    return AFNavigatePushAction(
      routeParam: AFUIPrototypeThirdPartyHomeParam.create(libraryContext));
  }

  @override
  Widget buildWithSPI(AFUIPrototypeThirdPartyHomeScreenSPI spi) {
    return _buildThirdParty(spi);
  }

  /// 
  Widget _buildThirdParty(AFUIPrototypeThirdPartyHomeScreenSPI spi) {
    final t = spi.t;
    final context = spi.context;
    final libraryContext = context.p.libraryContext;
    final libraryName = libraryContext.id.name;
    
    final libraryTests = AFibF.g.libraryTests(libraryContext.id);
    
    final cardRows = t.column();
    if(libraryTests != null) {
      t.buildThirdPartyPrototypeNav(
        spi: spi,
        tests: libraryTests,
        rows: cardRows,
      );
    }
    
    final rows = t.column();
    rows.add(t.childCardHeader(context, AFUIWidgetID.cardPrototype, "Prototypes and Tests", cardRows, margin: t.margin.b.s3));
    final leading = t.childButtonStandardBack(spi, screen: screenId);
    return t.buildPrototypeScaffold(libraryName, rows, leading: leading);
  }
}
