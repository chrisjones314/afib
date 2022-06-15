import 'package:afib/afui_id.dart';
import 'package:afib/src/dart/utils/af_exception.dart';
import 'package:quiver/core.dart';

class AFID {
  final List<Object>? withItems; 
  final String? prefix;
  final String codeId;
  final AFLibraryID? library;
  const AFID(this.prefix, this.codeId, this.library, {
    this.withItems
  });

  String get libraryTag {
    assert(library != null);
    return library?.codeId ?? "unknown";
  }

  String get code {
    final lib = library;
    if(lib == null) {
      return "${prefix}_$codeId";
    }
    final pref = prefix;
    if(pref == null) {
      return "${lib.codeId}_$codeId";
    }
    return "${lib.codeId}_${prefix}_$codeId";
  }

  @override
  String toString() {
    return code;
  }

  bool isLibrary(AFLibraryID lib) {
    return library == lib;
  }

  bool isKindOf(AFID other) {
    return code.startsWith(other.code);
  }

  int compareTo(AFID other) {
    return code.compareTo(other.code);
  }

  bool operator==(Object other) {
    return toString() == other.toString();
    //return (other is AFID && other.code == code);
  }

  TItem accessFirstWithItem<TItem extends Object>() {
    return accessWithItem(0);
  }

  TItem accessSecondWithItem<TItem extends Object>() {
    return accessWithItem(1);
  }

  TItem accessThirdWithItem<TItem extends Object>() {
    return accessWithItem(2);
  }

  TItem accessWithItem<TItem extends Object>(int n) {
    final wi = withItems;
    if(wi == null || n >= wi.length || n < 0) {
      throw AFException("Invalid index $n for with items $wi");
    }
    return wi[n] as TItem;
  }

  int get hashCode {
    return code.hashCode;
  }

  int get withCount {
    return withItems?.length ?? 0;
  }

  Never throwLibNotNull() {
    throw AFException("Library cannot be null");
  }

  bool endsWith(String ends) {
    return code.endsWith(ends);
  }
}

class AFTranslationID extends AFID {
  final List<dynamic>? values;
  const AFTranslationID(String code, AFLibraryID library, { this.values }) : super("i18n", code, library);

  /// Used to insert values into translated text.  
  /// 
  /// The translation can reference the values using {0}, {1}... {n} allowing you to change the 
  /// word/value order for different locales.
  AFTranslationID insert1(dynamic value) {
    final lib = library;
    if(lib == null) throwLibNotNull(); 
    return AFTranslationID(codeId, lib, values: [value]);
  }

  /// See [insert1]
  AFTranslationID insert2(dynamic v1, dynamic v2) {
    final lib = library;
    if(lib == null) throwLibNotNull(); 
    return AFTranslationID(codeId, lib, values: [v1, v2]);
  }

  /// See [insert1]
  AFTranslationID insert3(dynamic v1, dynamic v2, dynamic v3) {
    final lib = library;
    if(lib == null) throwLibNotNull(); 
    return AFTranslationID(codeId, lib, values: [v1, v2, v3]);
  }

  /// See [insert1]
  AFTranslationID insertN(List<dynamic> values) {
    final lib = library;
    if(lib == null) throwLibNotNull(); 
    return AFTranslationID(codeId, lib, values: values);
  }

  bool operator==(Object other) {
    return (other is AFTranslationID && other.code == code && other.library == library);
  }

  int get hashCode {
    return hash2(code.hashCode, library?.code);
  }

}

class AFIDWithTag extends AFID {
  final String? tag;
  const AFIDWithTag(String prefix, String code, AFLibraryID library, { this.tag }): super(prefix, code, library);
}

class AFScreenID extends AFID {
  const AFScreenID(String code, AFLibraryID library) : super("screen", code, library);
}

class AFLibraryID extends AFID {
  final String name;
  const AFLibraryID({
    required String code, 
    required this.name,
  }) : super("lib", code, null);
}

class AFWidgetID extends AFID {
  const AFWidgetID(String code, AFLibraryID library, {
    List<Object>? withItems,
  }) : super("wid", code, library, withItems: withItems);

  AFWidgetID with1(Object? item) {
    return with3(item, null, null);
  }

  AFWidgetID with2(Object? first, Object? second) {
    return with3(first, second, null);
  }

  AFWidgetID with3(Object? first, Object? second, Object? third) {
    final key = StringBuffer(code);
    final items = <Object>[];
    if(first != null) {
      key.write("_$first");
      items.add(first);
    }
    if(second != null) {
      key.write("_$second");
      items.add(second);
    }
    if(third != null) {
      key.write("_$third");
      items.add(third);
    }
    final lib = library;
    if(lib == null) throwLibNotNull();
    return AFWidgetID(key.toString(), lib, withItems: items);
  }

  
}

class AFBaseTestID extends AFID {
  const AFBaseTestID(String prefix, String code, AFLibraryID library) : super(prefix, code, library);
}

class AFFromStringTestID extends AFBaseTestID {
  final String fullId;
  AFFromStringTestID(this.fullId): super("", "", AFUILibraryID.id);

  
  String get id {
    return fullId;
  }

  String toString() {
    return fullId;
  }


}

class AFStateTestID extends AFBaseTestID {
  static const stateTestPrefix = "statetest";
  const AFStateTestID(String code, AFLibraryID library) : super(stateTestPrefix, code, library);
}

class AFScreenTestID extends AFBaseTestID {
  static const screenTestPrefix = "screentest";
  const AFScreenTestID(String code, AFLibraryID library) : super(screenTestPrefix, code, library);
}

class AFPrototypeID extends AFBaseTestID {
  static const prototypePrefix = "pr";
  const AFPrototypeID(String code, AFLibraryID library) : super(prototypePrefix, code, library);

  AFPrototypeID with1(dynamic item) {
    final lib = library;
    if(lib == null) throwLibNotNull();
    return AFPrototypeID("${code}_${item.toString()}", lib);
  }

}

class AFQueryTestID extends AFID {
  const AFQueryTestID(String code, AFLibraryID library) : super("querytest", code, library);
}

class AFLibraryProgrammingInterfaceID extends AFID {
  const AFLibraryProgrammingInterfaceID(String code, AFLibraryID library) : super("lpi", code, library);
}

class AFQueryID extends AFID {
  const AFQueryID(String code, AFLibraryID library): super("q", code, library);
}

class AFThemeID extends AFID {
  const AFThemeID(
    String code,
    AFLibraryID library): super("theme", code, library);   
}

class AFSourceTemplateID extends AFID {
  const AFSourceTemplateID(String code, AFLibraryID library): super(null, code, library);
}