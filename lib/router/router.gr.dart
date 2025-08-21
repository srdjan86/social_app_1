// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AutoRouterGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:auto_route/auto_route.dart' as _i7;
import 'package:flutter/material.dart' as _i8;
import 'package:social_app_1/pages/create_post_page.dart' as _i1;
import 'package:social_app_1/pages/home_page.dart' as _i2;
import 'package:social_app_1/pages/initial_page.dart' as _i3;
import 'package:social_app_1/pages/login_page.dart' as _i4;
import 'package:social_app_1/pages/post_page.dart' as _i5;
import 'package:social_app_1/pages/sign_up_page.dart' as _i6;

/// generated route for
/// [_i1.CreatePostPage]
class CreatePostRoute extends _i7.PageRouteInfo<void> {
  const CreatePostRoute({List<_i7.PageRouteInfo>? children})
      : super(CreatePostRoute.name, initialChildren: children);

  static const String name = 'CreatePostRoute';

  static _i7.PageInfo page = _i7.PageInfo(
    name,
    builder: (data) {
      return const _i1.CreatePostPage();
    },
  );
}

/// generated route for
/// [_i2.HomePage]
class HomeRoute extends _i7.PageRouteInfo<void> {
  const HomeRoute({List<_i7.PageRouteInfo>? children})
      : super(HomeRoute.name, initialChildren: children);

  static const String name = 'HomeRoute';

  static _i7.PageInfo page = _i7.PageInfo(
    name,
    builder: (data) {
      return const _i2.HomePage();
    },
  );
}

/// generated route for
/// [_i3.InitialPage]
class InitialRoute extends _i7.PageRouteInfo<void> {
  const InitialRoute({List<_i7.PageRouteInfo>? children})
      : super(InitialRoute.name, initialChildren: children);

  static const String name = 'InitialRoute';

  static _i7.PageInfo page = _i7.PageInfo(
    name,
    builder: (data) {
      return const _i3.InitialPage();
    },
  );
}

/// generated route for
/// [_i4.LoginPage]
class LoginRoute extends _i7.PageRouteInfo<void> {
  const LoginRoute({List<_i7.PageRouteInfo>? children})
      : super(LoginRoute.name, initialChildren: children);

  static const String name = 'LoginRoute';

  static _i7.PageInfo page = _i7.PageInfo(
    name,
    builder: (data) {
      return const _i4.LoginPage();
    },
  );
}

/// generated route for
/// [_i5.PostPage]
class PostRoute extends _i7.PageRouteInfo<PostRouteArgs> {
  PostRoute({
    _i8.Key? key,
    required String postId,
    List<_i7.PageRouteInfo>? children,
  }) : super(
          PostRoute.name,
          args: PostRouteArgs(key: key, postId: postId),
          initialChildren: children,
        );

  static const String name = 'PostRoute';

  static _i7.PageInfo page = _i7.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<PostRouteArgs>();
      return _i5.PostPage(key: args.key, postId: args.postId);
    },
  );
}

class PostRouteArgs {
  const PostRouteArgs({this.key, required this.postId});

  final _i8.Key? key;

  final String postId;

  @override
  String toString() {
    return 'PostRouteArgs{key: $key, postId: $postId}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! PostRouteArgs) return false;
    return key == other.key && postId == other.postId;
  }

  @override
  int get hashCode => key.hashCode ^ postId.hashCode;
}

/// generated route for
/// [_i6.SignUpPage]
class SignUpRoute extends _i7.PageRouteInfo<void> {
  const SignUpRoute({List<_i7.PageRouteInfo>? children})
      : super(SignUpRoute.name, initialChildren: children);

  static const String name = 'SignUpRoute';

  static _i7.PageInfo page = _i7.PageInfo(
    name,
    builder: (data) {
      return const _i6.SignUpPage();
    },
  );
}
