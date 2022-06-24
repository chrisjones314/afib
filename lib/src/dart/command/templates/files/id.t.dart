




import 'package:afib/src/dart/command/af_source_template.dart';

class AFAppcodeIDT extends AFSourceTemplate {

  final String template = '''

import 'package:afib/afib_command.dart';

class [!af_app_namespace(upper)]LibraryID {
  static const id = AFLibraryID(code: "[!af_app_namespace]", name: "[!af_package_name]");
}

class [!af_app_namespace(upper)]QueryID extends AFQueryID {


  const [!af_app_namespace(upper)]QueryID(String code): super(code, [!af_app_namespace(upper)]LibraryID.id);
}

class [!af_app_namespace(upper)]ThemeID extends AFThemeID {
  static const defaultTheme = [!af_app_namespace(upper)]ThemeID("defaultTheme");

  const [!af_app_namespace(upper)]ThemeID(String code): super(code, [!af_app_namespace(upper)]LibraryID.id);   
}

class [!af_app_namespace(upper)]ScreenID extends AFScreenID {


  const [!af_app_namespace(upper)]ScreenID(String code) : super(code, [!af_app_namespace(upper)]LibraryID.id);
}

class [!af_app_namespace(upper)]DrawerID extends AFScreenID {


  const [!af_app_namespace(upper)]DrawerID(String code) : super(code, [!af_app_namespace(upper)]LibraryID.id);
}


class [!af_app_namespace(upper)]WidgetID extends AFWidgetID {  


  const [!af_app_namespace(upper)]WidgetID(String code) : super(code, [!af_app_namespace(upper)]LibraryID.id);
}

class [!af_app_namespace(upper)]LibraryProgrammingInterfaceID extends AFLibraryProgrammingInterfaceID {  


  const [!af_app_namespace(upper)]LibraryProgrammingInterfaceID(String code) : super(code, [!af_app_namespace(upper)]LibraryID.id);
}

class [!af_app_namespace(upper)]TestDataID {
  static const [!af_app_namespace]StateFullLogin = "[!af_app_namespace]StateFullLogin";
}

class [!af_app_namespace(upper)]StateTestID extends AFStateTestID {


  const [!af_app_namespace(upper)]StateTestID(String code): super(code, [!af_app_namespace(upper)]LibraryID.id); 
}

class [!af_app_namespace(upper)]ScreenTestID extends AFScreenTestID {


  const [!af_app_namespace(upper)]ScreenTestID(String code): super(code, [!af_app_namespace(upper)]LibraryID.id); 
}

class [!af_app_namespace(upper)]PrototypeID extends AFPrototypeID {


  const [!af_app_namespace(upper)]PrototypeID(String code): super(code, [!af_app_namespace(upper)]LibraryID.id); 
}

''';

}







