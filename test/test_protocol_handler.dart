
import 'package:nrdr/services/protocol_handler.dart';
import 'package:nrdr/utils/constants.dart';

void main() {
  print('=== test ProtocolHandler ===\n');

  final handler = ProtocolHandler();

  // Test 1: PING
  print(' Test 1: PING');
  final ping = handler.processCommand('PING');
  print('Status: ${ping.statusCode}');
  print('Body: ${ping.body}');
  print('Success: ${ping.isSuccess}\n');

  // Test 2: PUBLISH
  print(' Test 2: PUBLISH');
  final publish = handler.processCommand('PUBLISH name نبراس');
  print('Status: ${publish.statusCode}');
  print('Body: ${publish.body}\n');

  // Test 3: FETCH
  print(' Test 3: FETCH');
  final fetch = handler.processCommand('FETCH name');
  print('Status: ${fetch.statusCode}');
  print('Body: ${fetch.body}\n');

  // Test 4: LIST
  print(' Test 4: LIST');
  handler.processCommand('PUBLISH age 23');
  handler.processCommand('PUBLISH city Damascus');
  final list = handler.processCommand('LIST');
  print('Status: ${list.statusCode}');
  print('Keys:\n${list.body}\n');

  // Test 5: DELETE
  print(' Test 5: DELETE');
  final delete = handler.processCommand('DELETE age');
  print('Status: ${delete.statusCode}');
  print('Body: ${delete.body}\n');

  // Test 6: NOT FOUND
  print('Test 6: NOT FOUND');
  final notFound = handler.processCommand('FETCH unknown');
  print('Status: ${notFound.statusCode}');
  print('Is Not Found: ${notFound.statusCode == ResponseStatus.notFound}\n');

  // Test 7: Bad Request
  print('Test 7: Bad Request');
  final badRequest = handler.processCommand('FETCH');
  print('Status: ${badRequest.statusCode}');
  print('Is Client Error: ${badRequest.isClientError}\n');

  // Test 8: Stats
  print(' Test 8: Stats');
  final stats = handler.getStats();
  print('Stats: $stats\n');
}