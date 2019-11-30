import 'package:flutter_webrtc/webrtc.dart';

typedef OnLocalStream = void Function(MediaStream stream);
typedef OnRemoteStream = void Function(MediaStream stream);

class Signaling {
  OnLocalStream onLocalStream;
  OnRemoteStream onRemoteStream;

  MediaStream _localStream;

  MediaStream get localStream => _localStream;
  RTCPeerConnection _peer;

  final Map<String, dynamic> configuration = {
    "iceServers": [
      {"url": "stun:stun.l.google.com:19302"},
    ]
  };

  final Map<String, dynamic> offerSdpConstraints = {
    "mandatory": {
      "OfferToReceiveAudio": true,
      "OfferToReceiveVideo": true,
    },
    "optional": [],
  };

  final Map<String, dynamic> loopbackConstraints = {
    "mandatory": {},
    "optional": [
      {"DtlsSrtpKeyAgreement": true},
    ],
  };

  init() async {
    final Map<String, dynamic> mediaConstraints = {
      'audio': true,
      'video': {
        'mandatory': {
          'minWidth':
              '480', // Provide your own width, height and frame rate here
          'minHeight': '640',
          'minFrameRate': '30',
        },
        'facingMode': 'user',
        'optional': [],
      }
    };

    _localStream = await navigator
        .getUserMedia(mediaConstraints); // get the user media stream

    if (onLocalStream != null) {
      //send the my stream to home screen
      onLocalStream(_localStream);
    }

    _peer = await createPeerConnection(
        configuration, loopbackConstraints); // create a perr connection
    _peer.addStream(_localStream); //

    _peer.onAddStream = gotRemoteStream; // when I recived a remote stream
  }

  // when your are receiving a call
  gotOffer(dynamic data) {
    final incommingOffer = RTCSessionDescription(data['sdp'], data['type']);
    _peer.setRemoteDescription(incommingOffer); // set the remote description
  }

  // when your are the caller
  Future<Map<String, dynamic>> sendMyOffer() async {
    final offer = await _peer.createOffer(offerSdpConstraints);
    _peer.setLocalDescription(offer); //set local destrintion with my offer
    return {'type': offer.type, 'sdp': offer.sdp};
  }

  // when your are the callee
  Future<Map<String, dynamic>> sendMyAnswer() async {
    final answer = await _peer.createAnswer(offerSdpConstraints);
    _peer.setLocalDescription(answer); //set local destrintion with my answer
    return {'type': answer.type, 'sdp': answer.sdp};
  }

  // this method will be called when you revice a remote video/audio stream
  gotRemoteStream(MediaStream remoteStream) {
    //send the remote stream to home screen
    if (onRemoteStream != null) {
      onRemoteStream(remoteStream);
    }
  }

  dispose() {
    _peer?.close();
    _localStream?.dispose();
  }
}
