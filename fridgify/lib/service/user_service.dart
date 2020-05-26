import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:fridgify/data/repository.dart';
import 'package:fridgify/exception/failed_to_fetch_content_exception.dart';
import 'package:fridgify/exception/failed_to_fetch_qr_exception.dart';
import 'package:fridgify/exception/failed_to_patch_user_exception.dart';
import 'package:fridgify/model/fridge.dart';
import 'package:fridgify/model/user.dart';
import 'package:http/http.dart';
import 'package:fridgify/model/user.dart';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fridgify/utils/permission_helper.dart';

class UserService {
  static const String userApi = "${Repository.baseURL}users/";
  static const String userManagementApi = "${Repository.baseURL}fridge/management/";

  Dio dio;

  User user;

  Logger logger = Logger();

  SharedPreferences sharedPreferences = Repository.sharedPreferences;

  static final UserService _userService = UserService._internal();

  factory UserService([Dio dio]) {
    _userService.dio = Repository.getDio(dio);
    return _userService;
  }

  UserService._internal();

  Future<User> fetchUser() async {
    logger.i('UserService => FETCHING USER FROM URL: $userApi');

    var response = await dio.get(userApi, options: Options(
      headers: Repository.getHeaders())
    );

    logger.i('UserService => FETCHING USER DATA: ${response.data}');

    if (response.statusCode == 200) {
      var user = response.data;
      User u = User.newUser(
          username: user['username'],
          password: user['password'],
          name: user['name'],
          surname: user['surname'],
          email: user['email'],
          birthDate: user['birth_date']);

      this.user = u;

      logger.i('UserService => $user');

      return this.user;
    }
    throw new FailedToFetchContentException();
  }

  User get() {
    return this.user;
  }

  Future<User> update(User user, String parameter, dynamic attribute) async {
    logger.i(
        'UserService => UPDATING $parameter with $attribute FROM URL: $userApi');

    var response = await dio.patch(userApi,
        data: jsonEncode({parameter: attribute}),
        options: Options(
          headers: Repository.getHeaders())
    );

    logger.i('UserService => PATCHING USER: ${response.statusCode}');

    if (response.statusCode == 200) {
      var us = response.data;
      logger.i('UserService => UPDATED SUCCESSFUL $user');

      User u = User.newUser(
          username: us['username'],
          password: user.password,
          name: us['name'],
          surname: us['surname'],
          email: us['email'],
          birthDate: us['birth_date']);

      this.user = u;
      return u;
    }
    throw new FailedToFetchContentException();
  }

  Future<Map<String, bool>> checkUsernameEmail(String user, String mail) async {

    logger.i(
        'UserService => CHECKING IF $user and $mail ARE UNIQUE FROM URL: ${userApi}duplicate/');

    var response = await dio.post("${userApi}duplicate/",
        data: jsonEncode({
          "username": user,
          "email": mail
        }),
        options: Options(
            headers: {"Content-Type": "application/json"})
    );

    logger.i('UserService => CHECKING FOR DUPLICATE USER: ${response.data}');
    Map<String, dynamic> res = response.data;

    if (response.statusCode == 200) {
      logger.i('UserService => EMAIL USER UNIQUE ${response.data}');
      return {"user": false, "mail": false};
    }

    return {"user": res.containsKey('username'), "mail": res.containsKey('email')};

  }

  Future<String> patchUser(Fridge f, User u, int role) async {

    var userUrl = "$userManagementApi${f.fridgeId}/users/${u.userId}/";

    logger.i("UserService => PATCHING USER ${u.username} FOR FRIDGE ${f.fridgeId} NEW ROLE $role URL $userUrl");

    var response = await dio.patch(userUrl, options: Options(headers: Repository.getHeaders()), data: jsonEncode({"role": role}));

    logger.i('UserService => PATCHED USER ${response.data}');

    if(response.statusCode == 200) {
      return response.data['role'];
    }

    throw FailedToPatchUserException();

  }

  Future<bool> kickUser(Fridge f, User u) async {

    var userUrl = "$userManagementApi${f.fridgeId}/users/${u.userId}/";

    logger.i("UserService => REMOVING USER ${u.username} FOR FRIDGE ${f.fridgeId} URL $userUrl");

    var response = await dio.delete(userUrl, options: Options(headers: Repository.getHeaders()),);

    logger.i('UserService => REMOVED USER ${response.data}');

    if(response.statusCode == 200) {
      return true;
    }

    throw FailedToPatchUserException();

  }

  Future<String> fetchDeepLink(Fridge f) async {
    var fridgeUrl = "$userManagementApi/${f.fridgeId}/qr-code";

    logger.i("UserService => FETCHIGN QR FROM $fridgeUrl");

    var response = await dio.get(fridgeUrl, options: Options(headers: Repository.getHeaders()));


    logger.i("UserService => RESPONSE FROM ${response.data}");

    if(response.statusCode == 201) {
      return response.data["dynamic_link"];
    }

    throw FailedToFetchQrException();

  }
}
