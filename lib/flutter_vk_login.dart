import 'dart:async';

import 'package:flutter/services.dart';

class FlutterVkLogin{
  static const MethodChannel channel =
      const MethodChannel("com.objresponse.fluttervklogin/vk_login");
  
  Future<bool> get isLoggedIn async => await currentAccessToken != null;

  Future<VKAccessToken> get currentAccessToken async {
    final Map<dynamic, dynamic> accessToken =
        await channel.invokeMethod('getCurrentAccessToken');

    if (accessToken == null) {
      return null;
    }

    return new VKAccessToken.fromMap(accessToken.cast<String, dynamic>());
  }

  Future<VkLoginResult> logIn(
    List<String> scope,
  ) async {
    final Map<dynamic, dynamic> result =
        await channel.invokeMethod('login', {
      'scope': scope,
    });

    return _deliverResult(
        new VkLoginResult._(result.cast<String, dynamic>()));
  }

  Future<void> logOut() async => channel.invokeMethod('logout');

  Future<T> _deliverResult<T>(T result) {
    return new Future.delayed(const Duration(milliseconds: 500), () => result);
  }
}

class VkLoginResult {
    final  VKLoginStatus status;
    final VKAccessToken token;
    final String errorMessage;

    VkLoginResult._(Map<String, dynamic> map)
    : status = _parseStatus(map['status']),
      token = map['accessToken'] != null ? new VKAccessToken.fromMap(map['accessToken']) : null,
      errorMessage = map['errorMessage'];

    static VKLoginStatus _parseStatus(String status) {
      switch (status) {
        case 'loggedIn':
          return VKLoginStatus.loggedIn;
        case 'cancelledByUser':
          return VKLoginStatus.cancelledByUser;
        case 'error':
          return VKLoginStatus.error;
      }
      throw new StateError('Invalid status: $status');
    }
}

enum VKLoginStatus {
  loggedIn,
  cancelledByUser,
  error,
}


class VKAccessToken{
  final String token;
  final DateTime expiresIn;
  final String userId;
  final String secret;
  final String email;
  final bool scope;

  VKAccessToken.fromMap (Map<dynamic, dynamic> map)
    : token = map['token'],
      expiresIn = new DateTime.fromMicrosecondsSinceEpoch(map['expiresIn'], isUtc: true),
      userId = map['userId'],
      secret = map['secret'],
      email = map['email'],
      scope = map['scope'];

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'token': token,
      'expiresIn': expiresIn.millisecondsSinceEpoch,
      'userId': userId,
      'secret': secret,
      'email': email,
      'scope': scope
    };
  
  }

  @override
  bool operator ==(Object other) => 
    identical(this, other) || other is VKAccessToken &&
      runtimeType == other.runtimeType &&
      token == other.token &&
      userId == other.userId &&
      expiresIn == other.expiresIn &&
      scope == other.scope;

  @override
  int get hashCode => 
    token.hashCode ^
    expiresIn.hashCode ^
    userId.hashCode ^
    secret.hashCode ^
    email.hashCode ^
    scope.hashCode;
}