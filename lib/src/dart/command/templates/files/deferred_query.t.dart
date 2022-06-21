import 'package:afib/src/dart/command/af_source_template.dart';

class DeferredQueryT extends AFSourceTemplate {

  final String template = '''
import 'package:afib/afib_flutter.dart';
[!af_import_statements]

class [!af_query_name]Query extends AFDeferredQuery {
  
  [!af_query_name]Query({
    AFID? id,
    Duration duration = const Duration(milliseconds: 300),
    AFOnResponseDelegate<AFUnused>? onSuccessDelegate,
  }): super(
    duration,
    id: id,
    onSuccessDelegate: onSuccessDelegate,
  );
  
  @override
  Duration? finishAsyncExecute(AFFinishQuerySuccessContext<[!af_state_type], AFUnused> context) {
    // this method is executed after the specified duration.  
    // return a non-null duration to call this method again at a later time.
    return null;
  }

  [!af_additional_methods]

}
''';
}

