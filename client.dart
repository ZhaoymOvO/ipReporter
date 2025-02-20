import 'dart:io';

void main(List<String> args) async {
  bool specifyServer = false;
  int cycle = 900;
  for (final i in args) {
    Iterable<dynamic> matches =
        RegExp(r"^\S+:\d+$").allMatches(i).cast<dynamic>();
    if (!matches.isEmpty) {
      specifyServer = true;
    }
  }
  if (args.length == 2) {
    cycle = int.parse(args[1]);
  }
  if (!specifyServer) {
    throw Exception("""
ipReporter client.dart by ZhaoymOvO

usage: client <serverAddress>:<serverPort> [cycle]

explain:
serverAddress:  server.dart's host's ip address
serverPort:     server.dart's listing port
cycle:          time between two reports (default: 900sec. or 15min.)

code released under `Mozilla Public License, Version 2.0`.
""");
  }
  while (true == true) {
    // print("[test] getting ipv6 address");
    final ipv6address = await _getPublicIPv6();

    final address = args[0].split(':')[0];
    final port = int.parse(args[0].split(':')[1]);
    final hostname = Platform.localHostname;
    final msg = "[${DateTime.now()}] ${hostname}: ${ipv6address}";
    _reportToServer(msg, address, port);
    print(msg);
    await Future.delayed(Duration(seconds: cycle));
  }
}

Future<void> _reportToServer(String msg, String address, int port) async {
  final socket = await Socket.connect(address, port);

  socket.write('$msg');
  await socket.flush();
  socket.close();
}

Future<String> _getPublicIPv6() async {
  // print('  [test] getting interfaces list');
  final interfaces = await NetworkInterface.list();
  // print('  [test] getting ipv6 addresses');
  for (final interface in interfaces) {
    // print('    [test] $interface');
    for (final address in interface.addresses) {
      // print('      [test] $address');
      if (address.type == InternetAddressType.IPv6) {
        // print('        [test] ipv6 address found');
        if (address.address.substring(0, 2) != 'fd' &&
            address.address.substring(0, 2) != 'fc') {
          // print('          [test] ipv6 internet address found');
          return address.address;
        } else {
          // print('          [test] not an internet address');
        }
      }
    }
  }

  throw Exception('IPv6 Internet address not found');
}
