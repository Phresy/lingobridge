import '../entities/translation_entry.dart';

/// The domain layer only knows this interface. `data/` provides the
/// concrete SQLite implementation. If a future phase adds cloud sync
/// (Supabase/Firebase), it becomes a second implementation of this same
/// contract — no screen or provider changes required.
abstract class TranslationRepository {
  Future<List<TranslationEntry>> getHistory();
  Future<List<TranslationEntry>> getFavorites();
  Future<List<TranslationEntry>> search(String query);
  Future<TranslationEntry> addEntry(TranslationEntry entry);
  Future<void> toggleFavorite(String id);
  Future<void> deleteEntry(String id);
  Future<void> clearHistory();
}
