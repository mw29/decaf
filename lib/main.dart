import 'package:beaverlog_flutter/beaverlog_flutter.dart';
import 'package:tapermind/constants/colors.dart';
import 'package:tapermind/pages/home.dart';
import 'package:tapermind/pages/onboarding_page.dart';
import 'package:tapermind/pages/plan_page.dart';
import 'package:tapermind/providers/settings_provider.dart';
import 'package:tapermind/secrets/secrets.dart';
import 'package:tapermind/widgets/add_medication_modal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

final pageIndexProvider = StateProvider<int>((ref) => 0);

void main() async {
  BeaverLog().init(
    appId: beaverlogAppId,
    publicKey: beaverlogPublicKey,
    host: 'https://beaverlog.deno.dev',
  );
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final base = ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.medication,
        brightness: Brightness.dark,
        surface: AppColors.surface,
      ).copyWith(
        surface: AppColors.surface,
        onSurface: Colors.white,
        primary: AppColors.medication,
        onPrimary: AppColors.background,
        secondary: AppColors.medication,
      ),
      useMaterial3: true,
      scaffoldBackgroundColor: AppColors.background,
    );
    return MaterialApp(
      title: 'TaperMind',
      theme: base.copyWith(
        textTheme: GoogleFonts.nunitoTextTheme(base.textTheme).apply(
          bodyColor: Colors.white,
          displayColor: Colors.white,
        ),
        cardTheme: base.cardTheme.copyWith(
          color: AppColors.surfaceCard,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(
              color: Colors.white.withValues(alpha: 0.07),
            ),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.medication,
            foregroundColor: AppColors.background,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            textStyle: GoogleFonts.nunito(
              fontWeight: FontWeight.w700,
              fontSize: 16,
            ),
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: AppColors.medication,
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.15)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.15)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.medication, width: 2),
          ),
          filled: true,
          fillColor: AppColors.surfaceCard,
          labelStyle: TextStyle(color: Colors.white.withValues(alpha: 0.5)),
          hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.3)),
        ),
        sliderTheme: SliderThemeData(
          activeTrackColor: AppColors.medication,
          thumbColor: AppColors.medication,
          inactiveTrackColor: AppColors.medication.withValues(alpha: 0.2),
          overlayColor: AppColors.medication.withValues(alpha: 0.1),
        ),
        chipTheme: ChipThemeData(
          backgroundColor: AppColors.surfaceCard,
          selectedColor: AppColors.medication,
          labelStyle: GoogleFonts.nunito(fontSize: 14, color: Colors.white),
          secondaryLabelStyle: GoogleFonts.nunito(
            fontSize: 14,
            color: AppColors.background,
            fontWeight: FontWeight.w600,
          ),
          side: BorderSide(color: Colors.white.withValues(alpha: 0.15)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: AppColors.background,
          elevation: 0,
          scrolledUnderElevation: 0,
          titleTextStyle: GoogleFonts.nunito(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
          iconTheme: const IconThemeData(color: Colors.white),
        ),
        bottomNavigationBarTheme: BottomNavigationBarThemeData(
          backgroundColor: AppColors.surface,
          selectedItemColor: AppColors.medication,
          unselectedItemColor: Colors.white.withValues(alpha: 0.4),
        ),
        bottomAppBarTheme: const BottomAppBarThemeData(
          color: AppColors.surface,
        ),
        dialogTheme: DialogThemeData(
          backgroundColor: AppColors.surfaceCard,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        dividerColor: Colors.white.withValues(alpha: 0.08),
        iconTheme: IconThemeData(color: Colors.white.withValues(alpha: 0.7)),
      ),
      themeMode: ThemeMode.dark,
      home: const AppRoot(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class AppRoot extends ConsumerWidget {
  const AppRoot({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settingsAsync = ref.watch(settingsProvider);
    return settingsAsync.when(
      data: (settings) {
        if (!settings.onboardingComplete) {
          return const OnboardingPage();
        }
        return const MainScreen();
      },
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (_, __) => const MainScreen(),
    );
  }
}

class MainScreen extends ConsumerWidget {
  const MainScreen({super.key});

  final List<Widget> _pages = const [HomePage(), PlanPage()];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedIndex = ref.watch(pageIndexProvider);

    return Scaffold(
      body: IndexedStack(index: selectedIndex, children: _pages),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            builder: (context) => const AddMedicationModal(),
          );
        },
        child: const Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 8.0,
        child: Wrap(
          children: [
            Theme(
              data: ThemeData(splashColor: Colors.transparent),
              child: BottomNavigationBar(
                backgroundColor: Colors.transparent,
                elevation: 0,
                currentIndex: selectedIndex,
                onTap:
                    (index) =>
                        ref.read(pageIndexProvider.notifier).state = index,
                type: BottomNavigationBarType.fixed,
                items: const [
                  BottomNavigationBarItem(
                    icon: Icon(Icons.home),
                    label: 'Home',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.calendar_month),
                    label: 'Plan',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
