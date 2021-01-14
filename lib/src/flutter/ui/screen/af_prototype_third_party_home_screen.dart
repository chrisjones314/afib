

import 'package:afib/afib_flutter.dart';
import 'package:afib/src/dart/redux/actions/af_route_actions.dart';
import 'package:afib/src/dart/redux/state/af_app_state.dart';
import 'package:afib/src/dart/redux/state/af_state.dart';
import 'package:afib/src/dart/utils/af_route_param.dart';
import 'package:afib/src/dart/utils/af_ui_id.dart';
import 'package:afib/src/flutter/ui/af_prototype_base.dart';
import 'package:afib/src/flutter/utils/af_state_view.dart';
import 'package:flutter/material.dart';


/// Parameter uses to filter the tests shown on the screen.
@immutable
class AFPrototypeThirdPartyHomeParam extends AFRouteParam {
  final AFUILibraryExtensionContext libraryContext;

  AFPrototypeThirdPartyHomeParam({this.libraryContext});
  
  factory AFPrototypeThirdPartyHomeParam.create(AFUILibraryExtensionContext context) {
    return AFPrototypeThirdPartyHomeParam(libraryContext: context);
  }
}

/// A screen used internally in prototype mode to render screens and widgets with test data,
/// and display them in a list.
class AFPrototypeThirdPartyHomeScreen extends AFProtoConnectedScreen<AFStateView, AFPrototypeThirdPartyHomeParam>{
  AFPrototypeThirdPartyHomeScreen(): super(AFUIScreenID.screenPrototypeThirdPartyHome);

  static AFNavigatePushAction navigatePush(AFUILibraryExtensionContext libraryContext) {
    return AFNavigatePushAction(screen: AFUIScreenID.screenPrototypeThirdPartyHome,
      param: AFPrototypeThirdPartyHomeParam.create(libraryContext));
  }

  @override
  AFStateView createStateViewAF(AFState state, AFRouteParam param, AFRouteParamWithChildren withChildren) {
    return AFStateView.unused();
  }

  @override
  AFStateView createStateView(AFAppStateArea state, AFRouteParam param) {
    // this should never be called, because createStateViewAF replaces it.
    throw UnimplementedError();
  }

  @override
  Widget buildWithContext(AFProtoBuildContext<AFStateView, AFPrototypeThirdPartyHomeParam> context) {
    return _buildThirdParty(context);
  }

  /// 
  Widget _buildThirdParty(AFProtoBuildContext<AFStateView, AFPrototypeThirdPartyHomeParam> context) {
    final t = context.t;
    final libraryContext = context.p.libraryContext;
    final libraryName = libraryContext.libraryName;
    
    final libraryTests = AFibF.g.libraryTests(libraryContext.libraryId);

    final cardRows = t.column();
    t.buildTestNavDownAll(
      context: context,
      tests: libraryTests,
      rows: cardRows,
    );
    
    final rows = t.column();
    rows.add(t.childCardHeader(context, AFUIWidgetID.cardTestHomeHeader, "Prototypes and Tests", cardRows, margin: t.margin.b.s3));
    final leading = t.childButtonStandardBack(context);
    return t.buildPrototypeScaffold(libraryName, rows, leading: leading);
  }
}
