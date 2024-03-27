import 'dart:async';
import 'dart:io';

import 'package:ini_file/ini_file.dart';
import 'package:process_run/process_run.dart';

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

Future<bool> chkNix() async {
  final results =
      await run('nix --version', verbose: true, throwOnError: false);
  return results.isNotEmpty && results.first.exitCode == 0;
}

Future<void> installNix() async {
  await run('/usr/bin/sk-nix-install install');
}

Future<void> uninstallNix() async {
  await run('/usr/bin/sk-nix-install uninstall');
}
