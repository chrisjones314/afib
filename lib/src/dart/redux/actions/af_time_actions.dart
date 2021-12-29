

import 'package:afib/src/dart/redux/state/models/af_time_state.dart';

class AFUpdateTimeStateAction {
  final AFTimeState revised;
  AFUpdateTimeStateAction(this.revised);
}