enum AuthResult {
  success,
  cancelled,
  failed
}

enum AuthStatus {
  authenticating,
  failure,
  success,
  canceled;

  String message([int retryCount = 0, int maxRetries = 3]) {
    switch (this) {
      case AuthStatus.authenticating:
        return "Authenticating...";
      case AuthStatus.failure:
        return "Failure $retryCount/$maxRetries, ${retryCount >= maxRetries ? 'cancelling...' : 'try again'}.";
      case AuthStatus.success:
        return "Success!";
      case AuthStatus.canceled:
        return "Canceled.";
    }
  }
}