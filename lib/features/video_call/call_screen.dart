// call_screen.dart
import 'package:design_test/features/video_call/signaling.dart';
import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';

final Signaling signaling = Signaling();

class CallScreen extends StatefulWidget {
  final Map offerData;
  final String roomId;
  final bool caller;
  const CallScreen({super.key, required this.offerData, required this.roomId, required this.caller});

  @override
  State<CallScreen> createState() => _CallScreenState();
}

class _CallScreenState extends State<CallScreen> {
  RTCVideoRenderer? localRenderer;
  RTCVideoRenderer? remoteRenderer;

  bool videoEnabled = true;
  bool audioEnabled = true;

  @override
  void initState() {
    super.initState();
    initRenderersAndStart();
  }

  Future<void> initRenderersAndStart() async {
    localRenderer = RTCVideoRenderer();
    remoteRenderer = RTCVideoRenderer();
    await localRenderer!.initialize();
    await remoteRenderer!.initialize();

    if (widget.caller) {
      await signaling.openUserMedia(localRenderer!, remoteRenderer!, widget.roomId);
      setState(() {});
    }
  }

  @override
  void dispose() {
    hangUpAndDispose();
    super.dispose();
  }

  Future<void> toggleVideo() async {
    if (signaling.localStream != null) {
      var videoTrack = signaling.localStream!.getVideoTracks().first;
      if (videoTrack != null) {
        videoTrack.enabled = !videoTrack.enabled;
        setState(() {
          videoEnabled = videoTrack.enabled;
        });
      }
    }
  }

  Future<void> toggleAudio() async {
    if (signaling.localStream != null) {
      var audioTrack = signaling.localStream!.getAudioTracks().first;
      if (audioTrack != null) {
        audioTrack.enabled = !audioTrack.enabled;
        setState(() {
          audioEnabled = audioTrack.enabled;
        });
      }
    }
  }

  Future<void> hangUpAndDispose() async {
    if (localRenderer != null && remoteRenderer != null) {
      await signaling.hangUp(localRenderer!, remoteRenderer!, widget.roomId);

      await localRenderer!.dispose();
      await remoteRenderer!.dispose();

      localRenderer = null;
      remoteRenderer = null;

      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    if (localRenderer == null || remoteRenderer == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: Stack(
              children: [
                RTCVideoView(
                  remoteRenderer!,
                  mirror: true,
                  objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
                ),
                Align(
                  alignment: Alignment.bottomRight,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                      height: 200,
                      width: 150,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: Colors.black,
                      ),
                      child: RTCVideoView(
                        localRenderer!,
                        objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
                        mirror: true,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(
            color: Colors.black54,
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                IconButton(
                  icon: Icon(
                    videoEnabled ? Icons.videocam : Icons.videocam_off,
                    color: Colors.white,
                    size: 30,
                  ),
                  onPressed: toggleVideo,
                ),
                IconButton(
                  icon: Icon(
                    audioEnabled ? Icons.mic : Icons.mic_off,
                    color: Colors.white,
                    size: 30,
                  ),
                  onPressed: toggleAudio,
                ),
                InkWell(
                  onTap: () async {
                    await hangUpAndDispose();
                    Navigator.of(context).pop();
                  },
                  child: const CircleAvatar(
                    backgroundColor: Colors.red,
                    radius: 28,
                    child: Icon(Icons.call_end, color: Colors.white, size: 28),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
