import 'dart:io';

import 'package:process_run/process_run.dart';
import 'package:sk_chos_tool/utils/process_utils.dart';

/// Systemctl service management utilities

/// Get service enable status (enabled, disabled, masked, etc.)
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

/// Check if a service is enabled
Future<bool> checkServiceEnabled(String serviceName) async {
  final status = await getServiceEnableStatus(serviceName);
  return status == 'enabled';
}

/// Check if a service is masked
Future<bool> checkServiceMasked(String serviceName) async {
  final status = await getServiceEnableStatus(serviceName);
  return status == 'masked';
}

/// Toggle service enable/disable state
Future<void> toggleService(String serviceName, bool enable) async {
  final currentStatus = await getServiceEnableStatus(serviceName);
  late final String command;
  late final String taskName;
  if (enable && currentStatus != 'enabled') {
    command = 'sudo systemctl enable --now $serviceName';
    taskName = 'Enable $serviceName';
  } else if (!enable && currentStatus == 'enabled') {
    command = 'sudo systemctl disable --now $serviceName';
    taskName = 'Disable $serviceName';
  } else {
    return;
  }
  await runWithLog(command: command, taskName: taskName);
}

/// Toggle service mask/unmask state
Future<void> toggleServiceMask(String serviceName, bool mask) async {
  final currentStatus = await getServiceEnableStatus(serviceName);
  late final String command;
  late final String taskName;
  if (mask && currentStatus != 'masked') {
    command = 'sudo systemctl mask $serviceName';
    taskName = 'Mask $serviceName';
  } else if (!mask && currentStatus == 'masked') {
    command = 'sudo systemctl unmask $serviceName';
    taskName = 'Unmask $serviceName';
  } else {
    return;
  }
  await runWithLog(command: command, taskName: taskName);
}

/// Toggle handheld device service (handycon, hhd, inputplumber)
/// Only one can be enabled at a time
Future<void> toggleHandheldService(String serviceName, bool enable) async {
  final allService = [
    'handycon.service',
    'hhd@${Platform.environment['USER']}.service',
    'hhd.service',
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

    // steam-powerbuttond follows inputplumber
    if (service == 'inputplumber.service') {
      await toggleService('steam-powerbuttond.service', valEnable);
    }
  }
}
