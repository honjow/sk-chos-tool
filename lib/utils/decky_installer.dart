import 'dart:io';

import 'package:ini_file/ini_file.dart';
import 'package:process_run/process_run.dart';

// ignore: constant_identifier_names
const SK_TOOL_SCRIPTS_PATH = '/usr/share/sk-chos-tool/scripts';

Future<bool> checkDeckyPluginExists(String pluginName) async {
  final pluginPath =
      '${Platform.environment['HOME']}/homebrew/plugins/$pluginName/plugin.json';
  final pluginFile = File(pluginPath);
  return pluginFile.existsSync();
}

Future<void> uninstallDeckyPlugin(String pluginName) async {
  final pluginPath =
      '${Platform.environment['HOME']}/homebrew/plugins/$pluginName';
  // delete the plugin directory
  final pluginDir = Directory(pluginPath);
  if (pluginDir.existsSync()) {
    await pluginDir.delete(recursive: true);
  }
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

Future<void> installPowerControl() async {
  final releasePrefix = await getGithubReleaseCdn();
  final command =
      '$SK_TOOL_SCRIPTS_PATH/power_control_install.sh $releasePrefix';
  await run(command);
}

Future<void> installHHDDecky() async {
  final releasePrefix = await getGithubReleaseCdn();
  final command = '$SK_TOOL_SCRIPTS_PATH/hhd_decky_install.sh $releasePrefix';
  await run(command);
}

Future<void> installHueSync() async {
  final releasePrefix = await getGithubReleaseCdn();
  final command = '$SK_TOOL_SCRIPTS_PATH/huesync_install.sh $releasePrefix';
  await run(command);
}

Future<void> installToMoon() async {
  const command =
      "curl -L http://i.ohmydeck.net | sed 's#/home/deck#/home/gamer#' | sed 's#curl#curl -k#g' | sh";
  await run(command);
}

Future<void> installSPB() async {
  await run(
      'curl -sL https://github.com/honjow/SBP-PS5-to-Handheld/raw/master/install.sh | sh');
}

Future<void> installSPBLegionGo() async {
  const command =
      'curl -L https://github.com/honjow/sk-holoiso-config/raw/master/scripts/install-SBP-Legion-Go-Theme.sh | sh';
  await run(command);
}
