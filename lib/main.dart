import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:journal_app/Screens/dashboard_screen.dart';
import 'package:journal_app/Screens/login_Screen.dart';
import 'package:journal_app/Screens/register_screen.dart';
import 'package:journal_app/provider/journal_provider.dart';
import 'package:journal_app/provider/myauth_provider.dart';
import 'package:provider/provider.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
          ChangeNotifierProvider(create: (_) => MyAuthProvider()),
         ChangeNotifierProvider(create: (_) => JournalProvider()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        ),
        home:RegisterScreen(),
      ),
    );
  }
}

