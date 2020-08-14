
import 'package:afib/src/dart/utils/af_id.dart';

class AFUIID {
  static const afibScreenPrefix = "_afib_";
  static const screenStartup = AFScreenID("${afibScreenPrefix}startup");
  static const screenSimplePrototypeList = AFScreenID("${afibScreenPrefix}simple_prototype_list");
  static const screenMultiScreenTestList = AFScreenID("${afibScreenPrefix}multi_screen_test_list");
  static const screenPrototypeSimple = AFScreenID("${afibScreenPrefix}prototype_simple");
  static const screenPrototypeState = AFScreenID("${afibScreenPrefix}prototype_state");
  static const screenPrototypeHome = AFScreenID("${afibScreenPrefix}prototype_home");
  static const buttonBack = AFWidgetID("${afibScreenPrefix}button_back");  
}

