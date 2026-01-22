import 'package:nrdr/models/nrdr_response.dart';

void main() {
  print('=== اختبار NrdrResponse ===\n');

  // Test 1: رد ناجح
  final raw1 = '200 OK\nHello Nrdr!\nEND\n';
  final response1 = NrdrResponse.parse(raw1);
  print('Test 1:');
  print('Code: ${response1.statusCode}');
  print('Name: ${response1.statusName}');
  print('Body: ${response1.body}');
  print('Success? ${response1.isSuccess}\n');

  // Test 2: رد 404
  final raw2 = '404 NOT_FOUND\nKey not found\nEND\n';
  final response2 = NrdrResponse.parse(raw2);
  print(' Test 2:');
  print('Code: ${response2.statusCode}');
  print('Client Error? ${response2.isClientError}\n');

  // Test 3: Factory methods
  final success = NrdrResponse.success('Data here');
  print(' Test 3:');
  print(success);
  print('');

  // Test 4: toRawString
  final response4 = NrdrResponse.success('Test');
  print(' Test 4:');
  print(response4.toRawString());
}