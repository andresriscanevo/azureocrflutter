import 'package:firebase_remote_config/firebase_remote_config.dart';

class RemoteConfig {
  static final hasuraHostName =
      FirebaseRemoteConfig.instance.getString('HASURA_HOST_NAME');
  static final loginEndpoint =
      FirebaseRemoteConfig.instance.getString('LOGIN_ENDPOINT');
  static final registerEndpoint =
      FirebaseRemoteConfig.instance.getString('REGISTER_ENDPOINT');
  static final tokensEnpoint =
      FirebaseRemoteConfig.instance.getString('TOKENS_ENDPOINT');
  static final appOrigin =
      FirebaseRemoteConfig.instance.getString('APP_ORIGIN');
  static final connectionTimeout =
      FirebaseRemoteConfig.instance.getInt('CONNECTION_TIMEOUT');
  static final changePasswordEndpoint =
      FirebaseRemoteConfig.instance.getString('CHANGE_PASSWORD');
  static final forgotPasswordEndpoint =
      FirebaseRemoteConfig.instance.getString('FORGOT_PASSWORD');
  static final adminSecretHasura =
      FirebaseRemoteConfig.instance.getString('HASURA_ADMIN_SECRET');
}
