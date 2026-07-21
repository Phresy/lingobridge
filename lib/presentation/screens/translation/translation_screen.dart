// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../../providers/connectivity_provider.dart';
import '../../providers/speech_provider.dart';
import '../../providers/translate_controller.dart';

class TranslationScreen extends ConsumerWidget {
  const TranslationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final connectivity = ref.watch(connectivityProvider);
    final translateState = ref.watch(translateControllerProvider);
    final controller = ref.read(translateControllerProvider.notifier);

    print(
        'UI BUILD - Result: ${translateState.result?.translatedText ?? "null"}');

    return Scaffold(
      appBar: AppBar(
        title: const Text('LingoBridge'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: _ConnectivityBadge(status: connectivity),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const _OfflineModeBanner(),
              const SizedBox(height: 8),
              _LanguageSelector(
                source: translateState.sourceLanguage,
                target: translateState.targetLanguage,
                onSwap: controller.swapLanguages,
                onSourceChanged: controller.setSourceLanguage,
                onTargetChanged: controller.setTargetLanguage,
              ),
              const SizedBox(height: 14),
              _DomainSelector(
                selected: translateState.domain,
                onChanged: controller.setDomain,
              ),
              const SizedBox(height: 16),
              _InputCard(
                sourceLanguage: translateState.sourceLanguage,
                onChanged: controller.setInputText,
                isTranslating: translateState.isTranslating,
                onTranslate: controller.translate,
                onDictated: controller.setInputText,
              ),
              if (translateState.error != null) ...[
                const SizedBox(height: 12),
                Text(
                  translateState.error!,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.error,
                  ),
                ),
              ],
              if (translateState.result != null) ...[
                const SizedBox(height: 16),
                _ResultCard(
                  text: translateState.result!.translatedText,
                  isFavorite: translateState.result!.isFavorite,
                  onFavoriteToggle: controller.toggleResultFavorite,
                  targetLanguage:
                      translateState.targetLanguage, // ← Pass language
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _OfflineModeBanner extends StatelessWidget {
  const _OfflineModeBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      margin: const EdgeInsets.only(bottom: 4),
      decoration: BoxDecoration(
        color: Colors.green.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          const Icon(Icons.offline_bolt_rounded, size: 18, color: Colors.green),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Offline mode - Translations from GhanaNLP data',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
        ],
      ),
    );
  }
}

class _InputCard extends ConsumerStatefulWidget {
  const _InputCard({
    required this.sourceLanguage,
    required this.onChanged,
    required this.isTranslating,
    required this.onTranslate,
    required this.onDictated,
  });

  final SupportedLanguage sourceLanguage;
  final ValueChanged<String> onChanged;
  final bool isTranslating;
  final VoidCallback onTranslate;
  final ValueChanged<String> onDictated;

  @override
  ConsumerState<_InputCard> createState() => _InputCardState();
}

class _InputCardState extends ConsumerState<_InputCard> {
  final _controller = TextEditingController();
  static const _maxChars = 500;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _toggleMic() async {
    final sttNotifier = ref.read(sttControllerProvider.notifier);
    final isListening = ref.read(sttControllerProvider).isListening;

    if (isListening) {
      await sttNotifier.stop();
      return;
    }
    await sttNotifier.start(widget.sourceLanguage);
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final sttState = ref.watch(sttControllerProvider);

    ref.listen(sttControllerProvider, (previous, next) {
      if (next.transcript.isNotEmpty &&
          next.transcript != previous?.transcript) {
        _controller.value = TextEditingValue(
          text: next.transcript,
          selection: TextSelection.collapsed(offset: next.transcript.length),
        );
        widget.onDictated(next.transcript);
      }
      if (next.error != null && next.error != previous?.error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(next.error!)),
        );
      }
    });

    return Container(
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(20),
        boxShadow: AppTheme.softShadow(context),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(
            controller: _controller,
            maxLines: 5,
            minLines: 3,
            maxLength: _maxChars,
            onChanged: widget.onChanged,
            decoration: InputDecoration(
              hintText: sttState.isListening
                  ? 'Listening...'
                  : 'Type or speak to translate...',
              border: InputBorder.none,
              counterText: '',
            ),
          ),
          Row(
            children: [
              Text(
                '${_controller.text.length}/$_maxChars',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
              ),
              const Spacer(),
              IconButton(
                tooltip: sttState.isListening
                    ? 'Stop listening'
                    : 'Voice input (works best in English on most devices)',
                onPressed: _toggleMic,
                icon: Icon(
                  sttState.isListening
                      ? Icons.stop_circle_rounded
                      : Icons.mic_none_rounded,
                  color: sttState.isListening ? scheme.error : null,
                ),
              ),
              FilledButton.icon(
                onPressed:
                    widget.isTranslating || _controller.text.trim().isEmpty
                        ? null
                        : widget.onTranslate,
                icon: widget.isTranslating
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.translate_rounded, size: 18),
                label: const Text('Translate'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ResultCard extends ConsumerWidget {
  const _ResultCard({
    required this.text,
    required this.isFavorite,
    required this.onFavoriteToggle,
    required this.targetLanguage, // ← NEW: Pass target language
  });

  final String text;
  final bool isFavorite;
  final VoidCallback onFavoriteToggle;
  final SupportedLanguage targetLanguage; // ← NEW

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    final playback = ref.watch(ttsControllerProvider);
    final ttsController = ref.read(ttsControllerProvider.notifier);

    print('Building Result Card with text: "$text"');

    return Container(
      decoration: BoxDecoration(
        color: scheme.primaryContainer,
        borderRadius: BorderRadius.circular(20),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            text,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: scheme.onPrimaryContainer,
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              // ===== PLAY BUTTON - Now passes language code =====
              IconButton(
                tooltip: playback == PlaybackState.playing ? 'Pause' : 'Play',
                onPressed: () {
                  if (playback == PlaybackState.playing) {
                    ttsController.pause();
                  } else {
                    // Pass the language code to TTS
                    ttsController.play(
                      text,
                      languageCode: targetLanguage.code, // ← 'tw', 'ee', 'ha'
                    );
                  }
                },
                icon: Icon(
                  playback == PlaybackState.playing
                      ? Icons.pause_circle_filled_rounded
                      : Icons.play_circle_fill_rounded,
                  color: scheme.onPrimaryContainer,
                ),
              ),
              // ===== REPLAY BUTTON =====
              IconButton(
                tooltip: 'Replay',
                onPressed: () {
                  ttsController.stop();
                  ttsController.play(
                    text,
                    languageCode: targetLanguage.code, // ← Pass language
                  );
                },
                icon: Icon(Icons.replay_rounded,
                    color: scheme.onPrimaryContainer),
              ),
              // ===== SPEED BUTTON =====
              IconButton(
                tooltip: 'Playback speed',
                onPressed: () => _showSpeedSheet(context, ttsController),
                icon:
                    Icon(Icons.speed_rounded, color: scheme.onPrimaryContainer),
              ),
              // ===== COPY BUTTON =====
              IconButton(
                tooltip: 'Copy',
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: text));
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Copied to clipboard')),
                  );
                },
                icon:
                    Icon(Icons.copy_rounded, color: scheme.onPrimaryContainer),
              ),
              const Spacer(),
              // ===== FAVOURITE BUTTON =====
              IconButton(
                tooltip: isFavorite
                    ? 'Remove from favourites'
                    : 'Save to favourites',
                onPressed: onFavoriteToggle,
                icon: Icon(
                  isFavorite
                      ? Icons.favorite_rounded
                      : Icons.favorite_border_rounded,
                  color: scheme.onPrimaryContainer,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showSpeedSheet(BuildContext context, TtsController controller) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setSheetState) {
          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Playback Speed',
                      style: Theme.of(context).textTheme.titleMedium),
                  Slider(
                    value: controller.rate,
                    min: 0.25,
                    max: 1.0,
                    divisions: 6,
                    label: '${controller.rate.toStringAsFixed(2)}x',
                    onChanged: (v) {
                      setSheetState(() {});
                      controller.setRate(v);
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _DomainSelector extends StatelessWidget {
  const _DomainSelector({required this.selected, required this.onChanged});

  final TranslationDomain selected;
  final ValueChanged<TranslationDomain> onChanged;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 36,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: TranslationDomain.values.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, i) {
          final domain = TranslationDomain.values[i];
          final isSelected = domain == selected;
          return ChoiceChip(
            label: Text(domain.label),
            selected: isSelected,
            onSelected: (_) => onChanged(domain),
          );
        },
      ),
    );
  }
}

class _LanguageSelector extends StatelessWidget {
  const _LanguageSelector({
    required this.source,
    required this.target,
    required this.onSwap,
    required this.onSourceChanged,
    required this.onTargetChanged,
  });

  final SupportedLanguage source;
  final SupportedLanguage target;
  final VoidCallback onSwap;
  final ValueChanged<SupportedLanguage> onSourceChanged;
  final ValueChanged<SupportedLanguage> onTargetChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _LangPill(
            language: source,
            onTap: () async {
              final picked = await _pickLanguage(context, source);
              if (picked != null) onSourceChanged(picked);
            },
          ),
        ),
        IconButton.filledTonal(
          onPressed: onSwap,
          icon: const Icon(Icons.swap_horiz_rounded),
        ),
        Expanded(
          child: _LangPill(
            language: target,
            onTap: () async {
              final picked = await _pickLanguage(context, target);
              if (picked != null) onTargetChanged(picked);
            },
          ),
        ),
      ],
    );
  }

