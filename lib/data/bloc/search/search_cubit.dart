import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:notes/data/search/search_repository.dart';

@injectable
class SearchCubit extends Cubit<List<String>> {
  SearchCubit(this._repo) : super(const []);

  final SearchRepository _repo;

  Future<void> load() async {
    emit(await _repo.recentSearches());
  }

  Future<void> record(String query) async {
    await _repo.record(query);
    await load();
  }

  Future<void> remove(String query) async {
    await _repo.remove(query);
    await load();
  }
}
