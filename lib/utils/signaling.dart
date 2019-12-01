import 'package:flutter_webrtc/webrtc.dart';

typedef OnLocalStream = void Function(MediaStream stream);
typedef OnRemoteStream = void Function(MediaStream stream);
typedef OnIceCandidate = void Function(dynamic iceCandidate);

class Signaling {
  OnLocalStream onLocalStream;
  OnRemoteStream onRemoteStream;
  OnIceCandidate onIceCandidate;

  MediaStream _localStream;

  RTCPeerConnection _peer;

  Map<String, dynamic> _myAnswer;
  Map<String, dynamic> get myAnswer => _myAnswer;

  final Map<String, dynamic> configuration = {
    "iceServers": [
      {
        "urls": [
          "stun:u1.xirsys.com",
          "stun:stun1.l.google.com:19302",
          "stun:numb.viagenie.ca:3478"
        ]
      },
      {
        "username":
            "UFsS1Zf40ri07DNlcJr-lA0qp89SgJm_8vrOipNL-iSTWQYxo_bP6CKEWmBxgb68AAAAAF0mPQR5b21hY2E2OQ==",
        "credential": "49182e20-a349-11e9-af68-f676af1e4042",
        "urls": [
          "turn:u1.xirsys.com:80?transport=udp",
          "turn:u1.xirsys.com:80?transport=tcp",
          "turns:u1.xirsys.com:443?transport=tcp"
        ]
      }
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
  }

  Future<RTCPeerConnection> createPeer(bool isCaller) async {
    final peer = await createPeerConnection(
        configuration, loopbackConstraints); // create a peer connection
    peer.onAddStream = gotRemoteStream; // when I recived a remote stream
    peer.addStream(_localStream); //

    if (isCaller) {
      peer.onIceCandidate = (RTCIceCandidate candidate) {
        if (onIceCandidate != null) {
          onIceCandidate({
            'sdpMLineIndex': candidate.sdpMlineIndex,
            'sdpMid': candidate.sdpMid,
            'candidate': candidate.candidate,
          });
        }
      };
    }
    return peer;
  }

  addCandidate(dynamic data) {
    RTCIceCandidate candidate = new RTCIceCandidate(
        data['candidate'], data['sdpMid'], data['sdpMLineIndex']);
    _peer.addCandidate(candidate);
  }

  //when somebody sends us an offer
  offer(dynamic offer) async {
    _peer = await createPeer(false);

    final desc = RTCSessionDescription(offer['sdp'], offer['type']);
    await _peer.setRemoteDescription(desc); // set the remote description

    final answer = await _peer.createAnswer(offerSdpConstraints);
    _peer.setLocalDescription(answer); //set local destrintion with my answer
    _myAnswer = {'type': answer.type, 'sdp': answer.sdp};
  }

  //when we got an answer from a remote user
  answer(dynamic answer) async {
    final desc = RTCSessionDescription(answer['sdp'], answer['type']);
    await _peer.setRemoteDescription(desc); // set the remote description
  }

  // when your are the caller
  Future<Map<String, dynamic>> call() async {
    _peer = await createPeer(true);
    final offerDesc = await _peer.createOffer(offerSdpConstraints);
    _peer.setLocalDescription(offerDesc); //set local destrintion with my offer
    return {'type': offerDesc.type, 'sdp': offerDesc.sdp};
  }

  // this method will be called when you revice a remote video/audio stream
  gotRemoteStream(MediaStream remoteStream) {
    print("gotRemoteStream");
    //send the remote stream to home screen
    if (onRemoteStream != null) {
      onRemoteStream(remoteStream);
    }
  }

  dispose() {
    _peer?.close();
    //_localStream?.dispose();
  }
}
