import 'package:flutter_riverpod/legacy.dart';

class OnboardingState {
  final String answerText;
  final String? audioPath;
  final String? videoPath;
  final bool isRecordingAudio;
  final bool isRecordingVideo;

  OnboardingState({
    required this.answerText,
    this.audioPath,
    this.videoPath,
    this.isRecordingAudio = false,
    this.isRecordingVideo = false,
  });

  OnboardingState copyWith({
    String? answerText,
    String? audioPath,
    String? videoPath,
    bool? isRecordingAudio,
    bool? isRecordingVideo,
    bool clearAudioPath = false,
    bool clearVideoPath = false,
  }) {
    return OnboardingState(
      answerText: answerText ?? this.answerText,
      audioPath: clearAudioPath ? null : (audioPath ?? this.audioPath),
      videoPath: clearVideoPath ? null : (videoPath ?? this.videoPath),
      isRecordingAudio: isRecordingAudio ?? this.isRecordingAudio,
      isRecordingVideo: isRecordingVideo ?? this.isRecordingVideo,
    );
  }
}

class OnboardingNotifier extends StateNotifier<OnboardingState> {
  OnboardingNotifier()
    : super(
        OnboardingState(
          answerText: '',
          isRecordingAudio: false,
          isRecordingVideo: false,
        ),
      );

  void setAnswer(String text) {
    state = state.copyWith(answerText: text);
  }

  void startAudioRecording() {
    state = state.copyWith(isRecordingAudio: true);
  }

  void stopAudioRecording(String path) {
    state = state.copyWith(isRecordingAudio: false, audioPath: path);
  }

  void deleteAudio() {
    state = state.copyWith(clearAudioPath: true);
  }

  void startVideoRecording() {
    state = state.copyWith(isRecordingVideo: true);
  }

  void stopVideoRecording(String path) {
    state = state.copyWith(isRecordingVideo: false, videoPath: path);
  }

  void deleteVideo() {
    state = state.copyWith(clearVideoPath: true);
  }
}

final onboardingProvider =
    StateNotifierProvider.autoDispose<OnboardingNotifier, OnboardingState>(
      (ref) => OnboardingNotifier(),
    );
