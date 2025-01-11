import 'package:flutter/material.dart';

class VoiceEngineScreen extends StatefulWidget {
  const VoiceEngineScreen({super.key});

  @override
  State<VoiceEngineScreen> createState() => _VoiceEngineScreenState();
}

class _VoiceEngineScreenState extends State<VoiceEngineScreen> {
  String? _selectedVoice; // TODO: This is placeholder
  double _pitch = 0.5; // TODO: This is placeholder

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Voice Engine'),
      ),
      body: Column(
        children: [
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Center(
              child: Text(
                'Choose the voice for your audio notifications while navigating.',
              ),
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          RadioListTile<String>(
            title: const Text('Male Voice'),
            subtitle: const Text('A husky male voice'),
            value: 'male',
            groupValue: _selectedVoice,
            onChanged: (value) {
              setState(() {
                _selectedVoice = value;
              });
            },
          ),
          RadioListTile<String>(
            title: const Text('Female Voice'),
            subtitle: const Text('A soft female voice'),
            value: 'female',
            groupValue: _selectedVoice,
            onChanged: (value) {
              setState(() {
                _selectedVoice = value;
              });
            },
          ),
          RadioListTile<String>(
            title: const Text('Default Voice'),
            subtitle: const Text('Electronic Voice'),
            value: 'default',
            groupValue: _selectedVoice,
            onChanged: (value) {
              setState(() {
                _selectedVoice = value;
              });
            },
          ),
          ListTile(
            contentPadding: const EdgeInsets.only(left: 25),
            title: Text(
              'Notification Volume',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            subtitle: Text(
              'Adjust the volume of your notifications.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          Slider(
            value: _pitch,
            onChanged: (newValue) {
              setState(() {
                _pitch = newValue;
              });
            },
          ),
        ],
      ),
    );
  }
}
