
class AFID {
  final String code;
  AFID(this.code);

  @override
  String toString() {
    return code;
  }
}

class AFScreenID extends AFID {
  AFScreenID(String code) : super(code);
}

class AFWidgetID extends AFID {
  AFWidgetID(String code) : super(code);
}

class AFTestID extends AFID {
  AFTestID(String code) : super(code);
}

class AFTestSectionID extends AFID {
  AFTestSectionID(String code) : super(code);
}

class AFStateTestID extends AFID {
  AFStateTestID(String code) : super(code);
}

class AFQueryTestID extends AFID {
  AFQueryTestID(String code) : super(code);
}

