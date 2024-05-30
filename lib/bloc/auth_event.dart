part of 'auth_bloc.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object> get props => [];
}

class SignUpRequested extends AuthEvent {
  final String email;
  final String password;
  final BuildContext context;
  SignUpRequested(
      {required this.email, required this.password, required this.context});
}

class SignInRequested extends AuthEvent {
  final String email;
  final String password;
  final BuildContext context;

  SignInRequested(
      {required this.email, required this.password, required this.context});
}

class SignOutRequested extends AuthEvent {}

class SendVerificationEmailRequested extends AuthEvent {
  final String? email;
  final String? password;
  final BuildContext? context;
  SendVerificationEmailRequested(this.email, this.password, this.context);
}

class CheckEmailVerificationRequested extends AuthEvent {}
