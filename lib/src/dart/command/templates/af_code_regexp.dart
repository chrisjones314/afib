

class AFCodeRegExp {
  static final startMixinStateAccess = RegExp(r"mixin\s*.*StateModelAccess\s+on\s+AFStateModelAccess\s+{");
  static final startShortcutsClass = RegExp(r"class\s+AFAHStateTestShortcuts\s+{");
  static final startDefineScreenTestsFunction = RegExp(r'void\s+defineUIPrototypes\(AFScreenTestDefinitionContext\s+definitions\)\s+{');
  static final startPrototypeID = RegExp(r"class\s+.*PrototypeID\s+extends\s+AFPrototypeID\s+{");
  static final startDefineScreenTestFunction = RegExp(r"void\s+define.*Prototypes\(AFScreenTestDefinitionContext\s+definitions\)\s+{");
  static final startScreenMap = RegExp(r"void\s+defineScreenMap\(AFScreenMap\s+.*\)\s+{");

  static RegExp startUIID(String kind) {
    return RegExp("class\\s+.*${kind}ID\\s+extends\\s+AFScreenID\\s+{");
  }
    
}
