import 'dart:async';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/common/error_text.dart';
import '../../../main.dart';
import '../../../models/user_model.dart';
import '../../video_call/home.dart';
import '../repository/auth_repository.dart';
import '../screens/signin.dart';


final userProvider = StateProvider<UserModel?>((ref) {
  return ;
});

final authControllerProvider = StateNotifierProvider<AuthController, bool>(
        (ref)=> AuthController(
        authRepository: ref.read(authRepositoryProvider),
        ref: ref
    ));


final getUserDataProvider = StreamProvider.family.autoDispose((ref,String uid) {
  final authController = ref.watch(authControllerProvider.notifier);
  return authController.getUserData(uid);
});

final getUsersProvider = FutureProvider.autoDispose<List<UserModel>>((ref) async {
  final authRepository = ref.watch(authRepositoryProvider);
  return await authRepository.getUsers();
});

class AuthController extends StateNotifier<bool>{
  final AuthRepository _authRepository;
  final Ref _ref;

  AuthController({required AuthRepository authRepository,required Ref ref})
      :_authRepository= authRepository,
        _ref= ref,
        super(false);

  Future<List<UserModel>> getUsers() async {
    try {
      final users = await _authRepository.getUsers();
      return users;
    } catch (e) {
      log("Error loading users: $e");
      rethrow;
    }
  }

  Future<void> signinUsingEmailPassWord(BuildContext context,String email,String password) async {
    print('controller');
    final user = await _authRepository.signinUsingEmailPassWord(email,password);
    log('vvvvvv');
    log(user.toString());

    user.fold(
            (l) => ErrorText(error: l.message),
            (r) async {
          UserModel userData = r as UserModel;
          // UserModel userData= await getUserData(user.uid).first;
          _ref.watch(userProvider.notifier).update((state) => userData);

          final SharedPreferences prefs =await SharedPreferences.getInstance();
          prefs.setString('userId',userData.userId.toString());
          navigatorKey.currentState?.pushAndRemoveUntil(MaterialPageRoute(builder: (context)=>const MyHomePage()), (route) => false);

        }
    );
  }

  Future<void> signOut(BuildContext context) async {
    log('controlller start');
    _ref.watch(authRepositoryProvider).signOut()
        .whenComplete(() async {
      Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => SignIn(),), (route) => false);
    });
  }


  Stream<UserModel> getUserData(String uid){
    return _authRepository.getUserData(uid);
  }

  keepLogin(WidgetRef ref,BuildContext context) async {

    final uId=await _authRepository.keepLogin();
    log(' auth controller :$uId');
    if(uId!=''){
      log('1111');
      UserModel userModel =await ref.watch(authControllerProvider.notifier).getUserData(uId).first;

      if(userModel.userId!=null){

        log('2222');
        ref.read(userProvider.notifier).update((state) => userModel);
        log('user found');
        Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context)=>const MyHomePage()), (route) => false);
      }
    }else{
      log('3333');
      log('user not found');
      Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context)=>SignIn()), (route) => false);

    }


  }

}