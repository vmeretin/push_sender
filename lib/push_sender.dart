import 'package:dio/dio.dart';
import 'package:googleapis_auth/auth_io.dart';

class PushSender {
  final _httpClient = Dio();

  late final AutoRefreshingAuthClient _authClient;
  late final String _projectId;

  late String _accessToken;

  Options get _options => Options(
        contentType: 'application/json',
        headers: <String, dynamic>{
          'Authorization': 'Bearer $_accessToken',
        },
      );

  Future<void> init() async {
    _authClient = await clientViaApplicationDefaultCredentials(
      scopes: [
        'https://www.googleapis.com/auth/firebase.readonly',
        'https://www.googleapis.com/auth/firebase.messaging',
      ],
    );
    _accessToken = _getAccessToken(_authClient.credentials);

    _authClient.credentialUpdates.map(_getAccessToken).listen((accessToken) {
      _accessToken = accessToken;
    });

    _projectId = await _getProjectId();
  }

  ///Returns message ID
  Future<String?> send({
    required String token,
  }) async {
    final response = await _httpClient.post<Map<String, dynamic>>(
      'https://fcm.googleapis.com/v1/projects/$_projectId/messages:send',
      options: _options,
      data: <String, dynamic>{
        'message': <String, dynamic>{
          'token': token,
          'notification': <String, dynamic>{
            'title': 'Test title',
            'body': 'Test body',
          },
        },
      },
    );

    final data = response.data;
    if (data == null) {
      return null;
    }

    return (data['name'] as String).split('/').last;
  }

  Future<String> _getProjectId() async {
    final response = await _httpClient.get<Map<String, dynamic>>(
      'https://firebase.googleapis.com/v1beta1/projects',
      options: _options,
    );

    final results = response.data!['results'] as List<dynamic>;

    final firebaseProject = results.first as Map<String, dynamic>;

    return firebaseProject['projectId'] as String;
  }

  String _getAccessToken(AccessCredentials accessCredentials) => accessCredentials.accessToken.data;
}
