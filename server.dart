import 'dart:convert';
import 'dart:io';

void main(List<String> args) async {
  int port = 12321;
  if (args.isNotEmpty) {
    port = int.parse(args[0]);
  }

  final serverSocket = await ServerSocket.bind(InternetAddress.anyIPv4, port);
  print('[+] listing port $port');

  await for (final client in serverSocket) {
    print('\n[+] connection from ${client.remoteAddress}');
    client.listen((data) {
      print(utf8.decode(data));
      client.close();
    });
  }
}
