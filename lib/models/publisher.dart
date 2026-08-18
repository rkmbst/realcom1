import 'package:flutter/material.dart';

class Publisher {
  final String id;
  final String name;
  final String handle;
  final Color accentColor;

  const Publisher({
    required this.id,
    required this.name,
    required this.handle,
    required this.accentColor,
  });

  factory Publisher.fromUser(
    dynamic user, {
    Color? accentColor,
  }) {
    return Publisher(
      id: user.id as String,
      name: user.displayName as String,
      handle: user.username as String,
      accentColor: accentColor ?? const Color(0xFF6750A4),
    );
  }
}
