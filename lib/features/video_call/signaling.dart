// signaling.dart
import 'dart:developer';
import 'package:flutter_webrtc/flutter_webrtc.dart';

typedef void StreamStateCallback(MediaStream stream);

class Signaling {
  Map<String, dynamic> configuration = {
    'iceServers': [
      {
        'urls': [
          'stun:stun1.l.google.com:19302',
          'stun:stun2.l.google.com:19302'
        ]
      }
    ]
  };

  RTCPeerConnection? peerConnection;
  MediaStream? localStream;
  MediaStream? remoteStream;
  StreamStateCallback? onAddRemoteStream;

  RTCSessionDescription? offerSdp;
  RTCSessionDescription? answerSdp;
  List<RTCIceCandidate> callerCandidates = [];
  List<RTCIceCandidate> calleeCandidates = [];

  /// NOTE: `localRenderer` and `remoteRenderer` are fully managed by UI now.
  /// Signaling only uses passed renderers, does not create or dispose them.
  Future<String> createRoom(RTCVideoRenderer remoteRenderer, String roomId) async {
    log("Creating room: $roomId");

    peerConnection = await createPeerConnection(configuration);
    registerPeerConnectionListeners();

    localStream?.getTracks().forEach((track) {
      peerConnection?.addTrack(track, localStream!);
    });

    peerConnection?.onIceCandidate = (RTCIceCandidate candidate) {
      log("Caller candidate: ${candidate.toMap()}");
      callerCandidates.add(candidate);
    };

    peerConnection?.onTrack = (RTCTrackEvent event) {
      log("Got remote track: ${event.streams[0]}");
      remoteStream ??= event.streams[0];
      event.streams[0].getTracks().forEach((track) {
        remoteStream?.addTrack(track);
      });
      remoteRenderer.srcObject = remoteStream;
    };

    RTCSessionDescription offer = await peerConnection!.createOffer();
    await peerConnection!.setLocalDescription(offer);
    log("Created offer: ${offer.sdp}");
    offerSdp = offer;

    return roomId;
  }

  Future<void> joinRoom(RTCVideoRenderer remoteRenderer, String roomId) async {
    log("Joining room: $roomId");

    peerConnection = await createPeerConnection(configuration);
    registerPeerConnectionListeners();

    localStream?.getTracks().forEach((track) {
      peerConnection?.addTrack(track, localStream!);
    });

    peerConnection?.onIceCandidate = (RTCIceCandidate candidate) {
      log("Callee candidate: ${candidate.toMap()}");
      calleeCandidates.add(candidate);
    };

    peerConnection?.onTrack = (RTCTrackEvent event) {
      log("Got remote track: ${event.streams[0]}");
      remoteStream ??= event.streams[0];
      event.streams[0].getTracks().forEach((track) {
        remoteStream?.addTrack(track);
      });
      remoteRenderer.srcObject = remoteStream;
    };

    if (offerSdp != null) {
      await peerConnection!.setRemoteDescription(offerSdp!);
      RTCSessionDescription answer = await peerConnection!.createAnswer();
      await peerConnection!.setLocalDescription(answer);
      log("Created answer: ${answer.sdp}");
      answerSdp = answer;
    }

    if (peerConnection != null && answerSdp != null) {
      await peerConnection!.setRemoteDescription(answerSdp!);
    }

    for (var candidate in callerCandidates) {
      await peerConnection!.addCandidate(candidate);
    }
  }

  Future<void> openUserMedia(
      RTCVideoRenderer localVideo, RTCVideoRenderer remoteVideo, String roomId) async {
    var stream = await navigator.mediaDevices.getUserMedia({'video': true, 'audio': true});
    localStream = stream;
    localVideo.srcObject = localStream;
    remoteVideo.srcObject = await createLocalMediaStream('remote');
  }

  Future<void> hangUp(RTCVideoRenderer localVideo, RTCVideoRenderer remoteVideo, String roomId) async {
    if (localVideo.srcObject != null) {
      for (var track in localVideo.srcObject!.getTracks()) {
        track.stop();
      }
      localVideo.srcObject = null;
    }

    if (remoteVideo.srcObject != null) {
      for (var track in remoteVideo.srcObject!.getTracks()) {
        track.stop();
      }
      remoteVideo.srcObject = null;
    }

    await peerConnection?.close();
    peerConnection = null;

    await localStream?.dispose();
    localStream = null;

    await remoteStream?.dispose();
    remoteStream = null;

    offerSdp = null;
    answerSdp = null;
    callerCandidates.clear();
    calleeCandidates.clear();

    log("Call ended and resources cleared.");
  }

  void registerPeerConnectionListeners() {
    peerConnection?.onIceGatheringState = (RTCIceGatheringState state) {
      log("ICE gathering state changed: $state");
    };

    peerConnection?.onConnectionState = (RTCPeerConnectionState state) {
      log("Connection state change: $state");
    };

    peerConnection?.onSignalingState = (RTCSignalingState state) {
      log("Signaling state change: $state");
    };

    peerConnection?.onAddStream = (MediaStream stream) {
      log("Remote stream added");
      onAddRemoteStream?.call(stream);
      remoteStream = stream;
    };
  }
}
