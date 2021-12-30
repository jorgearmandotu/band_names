

import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;



enum ServerStatus {
  // ignore: constant_identifier_names
  Online,
  // ignore: constant_identifier_names
  Offline,
  // ignore: constant_identifier_names
  Connecting
}

class SocketService with ChangeNotifier {

  ServerStatus _serverStatus = ServerStatus.Connecting;
  IO.Socket _socket = IO.io('http://localhost:3000');

  ServerStatus get serverStatus => _serverStatus;
  
  IO.Socket get socket => _socket;
  Function get emit => _socket.emit;

  SocketService(){
    _initConfig();
  }

  void _initConfig() {
    // Dart client
    _socket = IO.io('http://192.168.1.4:3000', 
    IO.OptionBuilder()
    .setTransports(['websocket'])
    .build()
    );
    _socket.onConnect((_) {
      _serverStatus = ServerStatus.Online;
      notifyListeners();
    });
    //socket.on('event', (data) => print(data));
    _socket.onDisconnect((_) {
     _serverStatus = ServerStatus.Offline;
     notifyListeners();
     });
    
    // socket.on('nuevo-mensaje', (payload) {
    //   // ignore: avoid_print
    //   print('nuevo-mensaje');
    //   // ignore: avoid_print
    //   print('nombre:'+ payload['nombre']);
    //   // ignore: avoid_print
    //   print('mensaje:'+ payload['mensaje']);
    //   // ignore: avoid_print
    //   print(payload.containsKey('mensaje2') ? payload['mensaje2'] : 'no hay 2do mensaje');
    // });

  }

}