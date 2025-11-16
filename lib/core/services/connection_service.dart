
import 'package:flutter/material.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';

abstract class ConnectionService {
  ValueNotifier<bool> get hasConnection;
  void listenConnectivity();
}

class ConnectionServiceImpl extends ChangeNotifier implements ConnectionService {

  @override
  ValueNotifier<bool> hasConnection = ValueNotifier(false);

  @override
  void listenConnectivity() {
    InternetConnection().onStatusChange.listen((status) {
      hasConnection.value = status == InternetStatus.connected;
    });
  }

}