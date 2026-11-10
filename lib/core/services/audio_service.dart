import 'package:audioplayers/audioplayers.dart';

class AudioService {
  static final AudioPlayer _audioPlayer = AudioPlayer();

  /// Plays a notification chime sound when a new booking arrives
  static Future<void> playNewBookingNotification() async {
    try {
      await _audioPlayer.stop();
      await _audioPlayer.play(
        UrlSource('https://actions.google.com/sounds/v1/alarms/beep_short.ogg'),
      );
    } catch (_) {
      // Ignore audio errors if blocked by browser autoplay rules
    }
  }
}
