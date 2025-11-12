import 'package:dio/dio.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import '../config/env_config.dart';

class UpdateInfo {
  final String latestVersion;
  final String currentVersion;
  final String downloadUrl;
  final String releaseNotes;
  final DateTime publishedAt;

  UpdateInfo({
    required this.latestVersion,
    required this.currentVersion,
    required this.downloadUrl,
    required this.releaseNotes,
    required this.publishedAt,
  });

  bool get hasUpdate => _compareVersions(latestVersion, currentVersion) > 0;

  static int _compareVersions(String v1, String v2) {
    final parts1 = v1.split('.').map(int.parse).toList();
    final parts2 = v2.split('.').map(int.parse).toList();

    for (int i = 0; i < 3; i++) {
      final p1 = i < parts1.length ? parts1[i] : 0;
      final p2 = i < parts2.length ? parts2[i] : 0;

      if (p1 > p2) return 1;
      if (p1 < p2) return -1;
    }

    return 0;
  }
}

class UpdateService {
  final Dio _dio;
  late final String githubOwner;
  late final String githubRepo;

  UpdateService({Dio? dio})
    : _dio =
          dio ??
          Dio(
            BaseOptions(
              connectTimeout: const Duration(seconds: 10),
              receiveTimeout: const Duration(seconds: 10),
              headers: {'Accept': 'application/vnd.github.v3+json'},
            ),
          ) {
    githubOwner = EnvConfig.githubOwner;
    githubRepo = EnvConfig.githubRepo;
  }

  Future<UpdateInfo?> checkForUpdates() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      final currentVersion = packageInfo.version;

      final response = await _dio.get(
        'https://api.github.com/repos/$githubOwner/$githubRepo/releases/latest',
      );

      if (response.statusCode == 200) {
        final data = response.data;
        final latestVersion = (data['tag_name'] as String).replaceFirst('v', '');
        final releaseNotes = data['body'] as String? ?? 'Sem notas de atualização';
        final publishedAt = DateTime.parse(data['published_at'] as String);

        // Procura o asset do instalador Windows
        String? downloadUrl;
        final assets = data['assets'] as List<dynamic>?;
        if (assets != null) {
          for (final asset in assets) {
            final name = asset['name'] as String;
            if (name.toLowerCase().endsWith('.exe')) {
              downloadUrl = asset['browser_download_url'] as String;
              break;
            }
          }
        }

        downloadUrl ??= data['html_url'] as String;

        return UpdateInfo(
          latestVersion: latestVersion,
          currentVersion: currentVersion,
          downloadUrl: downloadUrl,
          releaseNotes: releaseNotes,
          publishedAt: publishedAt,
        );
      }

      return null;
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        throw Exception('Tempo de conexão excedido. Verifique sua internet.');
      } else if (e.response?.statusCode == 404) {
        throw Exception('Repositório não encontrado.');
      } else {
        throw Exception('Erro ao verificar atualizações: ${e.message}');
      }
    } catch (e) {
      throw Exception('Erro inesperado ao verificar atualizações: $e');
    }
  }

  Future<void> openDownloadUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      throw Exception('Não foi possível abrir o link de download');
    }
  }
}
