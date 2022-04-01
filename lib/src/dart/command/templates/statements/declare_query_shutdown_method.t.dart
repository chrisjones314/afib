import 'package:afib/src/dart/command/af_source_template.dart';

class DeclareQueryShutdownMethodT extends AFSourceTemplate {
  final String template = '''
  /// This method is called when you execute an AFShutdownOngoingQueriesAction
  /// or when you re-execute a query of this type, replacing the existing listener
  /// with a new/differently configured query.
  @override
  void shutdown() {

  }

''';  
}
