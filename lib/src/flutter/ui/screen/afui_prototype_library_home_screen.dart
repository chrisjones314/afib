import 'package:afib/afib_uiid.dart';
import 'package:afib/src/dart/redux/actions/af_route_actions.dart';
import 'package:afib/src/dart/utils/af_route_param.dart';
import 'package:afib/src/flutter/core/af_app_extension_context.dart';
import 'package:afib/src/flutter/ui/afui_connected_base.dart';
import 'package:afib/src/flutter/ui/screen/af_connected_screen.dart';
import 'package:afib/src/flutter/ui/stateviews/afui_default_state_view.dart';
import 'package:afib/src/flutter/utils/afib_f.dart';
import 'package:flutter/material.dart';


/// Parameter uses to filter the tests shown on the screen.
@immutable
class AFUIPrototypeLibraryHomeParam extends AFScreenRouteParam {
  final AFCoreLibraryExtensionContext libraryContext;

  AFUIPrototypeLibraryHomeParam({required this.libraryContext}): super(screenId: AFUIScreenID.screenPrototypeLibraryHome);
  
  factory AFUIPrototypeLibraryHomeParam.create(AFCoreLibraryExtensionContext context) {
    return AFUIPrototypeLibraryHomeParam(libraryContext: context);
  }
}

class AFUIPrototypeLibraryHomeScreenSPI extends AFUIScreenSPI<AFUIDefaultStateView, AFUIPrototypeLibraryHomeParam> {
  const AFUIPrototypeLibraryHomeScreenSPI(AFBuildContext<AFUIDefaultStateView, AFUIPrototypeLibraryHomeParam> context, AFStandardSPIData standard): super(context, standard);
  
  factory AFUIPrototypeLibraryHomeScreenSPI.create(AFBuildContext<AFUIDefaultStateView, AFUIPrototypeLibraryHomeParam> context, AFStandardSPIData standard) {
    return AFUIPrototypeLibraryHomeScreenSPI(context, standard,
    );
  }
}

/// A screen used internally in prototype mode to render screens and widgets with test data,
/// and display them in a list.
class AFUIPrototypeLibraryHomeScreen extends AFUIConnectedScreen<AFUIPrototypeLibraryHomeScreenSPI, AFUIDefaultStateView, AFUIPrototypeLibraryHomeParam> {

  static final config =  AFUIDefaultScreenConfig<AFUIPrototypeLibraryHomeScreenSPI, AFUIPrototypeLibraryHomeParam> (
    spiCreator: AFUIPrototypeLibraryHomeScreenSPI.create,
  );

  AFUIPrototypeLibraryHomeScreen(): super(screenId: AFUIScreenID.screenPrototypeLibraryHome, config: config);

  static AFNavigatePushAction navigatePush(AFCoreLibraryExtensionContext libraryContext) {
    return AFNavigatePushAction(
      launchParam: AFUIPrototypeLibraryHomeParam.create(libraryContext));
  }

  @override
  Widget buildWithSPI(AFUIPrototypeLibraryHomeScreenSPI spi) {
    return _buildLibrary(spi);
  }

  /// 
  Widget _buildLibrary(AFUIPrototypeLibraryHomeScreenSPI spi) {
    final t = spi.t;
    final context = spi.context;
    final libraryContext = context.p.libraryContext;
    final libraryName = libraryContext.id.name;
    
    final libraryTests = AFibF.g.libraryTests(libraryContext.id);
    
    final cardRows = t.column();
    if(libraryTests != null) {
      t.buildLibraryPrototypeNav(
        spi: spi,
        tests: libraryTests,
        rows: cardRows,
      );
    }
    
    final rows = t.column();
    rows.add(t.childCardHeader(context, AFUIWidgetID.cardPrototype, "Prototypes and Tests", cardRows, margin: t.margin.b.s3));
    final main = ListView(children: rows);
    final leading = t.childButtonStandardBack(spi, screen: screenId);
    return t.buildPrototypeScaffold(spi, libraryName, main, leading: leading);
  }
}
