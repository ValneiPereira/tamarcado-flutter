import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp();
  } catch (_) {
    // Firebase não configurado (ex.: google-services.json ausente) — app segue sem push
  }

  runApp(
    const ProviderScope(
      child: TamarcadoApp(),
    ),
  );
}
