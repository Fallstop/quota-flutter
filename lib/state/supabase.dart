import 'package:flutter/material.dart';
import 'package:quota/contants.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:provider/provider.dart';
import 'package:quota/state/quotes_model.dart';

part 'supabase.g.dart';


class NewBook {
  late final String name;
  NewBook({required this.name});


  Future<Book> create() async {

    return Book.fromSupabase(await supabase.from("books").insert({"book_name": name, "owner_email": supabase.auth.currentUser!.email}).select('*').single());
  }
}

@JsonSerializable()
class Book {
  late final String id;
  late final String owner;
  late final String ownerEmail;
  late final String name;

  Book({required this.id, required this.owner, required this.ownerEmail, required this.name});

  factory Book.fromSupabase(Map<String, dynamic> map) {
    print(map);
    return Book(ownerEmail: map["owner_email"], owner: map["owner"], id: map["id"], name: map["book_name"]);
  }

  Future<List<Quote>> quotes(BuildContext context, {bool refresh_quotes = false}) async {
    QuotesModel quote_model = context.read();

    if (!quote_model.hasQuotesForBook(id) || refresh_quotes) {
      await quote_model.refresh(context, id);
    }

    return quote_model.quotesForBook(id);
  }


  Future<List<Member>> getMembers() async =>
      (await supabase.from("user_connections").select<List<Map<String, dynamic>>>("profiles:user (*)").eq("book", id))
          .map((entry) => Member.fromSupabase(entry["profiles"]))
          .toList();

  Future<void> addMember(String email) async {
    // Check to make sure we aren't double inserting
    if ((await getMembers()).any((element) => element.email == email)) {
      return;
    }

    final Map<String, dynamic> user = await supabase.from("profiles").select("id").eq("email", email).single();

    await supabase.from("user_connections").insert({"user": user["id"], "book": id});
  }

  Future<Book> updateName(String name) async =>
      Book.fromSupabase(await supabase.from("books").update({"book_name": name}).eq("id", id).select("*").single());

  Future<void> remove() async {
    await supabase.from("user_connections").delete().eq("book", id);
    await supabase.from("books").delete().eq("id", id);
  }

  bool isUserOwner() {
    return ownerEmail == supabase.auth.currentUser!.email;
  }

  factory Book.fromJson(Map<String, dynamic> json) => _$BookFromJson(json);
  Map<String, dynamic> toJson() => _$BookToJson(this);
}

class Member {
  final String email;
  final String id;

  Member({required this.email, required this.id});
  factory Member.fromSupabase(Map<String, dynamic> entry) => Member(email: entry["email"], id: entry["id"]);

  Future<void> removeFrom(Book book) async {
    await supabase.from("user_connections").delete().match({"book": book.id, "user": id});
  }
}

@JsonSerializable()
class Quote {
  late final String id;
  late final String person;
  late final String quote;
  late final DateTime date;
  late final String book;

  Quote({required this.id, required this.book, required this.date, required this.person, required this.quote});

  Future<void> delete(BuildContext context) async {
    try {
      await supabase.from("quotes").delete().eq("id", id);
    } catch (ex) {
      context.showErrorSnackBar(message: "Could not delete quote $quote");
    }
  }

  factory Quote.fromJson(Map<String, dynamic> json) => _$QuoteFromJson(json);
  Map<String, dynamic> toJson() => _$QuoteToJson(this);
}

@JsonSerializable()
class NewQuote {
  late final String book;
  late final String person;
  late final String quote;
  late final DateTime date;

  NewQuote({required this.book, required this.person, required this.quote, required this.date});

  Future<void> add() async {
    final dict = {"book": book, "person": person, "quote": quote, "date": date.toIso8601String()};


    await supabase.from("quotes").insert(dict);
  }

  factory NewQuote.fromJson(Map<String, dynamic> json) => _$NewQuoteFromJson(json);
  Map<String, dynamic> toJson() => _$NewQuoteToJson(this);
}
