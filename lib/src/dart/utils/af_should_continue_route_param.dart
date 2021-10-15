
import 'package:afib/src/dart/utils/af_id.dart';
import 'package:afib/src/dart/utils/af_route_param.dart';

enum AFShouldContinue {
  yesContinue,
  noCancel
}

class AFShouldContinueRouteParam extends AFRouteParam {
  final AFShouldContinue shouldContinue;

  AFShouldContinueRouteParam({
    required AFID screenId,
    required this.shouldContinue,
  }): super(id: screenId);

  AFShouldContinueRouteParam copyWith({
    AFShouldContinue? shouldContinue
  }) {
    return AFShouldContinueRouteParam(
      screenId: id, 
      shouldContinue: shouldContinue ?? this.shouldContinue
    );
  }
}