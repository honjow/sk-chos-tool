import 'dart:io';

import 'package:process_run/process_run.dart';
import 'package:sk_chos_tool/utils/util.dart';

Future<bool> checkDeckyPluginExists(String pluginName) async {
  final pluginPath =
      '${Platform.environment['HOME']}/homebrew/plugins/$pluginName/plugin.json';
  final pluginFile = File(pluginPath);
  return pluginFile.existsSync();
}

Future<void> uninstallDeckyPlugin(String pluginName) async {
  final pluginDirPath = '${Platform.environment['HOME']}/homebrew/plugins';
  final pluginPath = '$pluginDirPath/$pluginName';
  final command = 'chmod -R +rw $pluginDirPath';
  await run(command);

  // delete the plugin directory
  final pluginDir = Directory(pluginPath);
  if (pluginDir.existsSync()) {
    await pluginDir.delete(recursive: true);
    await restartDeckyLoader();
  }
}

Future<void> restartDeckyLoader() async {
  const command = 'sudo systemctl restart plugin_loader.service';
  await run(command);
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
