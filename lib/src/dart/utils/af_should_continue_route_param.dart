

import 'package:afib/src/dart/utils/af_route_param.dart';
import 'package:flutter/material.dart';

enum AFShouldContinue {
  yesContinue,
  noCancel
}

@immutable
class AFShouldContinueRouteParam extends AFRouteParam {
  final AFShouldContinue shouldContinue;
  AFShouldContinueRouteParam(this.shouldContinue);
}