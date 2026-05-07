class AudioService {
  bool isMicOn     = true;
  bool isSpeakerOn = true;

  void toggleMic()     => isMicOn     = !isMicOn;
  void toggleSpeaker() => isSpeakerOn = !isSpeakerOn;
}