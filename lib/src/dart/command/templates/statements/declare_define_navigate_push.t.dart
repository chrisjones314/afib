import 'package:afib/src/dart/command/af_source_template.dart';

class DeclareDefineNavigatePushT extends AFSourceTemplate {
  final String template = '''
  [!af_comment_navigate_push]
  static AFNavigatePushAction navigatePush() {
    return AFNavigatePushAction(
      routeParam: [!af_screen_name]RouteParam.create()
    );
  }
  ''';
}
