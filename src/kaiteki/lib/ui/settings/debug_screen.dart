import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:kaiteki/auth/login_functions.dart';
import 'package:kaiteki/di.dart';
import 'package:kaiteki/ui/onboarding/onboarding_screen.dart';
import 'package:kaiteki/utils/extensions.dart';
import 'package:url_launcher/url_launcher.dart';

class DebugScreen extends StatefulWidget {
  const DebugScreen({super.key});

  @override
  State<DebugScreen> createState() => _DebugScreenState();
}

class _DebugScreenState extends State<DebugScreen> {
  @override
  Widget build(BuildContext context) {
    final l10n = context.getL10n();

    return Scaffold(
      appBar: AppBar(title: Text(l10n.settingsDebugMaintenance)),
      body: Column(
        children: [
          const Material(
            elevation: 6,
            color: Colors.amberAccent,
            child: ListTile(
              leading: Icon(Icons.warning_rounded, color: Colors.black),
              title: Padding(
                padding: EdgeInsets.only(top: 8.0),
                child: Text(
                  "Proceed with caution",
                  style: TextStyle(color: Colors.black),
                ),
              ),
              subtitle: Padding(
                padding: EdgeInsets.only(bottom: 8.0),
                child: Text(
                  "Some settings might delete your user settings or have unintended behavior.",
                  style: TextStyle(color: Colors.black54),
                ),
              ),
              dense: true,
            ),
          ),
          ListTile(
            leading: const Icon(Icons.palette_rounded),
            title: const Text("Show theme"),
            onTap: () => context.push("/settings/debug/theme"),
          ),
          ListTile(
            leading: const Icon(Icons.key_rounded),
            title: const Text("Run OAuth Server"),
            onTap: () async => runOAuthServer(
              (u, _) => launchUrl(u),
              await generateOAuthLandingPage(Theme.of(context).colorScheme),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.waving_hand_rounded),
            title: const Text("Open onboarding"),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => const OnboardingScreen(),
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.feedback_rounded),
            title: const Text("Open exception dialog"),
            onTap: () async {
              try {
                throw Exception("Test exception");
              } catch (e, s) {
                await context.showExceptionDialog(e, s);
              }
            },
          ),
        ],
      ),
    );
  }
}
