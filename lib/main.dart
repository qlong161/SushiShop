import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:sushishop_btl/pages/intro_page.dart';
import 'package:sushishop_btl/pages/menu_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://rzysndbakpvqbscxzbwg.supabase.co',
    anonKey: 'sb_publishable_8XTaP4VSHmQg9-7Rg7wJFQ_yOjeLoeE',
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: '/intropage',
      routes: {
        '/intropage': (context) => const IntroPage(),
        '/menupage': (context) => const MenuPage(),
      },
    );
  }
}
