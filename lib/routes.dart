import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'features/auth/providers/auth_provider.dart';
import 'features/auth/screens/login_screen.dart';
import 'features/auth/screens/register_screen.dart';
import 'features/auth/screens/verify_code_screen.dart';
import 'features/auth/screens/splash_screen.dart';
import 'features/expenses/screens/add_edit_expense_screen.dart';
import 'features/expenses/screens/expense_detail_screen.dart';
import 'features/expenses/screens/home_screen.dart';

final router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/register',
      builder: (context, state) => const RegisterScreen(),
    ),
    GoRoute(
      path: '/verify-code',
      builder: (context, state) {
        final email = state.extra as String? ?? '';
        return VerifyCodeScreen(email: email);
      },
    ),
    GoRoute(
      path: '/home',
      builder: (context, state) => const HomeScreen(),
    ),
    GoRoute(
      path: '/add-expense',
      builder: (context, state) => const AddEditExpenseScreen(),
    ),
    GoRoute(
      path: '/edit-expense/:id',
      builder: (context, state) => AddEditExpenseScreen(expenseId: state.pathParameters['id']),
    ),
    GoRoute(
      path: '/expense/:id',
      builder: (context, state) => ExpenseDetailScreen(expenseId: state.pathParameters['id']!),
    ),
  ],
  redirect: (context, state) {
    // Basic Auth Guard
    final auth = context.read<AuthProvider>();
    final loggingIn = state.uri.toString() == '/login';
    final registering = state.uri.toString() == '/register';
    final verifying = state.uri.toString() == '/verify-code'; // Careful with params
    final simpleVerify = state.uri.toString().startsWith('/verify-code');
    final splash = state.uri.toString() == '/';
    
    // Allow splash, login and register to pass through
    if (splash || loggingIn || registering || simpleVerify) return null;

    // If not authenticated, go to login
    if (!auth.isAuthenticated) return '/login';

    return null;
  },
);
