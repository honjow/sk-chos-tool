import 'package:process_run/process_run.dart';
import 'package:sk_chos_tool/utils/const.dart';
import 'package:sk_chos_tool/utils/process_utils.dart';

/// Application installer utilities

// ignore: constant_identifier_names
const SK_TOOL_SCRIPTS_PATH = AppPaths.scriptsPath;

// ==================== CDN Configuration ====================

/// Get GitHub release CDN prefix
Future<String> getGithubReleaseCdn() async {
  return '';
  // const confPath = '/etc/sk-chos-tool/github_cdn.conf';
  // final ini = IniFile();
  // await ini.readFile(confPath);
  // final cdns = ini.getItem('release', 'server') ?? '';
  // final cdnList = cdns.split(':::');
  // // random select one
  // cdnList.shuffle();
  // return cdnList.first;
}

/// Get GitHub raw CDN prefix
Future<String> getGithubRawCdn() async {
  return '';
  // const confPath = '/etc/sk-chos-tool/github_cdn.conf';
  // final ini = IniFile();
  // await ini.readFile(confPath);
  // final cdns = ini.getItem('raw', 'server') ?? '';
  // final cdnList = cdns.split(':::');
  // // random select one
  // cdnList.shuffle();
  // return cdnList.first;
}

/// Get CDN URLs as tuple
Future<(String, String)> getCdn() async {
  final releasePrefix = await getGithubReleaseCdn();
  final rawPrefix = await getGithubRawCdn();
  return (releasePrefix, rawPrefix);
}

/// Get CDN parameters for scripts
Future<String> getCdnParam() async {
  return '';
  // final releasePrefix = await getGithubReleaseCdn();
  // final rawPrefix = await getGithubRawCdn();
  // return await chkEnableGithubCdn() ? '$releasePrefix $rawPrefix' : '';
}

// ==================== Game Launcher Installers ====================

/// Install EmuDeck
Future<void> installEmuDeck() async {
  final param = await getCdnParam();
  final command = 'bash $SK_TOOL_SCRIPTS_PATH/emudeck_install.sh $param';
  await runWithLog(command: command, taskName: 'EmuDeck');
}

/// Install Anime Games Launcher (Mihoyo all-in-one)
Future<void> installAnimeGamesLauncher() async {
  final param = await getCdnParam();
  final command =
      'bash $SK_TOOL_SCRIPTS_PATH/anime-games-launcher_install.sh $param';
  await runWithLog(command: command, taskName: 'Anime Games Launcher');
}

/// Install An Anime Game Launcher (Genshin Impact)
Future<void> installAnAnimeGameLauncher() async {
  final param = await getCdnParam();
  final command =
      'bash $SK_TOOL_SCRIPTS_PATH/an-anime-game-launcher_install.sh $param';
  await runWithLog(command: command, taskName: 'An Anime Game Launcher');
}

/// Install The Honkers Railway Launcher (Honkai: Star Rail)
Future<void> installTheHonkersRailwayLauncher() async {
  final param = await getCdnParam();
  final command =
      'bash $SK_TOOL_SCRIPTS_PATH/the-honkers-railway-launcher_install.sh $param';
  await runWithLog(command: command, taskName: 'The Honkers Railway Launcher');
}

/// Install Sleepy Launcher (Zenless Zone Zero)
Future<void> installSleepyLauncher() async {
  final param = await getCdnParam();
  final command =
      'bash $SK_TOOL_SCRIPTS_PATH/sleepy-launcher_install.sh $param';
  await runWithLog(command: command, taskName: 'Sleepy Launcher');
}

/// Install Honkers Launcher (Honkai Impact 3)
Future<void> installHonkersLauncher() async {
  final param = await getCdnParam();
  final command =
      'bash $SK_TOOL_SCRIPTS_PATH/honkers-launcher_install.sh $param';
  await runWithLog(command: command, taskName: 'Honkers Launcher');
}

// ==================== Other Installers ====================

/// Install Nix package manager
Future<void> installNix() async {
  await runWithLog(
    command: '/usr/bin/sk-nix-install install',
    taskName: 'Nix Package Manager',
  );
}

/// Uninstall Nix package manager
Future<void> uninstallNix() async {
  await runWithLog(
    command: '/usr/bin/sk-nix-install uninstall',
    taskName: 'Uninstall Nix',
  );
}

/// Check if Nix is installed
Future<bool> chkNix() async {
  final results = await run(
    'source /etc/profile.d/nix.sh && nix-env --version',
    verbose: true,
    throwOnError: false,
    runInShell: true,
  );
  return results.isNotEmpty && results.first.exitCode == 0;
}

/// Install/update sk-chos-tool itself
Future<void> installSkChosTool() async {
  await runWithLog(
    command: '/usr/bin/__sk-chos-tool-update',
    taskName: 'SkorionOS Tool',
  );
}

/// Uninstall AppImage application
Future<void> uninstallAppImage(String appName) async {
  await runWithLog(
    command: 'bash $SK_TOOL_SCRIPTS_PATH/appimage_uninstall.sh $appName',
    taskName: 'Uninstall $appName',
  );
}
