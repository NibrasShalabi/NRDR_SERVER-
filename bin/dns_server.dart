// bin/dns_server.dart

import 'package:nrdr/core/dns_server.dart';
import 'package:nrdr/utils/constants.dart';

void main(List<String> args) async {
  final server = DnsServer();

  final host = args.isNotEmpty ? args[0] : NrdrConstants.dnsHost;
  final port = args.length > 1 ? int.parse(args[1]) : NrdrConstants.dnsPort;

  await server.start(host: host, port: port);
}