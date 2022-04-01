

import 'package:afib/src/dart/command/af_source_template.dart';

class AFScreenT extends AFSourceTemplate {

  final String template = '''
import 'package:afib/afib_flutter.dart';
import 'package:flutter/material.dart';
import 'package:[!af_package_name]/id.dart';
[!af_import_statements]

[!af_declare_route_param]

[!af_declare_spi]


class [!af_screen_name]Screen extends [!af_app_namespace(upper)]ConnectedScreen<[!af_screen_name]SPI, [!af_state_view_type], [!af_screen_name]RouteParam> {
  static final config = [!af_state_view_prefix]ScreenConfig<[!af_screen_name]SPI, [!af_screen_name]RouteParam> (
    spiCreator: [!af_screen_name]SPI.create,
  );

  [!af_screen_name]Screen(): super(screenId: [!af_screen_id_type].[!af_screen_id], config: config);

  static AFNavigatePushAction navigatePush() {
    return AFNavigatePushAction(
      routeParam: [!af_screen_name]RouteParam.create()
    );
  }

  @override
  Widget buildWithSPI([!af_screen_name]SPI spi) {
    final t = spi.t;
    final body = _buildBody(spi);
    return t.childScaffold(
      spi: spi,
      body: body,
    );
  }

  Widget _buildBody([!af_screen_name]SPI spi) {
    final t = spi.t;
    return Center(child: t.childText("[!af_screen_name]"));
  }
}
''';
}
