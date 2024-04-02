import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quota/pages/add_quote_page.dart';
import 'package:quota/pages/book_args_widget.dart';
import 'package:quota/pages/books_page.dart';
import 'package:quota/pages/book_page.dart';
import 'package:quota/pages/settings_page.dart';
import 'package:quota/supabase.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:quota/pages/login_page.dart';
import 'package:quota/pages/splash_page.dart';
import 'books_model.dart';

Future<void> main() async {
  await Supabase.initialize(
    url: 'https://ruehdrpcjuuopfilxygv.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InJ1ZWhkcnBjanV1b3BmaWx4eWd2Iiwicm9sZSI6ImFub24iLCJpYXQiOjE2Njk2MTE4MDMsImV4cCI6MTk4NTE4NzgwM30.S7EEHtjIm0lThHfVP4D8NEDGXMSrJx631p32jtnn8x4',
  );
  runApp(ChangeNotifierProvider(
    create: (context) => BooksModel(),
    child: const MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Quota',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple).copyWith(
          background: Colors.grey[50]!,
        ),
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness: Brightness.dark,
        ).copyWith(background: Colors.grey[850]!),
      ),
      initialRoute: '/',
      routes: <String, WidgetBuilder>{
        '/': (_) => const SplashPage(),
        '/login': (_) => const LoginPage(),
        '/books': (_) => const BooksPage(),
        '/book': (_) => BookArgsExtractor(
            create: (book, _) => BookPage(
                  book: book,
                )),
        '/new-quote': (_) => BookArgsExtractor(create: (book, _) => AddQuotePage(book: book)),
        '/settings': (_) => BookArgsExtractor(create: (book, _) => SettingsPage(book: book))
      },
    );
  }
}
