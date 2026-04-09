import 'package:tapermind/pages/manage_medication_options.dart';
import 'package:tapermind/pages/manage_symptoms_page.dart';
import 'package:tapermind/providers/caffeine_options_provider.dart';
import 'package:tapermind/providers/symptoms_provider.dart';
import 'package:tapermind/utils/analytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tapermind/providers/events_provider.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:url_launcher/url_launcher.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.refresh),
            title: const Text('Reset Account'),
            onTap: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: const Text('Confirm Reset'),
                    content: const Text(
                      'Are you sure you want to reset your account? This action cannot be undone.',
                    ),
                    actions: <Widget>[
                      TextButton(
                        child: const Text('Cancel'),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      ),
                      TextButton(
                        child: const Text('Reset'),
                        onPressed: () async {
                          Analytics.track(AnalyticsEvent.resetAccount);
                          // Clear all user events
                          await ref.read(eventsProvider.notifier).clearAllEvents();
                          
                          // Reset medication options and symptoms to their default state
                          // This will re-enable default options and disable extras
                          final caffeineNotifier = ref.read(medicationOptionsProvider.notifier);
                          final symptomsNotifier = ref.read(symptomsProvider.notifier);

                          await caffeineNotifier.resetToDefaults();
                          await symptomsNotifier.resetToDefaults();
                          
                          Navigator.of(context).pop(); // Close the dialog
                        },
                      ),
                    ],
                  );
                },
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.medication),
            title: const Text('Manage Medication Options'),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const ManageMedicationOptionsPage(),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.medical_services),
            title: const Text('Manage Symptoms'),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const ManageSymptomsPage(),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.privacy_tip),
            title: const Text('Privacy Policy'),
            onTap: () async {
              final Uri url = Uri.parse('https://apphelion.dev/apps/decaf/privacy_policy');
              if (await canLaunchUrl(url)) {
                await launchUrl(url);
              }
            },
          ),
          ListTile(
            leading: const Icon(Icons.favorite),
            title: const Text('Leave us a Review'),
            onTap: () async {
              Analytics.track(AnalyticsEvent.requestAppReview);
              final InAppReview inAppReview = InAppReview.instance;
              
              if (await inAppReview.isAvailable()) {
                inAppReview.requestReview();
              } else {
                inAppReview.openStoreListing();
              }
            },
          ),
          ListTile(
            leading: const Icon(Icons.star),
            title: const Text('Star TaperMind on Github'),
            onTap: () async {
              final Uri url = Uri.parse('https://github.com/drg101/decaf');
              if (await canLaunchUrl(url)) {
                await launchUrl(url);
              }
            },
          ),
        ],
      ),
    );
  }
}
