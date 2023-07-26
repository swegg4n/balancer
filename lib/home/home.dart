import 'package:Balancer/analytics/analytics.dart';
import 'package:Balancer/history/history.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:Balancer/home/home_state.dart';
import 'package:Balancer/login/login.dart';
import 'package:Balancer/profile/profile.dart';
import 'package:Balancer/services/auth.dart';
import 'package:Balancer/shared/error.dart';
import 'package:Balancer/shared/loading.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    PageController pageController = PageController(initialPage: 1, keepPage: false);

    return ChangeNotifierProvider(
      create: (_) => HomeState(),
      child: StreamBuilder(
        stream: AuthService().userStream,
        builder: (context, snapshot) {
          var homeState = Provider.of<HomeState>(context);

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const LoadingScreen();
          } else if (snapshot.hasError) {
            return ErrorMessage(
              message: snapshot.error.toString(),
            );
          } else if (snapshot.hasData) {
            // if (!FirebaseAuth.instance.currentUser!.emailVerified) {
            //   return WillPopScope(
            //       onWillPop: () async {
            //         return false;
            //       },
            //       child: RegisterVerifyScreen());
            // } else {
            final screens = [
              const HistoryScreen(),
              const AnalyticsScreen(),
              const ProfileScreen(),
            ];

            return WillPopScope(
              onWillPop: () async {
                return false;
              },
              child: Scaffold(
                body: PageView(
                  controller: pageController,
                  onPageChanged: (idx) {
                    homeState.selectedIndex = idx;
                  },
                  children: screens,
                ),
                bottomNavigationBar: BottomNavigationBar(
                  iconSize: 30,
                  showSelectedLabels: false,
                  showUnselectedLabels: false,
                  currentIndex: homeState.selectedIndex,
                  onTap: (int idx) {
                    homeState.selectedIndex = idx;
                    pageController.animateToPage(idx, duration: const Duration(milliseconds: 10), curve: Curves.linear);
                  },
                  items: [
                    BottomNavigationBarItem(
                      activeIcon: Image.asset(
                        'assets/rb_icon_solid.png',
                        color: Colors.deepOrange,
                        height: 32,
                      ),
                      icon: Image.asset(
                        'assets/rb_icon_solid.png',
                        color: const Color(0xffcccccc),
                        height: 32,
                      ),
                      label: 'My RB',
                    ),
                    BottomNavigationBarItem(
                      activeIcon: Image.asset(
                        'assets/ball_icon_solid.png',
                        color: Colors.deepOrange,
                        height: 32,
                      ),
                      icon: Image.asset(
                        'assets/ball_icon_solid.png',
                        color: const Color(0xffcccccc),
                        height: 32,
                      ),
                      label: 'Play',
                    ),
                    const BottomNavigationBarItem(
                      activeIcon: Icon(
                        FontAwesomeIcons.solidUser,
                        color: Colors.deepOrange,
                      ),
                      icon: Icon(
                        FontAwesomeIcons.solidUser,
                        color: Color(0xffcccccc),
                      ),
                      label: 'Profile',
                    ),
                  ],
                ),
              ),
            );
            // }
          } else {
            return const LoginScreen();
          }
        },
      ),
    );
  }
}
