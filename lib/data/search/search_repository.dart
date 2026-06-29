abstract class SearchRepository {
  Future<List<String>> recentSearches();

  Future<void> record(String query);

  Future<void> remove(String query);
}
