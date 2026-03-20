import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract class SearchHistoryLocalDataSource {
  Future<List<String>> getSearchHistory();
  Future<void> saveSearchQuery(String query);
  Future<void> deleteSearchQuery(String query);
  Future<void> clearSearchHistory();
}

@LazySingleton(as: SearchHistoryLocalDataSource)
class SearchHistoryLocalDataSourceImpl implements SearchHistoryLocalDataSource {
  final SharedPreferences _sharedPreferences;
  static const String _historyKey = 'search_history';
  static const int _maxHistoryCount = 10;

  SearchHistoryLocalDataSourceImpl(this._sharedPreferences);

  @override
  Future<List<String>> getSearchHistory() async {
    return _sharedPreferences.getStringList(_historyKey) ?? [];
  }

  @override
  Future<void> saveSearchQuery(String query) async {
    final history = await getSearchHistory();
    // Remove if already exists to move it to the front
    history.remove(query);
    history.insert(0, query);
    
    // Limit to max history count
    if (history.length > _maxHistoryCount) {
      history.removeRange(_maxHistoryCount, history.length);
    }
    
    await _sharedPreferences.setStringList(_historyKey, history);
  }

  @override
  Future<void> deleteSearchQuery(String query) async {
    final history = await getSearchHistory();
    history.remove(query);
    await _sharedPreferences.setStringList(_historyKey, history);
  }

  @override
  Future<void> clearSearchHistory() async {
    await _sharedPreferences.remove(_historyKey);
  }
}
