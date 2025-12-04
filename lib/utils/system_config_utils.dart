import 'dart:io';

import 'package:sk_chos_tool/page/general_view.dart';
import 'package:sk_chos_tool/utils/const.dart';
import 'package:sk_chos_tool/utils/enum.dart';
import 'package:sk_chos_tool/utils/file_utils.dart';
import 'package:sk_chos_tool/utils/log.dart';
import 'package:sk_chos_tool/utils/process_utils.dart';

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
      await runWithLog(
        command:
            'sudo cp /lib/systemd/system/systemd-hibernate.service /etc/systemd/system/systemd-suspend.service',
        taskName: 'Enable Hibernate',
      );
    } else {
      await runWithLog(
        command: 'sudo rm /etc/systemd/system/systemd-suspend.service',
        taskName: 'Disable Hibernate',
      );
    }
    await runWithLog(
      command: 'sudo systemctl daemon-reload',
      taskName: 'Reload Systemd',
    );
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
        await runWithLog(
          command: 'sudo rm $filePath',
          taskName: 'Set Sleep Mode: Suspend',
        );
        break;
      case SleepMode.hibernate:
        await runWithLog(
          command:
              'sudo cp /lib/systemd/system/systemd-hibernate.service $filePath',
          taskName: 'Set Sleep Mode: Hibernate',
        );
        break;
      case SleepMode.suspendThenHibernate:
        await runWithLog(
          command:
              'sudo cp /lib/systemd/system/systemd-suspend-then-hibernate.service $filePath',
          taskName: 'Set Sleep Mode: Suspend Then Hibernate',
        );
        break;
    }
    await runWithLog(
      command: 'sudo systemctl daemon-reload',
      taskName: 'Reload Systemd',
    );
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
      await runWithLog(
        command: 'sudo mkdir -p /etc/systemd/sleep.conf.d',
        taskName: 'Create Hibernate Config Dir',
      );
      await runWithLog(
        command: 'sudo touch $filePath',
        taskName: 'Create Hibernate Config File',
      );
    }
    await runWithLog(
      command: '''
      bash -c "echo -e '[Sleep]\\nHibernateDelaySec=$delay' | sudo tee $filePath"
      ''',
      taskName: 'Set Hibernate Delay: $delay',
    );
    await runWithLog(
      command: 'sudo systemctl kill -s HUP systemd-logind',
      taskName: 'Reload Systemd Logind',
    );
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
    await runWithLog(
      command: 'sudo sk-firmware-override ${enable ? 'enable' : 'disable'}',
      taskName:
          enable ? 'Enable Firmware Override' : 'Disable Firmware Override',
    );
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
      await runWithLog(
        command: 'sudo sed -i "s/^$disableStr/$enableStr/g" $filePath',
        taskName: 'Enable USB Wakeup',
      );
    } else {
      await runWithLog(
        command: 'sudo sed -i "s/^$enableStr/$disableStr/g" $filePath',
        taskName: 'Disable USB Wakeup',
      );
    }
    await runWithLog(
      command: 'sudo frzr-tweaks',
      taskName: 'Apply Device Quirks',
    );
  } catch (e) {
    logger.e('Failed to set USB wakeup: $e');
    rethrow;
  }
}

// ==================== System Utilities ====================

/// Create/repair swapfile
Future<void> makeSwapfile() async {
  await runWithLog(
    command: 'sudo ${AppPaths.scriptsPath}/make_swapfile.sh -1',
    taskName: 'Make Swapfile',
  );
}

/// Clear system cache
Future<void> clearCache() async {
  await runWithLog(
    command: '''sudo rm -f /var/lib/pacman/db.lck
      rm -rf ~/.cache/sk-holoiso-config/*
      rm -rf ~/.local/share/pnpm/store/*
      yay -Scc --noconfirm
      ''',
    taskName: 'Clear System Cache',
  );
}

/// Repair boot
Future<void> bootRepair() async {
  await runWithLog(
    command: 'sudo /usr/bin/sk-chos-boot-fix',
    taskName: 'Boot Repair',
  );
}

/// Repair /etc configuration
Future<void> etcRepair() async {
  await runWithLog(
    command: 'sudo ${AppPaths.scriptsPath}/etc_repair.sh',
    taskName: 'Repair /etc',
  );
}

/// Repair /etc configuration (full)
Future<void> etcRepairFull() async {
  await runWithLog(
    command: 'sudo ${AppPaths.scriptsPath}/etc_repair.sh full',
    taskName: 'Repair /etc (Full)',
  );
}

/// Re-run first run script
Future<void> reFirstRun() async {
  await runWithLog(
    command: '/usr/bin/sk-first-run',
    taskName: 'First Run Setup',
  );
}

/// Reset GNOME settings
Future<void> resetGnome() async {
  await runWithLog(
    command: 'bash -c "sudo dconf update && dconf reset -f /"',
    taskName: 'Reset GNOME Settings',
  );
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
