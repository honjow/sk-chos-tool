import 'dart:async';
import 'dart:io';

import 'package:ini_file/ini_file.dart';
import 'package:process_run/process_run.dart';
import 'package:sk_chos_tool/page/general_view.dart';
import 'package:sk_chos_tool/utils/const.dart';
import 'package:sk_chos_tool/utils/enum.dart';
import 'package:sk_chos_tool/utils/log.dart';

// ignore: constant_identifier_names
const SK_TOOL_SCRIPTS_PATH = '/usr/share/sk-chos-tool/scripts';

Future<String> getServiceEnableStatus(String serviceName) async {
  final results = await run(
    'sudo systemctl is-enabled $serviceName',
    verbose: true,
    throwOnError: false,
  );
  if (results.isEmpty) {
    return 'disabled';
  }
  final result = results.first;

  return result.stdout.toString().trim();
}

Future<bool> checkServiceEnabled(String serviceName) async {
  final status = await getServiceEnableStatus(serviceName);
  return status == 'enabled';
}

Future<bool> checkServiceMasked(String serviceName) async {
  final status = await getServiceEnableStatus(serviceName);
  return status == 'masked';
}

Future<void> toggleService(String serviceName, bool enable) async {
  final currentStatus = await getServiceEnableStatus(serviceName);
  late final String command;
  if (enable && currentStatus != 'enabled') {
    command = 'sudo systemctl enable --now $serviceName';
  } else if (!enable && currentStatus == 'enabled') {
    command = 'sudo systemctl disable --now $serviceName';
  } else {
    return;
  }
  await run(command);
}

Future<void> toggleServiceMask(String serviceName, bool mask) async {
  final currentStatus = await getServiceEnableStatus(serviceName);
  late final String command;
  if (mask && currentStatus != 'masked') {
    command = 'sudo systemctl mask $serviceName';
  } else if (!mask && currentStatus == 'masked') {
    command = 'sudo systemctl unmask $serviceName';
  } else {
    return;
  }
  await run(command);
}

