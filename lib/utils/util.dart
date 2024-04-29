import 'dart:async';
import 'dart:io';

import 'package:ini_file/ini_file.dart';
import 'package:process_run/process_run.dart';

// ignore: constant_identifier_names
const SK_TOOL_SCRIPTS_PATH = '/usr/share/sk-chos-tool/scripts';

Future<bool> checkServiceAutostart(String serviceName) async {
  final results = await run(
    'sudo systemctl is-enabled $serviceName',
    verbose: true,
    throwOnError: false,
  );
  if (results.isEmpty) {
    return false;
  }
  final result = results.first;
  final code = result.exitCode;
  final stdout = result.stdout.toString();
  if (stdout.contains('enabled')) {
    return true;
  }

  return false;
}

Future<void> toggleService(String serviceName, bool enable) async {
  final results = await run(
    'sudo systemctl ${enable ? 'enable' : 'disable'} $serviceName',
    verbose: true,
  );
  if (results.isNotEmpty) {
    final result = results.first;
    final code = result.exitCode;
    final stdout = result.stdout.toString();
    if (code == 0) {
      return;
    }
  }
  throw Exception('Failed to toggle service');
}

Future<bool> chkHibernate() async {
  const filePath = 'etc/systemd/system/systemd-suspend.service';
  const checkContent = 'systemd-sleep hibernate';
  try {
    final file = File(filePath);
    final content = await file.readAsString();
    return content.contains(checkContent);
  } catch (e) {
    return false;
  }
}

Future<void> setHibernate(bool enable) async {
  try {
    if (enable) {
      await run(
          'sudo cp /lib/systemd/system/systemd-hibernate.service /etc/systemd/system/systemd-suspend.service');
    } else {
      await run('sudo rm /etc/systemd/system/systemd-suspend.service');
    }
    await run('sudo systemctl daemon-reload');
  } catch (e) {
    // throw Exception('Failed to set hibernate');
    rethrow;
  }
}

Future<void> setFirmwareOverride(bool enable) async {
  try {
    await run('sudo sk-firmware-override ${enable ? 'enable' : 'disable'}');
  } catch (e) {
    rethrow;
  }
}

Future<bool> chkFirmwareOverride() async {
  const filePath = '/etc/device-quirks/device-quirks.conf';
  const checkContent = 'USE_FIRMWARE_OVERRIDES=1';
  try {
    final file = File(filePath);
    final content = await file.readAsString();
    return content.contains(checkContent);
  } catch (e) {
    return false;
  }
}

Future<bool> chkUsbWakeup() async {
  const filePath = '/etc/device-quirks/device-quirks.conf';
  const checkContent = 'USB_WAKE_ENABLED=1';
  try {
    final file = File(filePath);
    final content = await file.readAsString();
    return content.contains(checkContent);
  } catch (e) {
    return false;
  }
}

Future<void> setUsbWakeup(bool enable) async {
  const filePath = '/etc/device-quirks/device-quirks.conf';
  const enableStr = 'USB_WAKE_ENABLED=1';
  const disableStr = 'USB_WAKE_ENABLED=0';
  try {
    if (enable) {
      await run('sudo sed -i "s/^$disableStr/$enableStr/g" $filePath');
    } else {
      await run('sudo sed -i "s/^$enableStr/$disableStr/g" $filePath');
    }
    await run('sudo frzr-tweaks');
  } catch (e) {
    rethrow;
  }
}

Future<bool> chkAutoupdate(String key) async {
  final value = await getAutoupdateConfig(key);
  return value == 'true';
}

Future<void> setAutoupdate(String key, bool enable) async {
  await setAutoupdateConfig(key, enable ? 'true' : 'false');
}

Future<String> getAutoupdateConfig(key) async {
  final path = '${Platform.environment['HOME']}/.config/sk-chos-tool';
  const section = 'autoupdate';

  final dir = Directory(path);
  if (!dir.existsSync()) {
    await dir.create(recursive: true);
  }
  final file = File('$path/autoupdate.conf');
  if (!file.existsSync()) {
    return '';
  }
  final ini = IniFile();
  await ini.readFile(file.path);
  return ini.getItem(section, key) ?? '';
}

Future<void> setAutoupdateConfig(String key, String value) async {
  final path = '${Platform.environment['HOME']}/.config/sk-chos-tool';
  const section = 'autoupdate';

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
  ini.writeFile();
}

Future<String> getUserConfig(String section, String key) async {
  final path = '${Platform.environment['HOME']}/.config/sk-chos-tool';

  final dir = Directory(path);
  if (!dir.existsSync()) {
    await dir.create(recursive: true);
  }
  final file = File('$path/sk-chos-tool.conf');
  if (!file.existsSync()) {
    return '';
  }
  final ini = IniFile();
  await ini.readFile(file.path);
  return ini.getItem(section, key) ?? '';
}

