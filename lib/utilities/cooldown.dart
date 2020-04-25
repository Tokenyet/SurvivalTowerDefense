class Cooldown {
  final double millis;
  Cooldown({
    this.millis = 500,
    bool initTime = false
  }) {
    if(initTime) time = DateTime.now();
  }

  DateTime time;

  void execute(void Function() callback) {
    if(time == null) time = DateTime.now();
    DateTime triggeredTime = DateTime.now();

    if(triggeredTime.difference(time).inMilliseconds < millis) return;
    
    time = triggeredTime;
    callback();
  }
}