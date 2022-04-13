

class AFCodeRegExp {
  static final startMixinStateAccess = RegExp(r"mixin\s*.*StateModelAccess\s+on\s+AFStateModelAccess\s+{");
  static final startShortcutsClass = RegExp(r"class\s+.*StateTestShortcuts\s+{");
  static final startDefineScreenTestsFunction = RegExp(r'void\s+defineUIPrototypes\(AFUIPrototypeDefinitionContext\s+definitions\)\s+{');
  static final startPrototypeID = RegExp(r"class\s+.*PrototypeID\s+extends\s+AFPrototypeID\s+{");
  static final startDefineScreenTestFunction = RegExp(r"void\s+define.*Prototypes\(AFUIPrototypeDefinitionContext\s+definitions\)\s+{");
  static final startScreenMap = RegExp(r"void\s+defineScreenMap\(AFScreenMap\s+.*\)\s+{");
  static final startDefineStateClass = RegExp(r"class\s+.*State\s+extends\s+AFFlexibleState\s+with\s+.*StateModelAccess\s+{");
  static final startReturnInitialState = RegExp(r"return\s+.*State.fromList\(\[");

  static RegExp startUIID(String kind) {
    return RegExp("class\\s+.*${kind}ID\\s+extends\\s+AFScreenID\\s+{");
  }
    
}
