typedef Config = Map<String, Map<String, String>>;

const Config defaultUserConfig = {
  'download': {
    'enable_github_cdn': 'false',
  },
};

const suspendServicePath = '/etc/systemd/system/systemd-suspend.service';
const hiberatehDelayPath = '/etc/systemd/sleep.conf.d/99-hibernate_delay.conf';
