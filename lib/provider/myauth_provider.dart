import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
class MyAuthProvider extends ChangeNotifier{
     String? _user ;
     String? get user => _user;
     final _auth = FirebaseAuth.instance;
     Future<void> login(String email,String password) async{
        final cd = await _auth.signInWithEmailAndPassword(email: email, password: password);
        _user = cd.user!.uid;
         notifyListeners();
     }
     Future<void> register(String email,String password) async{
        final cd = await _auth.createUserWithEmailAndPassword(email: email, password: password);
        _user = cd.user!.uid;
        notifyListeners();
     }
     Future<void> logout()async{
         await _auth.signOut();
         _user = null;
         notifyListeners();
     }
}