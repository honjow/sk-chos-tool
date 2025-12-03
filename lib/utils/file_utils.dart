import 'dart:io';

import 'package:ini_file/ini_file.dart';

/// File and configuration management utilities

// ==================== File Operations ====================

/// Check if file exists (async)
Future<bool> chkFileExists(String path) async {
  final file = File(path);
  return await file.exists();
}

/// Check if file exists (sync)
bool chkFileExistsSync(String path) {
  final file = File(path);
  return file.existsSync();
}

// ==================== Config File Management ====================

/// Change ownership of config directory to current user
Future<void> chownConfig() async {
  final path = '${Platform.environment['HOME']}/.config/sk-chos-tool';
  final user = Platform.environment['USER'];
  // This requires sudo, assuming it's available
  try {
    await Process.run('sudo', ['chown', '-R', '$user:$user', path]);
  } catch (e) {
    // Silently fail if sudo is not available or permission denied
  }
}

// ==================== Autoupdate Configuration ====================

/// Check if autoupdate is enabled for a key
Future<bool> chkAutoupdate(String key) async {
  final value = await getAutoupdateConfig(key);
  return value == 'true';
}

/// Set autoupdate for a key
Future<void> setAutoupdate(String key, bool enable) async {
  await setAutoupdateConfig(key, enable ? 'true' : 'false');
}

/// Get autoupdate configuration value
Future<String> getAutoupdateConfig(String key) async {
  final path = '${Platform.environment['HOME']}/.config/sk-chos-tool';
  const section = 'autoupdate';

  // Recursively set ownership to current user
  await chownConfig();

  final dir = Directory(path);
  if (!dir.existsSync()) {
    await dir.create(recursive: true);
  }
  final file = File('$path/autoupdate.conf');
  if (!file.existsSync()) {
    await file.create();
    await file.writeAsString('\n');
    return '';
  }
  final ini = IniFile();
  await ini.readFile(file.path);
  return ini.getItem(section, key) ?? '';
}

/// Set autoupdate configuration value
Future<void> setAutoupdateConfig(String key, String value) async {
  final path = '${Platform.environment['HOME']}/.config/sk-chos-tool';
  const section = 'autoupdate';

  // Recursively set ownership to current user
  await chownConfig();

  final dir = Directory(path);
  if (!dir.existsSync()) {
    await dir.create(recursive: true);
  }
  final file = File('$path/autoupdate.conf');
  if (!file.existsSync()) {
    await file.create();
  }
  final ini = IniFile();
  await ini.readFile(file.path);
  ini.setItem(section, key, value);
  await ini.writeFile();
}

// ==================== User Configuration ====================

/// Get user configuration value
Future<String> getUserConfig(String section, String key) async {
  final path = '${Platform.environment['HOME']}/.config/sk-chos-tool';

  // Recursively set ownership to current user
  await chownConfig();

  final dir = Directory(path);
  if (!dir.existsSync()) {
    await dir.create(recursive: true);
  }
  final file = File('$path/sk-chos-tool.conf');
  if (!file.existsSync()) {
    await file.create();
    await file.writeAsString('\n');
    return '';
  }
  final ini = IniFile();
  await ini.readFile(file.path);
  return ini.getItem(section, key) ?? '';
}

/// Set user configuration value
Future<void> setUserConfig(String section, String key, String value) async {
  final path = '${Platform.environment['HOME']}/.config/sk-chos-tool';

  // Recursively set ownership to current user
  await chownConfig();

  final dir = Directory(path);
  if (!dir.existsSync()) {
    await dir.create(recursive: true);
  }
  final file = File('$path/sk-chos-tool.conf');
  if (!file.existsSync()) {
    await file.create();
  }
  final ini = IniFile();
  await ini.readFile(file.path);
  ini.setItem(section, key, value);
  await ini.writeFile();
}

// ==================== GitHub CDN Configuration ====================

/// Check if GitHub CDN is enabled
Future<bool> chkEnableGithubCdn() async {
  final val = await getUserConfig('download', 'enable_github_cdn');
  // Default is false
  return val == 'false';
}

/// Set GitHub CDN enable/disable
Future<void> setEnableGithubCdn(bool enable) async {
  await setUserConfig(
      'download', 'enable_github_cdn', enable ? 'true' : 'false');
}
