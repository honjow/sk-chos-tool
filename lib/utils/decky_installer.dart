import 'dart:io';

import 'package:sk_chos_tool/utils/process_utils.dart';
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
  await runWithLog(
    command: command,
    taskName: 'Uninstall $pluginName',
  );

  // delete the plugin directory
  final pluginDir = Directory(pluginPath);
  if (pluginDir.existsSync()) {
    await pluginDir.delete(recursive: true);
    await restartDeckyLoader();
  }
}

Future<void> restartDeckyLoader() async {
  const command = 'sudo systemctl restart plugin_loader.service';
  await runWithLog(
    command: command,
    taskName: 'Restart Decky Loader',
  );
}

Future<void> installPowerControl() async {
  final releasePrefix = await getGithubReleaseCdn();
  final command =
      '$SK_TOOL_SCRIPTS_PATH/power_control_install.sh $releasePrefix';
  await runWithLog(command: command, taskName: 'PowerControl');
}

Future<void> installHHDDecky() async {
  final releasePrefix = await getGithubReleaseCdn();
  final command = '$SK_TOOL_SCRIPTS_PATH/hhd_decky_install.sh $releasePrefix';
  await runWithLog(command: command, taskName: 'HHD Decky');
}

Future<void> installHueSync() async {
  final releasePrefix = await getGithubReleaseCdn();
  final command = '$SK_TOOL_SCRIPTS_PATH/huesync_install.sh $releasePrefix';
  await runWithLog(command: command, taskName: 'HueSync');
}

Future<void> installToMoon() async {
  const command =
      "bash -c \"curl -L http://i.ohmydeck.net | sed 's#/home/deck#/home/gamer#' | sed 's#curl#curl -k#g' | sh\"";
  await runWithLog(command: command, taskName: 'ToMoon');
}

Future<void> installSPB() async {
  await runWithLog(
    command:
        'bash -c "curl -sL https://github.com/honjow/SBP-PS5-to-Handheld/raw/master/install.sh | sh"',
    taskName: 'SBP PS5 to Handheld',
  );
}

Future<void> installSPBLegionGo() async {
  const command =
      'bash -c "curl -L https://github.com/honjow/sk-holoiso-config/raw/master/scripts/install-SBP-Legion-Go-Theme.sh | sh"';
  await runWithLog(
    command: command,
    taskName: 'SBP Legion Go Theme',
    verbose: true,
  );
}
