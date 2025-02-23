import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../services/providers/user_settings.dart';

class VoiceEngineScreen extends StatefulWidget {
  const VoiceEngineScreen({super.key});

  @override
  State<VoiceEngineScreen> createState() => _VoiceEngineScreenState();
}

class _VoiceEngineScreenState extends State<VoiceEngineScreen> {
  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<UserSettingsProvider>(context);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Voice Engine'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Choose the voice for your audio notifications while navigating',
              style: theme.textTheme.titleMedium
                  ?.copyWith(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 15),

            // Voice Selection Options
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                _voiceOption(
                  context,
                  mode: "male",
                  title: "Male Voice",
                  subtitle: "A husky male voice",
                  icon: Icons.person_4,
                  selected: settings.selectedVoice == "en-gb-x-gbb-local",
                  onTap: () {
                    settings.setSelectedVoice("en-gb-x-gbb-local");
                    settings.setSelectedLocale("en-GB");
                  },
                ),
                _voiceOption(
                  context,
                  mode: "female",
                  title: "Female Voice",
                  subtitle: "A soft female voice",
                  icon: Icons.person_2,
                  selected: settings.selectedVoice == "en-gb-x-gba-local",
                  onTap: () {
                    settings.setSelectedVoice("en-gb-x-gba-local");
                    settings.setSelectedLocale("en-GB");
                  },
                ),
                // _voiceOption(
                //   context,
                //   mode: "default",
                //   title: "Kawaii",
                //   subtitle: "UwU~",
                //   icon: LucideIcons.bot,
                //   selected: settings.selectedVoice == "ja-JP-x-jaa-local",
                //   onTap: () {
                //     settings.setSelectedVoice("ja-JP-x-jaa-local");
                //     settings.setSelectedLocale("ja-JP");
                //   },
                // ),
              ],
            ),

            const SizedBox(height: 24),

            // Volume Control
            Text(
              'Notification Volume',
              style: theme.textTheme.titleMedium
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Adjust the volume of your notifications.',
              style: theme.textTheme.bodyMedium
                  ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
            ),
            const SizedBox(height: 12),

            Slider(
              value: settings.voiceVolume,
              min: 0,
              max: 1,
              divisions: 10,
              label: "${(settings.voiceVolume * 100).toInt()}%",
              activeColor: theme.colorScheme.primary,
              onChanged: (newValue) => settings.setVoiceVolume(newValue),
            ),

            // Pitch Control
            // Volume Control
            Text(
              'Control Speech Rate',
              style: theme.textTheme.titleMedium
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Adjust the speech rate of your notifications.',
              style: theme.textTheme.bodyMedium
                  ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
            ),
            const SizedBox(height: 12),

            Slider(
              value: settings.speechRate,
              min: 0,
              max: 1,
              divisions: 10,
              label: "${(settings.speechRate * 100).toInt()}%",
              activeColor: theme.colorScheme.primary,
              onChanged: (newValue) => settings.setSpeechRate(newValue),
            ),
          ],
        ),
      ),
    );
  }

  Widget _voiceOption(
    BuildContext context, {
    required String mode,
    required String title,
    required String subtitle,
    required IconData icon,
    required bool selected,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: MediaQuery.of(context).size.width / 3.5,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: selected
              ? theme.colorScheme.primaryContainer
              : theme.colorScheme.surfaceVariant,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? theme.colorScheme.primary : Colors.transparent,
            width: 2,
          ),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: theme.colorScheme.primary.withOpacity(0.3),
                    blurRadius: 6,
                    offset: const Offset(0, 3),
                  ),
                ]
              : [],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon,
                size: 32,
                color: selected
                    ? theme.colorScheme.primary
                    : theme.colorScheme.onSurface),
            const SizedBox(height: 8),
            Text(
              title,
              style: theme.textTheme.bodyLarge
                  ?.copyWith(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall
                  ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
            ),
          ],
        ),
      ),
    );
  }
}
