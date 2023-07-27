import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:personalnotes/services/auth/auth_exceptions.dart';
import 'package:personalnotes/services/auth/auth_provider.dart';
import 'package:personalnotes/services/auth/auth_user.dart';

void main() {
  group("Mock Authentication", () {
    final provider = MockAuthProvider();
    test("Should not be initialized to begin with", () {
      expect(provider.isInitialized, false);
    });

    test("Can't log out if not initialized", () {
      expect(
        provider.logOut(),
        throwsA(const TypeMatcher<NotInitializedException>()),
      );
    });

    test("Should be able to initialize", () async {
      await provider.initialize();
      expect(provider.isInitialized, true);
    });

    test("User should be null after initialization", () {
      expect(provider.currentUser, null);
    });

    test(
      "Should initialize in less than 2 sec",
      () async {
        await provider.initialize();
        expect(provider.isInitialized, true);
      },
      timeout: const Timeout(Duration(seconds: 2)),
    );

    test("Create user should delegate to login function", () async {
      final badEmailUser = provider.createUser(
        email: "john@doe.com",
        password: "password",
      );
      expect(badEmailUser,
          throwsA(const TypeMatcher<UserNotFoundAuthException>()));
      final user = await provider.createUser(
        email: "john",
        password: "doe",
      );
      expect(provider.currentUser, user);
      expect(user.isEmailVerified, false);
    });

    test("Logged in user should be able to get verified", () {
      provider.sendEmailVerification();
      final user = provider.currentUser;
      expect(user, isNotNull);
      expect(user!.isEmailVerified, true);
    });

    test("SHould be able to logout and login again", () async {
      await provider.logOut();
      await provider.logIn(
        email: "email",
        password: "password",
      );
      final user = provider.currentUser;
      expect(user, isNotNull);
    });
  });
}

class NotInitializedException implements Exception {}

class MockAuthProvider implements AuthProvider {
  AuthUser? _user;
  var _isInitialized = false;
  bool get isInitialized => _isInitialized;

  @override
  Future<AuthUser> createUser({
    required String email,
    required String password,
  }) {
    if (!isInitialized) throw NotInitializedException();
    Future.delayed(const Duration(seconds: 1));
    return logIn(
      email: email,
      password: password,
    );
  }

  @override
  AuthUser? get currentUser => _user;

  @override
  Future<void> initialize() async {
    await Future.delayed(const Duration(seconds: 1));
    _isInitialized = true;
  }

  @override
  Future<AuthUser> logIn({
    required String email,
    required String password,
  }) {
    if (!isInitialized) throw NotInitializedException();
    if (email == "john@doe.com") throw UserNotFoundAuthException();
    if (password == "johndoe") throw WrongPasswordAuthException();
    const user = AuthUser(isEmailVerified: false);
    _user = user;
    return Future.value(user);
  }

  @override
  Future<void> logOut() async {
    if (!isInitialized) throw NotInitializedException();
    if (_user == null) throw UserNotFoundAuthException();
    await Future.delayed(const Duration(seconds: 1));
    _user = null;
  }

  @override
  Future<void> sendEmailVerification() async {
    if (!isInitialized) throw NotInitializedException();
    final user = _user;
    if (_user == null) throw UserNotFoundAuthException();
    const newUser = AuthUser(isEmailVerified: true);
    _user = newUser;
  }
}
