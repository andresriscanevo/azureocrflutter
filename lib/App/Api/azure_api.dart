import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';

Future<String> azureApi(url) async {
  var uriSrf = Uri.parse(
      'https://srf-vision.cognitiveservices.azure.com/computervision/imageanalysis:analyze?api-version=2023-02-01-preview&features=Read&language=en&gender-neutral-caption=False');
  final response = await http.post(uriSrf,
      headers: {
        'Content-Type': 'application/json',
        'Ocp-Apim-Subscription-Key': 'f3db7370650b42b19dd4cc73d393f1f1'
      },
      body: jsonEncode({"url": url}));

  Map<String, dynamic> responseBody = jsonDecode(response.body);
  print(responseBody['readResult']['content']);
  return responseBody['readResult']['content'];
}
