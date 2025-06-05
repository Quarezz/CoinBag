enum AuthenticationStatus {
  unknown, // Initial status, or when status cannot be determined
  authenticated, // User is properly authenticated via backend
  unauthenticated, // User is not authenticated
  mockAuthenticated, // User is authenticated via mock/demo login
}