Future<void> setUserConfig(String section, String key, String value) async {
  final path = '${Platform.environment['HOME']}/.config/sk-chos-tool';

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
  ini.writeFile();
}

Future<bool> chkNix() async {
  final results = await run(
    'source /etc/profile.d/nix.sh && nix-env --version',
    verbose: true,
    throwOnError: false,
    runInShell: true,
  );
  return results.isNotEmpty && results.first.exitCode == 0;
}

Future<void> installNix() async {
  await run('/usr/bin/sk-nix-install install');
}

Future<void> uninstallNix() async {
  await run('/usr/bin/sk-nix-install uninstall');
}

Future<bool> chkFileExists(String path) async {
  final file = File(path);
  return await file.exists();
}

Future<String> getGithubReleaseCdn() async {
  const confPath = '/etc/sk-chos-tool/github_cdn.conf';
  final ini = IniFile();
  await ini.readFile(confPath);
  final cdns = ini.getItem('release', 'server') ?? '';
  final cdnList = cdns.split(':::');
  // random select one
  cdnList.shuffle();
  return cdnList.first;
}

Future<String> getGithubRawCdn() async {
  const confPath = '/etc/sk-chos-tool/github_cdn.conf';
  final ini = IniFile();
  await ini.readFile(confPath);
  final cdns = ini.getItem('raw', 'server') ?? '';
  final cdnList = cdns.split(':::');
  // random select one
  cdnList.shuffle();
  return cdnList.first;
}

Future<void> installEmuDeck() async {
  final param = await getCdnParam();
  final command = 'bash $SK_TOOL_SCRIPTS_PATH/emudeck_install.sh $param';
  await run(command);
}

// anime_games_launcher_install
Future<void> installAnimeGamesLauncher() async {
  final param = await getCdnParam();
  final command =
      'bash $SK_TOOL_SCRIPTS_PATH/anime-games-launcher_install.sh $param';
  await run(command);
}

// an_anime_game_launcher_install
Future<void> installAnAnimeGameLauncher() async {
  final param = await getCdnParam();
  final command =
      'bash $SK_TOOL_SCRIPTS_PATH/an-anime-game-launcher_install.sh $param';
  await run(command);
}

// the_honkers_railway_launcher_install
Future<void> installTheHonkersRailwayLauncher() async {
  final param = await getCdnParam();
  final command =
      'bash $SK_TOOL_SCRIPTS_PATH/the-honkers-railway-launcher_install.sh $param';
  await run(command);
}

// honkers_launcher_install
Future<void> installHonkersLauncher() async {
  final param = await getCdnParam();
  final command =
      'bash $SK_TOOL_SCRIPTS_PATH/honkers-launcher_install.sh $param';
  await run(command);
}

Future<(String, String)> getCdn() async {
  final releasePrefix = await getGithubReleaseCdn();
  final rawPrefix = await getGithubRawCdn();
  return (releasePrefix, rawPrefix);
}

Future<String> getCdnParam() async {
  final releasePrefix = await getGithubReleaseCdn();
  final rawPrefix = await getGithubRawCdn();
  return await chkEnableGithubCdn() ? '$releasePrefix $rawPrefix' : '';
}

// make_swapfile
Future<void> makeSwapfile() async {
  await run('sudo $SK_TOOL_SCRIPTS_PATH/make_swapfile.sh');
}

// clear_cache
Future<void> clearCache() async {
  await run('''sudo rm -f /var/lib/pacman/db.lck
      rm -rf ~/.cache/sk-holoiso-config/*
      rm -rf ~/.local/share/pnpm/store/*
      yay -Scc --noconfirm
      ''');
}

// boot_repair
Future<void> bootRepair() async {
  await run('sudo /usr/bin/sk-chos-boot-fix');
}

// etc_repair
Future<void> etcRepair() async {
  await run('sudo $SK_TOOL_SCRIPTS_PATH/etc_repair.sh');
}

// etc_repair_full
Future<void> etcRepairFull() async {
  await run('sudo $SK_TOOL_SCRIPTS_PATH/etc_repair.sh full');
}

// re_first_run
Future<void> reFirstRun() async {
  await run('/usr/bin/sk-first-run');
}

// reset_gnome
Future<void> resetGnome() async {
  await run('bash -c "sudo dconf update && dconf reset -f /"');
}

// install_sk_chos_tool
Future<void> installSkChosTool() async {
  await run('/usr/bin/__sk-chos-tool-update');
}

// set enable_github_cdn
Future<void> setEnableGithubCdn(bool enable) async {
  await setUserConfig(
      'download', 'enable_github_cdn', enable ? 'true' : 'false');
}

// chk enable_github_cdn
Future<bool> chkEnableGithubCdn() async {
  final val = await getUserConfig('download', 'enable_github_cdn');
  // 默认 true
  return val != 'false';
}
