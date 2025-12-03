import 'dart:io';

import 'package:process_run/process_run.dart';
import 'package:sk_chos_tool/page/general_view.dart';
import 'package:sk_chos_tool/utils/const.dart';
import 'package:sk_chos_tool/utils/enum.dart';
import 'package:sk_chos_tool/utils/file_utils.dart';
import 'package:sk_chos_tool/utils/log.dart';

/// System configuration utilities for hibernate, sleep, firmware, USB, etc.

// ==================== Hibernate ====================

/// Check if hibernate is enabled
Future<bool> chkHibernate() async {
  const filePath = 'etc/systemd/system/systemd-suspend.service';
  const checkContent = 'systemd-sleep hibernate';
  try {
    final file = File(filePath);
    final content = await file.readAsString();
    return content.contains(checkContent);
  } catch (e) {
    logger.w('Failed to check hibernate status: $e');
    return false;
  }
}

/// Set hibernate enable/disable
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
    logger.e('Failed to set hibernate: $e');
    rethrow;
  }
}

// ==================== Sleep Mode ====================

/// Get current sleep mode
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
    logger.w('Failed to get sleep mode: $e');
    return SleepMode.suspend;
  }
}

/// Set sleep mode
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
    logger.e('Failed to set sleep mode: $e');
    rethrow;
  }
}

// ==================== Hibernate Delay ====================

/// Get hibernate delay setting
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
    logger.w('Failed to get hibernate delay: $e');
    return '';
  }
}

/// Get hibernate delay, set to default if not exists
Future<String> getHibernateDelayAutoSet() async {
  final delay = await getHibernateDelay();
  logger.i('getHibernateDelayAutoSet $delay');
  if (delay.isEmpty) {
    await setHibernateDelay(kDefaultHibernateDelay);
    return kDefaultHibernateDelay;
  }
  return delay;
}

/// Set hibernate delay
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

// ==================== Firmware Override ====================

/// Check if firmware override is enabled
Future<bool> chkFirmwareOverride() async {
  const filePath = '/etc/device-quirks/device-quirks.conf';
  const checkContent = 'USE_FIRMWARE_OVERRIDES=1';
  try {
    final file = File(filePath);
    final content = await file.readAsString();
    return content.contains(checkContent);
  } catch (e) {
    logger.w('Failed to check firmware override: $e');
    return false;
  }
}

/// Set firmware override
Future<void> setFirmwareOverride(bool enable) async {
  try {
    await run('sudo sk-firmware-override ${enable ? 'enable' : 'disable'}');
  } catch (e) {
    logger.e('Failed to set firmware override: $e');
    rethrow;
  }
}

// ==================== USB Wakeup ====================

/// Check if USB wakeup is enabled
Future<bool> chkUsbWakeup() async {
  const filePath = '/etc/device-quirks/device-quirks.conf';
  const checkContent = 'USB_WAKE_ENABLED=1';
  try {
    final file = File(filePath);
    final content = await file.readAsString();
    return content.contains(checkContent);
  } catch (e) {
    logger.w('Failed to check USB wakeup: $e');
    return false;
  }
}

/// Set USB wakeup
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
    logger.e('Failed to set USB wakeup: $e');
    rethrow;
  }
}

// ==================== System Utilities ====================

/// Create/repair swapfile
Future<void> makeSwapfile() async {
  await run('sudo ${AppPaths.scriptsPath}/make_swapfile.sh');
}

/// Clear system cache
Future<void> clearCache() async {
  await run('''sudo rm -f /var/lib/pacman/db.lck
      rm -rf ~/.cache/sk-holoiso-config/*
      rm -rf ~/.local/share/pnpm/store/*
      yay -Scc --noconfirm
      ''');
}

/// Repair boot
Future<void> bootRepair() async {
  await run('sudo /usr/bin/sk-chos-boot-fix');
}

/// Repair /etc configuration
Future<void> etcRepair() async {
  await run('sudo ${AppPaths.scriptsPath}/etc_repair.sh');
}

/// Repair /etc configuration (full)
Future<void> etcRepairFull() async {
  await run('sudo ${AppPaths.scriptsPath}/etc_repair.sh full');
}

/// Re-run first run script
Future<void> reFirstRun() async {
  await run('/usr/bin/sk-first-run');
}

/// Reset GNOME settings
Future<void> resetGnome() async {
  await run('bash -c "sudo dconf update && dconf reset -f /"');
}

// ==================== Device Detection ====================

/// Check if HandyGCCS is installed
bool handyconInatalled() {
  return chkFileExistsSync('/usr/bin/handycon');
}

/// Check if HHD is installed
bool hhdInatalled() {
  return chkFileExistsSync('/usr/bin/hhd');
}

/// Check if InputPlumber is installed
bool inputplumberInatalled() {
  return chkFileExistsSync('/usr/bin/inputplumber');
}
