import 'dart:convert';
import 'dart:developer';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:hive_ce_flutter/adapters.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/failure.dart';
import '../../../core/type_dets.dart';
import '../../../models/user_model.dart';

final authRepositoryProvider = Provider((ref) => AuthRepository());

class AuthRepository {
  List<UserModel>? _userCache;
  Box<UserModel> get _usersBox => Hive.box<UserModel>('users');
  Future<List<UserModel>> getUsers() async {
    if (_usersBox.isNotEmpty) {
      return _usersBox.values.toList();
    }
    final String data = await rootBundle.loadString('assets/json_files/users_list.json');
    final List<dynamic> jsonResult = jsonDecode(data);
    List<UserModel> users = jsonResult.map((e) => UserModel.fromJson(e)).toList();
    await _usersBox.clear();
    await _usersBox.putAll({
      for (var user in users) user.userId: user,
    });

    return users;
  }
  Future<List<UserModel>> loadUsers() async {
    if (_userCache != null) return _userCache!;
    final String data = await rootBundle.loadString('assets/json_files/users_list.json');
    final List<dynamic> jsonResult = jsonDecode(data);
    _userCache = jsonResult.map((e) => UserModel.fromJson(e)).toList();
    print(_userCache);
    return _userCache!;
  }

  Future<void> signOut() async {
    final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
    final SharedPreferences prefs = await _prefs;
    prefs.clear();
  }

  FutureEither<UserModel> signinUsingEmailPassWord(String email, String password) async {
    try {
      log('lod');
      final users = await loadUsers();
      print('111');
      final user = users.where(
            (u) => u.email == email && u.password == password,
      ).toList();
      print('222');
      if (user.isEmpty) {
        print('33');
        return left(Failure('Invalid email or password'));
      }
      print('444');
      final foundUser = user.first;
      print(foundUser);
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('userId', foundUser.userId);
      return right(foundUser);
    } catch (e) {
      print('repo bug');
      return left(Failure(e.toString()));
    }
  }

  Stream<UserModel> getUserData(String uid) async* {
    final users = await loadUsers();
    final user = users.where((u) => u.userId == uid).toList();
    if (user.isNotEmpty) {
      yield user.first;
    }
  }

  Future<String> keepLogin() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String uid = prefs.getString('userId') ?? "";
    log('Current uid: $uid');
    return uid;
  }
}
