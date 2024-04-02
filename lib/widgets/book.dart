import 'package:flutter/material.dart';
import 'package:quota/widgets/book_args.dart';
import 'package:quota/supabase.dart';

class BookWidget extends StatelessWidget {
  const BookWidget({
    super.key,
    required this.book,
  });

  final Book book;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: Card.outlined(
        margin: const EdgeInsets.all(15.0),
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(10),
                child: Text(
                  book.name,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20.0),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(10, 0, 10, 10),
                child: Text(
                  book.ownerEmail,
                  style: const TextStyle(fontSize: 15),
                ),
              ),
            ],
          ),
        ),
      ),
      onTap: () {
        Navigator.pushNamed(context, "/book", arguments: BookArgs(book));
      },
    );
  }
}

                  // ElevatedButton(
                  //     onPressed: () {
                  //       Navigator.pushNamed(context, "/book", arguments: BookArgs(book));
                  //     },
                  //     child: const Text("View"))
