abstract class GuardStatusEvent {}

class ToggleGuardStatus extends GuardStatusEvent {
  final bool isOnline;

  ToggleGuardStatus(this.isOnline);
}

class LoadGuardStatus extends GuardStatusEvent {}
