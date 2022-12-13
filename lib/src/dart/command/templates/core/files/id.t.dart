import 'package:afib/src/dart/command/af_source_template.dart';

class IDT extends AFCoreFileSourceTemplate {

  IDT(): super(
    templateFileId: "id",
  );

  String get template => '''
import 'package:afib/afib_command.dart';

class ${insertAppNamespaceUpper}LibraryID {
  static const id = AFLibraryID(code: "$insertAppNamespace", name: "$insertPackageName");
}

class ${insertAppNamespaceUpper}QueryID extends AFQueryID {


  const ${insertAppNamespaceUpper}QueryID(String code): super(code, ${insertAppNamespaceUpper}LibraryID.id);
}

class ${insertAppNamespaceUpper}ThemeID extends AFThemeID {
  static const defaultTheme = ${insertAppNamespaceUpper}ThemeID("defaultTheme");

  const ${insertAppNamespaceUpper}ThemeID(String code): super(code, ${insertAppNamespaceUpper}LibraryID.id);   
}

class ${insertAppNamespaceUpper}ScreenID extends AFScreenID {


  const ${insertAppNamespaceUpper}ScreenID(String code) : super(code, ${insertAppNamespaceUpper}LibraryID.id);
}

class ${insertAppNamespaceUpper}DrawerID extends AFScreenID {


  const ${insertAppNamespaceUpper}DrawerID(String code) : super(code, ${insertAppNamespaceUpper}LibraryID.id);
}

class ${insertAppNamespaceUpper}DialogID extends AFScreenID {


  const ${insertAppNamespaceUpper}DialogID(String code) : super(code, ${insertAppNamespaceUpper}LibraryID.id);
}


class ${insertAppNamespaceUpper}BottomSheetID extends AFScreenID {


  const ${insertAppNamespaceUpper}BottomSheetID(String code) : super(code, ${insertAppNamespaceUpper}LibraryID.id);
}

class ${insertAppNamespaceUpper}WidgetID extends AFWidgetID {  
  static const standardClose = ${insertAppNamespaceUpper}WidgetID("standardClose");


  const ${insertAppNamespaceUpper}WidgetID(String code) : super(code, ${insertAppNamespaceUpper}LibraryID.id);
}

class ${insertAppNamespaceUpper}LibraryProgrammingInterfaceID extends AFLibraryProgrammingInterfaceID {  


  const ${insertAppNamespaceUpper}LibraryProgrammingInterfaceID(String code) : super(code, ${insertAppNamespaceUpper}LibraryID.id);
}

class ${insertAppNamespaceUpper}TestDataID {
  static const ${insertAppNamespace}StateFullLogin = "${insertAppNamespace}StateFullLogin";
}

class ${insertAppNamespaceUpper}UnitTestID extends AFStateTestID {


  const ${insertAppNamespaceUpper}UnitTestID(String code): super(code, ${insertAppNamespaceUpper}LibraryID.id); 
}


class ${insertAppNamespaceUpper}StateTestID extends AFStateTestID {


  const ${insertAppNamespaceUpper}StateTestID(String code): super(code, ${insertAppNamespaceUpper}LibraryID.id); 
}

class ${insertAppNamespaceUpper}ScreenTestID extends AFScreenTestID {


  const ${insertAppNamespaceUpper}ScreenTestID(String code): super(code, ${insertAppNamespaceUpper}LibraryID.id); 
}

class ${insertAppNamespaceUpper}PrototypeID extends AFPrototypeID {


  const ${insertAppNamespaceUpper}PrototypeID(String code): super(code, ${insertAppNamespaceUpper}LibraryID.id); 
}

class ${insertAppNamespaceUpper}WireframeID extends AFWireframeID {


  const ${insertAppNamespaceUpper}WireframeID(String code): super(code, ${insertAppNamespaceUpper}LibraryID.id); 
}


''';

}







