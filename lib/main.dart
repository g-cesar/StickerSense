import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'features/sticker/presentation/dashboard_screen.dart';

/// The entry point of the application.
///
/// It initializes the [ProviderScope] for Riverpod and runs the [MyApp] widget.
void main() {
  runApp(const ProviderScope(child: MyApp()));
}

/// The root widget of the application.
///
/// Sets up the [MaterialApp] with the application theme and the initial route.
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'StickerSense',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const DashboardScreen(),
    );
  }
}
