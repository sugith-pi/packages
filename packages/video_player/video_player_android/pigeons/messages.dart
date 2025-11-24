// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:pigeon/pigeon.dart';

@ConfigurePigeon(
  PigeonOptions(
    dartOut: 'lib/src/messages.g.dart',
    kotlinOut:
        'android/src/main/kotlin/io/flutter/plugins/videoplayer/Messages.kt',
    kotlinOptions: KotlinOptions(package: 'io.flutter.plugins.videoplayer'),
    copyrightHeader: 'pigeons/copyright.txt',
  ),
)
/// Pigeon equivalent of video_platform_interface's VideoFormat.
enum PlatformVideoFormat { dash, hls, ss }

/// Pigeon equivalent of Player's playback state.
/// https://developer.android.com/media/media3/exoplayer/listening-to-player-events#playback-state
enum PlatformPlaybackState { idle, buffering, ready, ended, unknown }

sealed class PlatformVideoEvent {}

/// Sent when the video is initialized and ready to play.
class InitializationEvent extends PlatformVideoEvent {
  /// The video duration in milliseconds.
  late final int duration;

  /// The width of the video in pixels.
  late final int width;

  /// The height of the video in pixels.
  late final int height;

  /// The rotation that should be applied during playback.
  late final int rotationCorrection;
}

/// Sent when the video state changes.
///
/// Corresponds to ExoPlayer's onPlaybackStateChanged.
class PlaybackStateChangeEvent extends PlatformVideoEvent {
  late final PlatformPlaybackState state;
}

/// Sent when the video starts or stops playing.
///
/// Corresponds to ExoPlayer's onIsPlayingChanged.
class IsPlayingStateEvent extends PlatformVideoEvent {
  late final bool isPlaying;
}

/// Information passed to the platform view creation.
class PlatformVideoViewCreationParams {
  const PlatformVideoViewCreationParams({required this.playerId});

  final int playerId;
}

class BufferConfigNative {
  /// default constructor for Buffer configuration for android
  BufferConfigNative({
    required this.minBuffer,
    required this.maxBuffer,
    required this.bufferForPlayback,
    required this.bufferForPlaybackAfterRebuffer,
  });

  ///The minimum duration of media that the player will
  ///attempt to ensure is buffered at all times, in milliseconds.
  int minBuffer;

  /// The maximum duration of media that the player will attempt to buffer, in milliseconds.
  int maxBuffer;

  /// The default duration of media that must be buffered for playback
  /// to start or resume following a user action such as a seek, in milliseconds.
  int bufferForPlayback;

  ///The default duration of media that must be buffered for playback to resume after a rebuffer, in milliseconds.
  ///A rebuffer is defined to be caused by buffer depletion rather than a user action.
  int bufferForPlaybackAfterRebuffer;
}

class CreationOptions {
  CreationOptions({
    required this.uri,
    required this.httpHeaders,
    required this.bufferConfig,
  });
  String uri;
  PlatformVideoFormat? formatHint;
  Map<String, String> httpHeaders;
  String? userAgent;
  BufferConfigNative bufferConfig;
}

class TexturePlayerIds {
  TexturePlayerIds({required this.playerId, required this.textureId});

  final int playerId;
  final int textureId;
}

@HostApi()
abstract class AndroidVideoPlayerApi {
  void initialize();
  // Creates a new player using a platform view for rendering and returns its
  // ID.
  int createForPlatformView(CreationOptions options);
  // Creates a new player using a texture for rendering and returns its IDs.
  TexturePlayerIds createForTextureView(CreationOptions options);
  void dispose(int playerId);
  void setMixWithOthers(bool mixWithOthers);
  String getLookupKeyForAsset(String asset, String? packageName);
}

@HostApi()
abstract class VideoPlayerInstanceApi {
  /// Sets whether to automatically loop playback of the video.
  void setLooping(bool looping);

  /// Sets the volume, with 0.0 being muted and 1.0 being full volume.
  void setVolume(double volume);

  /// Sets the playback speed as a multiple of normal speed.
  void setPlaybackSpeed(double speed);

  /// Begins playback if the video is not currently playing.
  void play();

  /// Pauses playback if the video is currently playing.
  void pause();

  /// Seeks to the given playback position, in milliseconds.
  void seekTo(int position);

  /// Returns the current playback position, in milliseconds.
  int getCurrentPosition();

  /// Returns the current buffer position, in milliseconds.
  int getBufferedPosition();
}

@EventChannelApi()
abstract class VideoEventChannel {
  PlatformVideoEvent videoEvents();
}
