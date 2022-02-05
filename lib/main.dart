import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:quizeapp/screens/SplashScreen.dart';
import 'package:quizeapp/services/AppSettingService.dart';
import 'package:quizeapp/services/CategoryService.dart';
import 'package:quizeapp/services/DailyQuizServices.dart';
import 'package:quizeapp/services/QuestionServices.dart';
import 'package:quizeapp/services/QuizServices.dart';
import 'package:quizeapp/services/UserService.dart';
import 'package:quizeapp/store/AppStore.dart';
import 'package:quizeapp/utils/Colors.dart';
import 'package:quizeapp/utils/Common.dart';
import 'package:quizeapp/utils/Constants.dart';
import 'package:url_strategy/url_strategy.dart';

AppStore appStore = AppStore();

FirebaseFirestore db = FirebaseFirestore.instance;
FirebaseAuth auth = FirebaseAuth.instance;

UserService userService = UserService();
QuestionServices questionServices = QuestionServices();
CategoryService categoryService = CategoryService();
QuizServices quizServices = QuizServices();
DailyQuizServices dailyQuizServices = DailyQuizServices();
AppSettingService appSettingService = AppSettingService();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  setPathUrlStrategy();

  defaultRadius = 6;
  defaultAppButtonRadius = 4;
  defaultAppBarElevation = 2.0;

  defaultAppButtonTextColorGlobal = colorPrimary;
  appButtonBackgroundColorGlobal = Colors.white;

  desktopBreakpointGlobal = 700.0;

  await initialize();

  defaultAppButtonShapeBorder = OutlineInputBorder(borderSide: BorderSide(color: colorPrimary));

  appStore.setLanguage(getStringAsync(LANGUAGE, defaultValue: defaultLanguage));
  appStore.setLoggedIn(getBoolAsync(IS_LOGGED_IN));

  if (appStore.isLoggedIn) {
    appStore.setUserId(getStringAsync(USER_ID));
    appStore.setAdmin(getBoolAsync(IS_ADMIN));
    appStore.setSuperAdmin(getBoolAsync(IS_SUPER_ADMIN));
    appStore.setFullName(getStringAsync(FULL_NAME));
    appStore.setUserEmail(getStringAsync(USER_EMAIL));
    appStore.setUserProfile(getStringAsync(PROFILE_IMAGE));
  }

  setTheme();

  if (isMobile || isWeb) {
    await Firebase.initializeApp().then((value) {
      //FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterError;
      //MobileAds.instance.initialize();
    });

    /*  if (isMobile) {
      await OneSignal.shared.init(
        mOneSignalAppId,
        iOSSettings: {OSiOSSettings.autoPrompt: false, OSiOSSettings.promptBeforeOpeningPushUrl: true, OSiOSSettings.inAppAlerts: false},
      );

      OneSignal.shared.setInFocusDisplayType(OSNotificationDisplayType.notification);

      OneSignal.shared.getPermissionSubscriptionState().then((value) {
        log(value.jsonRepresentation());

        setValue(PLAYER_ID, value.subscriptionStatus.userId.validate());
      });
    }*/
  }
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Observer(
      builder: (_) => MaterialApp(
        title: mAppName,
        // theme: AppTheme.darkTheme,
        themeMode: appStore.isDarkMode ? ThemeMode.dark : ThemeMode.light,
        debugShowCheckedModeBanner: false,
        home: SplashScreen(),
      ),
    );
  }
}
