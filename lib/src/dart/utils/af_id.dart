
class AFID {
  final String code;
  final String name;
  AFID(this.code, this.name);
}

class AFScreenID extends AFID {
  AFScreenID(String code, String name) : super(code, name);
}

class AFWidgetID extends AFID {
  AFWidgetID(String code, String name) : super(code, name);
}

class AFTestID extends AFID {
  AFTestID(String code, String name) : super(code, name);
}

class AFStateTestID extends AFID {
  AFStateTestID(String code, String name) : super(code, name);
}

class AFQueryTestID extends AFID {
  AFQueryTestID(String code, String name) : super(code, name);
}

