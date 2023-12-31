import 'package:Balancer/home/home.dart';
import 'package:Balancer/login/login.dart';
import 'package:Balancer/history/history.dart';
import 'package:Balancer/analytics/analytics.dart';
import 'package:Balancer/profile/profile.dart';

var appRoutes = {
  '/': (context) => const HomeScreen(),
  '/login': (context) => const LoginScreen(),
  '/history': (context) => const HistoryScreen(),
  '/analytics': (context) => AnalyticsScreen(),
  '/profile': (context) => const ProfileScreen(),
};
