import 'package:flutter/material.dart';

class Coach {
  const Coach({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.remoteConfigKey,
    this.systemInstruction = '',
  });

  final String id;
  final String name;
  final String description;
  final IconData icon;
  final String remoteConfigKey;
  final String systemInstruction;

  Coach copyWith({String? systemInstruction}) {
    return Coach(
      id: id,
      name: name,
      description: description,
      icon: icon,
      remoteConfigKey: remoteConfigKey,
      systemInstruction: systemInstruction ?? this.systemInstruction,
    );
  }
}
