import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_gemma/flutter_gemma.dart';
import 'package:google_fonts/google_fonts.dart';
import 'features/sticker/presentation/dashboard_screen.dart';
import 'features/onboarding/onboarding_screen.dart';
import 'core/settings/ai_mode_settings.dart';

/// The entry point of the application.
///
/// Initializes FlutterGemma for on-device AI support and runs the app.
void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize FlutterGemma with HuggingFace token for gated models
  const token = String.fromEnvironment('HUGGINGFACE_TOKEN');
  FlutterGemma.initialize(
    huggingFaceToken: token.isNotEmpty ? token : null,
    maxDownloadRetries: 10,
  );

  runApp(const ProviderScope(child: MyApp()));
}

/// The root widget of the application.
///
/// Sets up the [MaterialApp] with the application theme and routes.
/// On first launch, shows onboarding screen for AI mode selection.
class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Custom brand color: rgb(47,60,84)
    const brandColor = Color.fromRGBO(47, 60, 84, 1.0);

    return MaterialApp(
      title: 'StickerSense',
      // Light Theme
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: brandColor,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        textTheme: GoogleFonts.quicksandTextTheme(ThemeData.light().textTheme),
      ),
      // Dark Theme
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: brandColor,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
        textTheme: GoogleFonts.quicksandTextTheme(ThemeData.dark().textTheme),
      ),
      themeMode: ThemeMode.system, // Follow system theme
      home: const InitialScreen(),
      routes: {
        '/dashboard': (context) => const DashboardScreen(),
        '/onboarding': (context) => const OnboardingScreen(),
      },
    );
  }
}

/// Initial screen that checks first-run status and routes accordingly.
class InitialScreen extends StatefulWidget {
  const InitialScreen({super.key});

  @override
  State<InitialScreen> createState() => _InitialScreenState();
}

class _InitialScreenState extends State<InitialScreen> {
  @override
  void initState() {
    super.initState();
    _checkFirstRun();
  }

  /// Checks if this is the first app launch and navigates accordingly.
  Future<void> _checkFirstRun() async {
    final aiModeSettings = AIModeSettings();
    final isFirstRun = await aiModeSettings.isFirstRun();

    if (mounted) {
      if (isFirstRun) {
        Navigator.of(context).pushReplacementNamed('/onboarding');
      } else {
        Navigator.of(context).pushReplacementNamed('/dashboard');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Show loading indicator while checking first-run status
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}
