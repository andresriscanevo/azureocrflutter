import 'package:demoocrcamera/App/modules/capture/camera_ocr.dart';
import 'package:demoocrcamera/App/modules/home/home_page.dart';
import 'package:demoocrcamera/App/theme/AppTheme.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'App/services/gql_client_service.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  await _initializeRemoteConfig();
  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

Future<void> _initializeRemoteConfig() async {
  try {
    final remoteConfig = FirebaseRemoteConfig.instance;

    await remoteConfig.setConfigSettings(
      RemoteConfigSettings(
        fetchTimeout: const Duration(seconds: 15),
        minimumFetchInterval:
            kDebugMode ? const Duration(minutes: 5) : const Duration(hours: 4),
      ),
    );

    await remoteConfig.setDefaults({
      'CONNECTION_TIMEOUT': 15,
    });

    await remoteConfig.fetchAndActivate();
  } catch (error) {}
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final client = ref.watch(GraphQLClientService().gqlClientProvider);
    final appTheme = AppTheme(context);
    return GraphQLProvider(
      client: client,
      child: CacheProvider(
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Demo OCR Camera',
          theme: appTheme.lightTheme(),
          darkTheme: appTheme.darkTheme(),
          home: HomePage(),
        ),
      ),
    );
  }
}
