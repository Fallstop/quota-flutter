// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'supabase.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

StoredData _$StoredDataFromJson(Map<String, dynamic> json) => StoredData(
      quotesCache: (json['quotesCache'] as Map<String, dynamic>).map(
        (k, e) => MapEntry(k, CacheEntry.fromJson(e as Map<String, dynamic>)),
      ),
      needsRemoving:
          (json['needsRemoving'] as List<dynamic>).map((e) => Quote.fromJson(e as Map<String, dynamic>)).toList(),
      needsAdding:
          (json['needsAdding'] as List<dynamic>).map((e) => NewQuote.fromJson(e as Map<String, dynamic>)).toList(),
    );

Map<String, dynamic> _$StoredDataToJson(StoredData instance) => <String, dynamic>{
      'quotesCache': instance.quotesCache,
      'needsRemoving': instance.needsRemoving,
      'needsAdding': instance.needsAdding,
    };

CacheEntry _$CacheEntryFromJson(Map<String, dynamic> json) => CacheEntry(
      expiry: DateTime.parse(json['expiry'] as String),
      quotes: (json['quotes'] as List<dynamic>).map((e) => Quote.fromJson(e as Map<String, dynamic>)).toList(),
    );

Map<String, dynamic> _$CacheEntryToJson(CacheEntry instance) => <String, dynamic>{
      'expiry': instance.expiry.toIso8601String(),
      'quotes': instance.quotes,
    };

Book _$BookFromJson(Map<String, dynamic> json) => Book(
      id: json['id'] as String,
      owner: json['owner'] as String,
      ownerEmail: json['ownerEmail'] as String,
      name: json['name'] as String,
    );

Map<String, dynamic> _$BookToJson(Book instance) => <String, dynamic>{
      'id': instance.id,
      'owner': instance.owner,
      'ownerEmail': instance.ownerEmail,
      'name': instance.name,
    };

Quote _$QuoteFromJson(Map<String, dynamic> json) => Quote(
      id: json['id'] as String,
      book: json['book'] as String,
      date: DateTime.parse(json['date'] as String),
      person: json['person'] as String,
      quote: json['quote'] as String,
    );

Map<String, dynamic> _$QuoteToJson(Quote instance) => <String, dynamic>{
      'id': instance.id,
      'person': instance.person,
      'quote': instance.quote,
      'date': instance.date.toIso8601String(),
      'book': instance.book,
    };

NewQuote _$NewQuoteFromJson(Map<String, dynamic> json) => NewQuote(
      book: json['book'] as String,
      person: json['person'] as String,
      quote: json['quote'] as String,
      date: DateTime.parse(json['date'] as String),
    );

Map<String, dynamic> _$NewQuoteToJson(NewQuote instance) => <String, dynamic>{
      'book': instance.book,
      'person': instance.person,
      'quote': instance.quote,
      'date': instance.date.toIso8601String(),
    };
