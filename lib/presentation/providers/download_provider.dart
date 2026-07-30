import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/pack_downloader.dart';

class DownloadState {
  const DownloadState({
    this.progress = 0.0,
    this.status = 'Idle',
    this.isDownloading = false,
    this.error,
    this.currentLanguage = '',
  });

  final double progress;
  final String status;
  final bool isDownloading;
  final String? error;
  final String currentLanguage;

  DownloadState copyWith({
    double? progress,
    String? status,
    bool? isDownloading,
    String? error,
    String? currentLanguage,
    bool clearError = false,
  }) {
    return DownloadState(
      progress: progress ?? this.progress,
      status: status ?? this.status,
      isDownloading: isDownloading ?? this.isDownloading,
      error: clearError ? null : (error ?? this.error),
      currentLanguage: currentLanguage ?? this.currentLanguage,
    );
  }
}

class DownloadNotifier extends StateNotifier<DownloadState> {
  DownloadNotifier() : super(const DownloadState());

  final PackDownloader _downloader = PackDownloader();

  Future<void> downloadPack(String languageCode, String url) async {
    // Prevent multiple downloads
    if (state.isDownloading) return;

    state = state.copyWith(
      isDownloading: true,
      status: 'Starting...',
      clearError: true,
      currentLanguage: languageCode,
    );

    try {
      await _downloader.downloadPack(
        languageCode: languageCode,
        url: url,
        onProgress: (received, total) {
          final progress = received / total;
          state = state.copyWith(
            progress: progress,
            status: '${(progress * 100).round()}%',
          );
        },
        onStatus: (status) {
          state = state.copyWith(status: status);
        },
      );

      state = state.copyWith(
        isDownloading: false,
        status: 'Download complete!',
        progress: 1.0,
        currentLanguage: '',
      );
    } catch (e) {
      state = state.copyWith(
        isDownloading: false,
        error: e.toString(),
        status: 'Error',
        currentLanguage: '',
      );
    }
  }

  Future<void> deletePack(String languageCode) async {
    await _downloader.deletePack(languageCode);
  }

  Future<bool> isDownloaded(String languageCode) async {
    return await _downloader.isPackDownloaded(languageCode);
  }

  Future<int> getPackSize(String languageCode) async {
    return await _downloader.getPackSize(languageCode);
  }

  Future<List<String>> getDownloadedPacks() async {
    return await _downloader.getDownloadedPacks();
  }

  void resetProgress() {
    state = const DownloadState();
  }
}

final downloadProvider = StateNotifierProvider<DownloadNotifier, DownloadState>(
  (ref) => DownloadNotifier(),
);
