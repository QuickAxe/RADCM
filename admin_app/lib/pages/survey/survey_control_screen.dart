import 'package:admin_app/utils/context_extensions.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../services/api services/dio_client_user_service.dart';

class SurveyControlScreen extends StatefulWidget {
  const SurveyControlScreen({super.key});

  @override
  State<SurveyControlScreen> createState() => _SurveyControlScreenState();
}

class _SurveyControlScreenState extends State<SurveyControlScreen> {
  String responseMessage = 'Awaiting command...';
  bool showErrorActions = false; // toggles those help buttons
  String lastCommand = '';

  // NOTE: there are several Future.delayed calls in the func below, that's just so that the UI updates, with the latest setState response
  /// function to send commands to the UAV
  Future<void> sendCommand(String command) async {
    const fallbackUrls = [
      'http://192.168.50.1:3333',
      // 'http://raspberrypi.local:3333',
    ];

    // to support retry
    setState(() {
      lastCommand = command;
    });

    for (final url in fallbackUrls) {
      setState(() {
        responseMessage = 'Trying $url...';
      });

      await Future.delayed(const Duration(milliseconds: 50));

      final dio = DioClientUser();

      final result = await dio.postRequest(
        '',
        {'command': command},
        baseUrl: url,
      );

      if (result.success) {
        setState(() {
          responseMessage = 'Success [$url]: ${result.data}';
          showErrorActions = false;
        });
        return;
      } else {
        setState(() {
          responseMessage = 'Failed [$url]: ${result.errorMessage}';
        });
      }

      await Future.delayed(const Duration(milliseconds: 300));
    }

    setState(() {
      responseMessage +=
          '\nAll attempts failed for "$command".\n\nAre you connected to the UAV?';
      showErrorActions = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Survey Controls'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            // the msg thing
            Expanded(
              flex: 2,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                // color: Colors.grey.shade200,
                child: SingleChildScrollView(
                  child: Text(
                    responseMessage,
                    style: context.theme.textTheme.bodyLarge?.copyWith(
                      fontFamily: 'monospace',
                    ),
                  ),
                ),
              ),
            ),

            if (showErrorActions)
              Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    FilledButton.tonalIcon(
                      onPressed: () => sendCommand(lastCommand),
                      icon: const Icon(Icons.refresh),
                      label: const Text('Retry Command'),
                    ),
                    FilledButton.tonalIcon(
                      onPressed: () =>
                          Navigator.pushReplacementNamed(context, '/survey'),
                      icon: const Icon(LucideIcons.qrCode),
                      label: const Text('Scan again'),
                    ),
                  ],
                ),
              ),

            const Divider(height: 1),
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Top row with Start and Stop
                    Row(
                      children: [
                        // start
                        Expanded(
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 40),
                              backgroundColor: context.colorScheme.primary,
                            ),
                            onPressed: () => sendCommand("start"),
                            icon: Icon(
                              Icons.play_arrow_rounded,
                              color: context.colorScheme.onPrimary,
                            ),
                            label: Text(
                              'Start',
                              style:
                                  context.theme.textTheme.labelLarge?.copyWith(
                                color: context.colorScheme.onPrimary,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        // stop
                        Expanded(
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 40),
                              backgroundColor: context.colorScheme.tertiary,
                            ),
                            onPressed: () async {
                              final confirmed = await showDialog<bool>(
                                context: context,
                                builder: (ctx) => AlertDialog(
                                  title: const Text('Confirm Stop'),
                                  content: const Text(
                                      'Are you sure you want to stop the survey?'),
                                  actions: [
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.of(ctx).pop(false),
                                      child: const Text('Cancel'),
                                    ),
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.of(ctx).pop(true),
                                      child: const Text('Yes, Stop'),
                                    ),
                                  ],
                                ),
                              );

                              if (confirmed == true) {
                                sendCommand("stop");
                              }
                            },
                            icon: Icon(
                              Icons.stop_rounded,
                              color: context.colorScheme.onTertiary,
                            ),
                            label: Text(
                              'Stop',
                              style:
                                  context.theme.textTheme.labelLarge?.copyWith(
                                color: context.colorScheme.onTertiary,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // submit button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 40),
                          backgroundColor:
                              context.colorScheme.secondaryContainer,
                        ),
                        onPressed: () async {
                          final confirmed = await showDialog<bool>(
                            context: context,
                            builder: (ctx) => AlertDialog(
                              title: const Text('Confirm Submit'),
                              content: const Text(
                                  'Are you sure you want to the images collected so far?'),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.of(ctx).pop(false),
                                  child: const Text('Cancel'),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.of(ctx).pop(true),
                                  child: const Text('Yes, Submit'),
                                ),
                              ],
                            ),
                          );

                          if (confirmed == true) {
                            sendCommand("submit");
                          }
                        },
                        icon: Icon(
                          Icons.check_rounded,
                          color: context.colorScheme.onSecondaryContainer,
                        ),
                        label: Text(
                          'Submit Images',
                          style: context.theme.textTheme.labelLarge?.copyWith(
                            color: context.colorScheme.onSecondaryContainer,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
