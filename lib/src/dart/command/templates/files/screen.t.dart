

import 'package:afib/src/dart/command/af_source_template.dart';

class AFScreenT extends AFSourceTemplate {

  final String template = '''
import 'package:afib/afib_flutter.dart';
import 'package:flutter/material.dart';
import 'package:[!af_package_name]/[!af_app_namespace]_id.dart';
[!af_import_statements]

[!af_declare_route_param]

[!af_declare_spi]


class [!af_screen_name] extends [!af_app_namespace(upper)]Connected[!af_control_type_suffix]<[!af_screen_name]SPI, [!af_state_view_type], [!af_screen_name]RouteParam> {
  // just used for the initial screen template, not signficant to function of framework and can be deleted.
  static const uiTitle = "[!af_screen_name(spaces)]";

  [!af_comment_config_decl]
  static final config = [!af_state_view_prefix]ScreenConfig<[!af_screen_name]SPI, [!af_screen_name]RouteParam> (
    spiCreator: [!af_screen_name]SPI.create,
  );

  [!af_screen_name](): super(
    screenId: [!af_screen_id_type].[!af_screen_id], 
    config: config,
    [!af_super_impls]
  );

  [!af_comment_navigate_push]
  static AFNavigatePushAction navigatePush() {
    return AFNavigatePushAction(
      routeParam: [!af_screen_name]RouteParam.create()
    );
  }

  [!af_comment_build_with_spi]
  @override
  Widget buildWithSPI([!af_screen_name]SPI spi) {
    [!af_build_with_spi_impl]
  }

  [!af_comment_build_body]
  Widget _buildBody([!af_screen_name]SPI spi) {
    [!af_build_body_impl]
  }
}
''';
}
