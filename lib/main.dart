import 'package:flutter/material.dart';
import 'package:provider/provider.dart' as provider;

import 'package:quota/pages/add_quote_page.dart';
import 'package:quota/state/quotes_model.dart';
import 'package:quota/widgets/book_args.dart';
import 'package:quota/pages/books_page.dart';
import 'package:quota/pages/book_page.dart';
import 'package:quota/pages/settings_page.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:quota/pages/login_page.dart';
import 'package:quota/pages/splash_page.dart';
import 'state/books_model.dart';

Future<void> main() async {
  await Supabase.initialize(
    url: 'https://ruehdrpcjuuopfilxygv.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InJ1ZWhkcnBjanV1b3BmaWx4eWd2Iiwicm9sZSI6ImFub24iLCJpYXQiOjE2Njk2MTE4MDMsImV4cCI6MTk4NTE4NzgwM30.S7EEHtjIm0lThHfVP4D8NEDGXMSrJx631p32jtnn8x4',
  );
  runApp(provider.MultiProvider(
    providers: [
      provider.ChangeNotifierProvider<BooksModel>(
        create: (context) => BooksModel(context),
      ),
      provider.ChangeNotifierProvider<QuotesModel>(
        create: (context) => QuotesModel(context),
      ),
    ],
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
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness: Brightness.dark,
        ),
      ),
      initialRoute: '/',
      routes: <String, WidgetBuilder>{
        '/': (_) => const SplashPage(),
        '/login': (_) => const LoginPage(),
        '/books': (_) => const BooksPage(),
        '/book': (_) => BookArgsExtractor(
            create: (bookId, _) => BookPage(
                  bookId: bookId,
                )),
        '/new-quote': (_) => BookArgsExtractor(create: (bookId, _) => AddQuotePage(bookId: bookId)),
        '/settings': (_) => BookArgsExtractor(create: (bookId, _) => SettingsPage(bookId: bookId))
      },
    );
  }
}
