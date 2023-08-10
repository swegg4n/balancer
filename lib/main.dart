import 'dart:async';
import 'package:Balancer/analytics/analytics_state.dart';
import 'package:Balancer/expenses/expenses_state.dart';
import 'package:Balancer/history/history_state.dart';
import 'package:Balancer/profile/profile_state.dart';
import 'package:Balancer/shared/foreground.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:device_preview/device_preview.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:Balancer/routes.dart';
import 'package:Balancer/services/app_preferences.dart';
import 'package:Balancer/services/firestore.dart';
import 'package:Balancer/services/messaging.dart';
import 'package:Balancer/shared/error.dart';
import 'package:Balancer/services/models.dart';
import 'package:Balancer/theme.dart';
import 'package:provider/provider.dart';
// import 'firebase_options.dart';

// to build, run: flutter build appbundle
// output is located in  'build\app\outputs\bundle\release\app-release.aab'

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // runApp(
  //   DevicePreview(
  //     enabled: true,
  //     tools: const [...DevicePreview.defaultTools],
  //     builder: (context) => const App(),
  //   ),
  // );
  runApp(const App());
}

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  final Future<FirebaseApp> _initialization = Firebase.initializeApp();

  @override
  void initState() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint('recieved firebase notification');
      var notification = message.notification;
      // var androidNotification = message.notification?.android;
      if (notification != null /*&& androidNotification != null*/) {
        MessagingService.flutterLocalNotificationsPlugin.show(
          notification.hashCode,
          notification.title,
          notification.body,
          NotificationDetails(
            android: AndroidNotificationDetails(
              MessagingService.channel.id,
              MessagingService.channel.name,
              channelDescription: MessagingService.channel.description,
              color: Colors.black87,
              playSound: true,
              icon: '@mipmap/ic_launcher',
            ),
          ),
        );
      }
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      var notification = message.notification;
      // var androidNotification = message.notification?.android;

      if (notification != null /*&& androidNotification != null*/) {
        showDialog(
          context: context,
          builder: (_) {
            return AlertDialog(
              title: Text(notification.title!),
              content: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(notification.body ?? ''),
                  ],
                ),
              ),
            );
          },
        );
      }
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    return AnnotatedRegion(
      value: const SystemUiOverlayStyle(
        systemNavigationBarColor: Color(0xff303030),
        systemNavigationBarIconBrightness: Brightness.dark,
        systemNavigationBarDividerColor: Color(0xff303030),
      ),
      child: FutureBuilder(
        future: _initialization,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: ErrorMessage(
                message: snapshot.error.toString(),
              ),
            );
          }

          if (snapshot.connectionState == ConnectionState.done) {
            MessagingService().initialize();

            return FutureBuilder(
                future: AppPreferences.init(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Center(
                      child: ErrorMessage(
                        message: snapshot.error.toString(),
                      ),
                    );
                  }

                  if (snapshot.connectionState == ConnectionState.done) {
                    return MultiProvider(
                      providers: [
                        ChangeNotifierProvider(create: (_) => ProfileState()),
                        ChangeNotifierProvider(create: (_) => ExpensesState()),
                        ChangeNotifierProvider(create: (_) => HistoryState()),
                        ChangeNotifierProvider(create: (_) => AnalyticsState()),
                        StreamProvider(create: (_) => FirestoreService().streamUser(), initialData: MyUser()),
                      ],
                      child: MaterialApp(routes: appRoutes, theme: appTheme),
                    );
                  }

                  return MediaQuery(data: const MediaQueryData(), child: MaterialApp(theme: appTheme, home: const ForegroundScreen()));
                });
          }
          return MediaQuery(data: const MediaQueryData(), child: MaterialApp(theme: appTheme, home: const ForegroundScreen()));
        },
      ),
    );
  }
}
