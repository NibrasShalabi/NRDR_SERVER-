// bin/dns_client.dart

import 'dart:io';
import 'dart:convert';
import 'package:nrdr/models/nrdr_response.dart';

void main(List<String> args) async {
  if (args.isEmpty) {
    _printHelp();
    return;
  }

  final command = args[0].toLowerCase();

  try {
    final socket = await Socket.connect('localhost', 1112);

    switch (command) {
      case 'register':
        if (args.length < 4) {
          print(' Usage: dns_client.dart register <domain> <host> <port>');
          return;
        }
        socket.writeln('REGISTER ${args[1]} ${args[2]} ${args[3]} web');
        break;

      case 'resolve':
        if (args.length < 2) {
          print(' Usage: dns_client.dart resolve <domain>');
          return;
        }
        socket.writeln('RESOLVE ${args[1]}');
        break;

      case 'list':
        socket.writeln('LIST');
        break;

      case 'delete':
        if (args.length < 2) {
          print(' Usage: dns_client.dart delete <domain>');
          return;
        }
        socket.writeln('DELETE ${args[1]}');
        break;
    }

    await socket.flush();

    final responseData = await socket.first;
    final responseText = utf8.decode(responseData);
    final response = NrdrResponse.parse(responseText);

    print('Status: ${response.statusCode} ${response.statusName}');
    print("${response.body}");

    await socket.close();

  } catch (e) {
    print(' Error: $e');
  }
}

void _printHelp() {
  print('''
DNS Client

Usage:
  dart run bin/dns_client.dart <command> [args]

Commands:
  register <domain> <host> <port>  - Register domain
  resolve <domain>                 - Resolve domain
  list                            - List all domains
  delete <domain>                 - Delete domain

Examples:
  dart run bin/dns_client.dart register api.nrdr 127.0.0.1 1413
  dart run bin/dns_client.dart resolve api.nrdr
  dart run bin/dns_client.dart list
  ''');
}