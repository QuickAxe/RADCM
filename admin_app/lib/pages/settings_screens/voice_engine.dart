import 'dart:developer' as dev;

import 'package:admin_app/services/tts_service.dart';
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
    dev.log(settings.selectedVoice);

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
            SwitchListTile(
              title: const Text("Enable Voice Notifications"),
              value: settings.voiceEnabled,
              onChanged: (value) => settings.toggleVoiceEnabled(),
            ),
            const SizedBox(height: 15),
            Opacity(
              opacity: settings.voiceEnabled ? 1.0 : 0.5,
              child: AbsorbPointer(
                absorbing: settings.voiceEnabled == false,
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
                          selected:
                              settings.selectedVoice == "en-gb-x-gbb-local",
                          onTap: () {
                            settings.setSelectedVoice("en-gb-x-gbb-local");
                            settings.setSelectedLocale("en-GB");
                            TtsService(settings).speak(
                              "Got it. I'll watch for road anomalies and guide you with turn-by-turn directions.",
                            );
                          },
                        ),
                        _voiceOption(
                          context,
                          mode: "female",
                          title: "Female Voice",
                          subtitle: "A soft female voice",
                          icon: Icons.person_2,
                          selected:
                              settings.selectedVoice == "en-gb-x-gba-local",
                          onTap: () {
                            settings.setSelectedVoice("en-gb-x-gba-local");
                            settings.setSelectedLocale("en-GB");
                            TtsService(settings).speak(
                                "Alright! I’ll watch out for anomalies and guide you with turn-by-turn directions.");
                          },
                        ),
                      ],
                    ),

                    const SizedBox(height: 30),
                    _sliderWithText(
                      context,
                      title: "Notification Volume",
                      description: "Adjust the volume of your notifications.",
                      value: settings.voiceVolume,
                      min: 0,
                      max: 1,
                      onChanged: (newValue) =>
                          settings.setVoiceVolume(newValue),
                      onChangeEnd: (newValue) => TtsService(settings).speak(
                          "The volume is now at ${(newValue * 100).toInt()}%"),
                    ),
                    const SizedBox(height: 24),
                    _sliderWithText(
                      context,
                      title: "Control Speech Rate",
                      description:
                          "Adjust the speech rate of your notifications.",
                      value: settings.speechRate,
                      min: 0,
                      max: 1,
                      onChanged: (newValue) => settings.setSpeechRate(newValue),
                      onChangeEnd: (newValue) => TtsService(settings)
                          .speak("This is how fast I'll speak!"),
                    ),
                  ],
                ),
              ),
            )
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

  Widget _sliderWithText(
    BuildContext context, {
    required String title,
    required String description,
    required double value,
    required double min,
    required double max,
    required ValueChanged<double> onChanged,
    required ValueChanged<double> onChangeEnd,
  }) {
    final theme = Theme.of(context);
    final settings = Provider.of<UserSettingsProvider>(context, listen: false);
    final ttsService = TtsService(settings);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: theme.textTheme.titleMedium
              ?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(
          description,
          style: theme.textTheme.bodyMedium
              ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
        ),
        const SizedBox(height: 12),
        Slider(
          value: value,
          min: min,
          max: max,
          divisions: 10,
          label: "${(value * 100).toInt()}%",
          activeColor: theme.colorScheme.primary,
          onChanged: onChanged,
          onChangeEnd: onChangeEnd,
        ),
      ],
    );
  }
}
