enum SleepMode {
  suspend('suspend'),
  hibernate('hibernate'),
  suspendThenHibernate('suspend-then-hibernate');

  final String value;

  const SleepMode(this.value);
}
