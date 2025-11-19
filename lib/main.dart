import 'package:Witnessed/screens/auth/login_screen.dart';
import 'package:Witnessed/screens/auth/splash_screen.dart';
import 'package:Witnessed/screens/home/home_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'firebase_options.dart';
import 'package:Witnessed/providers/auth_provider.dart' as app_auth_provider;
import 'package:Witnessed/providers/profile_provider.dart';
import 'package:Witnessed/services/auth_service.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthService()),
        ChangeNotifierProxyProvider<AuthService, app_auth_provider.AuthProvider>(
          create: (_) => app_auth_provider.AuthProvider(authService: AuthService()),
          update: (_, authService, previous) =>
              previous ?? app_auth_provider.AuthProvider(authService: authService),
        ),
        ChangeNotifierProvider(create: (_) => ProfileProvider()),
      ],
      child: MaterialApp(
        title: 'AI Social Platform',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.blue,
          brightness: Brightness.light,
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.blue,
            brightness: Brightness.light,
          ),
        ),
        home: AuthWrapper(),
      ),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    
    return StreamBuilder<User?>(
      stream: authService.authStateChanges,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return SplashScreen();
        }
        
        if (snapshot.hasData && snapshot.data != null) {
          return HomeScreen();
        }
        
        return LoginScreen();
      },
    );
  }
}
