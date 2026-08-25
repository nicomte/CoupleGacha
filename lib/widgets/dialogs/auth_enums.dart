enum AuthResult {
  success,
  cancelled,
  failed
}

enum AuthStatus {
  waiting("Waiting for authentication..."),
  attempting("Authentication in progress..."),
  failure1("Failure 1/3, try again."),
  failure2("Failure 2/3, try again."),
  failure3("Failure 3/3, Cancelling."),
  canceled("Canceled.");

  const AuthStatus(this.message);
  final String message;
}