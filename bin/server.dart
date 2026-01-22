// bin/server.dart

import 'package:nrdr/core/nrdr_server.dart';
import 'package:nrdr/utils/constants.dart';

void main(List<String> args) async {
  final server = NrdrServer();

  final host = args.length > 0 ? args[0] : NrdrConstants.serverHost;
  final port = args.length > 1 ? int.parse(args[1]) : NrdrConstants.serverPort;

  await server.start(host: host, port: port);
}