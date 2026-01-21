import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'screens/customer/splash_screen.dart';
import 'screens/auth/login_screen.dart';
import 'services/cart_provider.dart';
import 'services/auth_service.dart';
import 'services/app_language.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => CartProvider()),
        ChangeNotifierProvider(create: (_) => AppLanguage()),
        Provider(create: (_) => AuthService()),
      ],
      child: MaterialApp(
        title: 'سوبر ماركت الأمير',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFFF57C00),
            primary: const Color(0xFFF57C00),
            secondary: const Color(0xFFFF9800),
            surface: const Color(0xFF0a0a0a),
            background: const Color(0xFF0a0a0a),
            brightness: Brightness.dark,
          ),
          useMaterial3: true,
          fontFamily: 'Cairo',
          scaffoldBackgroundColor: const Color(0xFF0a0a0a),
          cardColor: const Color(0xFF1a1a1a),
          appBarTheme: const AppBarTheme(
            backgroundColor: Color(0xFFF57C00),
            foregroundColor: Colors.white,
          ),
          inputDecorationTheme: InputDecorationTheme(
            filled: true,
            fillColor: const Color(0xFF2a2a2a),
            labelStyle: const TextStyle(color: Colors.orange),
            hintStyle: const TextStyle(color: Colors.grey),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFFF57C00)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFFF57C00)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFFF57C00), width: 2),
            ),
          ),
          snackBarTheme: const SnackBarThemeData(
            backgroundColor: Color(0xFFF57C00),
            contentTextStyle: TextStyle(color: Colors.white),
          ),
        ),
        home: const AuthWrapper(),
      ),
    );
  }
}

// Wrapper للتحقق من حالة المستخدم
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // في الانتظار
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        // لا يوجد مستخدم مسجل دخول
        if (!snapshot.hasData) {
          return const LoginScreen();
        }

        // هناك مستخدم مسجل دخول → اذهب للـ SplashScreen (ستتحقق من الـ role)
        return const SplashScreen();
      },
    );
  }
}


