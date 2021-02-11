
import 'package:quiver/core.dart';

class AFID {
  final String prefix;
  final String codeId;
  final AFLibraryID library;
  const AFID(this.prefix, this.codeId, this.library);

  String get code {
    if(library == null) {
      return "${prefix}_$codeId";
    }
    return "${library.codeId}_${prefix}_$codeId";
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

  AFWidgetID with1(dynamic item) {
    return AFWidgetID("${code}_${item.toString()}", library);
  }

  AFWidgetID with2(dynamic first, dynamic second) {
    final key = StringBuffer(code);
    key.write("_${first.toString()}");
    if(second != null) {
      key.write("_${second.toString()}");
    }
    return AFWidgetID(key.toString(), library);
  }

  bool endsWith(String ends) {
    return code.endsWith(ends);
  }

}

class AFIDWithTags extends AFID {
  final dynamic group;
  final List<String> tags;

  const AFIDWithTags(String prefix, String code,  AFLibraryID library, { this.tags, this.group, }): super(prefix, code, library);

  String get tagsText {
    if(tags == null) {
      return "";
    }
    return tags.join(", ");
  }

  String get effectiveGroup {
    if(group != null) {
      return group.toString();
    }

    if(tags != null && tags.isNotEmpty) {
      return tags.first;
    }

    return null;
  }

  bool hasTag(String tag) {
    return tags != null && tags.contains(tag);
  }

  bool hasTagLike(String tag) {
    if(tag.length < 2 || tags == null) {
      return false;
    }
    for(final test in tags) {
      if(test.contains(tag)) {
        return true;
      }
    }
    return false;
  }
}

class AFTranslationID extends AFID {
  final List<dynamic> values;
  const AFTranslationID(String code, AFLibraryID library, { this.values}) : super("i18n", code, library);

  /// Used to insert values into translated text.  
  /// 
  /// The translation can reference the values using {0}, {1}... {n} allowing you to change the 
  /// word/value order for different locales.
  AFTranslationID insert1(dynamic value) {
    return AFTranslationID(codeId, library, values: [value]);
  }

  /// See [insert1]
  AFTranslationID insert2(dynamic v1, dynamic v2) {
    return AFTranslationID(codeId, library, values: [v1, v2]);
  }

  /// See [insert1]
  AFTranslationID insert3(dynamic v1, dynamic v2, dynamic v3) {
    return AFTranslationID(codeId, library, values: [v1, v2, v3]);
  }

  /// See [insert1]
  AFTranslationID insertN(List<dynamic> values) {
    return AFTranslationID(codeId, library, values: values);
  }

  bool operator==(Object other) {
    return (other is AFTranslationID && other.code == code && other.library == library);
  }

  int get hashCode {
    return hash2(code.hashCode, library.code);
  }

}

class AFIDWithTag extends AFID {
  final String tag;
  const AFIDWithTag(String prefix, String code, AFLibraryID library, { this.tag }): super(prefix, code, library);
}

class AFScreenID extends AFID {
  const AFScreenID(String code, AFLibraryID library) : super("screen", code, library);
}

class AFLibraryID extends AFID {
  final String name;
  const AFLibraryID({String code, this.name}) : super("lib", code, null);
}

class AFWidgetID extends AFID {
  const AFWidgetID(String code, AFLibraryID library) : super("wid", code, library);
}

class AFTestID extends AFIDWithTags {
  const AFTestID(String prefix, String code, AFLibraryID library, {String group, List<String> tags}) : super(prefix, code, library, tags: tags, group: group);
}

class AFStateTestID extends AFTestID {
  const AFStateTestID(String code, AFLibraryID library, {String group, List<String> tags, }) : super("statet", code, library, tags: tags, group: group);
}

class AFReusableTestID extends AFTestID {
  const AFReusableTestID(String code, AFLibraryID library, {String group, List<String> tags }) : super("rt", code, library, tags: tags, group: group);
}

class AFSingleScreenTestID extends AFTestID {
  const AFSingleScreenTestID(String code, AFLibraryID library, {String group, List<String> tags, }) : super("st", code, library, tags: tags, group: group);
}

class AFWorkflowTestID extends AFTestID {
  const AFWorkflowTestID(String code, AFLibraryID library, {String group, List<String> tags}) : super("wt", code, library, tags: tags, group: group);
}
/*
class AFTestDataID extends AFID {
  const AFTestDataID(String code) : super("td", code);
}
*/

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
