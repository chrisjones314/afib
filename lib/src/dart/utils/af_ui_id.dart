
import 'package:afib/src/dart/utils/af_id.dart';

class AFUIID {
  static const afibScreenPrefix = "_afib_";
  static const screenStartup = AFScreenID("${afibScreenPrefix}startup");
  static const screenPrototypeListSingleScreen = AFScreenID("${afibScreenPrefix}prototype_list_single_screen");
  static const screenPrototypeListWorkflow = AFScreenID("${afibScreenPrefix}prototype_list_multi_screen");
  static const screenPrototypeSingleScreen = AFScreenID("${afibScreenPrefix}prototype_single_screen");
  static const screenPrototypeWorkflow = AFScreenID("${afibScreenPrefix}prototype_multi_screen");
  static const screenTestDrawer = AFScreenID("${afibScreenPrefix}prototype_test_drawer");
  static const screenPrototypeHome = AFScreenID("${afibScreenPrefix}prototype_home");
  static const screenPrototypeWidget = AFScreenID("${afibScreenPrefix}prototype_widget");
  static const buttonBack = AFWidgetID("${afibScreenPrefix}button_back");  
}

