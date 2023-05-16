

import 'package:afib/afib_command.dart';

class StarterSigninStateTestT extends AFFileSourceTemplate {
  static const insertCheckSigninQuery = AFSourceTemplateInsertion("check_signin_query");
  static const insertReadUserQuery = AFSourceTemplateInsertion("read_user_query");

  StarterSigninStateTestT({
    required String templateFileId,
    required List<String> templateFolder,
    required Object checkSigninQuery,
    required Object readUserQuery,
    required Object extraImports,
  }): super(
    templateFileId: templateFileId,
    templateFolder: templateFolder,
    embeddedInsertions: AFSourceTemplateInsertions(insertions: {
      insertCheckSigninQuery: checkSigninQuery,
      insertReadUserQuery: readUserQuery,
      AFSourceTemplate.insertExtraImportsInsertion: extraImports,
    })
  );

  static StarterSigninStateTestT example() {
    return StarterSigninStateTestT(
      templateFileId: "state_test",
      templateFolder: AFProjectPaths.pathGenerateStarterSigninFiles,
      checkSigninQuery: "CheckSigninQuery",
      readUserQuery: "ReadUserQuery",
      extraImports: '''
import 'package:${AFSourceTemplate.insertPackagePathInsertion}/query/simple/check_signin_query.dart';
import 'package:${AFSourceTemplate.insertPackagePathInsertion}/query/simple/read_user_query.dart';
''',
    );
  }

