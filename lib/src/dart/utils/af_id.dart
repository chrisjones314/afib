import 'package:afib/src/dart/utils/af_exception.dart';
import 'package:quiver/core.dart';

class AFID {
  final String? prefix;
  final String codeId;
  final AFLibraryID? library;
  const AFID(this.prefix, this.codeId, this.library);

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

  int compareTo(AFID other) {
    return code.compareTo(other.code);
  }

  bool operator==(Object other) {
    return (other is AFID && other.code == code);
  }

  int get hashCode {
    return code.hashCode;
  }

  Never throwLibNotNull() {
    throw AFException("Library cannot be null");
  }

  AFWidgetID with1(dynamic item) {
    final lib = library;
    if(lib == null) throwLibNotNull();
    return AFWidgetID("${code}_${item.toString()}", lib);
  }

  AFWidgetID with2(dynamic first, dynamic second) {
    final key = StringBuffer(code);
    key.write("_${first.toString()}");
    if(second != null) {
      key.write("_${second.toString()}");
    }
    final lib = library;
    if(lib == null) throwLibNotNull();
    return AFWidgetID(key.toString(), lib);
  }

  bool endsWith(String ends) {
    return code.endsWith(ends);
  }

}

class AFIDWithTags extends AFID {
  final dynamic group;
  final List<String>? tags;

  const AFIDWithTags(String prefix, String code,  AFLibraryID library, { this.tags, this.group, }): super(prefix, code, library);

  String get tagsText {
    final t = tags;
    if(t == null) {
      return "";
    }
    return t.join(", ");
  }

  String? get effectiveGroup {
    if(group != null) {
      return group.toString();
    }

    final t = tags;
    if(t != null && t.isNotEmpty) {
      return t.first;
    }

    return null;
  }

  bool hasTag(String tag) {
    final t = tags;
    return t != null && t.contains(tag);
  }

  bool hasTagLike(String tag) {
    if(tag.length < 2 || tags == null) {
      return false;
    }
    final t = tags;
    if(t == null) return false;
    for(final test in t) {
      if(test.contains(tag)) {
        return true;
      }
    }
    return false;
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
    required this.name
  }) : super("lib", code, null);
}

class AFWidgetID extends AFID {
  const AFWidgetID(String code, AFLibraryID library) : super("wid", code, library);
}

class AFBaseTestID extends AFIDWithTags {
  const AFBaseTestID(String prefix, String code, AFLibraryID library, {String? group, List<String>? tags}) : super(prefix, code, library, tags: tags, group: group);
}

class AFStateTestID extends AFBaseTestID {
  const AFStateTestID(String code, AFLibraryID library, {String? group, List<String>? tags, }) : super("statet", code, library, tags: tags, group: group);
}

class AFScreenTestID extends AFBaseTestID {
  const AFScreenTestID(String code, AFLibraryID library, {String? group, List<String>? tags }) : super("rt", code, library, tags: tags, group: group);
}

class AFPrototypeID extends AFBaseTestID {
  const AFPrototypeID(String code, AFLibraryID library, {String? group, List<String>? tags, }) : super("pr", code, library, tags: tags, group: group);
}

class AFQueryTestID extends AFID {
  const AFQueryTestID(String code, AFLibraryID library) : super("qt", code, library);
}

class AFQueryID extends AFID {
  const AFQueryID(String code, AFLibraryID library): super("q", code, library);
}

class AFThemeID extends AFIDWithTag {
  const AFThemeID(
    String code,
    AFLibraryID library,
    String tag): super("theme", code, library, tag: tag);   
}

class AFSourceTemplateID extends AFID {
  const AFSourceTemplateID(String code, AFLibraryID library): super(null, code, library);
}