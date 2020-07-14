
class AFID {
  final String code;
  const AFID(this.code);

  @override
  String toString() {
    return code;
  }
}

class AFScreenID extends AFID {
  const AFScreenID(String code) : super(code);
}

class AFWidgetID extends AFID {
  const AFWidgetID(String code) : super(code);
}

class AFTestID extends AFID {
  const AFTestID(String code) : super(code);
}

class AFTestDataID extends AFID {
  const AFTestDataID(String code) : super(code);
}

class AFTestSectionID extends AFID {
  const AFTestSectionID(String code) : super(code);
}

class AFStateTestID extends AFTestID {
  const AFStateTestID(String code) : super(code);
}

class AFQueryTestID extends AFID {
  const AFQueryTestID(String code) : super(code);
}

class AFQueryID extends AFID {
  const AFQueryID(String code): super(code);
}