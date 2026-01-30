import '../models/user.dart';

class AuthState {
  final bool isLoading;
  final String? errorMessage;
  final User? user;

  const AuthState({
    this.isLoading = false,
    this.errorMessage,
    this.user,
  });

  // Check if the user is authenticated
  bool get isAuthenticated => user != null;
  
  //function to copy the state with new values
  AuthState copyWith({ bool? isLoading, String? errorMessage, User? user,})
    {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      user: user ?? this.user,
    );
  }
}
