import 'package:go_router/go_router.dart';
import 'package:todo_list_provider/app/categories/category_page.dart';
import 'package:todo_list_provider/app/core/auth_provider/app_auth_provider.dart';
import 'package:todo_list_provider/app/home/home_page/home_page.dart';
import 'package:todo_list_provider/app/modules/auth/login/login_page.dart';
import 'package:todo_list_provider/app/modules/auth/register/register_page.dart';
import 'package:todo_list_provider/app/modules/splash/splash_page.dart';

GoRouter createRouter(AppAuthProvider authProvider) {
  return GoRouter(
    initialLocation: '/splash',

    refreshListenable: authProvider, // <-- ESSENCIAL PARA GO ROUTER

    redirect: (context, state) {
      final isLoggedIn = authProvider.isLoggedIn;
      final location = state.uri.toString();

      if (location == '/splash') {
        return isLoggedIn ? '/home' : '/login';
      }

      if (!isLoggedIn && location == '/home') {
        return '/login';
      }

      if (isLoggedIn && location == '/login') {
        return '/home';
      }

      return null;
    },

    routes: [
      GoRoute(path: '/splash', builder: (_, __) => const SplashPage()),
      GoRoute(path: '/login', builder: (_, __) => const LoginPage()),
      GoRoute(path: '/register', builder: (_, __) => const RegisterPage()),
      GoRoute(path: '/home', builder: (_, __) => const HomePage()),
      GoRoute(path: '/categories', builder: (_, __) => const CategoryPage()),
    ],
  );
}
