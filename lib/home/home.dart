import 'package:Balancer/analytics/analytics.dart';
import 'package:Balancer/history/history.dart';
import 'package:Balancer/shared/foreground.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:Balancer/home/home_state.dart';
import 'package:Balancer/login/login.dart';
import 'package:Balancer/profile/profile.dart';
import 'package:Balancer/services/auth.dart';
import 'package:Balancer/shared/error.dart';
import 'package:provider/provider.dart';

import '../login/register.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => HomeState(),
      child: StreamBuilder(
        stream: AuthService().userStream,
        builder: (context, snapshot) {
          var homeState = Provider.of<HomeState>(context);

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const ForegroundScreen();
          } else if (snapshot.hasError) {
            return ErrorMessage(
              message: snapshot.error.toString(),
            );
          } else if (snapshot.hasData) {
            if (!FirebaseAuth.instance.currentUser!.emailVerified) {
              return WillPopScope(
                  onWillPop: () async {
                    return false;
                  },
                  child: RegisterVerifyScreen());
            } else {
              final screens = [
                const HistoryScreen(),
                AnalyticsScreen(),
                const ProfileScreen(),
              ];

              return WillPopScope(
                onWillPop: () async {
                  return false;
                },
                child: Scaffold(
                  body: IndexedStack(
                    index: homeState.selectedIndex,
                    children: screens,
                  ),
                  bottomNavigationBar: BottomNavigationBar(
                    iconSize: 30,
                    showSelectedLabels: false,
                    showUnselectedLabels: false,
                    currentIndex: homeState.selectedIndex,
                    onTap: (int idx) {
                      homeState.selectedIndex = idx;

                      if (idx == 0) {
                        debugPrint('Navigating to history');
                      }
                    },
                    items: [
                      BottomNavigationBarItem(
                        activeIcon: Icon(
                          FontAwesomeIcons.book,
                          color: Theme.of(context).primaryColor,
                        ),
                        icon: const Icon(
                          FontAwesomeIcons.book,
                          color: Color(0xffcccccc),
                        ),
                        label: 'History',
                      ),
                      BottomNavigationBarItem(
                        activeIcon: Icon(
                          FontAwesomeIcons.chartColumn,
                          color: Theme.of(context).primaryColor,
                        ),
                        icon: const Icon(
                          FontAwesomeIcons.chartColumn,
                          color: Color(0xffcccccc),
                        ),
                        label: 'Analytics',
                      ),
                      BottomNavigationBarItem(
                        activeIcon: Icon(
                          FontAwesomeIcons.houseUser,
                          color: Theme.of(context).primaryColor,
                        ),
                        icon: const Icon(
                          FontAwesomeIcons.houseUser,
                          color: Color(0xffcccccc),
                        ),
                        label: 'Profile',
                      ),
                    ],
                  ),
                ),
              );
            }
          } else {
            return const LoginScreen();
          }
        },
      ),
    );
  }
}
