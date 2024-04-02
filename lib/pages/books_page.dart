import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quota/books_model.dart';
import 'package:quota/pages/book_args_widget.dart';
import 'package:quota/pages/book_page.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../contants.dart';
import '../supabase.dart';

class BooksPage extends StatefulWidget {
  const BooksPage({super.key});

  @override
  State<BooksPage> createState() => _BooksPageState();
}

class _BooksPageState extends State<BooksPage> {
  late TextEditingController _bookNameController;

  Future<void> _signOut() async {
    context.read<BooksModel>().clear();
    try {
      await supabase.auth.signOut();
    } on AuthException catch (error) {
      context.showErrorSnackBar(message: error.message);
    } catch (error) {
      context.showErrorSnackBar(message: 'Unexpected error occurred');
    }
    if (mounted) {
      Navigator.of(context).pushReplacementNamed('/');
    }
  }

  @override
  void initState() {
    super.initState();
    _bookNameController = TextEditingController();
    context.read<BooksModel>().refresh(context);
  }

  @override
  void dispose() {
    _bookNameController.dispose();
    super.dispose();
  }

  Widget _booksView(BuildContext context, BooksModel booksModel, Widget? child) {
    final loading = booksModel.loading;

    // If the books are still loading, return a loading spinner
    if (loading) {
      return SizedBox(
          width: MediaQuery.of(context).size.width,
          child: const Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                Text(
                  "Loading",
                  style: TextStyle(fontWeight: FontWeight.bold),
                )
              ]));
    }

    List<Book> books = booksModel.books;
    books.sort((a, b) => a.ownerEmail == supabase.auth.currentUser!.email ? -1 : 1);


    // Add all books owned by other users
    List<Widget> bookCards = books
        .map((book) => Card.outlined(
            margin: const EdgeInsets.all(15.0),
            child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Column(children: [
                  Padding(
                      padding: const EdgeInsets.all(10),
                      child: Text(
                        book.name,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20.0),
                      )),
                  Padding(
                      padding: const EdgeInsets.fromLTRB(10, 0, 10, 10),
                      child: Text(
                        book.ownerEmail,
                        style: const TextStyle(fontSize: 15),
                      )),
                  ElevatedButton(
                      onPressed: () {
                        Navigator.pushNamed(context, "/book", arguments: BookArgs(book));
                      },
                      child: const Text("View"))
                ]))))
        .toList();

    return ListView(
      children: [
        ...bookCards,
        Padding(
          padding: EdgeInsets.fromLTRB(15.0,15.0,15.0,40.0),
          child: ElevatedButton(
              onPressed: () {
                showDialog<bool>(
                    context: context,
                    builder: (context) => AlertDialog(
                          title: const Text("Add details"),
                          content: Column(children: [
                            TextField(
                              decoration: const InputDecoration(label: Text("Book name")),
                              controller: _bookNameController,
                            )
                          ]),
                          actions: [
                            TextButton(
                                onPressed: () {
                                  if (_bookNameController.text.trim().isEmpty) {
                                    context.showErrorSnackBar(message: "Book name should not be empty");
                                    return;
                                  }
                                  Navigator.pop(context, true);
                                },
                                child: const Text("Ok")),
                            TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Cancel"))
                          ],
                        )).then((result) {
                  if (result ?? false) {
                    if (_bookNameController.text.trim() == "") {
                      context.showErrorSnackBar(message: "Book name not be empty");
                      return;
                    }

                    _bookNameController.clear();
                    booksModel.refresh(context);
                    final newBook = NewBook(name: _bookNameController.text);

                    newBook.create().then((book) {
                      Navigator.pushNamed(context, "/book", arguments: BookArgs(book));
                    }).catchError((ex) {
                      log("Cound not create book", error: ex);
                      context.showErrorSnackBar(message: "Could not create book");
                    });
                  }
                });
              },
              child: const Text("Create Book")),
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Text("Select book"), actions: [
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: ElevatedButton.icon(
                onPressed: _signOut,
                icon: const Icon(Icons.logout),
                label: const Text("Logout"),
                style: const ButtonStyle(backgroundColor: MaterialStatePropertyAll<Color>(Colors.red))),
          ),
        ]),
        floatingActionButton: FloatingActionButton(
            onPressed: () => context.read<BooksModel>().refresh(context), child: const Icon(Icons.refresh)),
        body: Container(
          width: MediaQuery.of(context).size.width,
          child: Consumer<BooksModel>(
            builder: _booksView,
          ),
        ));
  }
}
