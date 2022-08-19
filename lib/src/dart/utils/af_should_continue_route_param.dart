
import 'package:afib/src/dart/utils/af_id.dart';
import 'package:afib/src/dart/utils/af_route_param.dart';

enum AFShouldContinue {
  yesContinue,
  noCancel
}

class AFShouldContinueRouteParam extends AFDialogRouteParam {
  final AFShouldContinue shouldContinue;

  AFShouldContinueRouteParam({
    required AFScreenID screenId,
    required this.shouldContinue,
  }): super(screenId: screenId);

  AFShouldContinueRouteParam copyWith({
    AFShouldContinue? shouldContinue
  }) {
    return AFShouldContinueRouteParam(
      screenId: screenId, 
      shouldContinue: shouldContinue ?? this.shouldContinue
    );
  }
}