

class AFCodeRegExp {
  static final startMixinStateAccess = RegExp(r"mixin\s*.*StateModelAccess\s+on\s+AFStateModelAccess\s+{");
  static final startShortcutsClass = RegExp(r"class\s+.*StateTestShortcuts\s+{");
  static final startDefineScreenTestsFunction = RegExp(r'void\s+defineUIPrototypes\(AFUIPrototypeDefinitionContext\s+definitions\)\s+{');
  static final startPrototypeID = RegExp(r"class\s+.*PrototypeID\s+extends\s+AFPrototypeID\s+{");
  static final startDefineScreenTestFunction = RegExp(r"void\s+define.*Prototypes\(AFUIPrototypeDefinitionContext\s+definitions\)\s+{");
  static final startScreenMap = RegExp(r"void\s+defineScreens\(AFUIDefinitionContext\s+context\)\s+{");
  static final startDefineStateClass = RegExp(r"class\s+.*State\s+extends\s+AFFlexibleState\s+with\s+.*StateModelAccess\s+{");
  static final startReturnInitialState = RegExp(r"return\s+.*State.fromList\(\[");
  static final startExtendThirdPartyBase = RegExp(r"void\s+extendThirdPartyBase\(AFBaseExtensionContext\s+context\)\s+{");
  static final startExtendThirdPartyCommand = RegExp(r"void\s+extendThirdPartyCommand\(AFCommandThirdPartyExtensionContext\s+context\)\s+{");
  static final startExtendThirdPartyUI = RegExp(r"void\s+extendThirdPartyUI\(AFAppThirdPartyExtensionContext\s+context\)\s+{");
  static final startDefineThemes = RegExp(r"void\s+defineFunctionalThemes\(AFUIDefinitionContext\s+context\)\s+{");
  static final startDefineUI = RegExp(r"void\s+defineUI\(AFUIDefinitionContext\s+context\)\s+{");
  static final startExtendCommand = RegExp(r"void\s+extendCommand\(AFCommandExtensionContext\s+context\)\s+{");
  
  static RegExp startUIID(String kind) {
    return RegExp("class\\s+.*${kind}ID\\s+extends\\s+AFScreenID\\s+{");
  }
    
}
