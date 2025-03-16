import 'package:flutter_90tank/event/base_event.dart';

class HeroTankDestroyEvent extends BaseEvent {
  final bool isDead;

  HeroTankDestroyEvent({this.isDead = false});
}
