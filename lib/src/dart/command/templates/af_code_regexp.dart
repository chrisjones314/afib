

class AFCodeRegExp {
  static final startMixinStateAccess = RegExp(r"mixin\s*.*StateModelAccess\s+on\s+AFStateModelAccess\s+{");
  static final startShortcutsClass = RegExp(r"class\s+.*StateTestShortcuts\s+{");
  static final startDefineScreenTestsFunction = RegExp(r'void\s+defineUIPrototypes\(AFUIPrototypeDefinitionContext\s+definitions\)\s+{');
  static final startPrototypeID = RegExp(r"class\s+.*PrototypeID\s+extends\s+AFPrototypeID\s+{");
  static final startDefineScreenTestFunction = RegExp(r"void\s+define.*Prototypes\(AFUIPrototypeDefinitionContext\s+definitions\)\s+{");
  static final startScreenMap = RegExp(r"void\s+defineScreens\(AFUIDefinitionContext\s+context\)\s+{");
  static final startDefineStateClass = RegExp(r"class\s+.*State\s+extends\s+AFFlexibleState\s+with\s+.*StateModelAccess\s+{");
  static final startReturnInitialState = RegExp(r"return\s+.*State.fromList\(\s*\[");
  static final startExtendLibraryBase = RegExp(r"void\s+extendBaseLibrary\(AFBaseExtensionContext\s+context\)\s+{");
  static final startExtendLibraryCommand = RegExp(r"void\s+extendCommandLibrary\(AFCommandUILibraryExtensionContext\s+context\)\s+{");
  static final startExtendLibraryUI = RegExp(r"void\s+extendUILibrary\(AFAppLibraryExtensionContext\s+context\)\s+{");
  static final startDefineThemes = RegExp(r"void\s+defineFunctionalThemes\(AFUIDefinitionContext\s+context\)\s+{");
  static final startDefineUI = RegExp(r"void\s+defineUI\(AFUIDefinitionContext\s+context\)\s+{");
  static final startExtendCommand = RegExp(r"void\s+extendCommand\(AFCommand.*ExtensionContext\s+context\)\s+{");
  static final startDefineTestData = RegExp(r"void\s+defineTestData\(AFDefineTestDataContext\s+context\)\s+{");
  static final startDeclareTestData = RegExp(r"final\s+stateFullLogin\s+=\s+<Object>\[");
  static final startDeclareTestDataID = RegExp(r"class\s+.*TestDataID\s+{");
  static final startDefineLPI = RegExp(r"void\s+defineLibraryProgrammingInterfaces\(AFUIDefinitionContext\s+context\)\s+{");
  static final startDeclareLPI = RegExp(r"class\s+.*LPI\s+extends\s+.*LPI\s+{");
  static final afTag = RegExp(r".*\[!af_.*\].*");

  static RegExp startUIID(String kind, String kindSuper) {
    return RegExp("class\\s+.*${kind}ID\\s+extends\\s+AF${kindSuper}ID\\s+{");
  }
    
}
