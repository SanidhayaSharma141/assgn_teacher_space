part of 'auth_bloc.dart';

abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object> get props => [];
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthSignedUp extends AuthState {}

class AuthSignedIn extends AuthState {}

class AuthSignedOut extends AuthState {}

class AuthSignUpSuccess extends AuthState {}

class AuthEmailNotVerified extends AuthState {}

class AuthEmailVerificationSent extends AuthState {}

class AuthError extends AuthState {
  final String error;

  AuthError(this.error);

  @override
  List<Object> get props => [error];
}
