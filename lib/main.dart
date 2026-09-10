// Main App Entry Point

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'src/core/theme/cipherpoint_theme.dart';
import 'src/app/router.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Preload fonts
  GoogleFonts.config.allowRuntimeFetching = false;

  runApp(const ProviderScope(child: CipherPointApp()));
}

class CipherPointApp extends ConsumerWidget {
  const CipherPointApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    final theme = createCipherPointTheme();

    return MaterialApp.router(
      title: 'CipherPoint',
      debugShowCheckedModeBanner: false,
      theme: theme,
      darkTheme: theme,
      themeMode: ThemeMode.dark,
      routerConfig: router,
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaler: TextScaler.linear(
              MediaQuery.of(context).textScaler.scale(1.0).clamp(0.85, 1.15),
            ),
          ),
          child: child!,
        );
      },
    );
  }
}
