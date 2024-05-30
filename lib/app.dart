import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:teacher_space/auth/auth.dart';
import 'package:teacher_space/bloc/auth_bloc.dart';
import 'package:teacher_space/home_screen.dart';
import 'package:teacher_space/login_screen.dart';

class MyApp extends StatelessWidget {
  final AuthRepository _authRepository = AuthRepository();

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(
          create: (context) => AuthBloc(_authRepository),
        ),
      ],
      child: MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Flutter Firebase App',
          theme: ThemeData.dark().copyWith(
            scaffoldBackgroundColor: Color.fromRGBO(16, 13, 34, 1),
          ),
          home: BlocBuilder<AuthBloc, AuthState>(
            builder: (context, state) {
              if (FirebaseAuth.instance.currentUser != null &&
                  !FirebaseAuth.instance.currentUser!.emailVerified) {
                FirebaseAuth.instance.signOut();
              }
              if (state is AuthSignedIn ||
                  FirebaseAuth.instance.currentUser != null) {
                return HomeScreen();
              }
              return LoginScreen();
            },
          )),
    );
  }
}