  String get template => '''
import 'package:afib/afib_flutter.dart';
import 'package:afib_signin/afsi_flutter.dart';
import 'package:flutter_test/flutter_test.dart' as ft;
import 'package:$insertPackagePath/query/simple/signin_query.dart';
import 'package:$insertPackagePath/query/simple/signout_query.dart';
import 'package:$insertPackagePath/query/simple/startup_query.dart';
import 'package:$insertPackagePath/ui/widgets/registration_details_widget.dart';
import 'package:$insertPackagePath/query/simple/registration_query.dart';
import 'package:$insertPackagePath/query/simple/write_one_user_query.dart';
import 'package:$insertPackagePath/${insertAppNamespace}_id.dart';
import 'package:$insertPackagePath/state/models/user.dart';
import 'package:$insertPackagePath/state/root/user_credential_root.dart';
import 'package:$insertPackagePath/test/${insertAppNamespace}_state_test_shortcuts.dart';
$insertExtraImports

// ignore_for_file: depend_on_referenced_packages, unused_import

void defineStartupStateTest(AFStateTestDefinitionContext definitions) {

  // I don't like hard-coding values in tests.  You can access test data here
  // to avoid it.
  final westCoastUser = definitions.find<User>(${insertAppNamespaceUpper}TestDataID.userWestCoast);
  final eastCoastUser = definitions.find<User>(${insertAppNamespaceUpper}TestDataID.userEastCoast);
  final midwestUser = definitions.find<User>(${insertAppNamespaceUpper}TestDataID.userMidwest);

  definitions.addTest(${insertAppNamespaceUpper}StateTestID.alreadyLoggedInWestCoast, extendTest: null, body: (testContext) {
    testContext.defineInitialTime(AFTimeState.createNow());
    // when we check for signin, it returns a valid user credential.
    testContext.defineQueryResponseUnused<StartupQuery>();
    testContext.defineQueryResponseFixed<$insertCheckSigninQuery>(${insertAppNamespaceUpper}TestDataID.userCredentialWestCoast);

    // note that this query is the start of what would likely be many queries that pull back application
    // specific data.  As the list of query responses defined here grows, it will be nice to extend this test
    // and inherit all these definitions.
    testContext.defineQueryResponseFixed<$insertReadUserQuery>(${insertAppNamespaceUpper}TestDataID.userWestCoast);

    // This is necessary in case you decide to click the signout button.   Note that if this seems duplicative
    // with the current implementation of SignoutQuery.startAsync, that is because that implementation would normally
    // be a real implementation (or throwUnimplemented during prototyping), not one that returns test data.   
    // The purpose of a state test is to allow you to 
    // inject different test responses into various queries, rather than having a single test response hard-coded
    // into the startAsync method.
    testContext.defineQueryResponseFixed<SignoutQuery>(UserCredentialRoot.createNotSignedIn());

    // this is not used during the inital execution of the test, but if you sign out and then sign back in, this
    // will get used.  Note that as a result any email/password will work.
    testContext.defineQueryResponseFixed<SigninQuery>(${insertAppNamespaceUpper}TestDataID.userCredentialWestCoast);

    testContext.executeStartup();

    // as is, this will put us on the home screen.
    // because this is a base test for lots of other tests, don't execute/validate screens here.  Other tests
    // may override responses, causing a different screen to be showing initially.  Instead, create another test
    // that extends this one, and validates/manipulates the home screen.
  });

  definitions.addTest(${insertAppNamespaceUpper}StateTestID.alreadyLoggedInEastCoast, extendTest:  ${insertAppNamespaceUpper}StateTestID.alreadyLoggedInWestCoast, body: (testContext) {

    // this is just showing that we can override query responses to produce different test data.  In this trivial
    // example, the only test data that can be meaningfully varied is the zip code, so we've named our scenarios east/west coast.

    // Although this extension overrides a high percentage of the queries (not all, for example it doesn't need to override
    // the signout query), that is due to the simplicity of the example.   In a real app, you might have a bunch of examples
    // that override some of the test data (for example, different todo list content), while leaving other data constant (for example,
    // the user settings).
    testContext.defineQueryResponseFixed<$insertCheckSigninQuery>(${insertAppNamespaceUpper}TestDataID.userCredentialEastCoast);
    testContext.defineQueryResponseFixed<$insertReadUserQuery>(${insertAppNamespaceUpper}TestDataID.userEastCoast);
    testContext.defineQueryResponseFixed<SigninQuery>(${insertAppNamespaceUpper}TestDataID.userCredentialEastCoast);
  });


  definitions.addTest(${insertAppNamespaceUpper}StateTestID.readyForLoginWestCoast, extendTest: ${insertAppNamespaceUpper}StateTestID.alreadyLoggedInWestCoast, body: (testContext) {

    // this will be like the alreadyLoggedInWestCoast test, except that the $insertCheckSigninQuery will return not signed in.
    // when the user clicks the signin button, it will return the west coast signin result already specified in the parent test, 
    // and everything else will work from there.
    testContext.defineQueryResponseFixed<$insertCheckSigninQuery>(UserCredentialRoot.createNotSignedIn());

    // The bast test has a fixed response, but this is a nice chance to show a dynamic response.   
    testContext.defineQueryResponseDynamic<SigninQuery>(body: (context, query) {
      final email = query.email;
      if(email != westCoastUser.email) {
        context.onError((AFQueryError(message: "Please enter \${westCoastUser.email} as the email")));
      } else {
        context.onSuccess(UserCredentialRoot(
          userId: westCoastUser.id,
          token: '--', 
          storedEmail: eastCoastUser.email
        ));
      }
    });

    // we should start on the signin screen in this case.
    testContext.executeVerifyActiveScreenId(AFSIScreenID.signin);
  });

  definitions.addTest(${insertAppNamespaceUpper}StateTestID.performLoginWestCoast, extendTest: ${insertAppNamespaceUpper}StateTestID.readyForLoginWestCoast, body: (testContext) {

    // this will be like the alreadyLoggedInWestCoast test, except that the $insertCheckSigninQuery will return not signed in.
    // when the user clicks the signin button, it will return the west coast signin result already specified in the parent test, 
    // and everything else will work from there.
    testContext.defineQueryResponseFixed<$insertCheckSigninQuery>(UserCredentialRoot.createNotSignedIn());

    // we should start on the signin screen in this case.
    testContext.executeVerifyActiveScreenId(AFSIScreenID.signin);

    // This example shows how you manipulate the SPI during state tests, but more importantly it shows that the SPI provides
    // a nice API for interacting with your app.  In this case, you didn't write this SPI (it comes from Afib Signin), so it
    // is important that it be intuitive to use.   SPIs should be like that in general.  Subsequent developers will come along
    // and want to develop a test that validates/drives some UI you wrote, and your SPI should be easy for them to use and understand.
    // This is also where conventions, like starting event handlers with onChanged, onPressed, etc are useful.
    final signinShortcuts = AFSIStateTestShortcuts(testContext);
    final signinScreen = signinShortcuts.createSigninScreen();

    final ${insertAppNamespace}Shortcuts = ${insertAppNamespaceUpper}StateTestShortcuts(testContext);
    final homePageScreen = ${insertAppNamespace}Shortcuts.createHomePageScreen();

    signinScreen.executeScreen((e, screenContext) { 
      screenContext.executeBuild((spi) => spi.onChangedEmail(westCoastUser.email));
      screenContext.executeBuild((spi) => spi.onChangedPassword("test"));

      // if you uncomment this line, then when you enter this test in prototype mode, yoou will see that the
      // signin screen has been filled in, but the test will stop there.
      // screenContext.executeDebugStopHere();

      screenContext.executeBuild((spi) => spi.onPressedSignin());

    });
    
    homePageScreen.executeScreen((e, screenContext) { 
      screenContext.executeBuild((spi) { 
        e.expect(spi.activeUser.firstName, ft.equals(westCoastUser.firstName));
      });
    });
  });


  definitions.addTest(${insertAppNamespaceUpper}StateTestID.manipulateAfterSigninWestCoast, extendTest: ${insertAppNamespaceUpper}StateTestID.alreadyLoggedInWestCoast, body: (testContext) {
    // In reality, you will likely develop many tests that manipulate your app in various ways after a successful signin, which
    // will have names more specific than this one.

    // Those tests may not leave you on the home screen.  You are not required to start from the home screen, this
    // example is just simple.

    // You might choose to build a hierarchy of tests that manipulate SPIs, leaving you in more and more robust test states, and
    // on different screens.   Each new extended test can pick up from where its 'extendTest' predecessor left off.

    // Or, you might choose to override some of the defined query results from alreadyLoggedInWestCoast, starting with different
    // test data as your app grows more complex.   This can allow you to preserve the test data that existing tests see, while
    // also developing more robust test data for new tests.
    final shortcuts = ${insertAppNamespaceUpper}StateTestShortcuts(testContext);
    final homeScreen = shortcuts.createHomePageScreen();

    // this does one simple validation, as this app has no business functionality to validate, but you would begin building
    // more validations/manipulatings in tests like this.
    final expectedUser = definitions.find<User>(${insertAppNamespaceUpper}TestDataID.userWestCoast);
    homeScreen.executeScreen((e, screenContext) { 
      screenContext.executeBuild((spi) { 
        e.expect(spi.activeUser.firstName, ft.equals(expectedUser.firstName));
      });
    });
  });

  definitions.addTest(${insertAppNamespaceUpper}StateTestID.readyToRegister, extendTest: ${insertAppNamespaceUpper}StateTestID.readyForLoginWestCoast, body: (testContext) {
    // this is an important example, because rather than using a fixed result, it dynamically generates a result 
    // for the RegistrationQuery.  As a result, we can drive the UI from the signin page, all the way through the reegistration
    // process, and get the expected result.  That is, you can click on the readyToRegister test in prototype mode, enter your own 
    // registration details, click Signup, and it will work.
    testContext.defineQueryResponseDynamic<RegistrationQuery>(body: (context, query) {
      final email = query.email;
      context.onSuccess(UserCredentialRoot(
        userId: AFDocumentIDGenerator.createTestIdIncreasing("testuser"), 
        token: "--", 
        storedEmail: email,
      ));
    });

    testContext.defineQueryResponseDynamic<WriteOneUserQuery>(body: (context, query) {
      final user = query.user;
      var result = user;
      // this is a very common pattern for write queries.  If it has a new id, you revise its ID with a test id,
      // otherwise, you just make sure to change the pointer using copyWith, as that would happen in a real query
      // which is probably deserializing a network response.
      assert(!AFDocumentIDGenerator.isNewId(user.id));
      result = user.copyWith();
      context.onSuccess(result);
    });

    // let's go ahead and navigate to the registration screen, 
    final signinShortcuts = AFSIStateTestShortcuts(testContext);
    final signinScreen = signinShortcuts.createSigninScreen();

    // but first, intentionally leave some state on the signin screen, if you hit 'back to signin', rather than
    // registering, you will see that it is there (actually, it gets pulled onto the registration screen also,
    // as afib_signin does that by default)
    signinScreen.executeScreen((e, screenContext) { 
      screenContext.executeBuild((spi) => spi.onChangedEmail("southy.was.here@nowhere.com"));
      screenContext.executeBuild((spi) => spi.onPressedRegister());
    });
  });


  definitions.addTest(${insertAppNamespaceUpper}StateTestID.registerMidwest, extendTest: ${insertAppNamespaceUpper}StateTestID.readyToRegister, body: (testContext) {

    final signinShortcuts = AFSIStateTestShortcuts(testContext);
    final stShortcuts = ${insertAppNamespaceUpper}StateTestShortcuts(testContext);
    final registerScreen = signinShortcuts.createRegisterScreen();
    final registerDetails = stShortcuts.createRegistrationDetailsWidget(registerScreen);
    final homeScreen = stShortcuts.createHomePageScreen();

    const testPassword = "test";
    registerScreen.executeScreen((e, screenContext) { 
      screenContext.executeBuild((spi) => spi.onChangedEmail(midwestUser.email));
      screenContext.executeBuild((spi) => spi.onChangedPassword(testPassword));
      screenContext.executeBuild((spi) => spi.onChangedPasswordConfirm(testPassword));

      // now, we need to modify the controls on the custom RegistrationDetailsWidget that we inserted into the 
      // standard signin UI  via our SigninTheme override
      registerDetails.executeWidget(screenContext, 
        // often the launch param would come from the SPI of the parent screen.  But in this case, the parent is 
        // AFSI, which knows nothing about our custom widget, so it comes from a static method on the widget itself.
        launchParam: RegistrationDetailsWidget.createLaunchParam(screenId: AFSIScreenID.register), 
        body: (widgetContext) {
          widgetContext.executeBuild((spi) => spi.onChangedFirstName(midwestUser.firstName));
          widgetContext.executeBuild((spi) => spi.onChangedLastName(midwestUser.lastName));
          widgetContext.executeBuild((spi) => spi.onChangedZipCode(midwestUser.zipCode));
        }
      );

      // if you uncomment this line, then when you click on this state test in prototype mode you will see the whole
      // registration form is filled on.
      // screenContext.executeDebugStopHere();

      screenContext.executeBuild((spi) => spi.onPressedRegister());
    });

    // we registered, we should be on the home screen with the correct registration details.
    homeScreen.executeScreen((e, screenContext) { 
      screenContext.executeBuild((spi) { 
        e.expect(spi.activeUser.firstName, ft.equals(midwestUser.firstName));
      });
    });
  });
}
''';
}