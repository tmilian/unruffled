import 'package:flutter/widgets.dart';
import 'package:test/test.dart';

import '_support/setup.dart';

void main() async {
  setUp(setUpFn);
  tearDown(tearDownFn);

  WidgetsFlutterBinding.ensureInitialized();

  test('Authenticate', () async {
    final data = {
      "email": "test@test.com",
      "password": "test123",
      "strategy": "local",
    };
    dioAdapter.onPost(unruffled.authenticationUrl, (server) {
      return server.reply(200, {
        "accessToken":
            "eyJhbGciOiJIUzI1NiIsInR5cCI6ImFjY2VzcyJ9.eyJpYXQiOjE2NTI5NjQ1NzgsImV4cCI6MTY1MzA1MDk3OCwiYXVkIjoiaHR0cHM6Ly95b3VyZG9tYWluLmNvbSIsImlzcyI6ImZlYXRoZXJzIiwic3ViIjoiNjI2M2MzYzI1MzFkZmU2N2ZjOTIzMTBhIiwianRpIjoiMjljOGJmNmEtODYyMS00MGUxLWE2ODQtNzdjOWY1MDljNjg3In0.ZH53Aj2I5qj1Uc-rByDO80S1NdkU9UrCrNyS7PJhp98",
        "refreshToken":
            "eyJhbGciOiJIUzI1NiIsInR5cCI6ImFjY2VzcyJ9.eyJ0b2tlblR5cGUiOiJyZWZyZXNoIiwidXNlciI6eyJfaWQiOiI2MjYzYzNjMjUzMWRmZTY3ZmM5MjMxMGEiLCJlbWFpbCI6ImNsaWVudDFAdGVzdC5jb20iLCJuYW1lIjoiSmVhbiIsInN1cm5hbWUiOiJEdXBvbnQiLCJqb2IiOiJDRU8iLCJwZXJtaXNzaW9ucyI6WyJjbGllbnQiXSwiY3JlYXRlZEF0IjoiMjAyMi0wNC0yM1QwOToxNTo0Ni4yNTRaIiwidXBkYXRlZEF0IjoiMjAyMi0wNC0yNFQxNTo0OTozMS45NzhaIiwiX192IjowLCJjb21wYW55IjoiNjI2M2M3NTA1ODhkZjBjN2RhODhjYzE3In0sImlhdCI6MTY1Mjk2NDU3OCwiZXhwIjoxNjUzMDUwOTc4LCJhdWQiOiJodHRwczovL3lvdXJkb21haW4uY29tIiwiaXNzIjoiZmVhdGhlcnMiLCJzdWIiOiI2MjYzYzNjMjUzMWRmZTY3ZmM5MjMxMGEiLCJqdGkiOiIzYzhiNmJiMS0yYzM3LTQ3YzUtODZlZS05MjZlYTA1MTgwZDcifQ.e6OVTSAv08zfrWwyhG1ZNCwiYs_pqaGuj5rq2-XwwRo",
        "authentication": {"strategy": "local"},
        "user": {
          "_id": "6263c3c2531dfe67fc92310a",
          "email": "client1@test.com",
          "name": "Jean",
          "surname": "Dupont",
          "job": "CEO",
          "permissions": ["client"],
          "createdAt": "2022-04-23T09:15:46.254Z",
          "updatedAt": "2022-04-24T15:49:31.978Z",
          "__v": 0,
          "company": "6263c750588df0c7da88cc17"
        }
      });
    }, data: data);
    var result = await unruffled.authenticate(body: data);
    expect(result["accessToken"],
        "eyJhbGciOiJIUzI1NiIsInR5cCI6ImFjY2VzcyJ9.eyJpYXQiOjE2NTI5NjQ1NzgsImV4cCI6MTY1MzA1MDk3OCwiYXVkIjoiaHR0cHM6Ly95b3VyZG9tYWluLmNvbSIsImlzcyI6ImZlYXRoZXJzIiwic3ViIjoiNjI2M2MzYzI1MzFkZmU2N2ZjOTIzMTBhIiwianRpIjoiMjljOGJmNmEtODYyMS00MGUxLWE2ODQtNzdjOWY1MDljNjg3In0.ZH53Aj2I5qj1Uc-rByDO80S1NdkU9UrCrNyS7PJhp98");
  });
}
