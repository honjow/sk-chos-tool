typedef Config = Map<String, Map<String, String>>;

const Config defaultUserConfig = {
  'download': {
    'enable_github_cdn': 'false',
  },
};

// ==================== Path Constants ====================

/// System path constants
class AppPaths {
  /// Scripts directory path
  static const scriptsPath = '/usr/share/sk-chos-tool/scripts';

  /// Device quirks configuration file
  static const deviceQuirksConf = '/etc/device-quirks/device-quirks.conf';

  /// User configuration file path
  static const userConfigPath = '/home/gamer/.config/sk-chos-tool/config.ini';

  /// Systemd suspend service path
  static const suspendServicePath =
      '/etc/systemd/system/systemd-suspend.service';

  /// Hibernate delay configuration path
  static const hibernateDelayPath =
      '/etc/systemd/sleep.conf.d/99-hibernate_delay.conf';
}

// ==================== Service Names ====================

/// System service name constants
class SystemServices {
  /// HandyGCCS service
  static const handycon = 'handycon.service';

  /// Handheld Daemon service
  static const hhd = 'hhd.service';

  /// InputPlumber service
  static const inputplumber = 'inputplumber.service';

  /// Steam power button daemon service
  static const steamPowerButton = 'steam-powerbuttond.service';

  /// HHD user-specific service
  static String hhdUser(String user) => 'hhd@$user.service';
}

// Legacy constants for backward compatibility
const suspendServicePath = AppPaths.suspendServicePath;
const hiberatehDelayPath = AppPaths.hibernateDelayPath;
