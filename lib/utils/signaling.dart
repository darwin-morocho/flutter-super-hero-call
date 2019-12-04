import 'dart:convert';

import 'package:flutter_webrtc/webrtc.dart';
import 'package:super_hero_call/models/super_hero.dart';
import 'package:super_hero_call/utils/consts.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

typedef OnConnected(Map<String, SuperHero> data);
typedef OnAssigned = void Function(String superHeroName);
typedef OnTaken = void Function(String superHeroName);
typedef OnResponse = void Function(dynamic data);
typedef OnRequest = void Function(dynamic data);
typedef OnCancelRequest = void Function();
typedef OnDisconnected = void Function(String superHeroName);
typedef OnFinish = void Function();

typedef OnLocalStream = void Function(MediaStream stream);
typedef OnRemoteStream = void Function(MediaStream stream);

class Signaling {
  IO.Socket _socket;

  OnConnected onConnected;
  OnAssigned onAssigned;
  OnAssigned onTaken;
  OnResponse onResponse;
  OnRequest onRequest;
  OnCancelRequest onCancelRequest;
  OnDisconnected onDisconnected;
  OnFinish onFinish;

  OnLocalStream onLocalStream;
  OnRemoteStream onRemoteStream;

  MediaStream _localStream;

  RTCPeerConnection _peer;

  String _him;
  RTCSessionDescription _incommingOffer;

  RTCSessionDescription _myAnswer;

  Future<void> connect() async {
    // const uri = "http://192.168.1.35:5000";
    const uri = "https://backend-super-hero-call.herokuapp.com";
    _socket = IO.io(uri, <String, dynamic>{
      'transports': ['websocket'],
    });

    _socket.on('on-connected', (dynamic data) {
      try {
        // get a map of super heroes
        final Map<String, SuperHero> mapData = Map();
        final tmp = new Map<String, dynamic>.from(jsonDecode(jsonEncode(data)));
        tmp.forEach((key, value) {
          final superHero = SuperHero.fromJson(value);
          mapData[key] = superHero;
        });
        if (onConnected != null) {
          onConnected(mapData); // send the heroes to our app_state_bloc
        }
      } catch (e) {
        print(e);
      }
    });

    _socket.on('on-assigned', (data) {
      if (onAssigned != null) {
        onAssigned(data);
      }
    });
    _socket.on('on-taken', (data) {
      if (onTaken != null) {
        onTaken(data);
      }
    });

    _socket.on('on-request', (data) {
      print("on-request");
      if (onRequest != null) {
        final offer = data['offer'];
        this._him = data['superHeroName'];
        _incommingOffer = RTCSessionDescription(offer['sdp'], offer['type']);
        onRequest(data);
      }
    });

    _socket.on('on-cancel-request', (_) {
      if (onCancelRequest != null) {
        onCancelRequest();
      }
    });

    _socket.on('on-response', (answer) {
      if (onResponse != null) {
        if (answer != null) {
          //when we got an answer from a remote user
          final desc = RTCSessionDescription(
              answer['sdp'], answer['type']); // create the offer description
          _peer.setRemoteDescription(desc); // set the remote description
        }
        onResponse(answer);
      }
    });

    _socket.on('on-disconnected', (data) {
      if (onDisconnected != null) {
        onDisconnected(data);
      }
    });

    _socket.on('on-finish-call', (_) {
      if (onFinish != null) {
        onFinish();
      }
    });

    _socket.on('on-candidate', (candidate) {
      _addCandidate(candidate);
    });
  }

  getUserMedia() async {
    _localStream = await navigator.getUserMedia(
        WebrtcConfig.mediaConstraints); // get the user media stream

    if (onLocalStream != null) {
      //send the my stream to home screen
      onLocalStream(_localStream);
    }
  }

  Future<RTCPeerConnection> createPeer() async {
    final peer = await createPeerConnection(WebrtcConfig.configuration,
        WebrtcConfig.loopbackConstraints); // create a peer connection
    peer.onAddStream = gotRemoteStream; // when I recived a remote stream
    peer.addStream(_localStream); // the audio and video to the other user

    peer.onIceCandidate = (RTCIceCandidate candidate) {
      if (candidate != null && _him != null) {
        print("enviando candidate");
        // send the ICE candidate to the other user into the call
        _socket
            ?.emit('candidate', {'to': _him, 'candidate': candidate.toMap()});
      }
    };
    return peer;
  }

  _addCandidate(dynamic data) async {
    print("add cantidate $data");
    RTCIceCandidate candidate = new RTCIceCandidate(
        data['candidate'], data['sdpMid'], data['sdpMLineIndex']);
    await _peer.addCandidate(candidate);
  }

  void acceptOrDeclineCall(String requestId, bool accept) async {
    if (accept) {
      _peer = await createPeer();
      await _peer.setRemoteDescription(_incommingOffer); // set the remote description
      _myAnswer = await _peer.createAnswer(WebrtcConfig.offerSdpConstraints);
      await _peer.setLocalDescription(
          _myAnswer); //set local destrintion with my answer
    }
    _socket?.emit('response',
        {"requestId": requestId, "answer": accept ? _myAnswer.toMap() : null});
  }

  // this method will be called when you revice a remote video/audio stream
  gotRemoteStream(MediaStream remoteStream) {
    //send the remote stream to home screen
    if (onRemoteStream != null) {
      onRemoteStream(remoteStream);
    }
  }

  void pickSuperHero(String superHeroName) {
    _socket?.emit('pick', superHeroName);
  }

  // when your are the caller
  void callTo(String heroName) async {
    _him = heroName;
    _peer = await createPeer(); // create a new peer with us a caller
    final offer = await _peer.createOffer(WebrtcConfig.offerSdpConstraints);
    //set local description with our offer
    await _peer.setLocalDescription(offer);
    _socket
        ?.emit('request', {"superHeroName": heroName, "offer": offer.toMap()});
  }

  void cancelCall() {
    _him = null;
    _socket?.emit('cancel-request');
  }

  void finishCall() {
    _him = null;
    _socket?.emit('finish-call');
  }

  dispose() {
    _peer?.close();
    if (_socket != null) {
      _socket.disconnect();
      _socket.close();
      _socket = null;
    }
    //_localStream?.dispose();
  }
}
