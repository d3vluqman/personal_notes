// Login exceptions
class UserNotFound implements Exception {}
class WrongPassword implements Exception {}

// Register exceptions
class WeakPassword implements Exception {}
class EmailAlreadyInUse implements Exception {}
class InvalidEmail implements Exception {}

// Generic exceptions
class UserNotLoggedInAuthExeption implements Exception {}
