class WebrtcConfig {
  static const Map<String, dynamic> mediaConstraints = {
    'audio': true,
    'video': {
      'mandatory': {
        'minWidth': '480', // Provide your own width, height and frame rate here
        'minHeight': '640',
        'minFrameRate': '30',
      },
      'facingMode': 'user',
      'optional': [],
    }
  };

  static const Map<String, dynamic> configuration = {
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

  static const Map<String, dynamic> offerSdpConstraints = {
    "mandatory": {
      "OfferToReceiveAudio": true,
      "OfferToReceiveVideo": true,
    },
    "optional": [],
  };

  static const Map<String, dynamic> loopbackConstraints = {
    "mandatory": {},
    "optional": [
      {"DtlsSrtpKeyAgreement": true},
    ],
  };
}
