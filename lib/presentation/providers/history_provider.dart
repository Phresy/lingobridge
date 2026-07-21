import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/translation_entry.dart';
import '../../domain/repositories/translation_repository.dart';
import 'translation_di_provider.dart';

class HistoryState {
  const HistoryState({
    this.entries = const [],
    this.isLoading = true,
    this.query = '',
    this.favoritesOnly = false,
    this.error,
  });

  final List<TranslationEntry> entries;
  final bool isLoading;
  final String query;
  final bool favoritesOnly;
  final String? error;

  HistoryState copyWith({
    List<TranslationEntry>? entries,
    bool? isLoading,
    String? query,
    bool? favoritesOnly,
    String? error,
  }) {
    return HistoryState(
      entries: entries ?? this.entries,
      isLoading: isLoading ?? this.isLoading,
      query: query ?? this.query,
      favoritesOnly: favoritesOnly ?? this.favoritesOnly,
      error: error,
    );
  }
}

/// Deliberately re-queries SQLite on every mutation (favorite/delete/search)
/// rather than mutating an in-memory list. History is small (this is a
/// phone app, not a warehouse), so the simplicity of "always trust the DB"
/// beats the bug surface of keeping two copies of the data in sync.
class HistoryNotifier extends StateNotifier<HistoryState> {
  HistoryNotifier(this._repository) : super(const HistoryState()) {
    load();
  }

  final TranslationRepository _repository;

  Future<void> load() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final entries = state.favoritesOnly
          ? await _repository.getFavorites()
          : (state.query.isEmpty
              ? await _repository.getHistory()
              : await _repository.search(state.query));
      state = state.copyWith(entries: entries, isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Could not load history. Please try again.',
      );
    }
  }

  Future<void> setQuery(String query) async {
    state = state.copyWith(query: query);
    await load();
  }

  Future<void> setFavoritesOnly(bool value) async {
    state = state.copyWith(favoritesOnly: value);
    await load();
  }

  Future<void> toggleFavorite(String id) async {
    await _repository.toggleFavorite(id);
    await load();
  }

  Future<void> delete(String id) async {
    await _repository.deleteEntry(id);
    await load();
  }

  Future<void> clearAll() async {
    await _repository.clearHistory();
    await load();
  }
}

final historyProvider =
    StateNotifierProvider<HistoryNotifier, HistoryState>(
  (ref) => HistoryNotifier(ref.watch(translationRepositoryProvider)),
);
