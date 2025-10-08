import 'dart:io';
import 'package:path/path.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:me_mpr/auth/auth_gate.dart';
import 'package:me_mpr/failure/failure.dart';
import 'package:me_mpr/failure/user.dart';
import 'package:me_mpr/services/auth_service.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:fpdart/fpdart.dart';
import 'package:http/http.dart' as http;

class UserService {
  final String fastAPIBackendEndpoint =
      dotenv.env['FASTAPI_BACKEND_ENDPOINT'] ?? 'http://localhost:8000';

  final String expressBackendEndpoint =
      dotenv.env['EXPRESS_BACKEND_ENDPOINT'] ?? 'http://localhost:9000';

  Future<Either<AppFailure, UserResult>> createUser(
    String name,
    String phone,
    DateTime dob,
    File image, {
    isVerified = false,
  }) async {
    final token = await AuthService().getToken();
    print(token);

    var url = Uri.https(expressBackendEndpoint, "/create-user");

    var request = http.MultipartRequest("POST", url);

    request.files.add(
      await http.MultipartFile.fromPath(
        'image',
        image.path,
        filename: basename(image.path),
      ),
    );

    request.fields.addAll({
      'uid': token,
      'name': name,
      'phone': phone,
      'dob': dob.toString(),
    });

    request.headers.addAll({'Authorization': 'Bearer $token'});

    var response = await request.send();

    print(response);

    return Left(AppFailure("testing"));
  }

  Future<Either<AppFailure, VerificationResult>> verifyUser(
    String state,
    String licenseNo,
    String sdw,
    DateTime doi,
    DateTime validity,
  ) async {
    final token = await FirebaseAuth.instance.currentUser!.getIdToken();
    print(token);
    print("HIEEEEEEEEEEEEE");
    var url = Uri.https(fastAPIBackendEndpoint, '/verify-dl');
    var response = await http.post(
      url,
      body: {
        'state': state,
        'licenseNo': licenseNo,
        'sdw': sdw,
        'doi': doi,
        'validity': validity,
      },
      headers: {HttpHeaders.authorizationHeader: 'Bearer $token'},
    );
    print(response);
    return Left(AppFailure("testing"));
  }
}
