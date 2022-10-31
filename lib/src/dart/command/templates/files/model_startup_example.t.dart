

import 'package:afib/src/dart/command/af_source_template.dart';

class AFModelStartupExampleT extends AFSourceTemplate {

  final String template = '''
import 'package:meta/meta.dart';

@immutable
class [!af_model_name] {
  final int count;
  [!af_model_name]({
    required this.count
  });

  factory [!af_model_name].initialState() {
    return [!af_model_name](count: 0);
  }

  CountInStateRoot reviseIncrementCount() {
    return copyWith(count: count+1);
  }

  [!af_model_name] copyWith({
    int? count
  }) {
    return [!af_model_name](
      count: count ?? this.count,      
    );
  }
}
''';
}
