
class AFID {
  final String code;
  const AFID(this.code);

  @override
  String toString() {
    return code;
  }

  int compareTo(AFID other) {
    return code.compareTo(other.code);
  }
}

class AFIDWithTags extends AFID {
  final dynamic group;
  final List<String> tags;

  const AFIDWithTags(String code, this.tags, this.group): super(code);

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
}

class AFScreenID extends AFID {
  const AFScreenID(String code) : super(code);
}

class AFWidgetID extends AFID {
  const AFWidgetID(String code) : super(code);

  AFWidgetID with1(dynamic item) {
    return AFWidgetID("${code}_${item.toString()}");
  }
}

class AFTestID extends AFIDWithTags {
  const AFTestID(String code, {String group, List<String> tags}) : super(code, tags, group);
}

class AFTestDataID extends AFID {
  const AFTestDataID(String code) : super(code);
}

class AFTestSectionID extends AFID {
  const AFTestSectionID(String code) : super(code);
}

class AFQueryTestID extends AFID {
  const AFQueryTestID(String code) : super(code);
}

class AFQueryID extends AFID {
  const AFQueryID(String code): super(code);
}