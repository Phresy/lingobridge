import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

// FIXED: Add this import for the extensions
import '../../../core/constants/app_constants.dart';
import '../../../domain/entities/translation_entry.dart';
import '../../providers/history_provider.dart';

class HistoryScreen extends ConsumerStatefulWidget {
  const HistoryScreen({super.key});

  @override
  ConsumerState<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends ConsumerState<HistoryScreen> {
  bool _searching = false;
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(historyProvider);
    final notifier = ref.read(historyProvider.notifier);
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: _searching
            ? TextField(
                controller: _searchController,
                autofocus: true,
                decoration: const InputDecoration(
                  hintText: 'Search history…',
                  border: InputBorder.none,
                ),
                onChanged: notifier.setQuery,
              )
            : const Text('History'),
        actions: [
          IconButton(
            onPressed: () {
              setState(() {
                if (_searching) _searchController.clear();
                _searching = !_searching;
              });
              if (!_searching) notifier.setQuery('');
            },
            icon: Icon(_searching ? Icons.close_rounded : Icons.search_rounded),
          ),
          if (!_searching)
            PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'clear') _confirmClear(context, notifier);
              },
              itemBuilder: (context) => const [
                PopupMenuItem(value: 'clear', child: Text('Clear all history')),
              ],
            ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: Padding(
            padding: const EdgeInsets.only(left: 16, bottom: 8),
            child: Align(
              alignment: Alignment.centerLeft,
              child: FilterChip(
                label: const Text('Favourites only'),
                avatar: const Icon(Icons.favorite_rounded, size: 16),
                selected: state.favoritesOnly,
                onSelected: notifier.setFavoritesOnly,
              ),
            ),
          ),
        ),
      ),
      body: _buildBody(context, state, notifier, scheme),
    );
  }

  Widget _buildBody(
    BuildContext context,
    HistoryState state,
    HistoryNotifier notifier,
    ColorScheme scheme,
  ) {
    if (state.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (state.error != null) {
      return Center(child: Text(state.error!));
    }
    if (state.entries.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              state.favoritesOnly
                  ? Icons.favorite_border_rounded
                  : Icons.history_rounded,
              size: 56,
              color: scheme.outline,
            ),
            const SizedBox(height: 12),
            Text(
              state.query.isNotEmpty
                  ? 'No results for "${state.query}"'
                  : state.favoritesOnly
                      ? 'No favourites yet'
                      : 'Your translations will appear here',
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: scheme.onSurfaceVariant),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: notifier.load,
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: state.entries.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (context, i) {
          final entry = state.entries[i];
          return Dismissible(
            key: ValueKey(entry.id),
            direction: DismissDirection.endToStart,
            background: Container(
              decoration: BoxDecoration(
                color: scheme.errorContainer,
                borderRadius: BorderRadius.circular(20),
              ),
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.only(right: 20),
              child: Icon(Icons.delete_rounded, color: scheme.onErrorContainer),
            ),
            onDismissed: (_) => notifier.delete(entry.id),
            child: _HistoryTile(
              entry: entry,
              onFavoriteToggle: () => notifier.toggleFavorite(entry.id),
            ),
          );
        },
      ),
    );
  }

  void _confirmClear(BuildContext context, HistoryNotifier notifier) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear all history?'),
        content: const Text(
            'This deletes every saved translation, including favourites. This cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              notifier.clearAll();
              Navigator.pop(context);
            },
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }
}

class _HistoryTile extends StatelessWidget {
  const _HistoryTile({required this.entry, required this.onFavoriteToggle});

  final TranslationEntry entry;
  final VoidCallback onFavoriteToggle;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _Pill(
                  '${entry.sourceLanguage.displayName} → ${entry.targetLanguage.displayName}'),
              const SizedBox(width: 6),
              _Pill(entry.domain.label),
              const Spacer(),
              Text(
                DateFormat('MMM d, HH:mm').format(entry.createdAt),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(entry.sourceText, style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 4),
          Text(
            entry.translatedText,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: scheme.primary,
                ),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: IconButton(
              onPressed: onFavoriteToggle,
              icon: Icon(
                entry.isFavorite
                    ? Icons.favorite_rounded
                    : Icons.favorite_border_rounded,
                color: entry.isFavorite ? scheme.error : scheme.outline,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill(this.label);
  final String label;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall,
      ),
    );
  }
}
