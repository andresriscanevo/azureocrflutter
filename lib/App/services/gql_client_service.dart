import 'dart:convert';

import 'package:flutter/material.dart' show ValueNotifier;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:jwt_decode/jwt_decode.dart';

import '../config/remote_config.dart';

final deviceTokenProvider = StateProvider<String>((ref) => '');
final authTokenProvider = StateProvider<String>((ref) => '');
final checkTokenExpirationProvider = FutureProvider<String>((ref) async {
  return GenerateToken.checkTokenExpiration(ref.watch(authTokenProvider));
});

class GraphQLClientService {
  static final _hasuraHostName = RemoteConfig.hasuraHostName;
  static final _connectionTimeout = RemoteConfig.connectionTimeout;
  static final _httpsEndpoint = 'https://${_hasuraHostName}/v1/graphql';
  static final _wssEndpoint = 'wss://${_hasuraHostName}/v1/graphql';
  static const Map<String, String> _headers = {
    'content-type': 'application/json',
    'x-hasura-admin-secret': 'Srf2020***',
  };

  final gqlClientProvider = Provider<ValueNotifier<GraphQLClient>>(
    (ref) {
      final newToken = ref.watch(checkTokenExpirationProvider).value;
      final httpLink = HttpLink(_httpsEndpoint, defaultHeaders: _headers);
      final wsLink = WebSocketLink(
        _wssEndpoint,
        config: SocketClientConfig(
          queryAndMutationTimeout: Duration(seconds: _connectionTimeout),
          autoReconnect: true,
          inactivityTimeout: Duration(seconds: _connectionTimeout),
          initialPayload: () {
            return {'headers': _headers};
          },
        ),
      );
      final authLink = AuthLink(getToken: () => 'Bearer $newToken');
      final link = authLink.concat(
          Link.split((request) => request.isSubscription, wsLink, httpLink));

      return ValueNotifier(
        GraphQLClient(
          link: link,
          cache: GraphQLCache(), //GraphQLCache(store: HiveStore()),
        ),
      );
    },
  );
}

class GenerateToken {
  static Future<String> checkTokenExpiration(String token) async {
    var newToken = token;

    if (newToken.isEmpty) return '';

    try {
      final tokenInfo = Jwt.parseJwt(token);
      final expiryDate = Jwt.getExpiryDate(token);
      final res = await http.get(
          Uri.parse('https://worldtimeapi.org/api/timezone/America/Bogota'));
      final data = jsonDecode(res.body);
      final currentDate = DateFormat('yyyy-MM-dd').parse(data['datetime']);
      final diffInDays = expiryDate!.difference(currentDate).inDays;

      if (diffInDays <= 3) {
        final theNewToken = await _getNewToken(
          uid: tokenInfo['https://hasura.io/jwt/claims']['x-hasura-user-id'],
          currentToken: token,
          role: tokenInfo['https://hasura.io/jwt/claims']
              ['x-hasura-default-role'],
        );

        if (theNewToken != '' && !theNewToken.startsWith('Error')) {
          newToken = theNewToken;
        }

        return newToken;
      }
      return Future.error('Error: Conexión a internet es inestable.');
    } catch (error) {
      return Future.error('Error: $error.');
    }
  }

  static Future<String> _getNewToken(
      {required String uid,
      required String currentToken,
      required String role}) async {
    final tokensEndpoint = RemoteConfig.tokensEnpoint;
    final origin = RemoteConfig.appOrigin;
    final body = <String, dynamic>{
      'uid': uid,
      'role': role,
    };

    final response = await http.post(
      Uri.parse(tokensEndpoint),
      headers: {
        'origin': origin,
      },
      body: body,
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      final newToken = data['accessToken'];

      return newToken;
    } else {
      return 'Error: ${data['statusText']}';
    }
  }
}
