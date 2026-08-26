import '../core/utils/json.dart';

/// Odgovor sa strane list endpointa. Paginacija je obavezna na svakom list pozivu.
class PagedResult<T> {
  const PagedResult({
    required this.items,
    required this.totalCount,
    required this.page,
    required this.pageSize,
    required this.totalPages,
    required this.hasNextPage,
  });

  final List<T> items;
  final int totalCount;
  final int page;
  final int pageSize;
  final int totalPages;
  final bool hasNextPage;

  bool get isEmpty => items.isEmpty;

  factory PagedResult.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) mapper,
  ) {
    return PagedResult<T>(
      items: Json.list(json['items'], mapper),
      totalCount: Json.integer(json['totalCount']),
      page: Json.integer(json['page'], 1),
      pageSize: Json.integer(json['pageSize'], 20),
      totalPages: Json.integer(json['totalPages']),
      hasNextPage: Json.boolean(json['hasNextPage']),
    );
  }

  static PagedResult<T> empty<T>() => PagedResult<T>(
        items: const [],
        totalCount: 0,
        page: 1,
        pageSize: 20,
        totalPages: 0,
        hasNextPage: false,
      );
}

/// Stavka za punjenje padajucih lista.
class Lookup {
  const Lookup({required this.id, required this.name});

  final int id;
  final String name;

  factory Lookup.fromJson(Map<String, dynamic> json) =>
      Lookup(id: Json.integer(json['id']), name: Json.str(json['name']));

  @override
  bool operator ==(Object other) =>
      other is Lookup && other.id == id && other.name == name;

  @override
  int get hashCode => Object.hash(id, name);
}