Future<void> toggleHandheldService(String serviceName, bool enable) async {
  final allService = [
    'handycon.service',
    'hhd@${Platform.environment['USER']}.service',
    'inputplumber.service',
  ];
  for (final service in allService) {
    late bool valMask;
    late bool valEnable;
    if (enable) {
      valMask = service != serviceName;
      valEnable = service == serviceName;
    } else {
      valMask = true;
      valEnable = false;
    }
    await toggleServiceMask(service, valMask);
    await toggleService(service, valEnable);
  }
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

Future<void> chownConfig() async {
  final path = '${Platform.environment['HOME']}/.config/sk-chos-tool';
  final user = Platform.environment['USER'];
  await run('sudo chown -R $user:$user $path');
}

Future<String> getAutoupdateConfig(key) async {
  final path = '${Platform.environment['HOME']}/.config/sk-chos-tool';
  const section = 'autoupdate';

  // 递归设置所属用户和组
  await chownConfig();

  final dir = Directory(path);
  if (!dir.existsSync()) {
    await dir.create(recursive: true);
  }
  final file = File('$path/autoupdate.conf');
  if (!file.existsSync()) {
    file.create();
    file.writeAsString('\n');
    return '';
  }
  final ini = IniFile();
  await ini.readFile(file.path);
  return ini.getItem(section, key) ?? '';
}

Future<void> setAutoupdateConfig(String key, String value) async {
  final path = '${Platform.environment['HOME']}/.config/sk-chos-tool';
  const section = 'autoupdate';

  // 递归设置所属用户和组
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
  ini.writeFile();
}

Future<String> getUserConfig(String section, String key) async {
  final path = '${Platform.environment['HOME']}/.config/sk-chos-tool';

  // 递归设置所属用户和组
  await chownConfig();

  final dir = Directory(path);
  if (!dir.existsSync()) {
    await dir.create(recursive: true);
  }
  final file = File('$path/sk-chos-tool.conf');
  if (!file.existsSync()) {
    file.create();
    file.writeAsString('\n');
    return '';
  }
  final ini = IniFile();
  await ini.readFile(file.path);
  return ini.getItem(section, key) ?? '';
}

Future<void> setUserConfig(String section, String key, String value) async {
  final path = '${Platform.environment['HOME']}/.config/sk-chos-tool';

  // 递归设置所属用户和组
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

Future<void> uninstallAppImage(String appName) async {
  await run('bash $SK_TOOL_SCRIPTS_PATH/appimage_uninstall.sh $appName');
}

bool chkFileExistsSync(String path) {
  final file = File(path);
  return file.existsSync();
}

bool handyconInatalled() {
  return chkFileExistsSync('/usr/bin/handycon');
}

bool hhdInatalled() {
  return chkFileExistsSync('/usr/bin/hhd');
}

bool inputplumberInatalled() {
  return chkFileExistsSync('/usr/bin/inputplumber');
}

Future<SleepMode> getSleepMode() async {
  logger.i('getSleepMode');
  const filePath = suspendServicePath;
  const hibernateContent = 'systemd-sleep hibernate';
  const suspendThenHibernateContent = 'systemd-sleep suspend-then-hibernate';
  try {
    final file = File(filePath);
    if (!await file.exists()) {
      return SleepMode.suspend;
    }
    final content = await file.readAsString();
    if (content.contains(hibernateContent)) {
      return SleepMode.hibernate;
    } else if (content.contains(suspendThenHibernateContent)) {
      return SleepMode.suspendThenHibernate;
    }
    return SleepMode.suspend;
  } catch (e) {
    return SleepMode.suspend;
  }
}

Future<void> setSleepMode(SleepMode mode) async {
  logger.i('setSleepMode $mode');
  try {
    const filePath = suspendServicePath;
    switch (mode) {
      case SleepMode.suspend:
        await run('sudo rm $filePath');
        break;
      case SleepMode.hibernate:
        await run(
            'sudo cp /lib/systemd/system/systemd-hibernate.service $filePath');
        break;
      case SleepMode.suspendThenHibernate:
        await run(
            'sudo cp /lib/systemd/system/systemd-suspend-then-hibernate.service $filePath');
        break;
    }
    await run('sudo systemctl daemon-reload');
  } catch (e) {
    rethrow;
  }
}

Future<String> getHibernateDelay() async {
  logger.i('getHibernateDelay');
  const filePath = hiberatehDelayPath;
  try {
    final file = File(filePath);
    if (!await file.exists()) {
      logger.i('hibernate delay file not exists');
      return '';
    }
    final content = await file.readAsString();
    logger.i('hibernate delay content \n$content');
    final reg = RegExp(r'HibernateDelaySec=(.+)');
    final match = reg.firstMatch(content);
    if (match != null) {
      return match.group(1) ?? kDefaultHibernateDelay;
    }
    return '';
  } catch (e) {
    return '';
  }
}

Future<String> getHibernateDelayAutoSet() async {
  final delay = await getHibernateDelay();
  logger.i('getHibernateDelayAutoSet $delay');
  if (delay.isEmpty) {
    await setHibernateDelay(kDefaultHibernateDelay);
    return kDefaultHibernateDelay;
  }
  return delay;
}

Future<void> setHibernateDelay(String delay) async {
  logger.i('setHibernateDelay $delay');
  try {
    const filePath = hiberatehDelayPath;
    final file = File(filePath);
    if (!await file.exists()) {
      await run('sudo mkdir -p /etc/systemd/sleep.conf.d');
      await run('sudo touch $filePath');
    }
    await run(
      '''
      bash -c "echo -e '[Sleep]\\nHibernateDelaySec=$delay' | sudo tee $filePath"
      ''',
    );
    await run('sudo systemctl kill -s HUP systemd-logind');
  } catch (e) {
    logger.e('Failed to set hibernate delay $e');
    rethrow;
  }
}
