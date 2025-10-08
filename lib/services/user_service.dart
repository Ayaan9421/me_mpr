import 'package:flutter_dotenv/flutter_dotenv.dart';

class UserService {
  final String fastAPIBackendEndpoint =
      dotenv.env['FASTAPI_BACKEND_ENDPOINT'] ?? 'http://localhost:8000';

  final String expressBackendEndpoint =
      dotenv.env['EXPRESS_BACKEND_ENDPOINT'] ?? 'http://localhost:9000';
}
