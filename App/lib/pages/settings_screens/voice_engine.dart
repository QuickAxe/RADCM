import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
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
            const Text(
              'Choose the voice for your audio notifications while navigating',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 15),

            // Voice Selection Options
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _voiceOption(
                  context,
                  mode: "male",
                  title: "Male Voice",
                  subtitle: "A husky male voice",
                  icon: Icons.person_4,
                  selected: settings.selectedVoice == "male",
                  onTap: () => settings.setSelectedVoice("male"),
                ),
                _voiceOption(
                  context,
                  mode: "female",
                  title: "Female Voice",
                  subtitle: "A soft female voice",
                  icon: Icons.person_2,
                  selected: settings.selectedVoice == "female",
                  onTap: () => settings.setSelectedVoice("female"),
                ),
                _voiceOption(
                  context,
                  mode: "default",
                  title: "Default Voice",
                  subtitle: "Electronic Robo Voice",
                  icon: LucideIcons.bot,
                  selected: settings.selectedVoice == "default",
                  onTap: () => settings.setSelectedVoice("default"),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Volume Control
            const Text(
              'Notification Volume',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Adjust the volume of your notifications.',
              style: TextStyle(fontSize: 14, color: Colors.black54),
            ),
            const SizedBox(height: 12),

            Slider(
              value: settings.voiceVolume,
              min: 0,
              max: 1,
              divisions: 10,
              label: "${(settings.voiceVolume * 100).toInt()}%",
              activeColor: Colors.blue,
              onChanged: (newValue) => settings.setVoiceVolume(newValue),
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
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: MediaQuery.of(context).size.width / 3.5,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: selected ? Colors.blue.shade100 : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? Colors.blue : Colors.transparent,
            width: 2,
          ),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: Colors.blue.withOpacity(0.3),
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
                size: 32, color: selected ? Colors.blue : Colors.black54),
            const SizedBox(height: 8),
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
            Text(subtitle,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 12, color: Colors.black54)),
          ],
        ),
      ),
    );
  }
}
