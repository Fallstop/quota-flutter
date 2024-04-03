import 'package:flutter/material.dart';
import 'package:quota/state/quotes_model.dart';
import 'package:quota/widgets/book_args.dart';
import 'package:quota/state/supabase.dart';

class BookWidget extends StatelessWidget {
  const BookWidget({
    super.key,
    required this.book,
    required this.quoteCount,
  });

  final Book book;
  final int quoteCount;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: Card.outlined(
        margin: const EdgeInsets.all(15.0),
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Row(
            children: [
              Column(
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
              const Spacer(),
              Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(10),
                      child: Text(
                        quoteCount.toString(),
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 25.0),
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.fromLTRB(10, 0, 10, 10),
                      child: Text(
                        "quotes",
                        style: TextStyle(fontSize: 15),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      onTap: () {
        Navigator.pushNamed(context, "/book", arguments: BookArgs(book.id));
      },
    );
  }
}

                  // ElevatedButton(
                  //     onPressed: () {
                  //       Navigator.pushNamed(context, "/book", arguments: BookArgs(book));
                  //     },
                  //     child: const Text("View"))
