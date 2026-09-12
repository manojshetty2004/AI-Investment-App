import 'dart:convert';

import 'package:app/services/api_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  test('sends recommendation inputs and reads status and logs', () async {
    final requests = <http.Request>[];
    final api = ApiService(baseUrl: 'http://localhost:8000', client: MockClient((request) async {
      requests.add(request);
      if (request.url.path == '/recommend') {
        return http.Response(jsonEncode({'expected_return': '8-10%'}), 200);
      }
      if (request.url.path == '/agents/status') {
        return http.Response(jsonEncode({'agents': {'risk_agent': 'available'}}), 200);
      }
      return http.Response(jsonEncode([{'agent': 'orchestrator', 'status': 'completed'}]), 200);
    }));

    expect((await api.getRecommendation(riskType: 'Low', investmentAmount: 100000, investmentTenure: 5))['expected_return'], '8-10%');
    expect(jsonDecode(requests.first.body), {'risk_type': 'Low', 'investment_amount': 100000, 'investment_tenure': 5});
    expect((await api.getAgentStatus())['agents']['risk_agent'], 'available');
    expect((await api.getLogs()).first['status'], 'completed');
    api.dispose();
  });

  test('surfaces downstream agent failure', () async {
    final api = ApiService(client: MockClient((_) async => http.Response(
      jsonEncode({'detail': {'agent': 'research_agent', 'message': 'unavailable'}}), 503,
    )));
    expect(
      api.getRecommendation(riskType: 'MediumHigh', investmentAmount: 100000, investmentTenure: 5),
      throwsA(isA<ApiException>().having((error) => error.message, 'message', contains('research_agent'))),
    );
    api.dispose();
  });
}