  Future<SupportedLanguage?> _pickLanguage(
    BuildContext context,
    SupportedLanguage current,
  ) {
    return showModalBottomSheet<SupportedLanguage>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: SupportedLanguage.values
              .map(
                (l) => ListTile(
                  title: Text(l.displayName),
                  trailing:
                      l == current ? const Icon(Icons.check_rounded) : null,
                  onTap: () => Navigator.pop(context, l),
                ),
              )
              .toList(),
        ),
      ),
    );
  }
}

class _LangPill extends StatelessWidget {
  const _LangPill({required this.language, required this.onTap});
  final SupportedLanguage language;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
        decoration: BoxDecoration(
          color: scheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Flexible(
              child: Text(
                language.displayName,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
            const Icon(Icons.expand_more_rounded, size: 18),
          ],
        ),
      ),
    );
  }
}

class _ConnectivityBadge extends StatelessWidget {
  const _ConnectivityBadge({required this.status});
  final ConnectivityState status;

  @override
  Widget build(BuildContext context) {
    final isOnline = status.isConnected;
    final isChecking = status.isChecking;
    final color = isChecking
        ? Colors.grey
        : (isOnline ? AppTheme.success : AppTheme.warning);
    final label = isChecking ? 'Checking' : (isOnline ? 'Online' : 'Offline');

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
