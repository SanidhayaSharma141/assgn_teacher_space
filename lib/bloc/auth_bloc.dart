import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:teacher_space/auth/auth.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository _authRepository;

  AuthBloc(this._authRepository) : super(AuthInitial()) {
    on<SignUpRequested>((event, emit) async {
      emit(AuthLoading());
      try {
        await _authRepository.signUp(
            email: event.email,
            password: event.password,
            context: event.context);
        emit(AuthSignUpSuccess());
      } catch (e) {
        emit(AuthError(e.toString()));
        ScaffoldMessenger.of(event.context)
            .showSnackBar(SnackBar(content: Text(e.toString())));
      }
    });

    on<SignInRequested>((event, emit) async {
      emit(AuthLoading());
      try {
        final x = await _authRepository.signIn(
            email: event.email, password: event.password);
        if (x) {
          emit(AuthSignedIn());
        } else {
          ScaffoldMessenger.of(event.context).showSnackBar(
              SnackBar(content: Text("Verify the email to log in")));
          emit(AuthEmailNotVerified());
        }
      } catch (e) {
        emit(AuthError(e.toString()));
        ScaffoldMessenger.of(event.context)
            .showSnackBar(SnackBar(content: Text(e.toString())));
      }
    });

    on<SignOutRequested>((event, emit) async {
      emit(AuthLoading());
      try {
        await _authRepository.signOut();
        emit(AuthSignedOut());
      } catch (e) {
        emit(AuthError(e.toString()));
      }
    });

    on<SendVerificationEmailRequested>((event, emit) async {
      emit(AuthLoading());
      try {
        if (event.email != null && event.password != null) {
          await FirebaseAuth.instance.signInWithEmailAndPassword(
              email: event.email!, password: event.password!);
          if (FirebaseAuth.instance.currentUser == null) {
            ScaffoldMessenger.of(event.context!).showSnackBar(
                SnackBar(content: Text("Enter correct credentials")));
            return;
          }
        }
        await _authRepository.sendVerificationEmail();
        emit(AuthEmailVerificationSent());
        if (event.email != null && event.password != null) {
          await FirebaseAuth.instance.signOut();
          ScaffoldMessenger.of(event.context!)
              .showSnackBar(SnackBar(content: Text("Email sent successfully")));
        }
      } catch (e) {
        emit(AuthError(e.toString()));
        ScaffoldMessenger.of(event.context!)
            .showSnackBar(SnackBar(content: Text(e.toString())));
      }
    });

    on<CheckEmailVerificationRequested>((event, emit) async {
      emit(AuthLoading());
      try {
        bool isVerified = await _authRepository.isEmailVerified();
        if (isVerified) {
          emit(AuthSignedIn());
        } else {
          emit(AuthEmailNotVerified());
        }
      } catch (e) {
        emit(AuthError(e.toString()));
      }
    });
  }
}
