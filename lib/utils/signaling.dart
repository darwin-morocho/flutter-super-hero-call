import 'package:flutter_webrtc/webrtc.dart';
import 'package:super_hero_call/utils/consts.dart';

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

  init() async {
    _localStream = await navigator.getUserMedia(
        WebrtcConfig.mediaConstraints); // get the user media stream

    if (onLocalStream != null) {
      //send the my stream to home screen
      onLocalStream(_localStream);
    }
  }

  ///
  /// [isCaller] is true if we are the caller
  Future<RTCPeerConnection> createPeer(bool isCaller) async {
    final peer = await createPeerConnection(WebrtcConfig.configuration,
        WebrtcConfig.loopbackConstraints); // create a peer connection
    peer.onAddStream = gotRemoteStream; // when I recived a remote stream
    peer.addStream(_localStream); // the audio and video to the other user

    if (isCaller) {
      // if we are the caller
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

    final desc = RTCSessionDescription(
        offer['sdp'], offer['type']); //create the offer description
    await _peer.setRemoteDescription(desc); // set the remote description

    final answer = await _peer.createAnswer(WebrtcConfig.offerSdpConstraints);
    _peer.setLocalDescription(answer); //set local destrintion with my answer
    _myAnswer = {'type': answer.type, 'sdp': answer.sdp};
  }

  //when we got an answer from a remote user
  answer(dynamic answer) async {
    final desc = RTCSessionDescription(
        answer['sdp'], answer['type']); // create the offer description
    await _peer.setRemoteDescription(desc); // set the remote description
  }

  // when your are the caller
  Future<Map<String, dynamic>> call() async {
    _peer = await createPeer(true); // create a new peer with us a caller
    final offerDesc = await _peer.createOffer(WebrtcConfig.offerSdpConstraints);
    _peer.setLocalDescription(offerDesc); //set local destrintion with my offer
    return {
      'type': offerDesc.type,
      'sdp': offerDesc.sdp
    }; // return my offer data
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
