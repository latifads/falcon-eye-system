import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../widgets/falcon_widgets.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({
    required this.onStartMission,
    required this.onHistory,
    required this.onDiagnostics,
    required this.onConnectDrone,
    required this.droneConnected,
    required this.serverConnected,
    super.key,
  });

  final VoidCallback onStartMission;
  final VoidCallback onHistory;
  final VoidCallback onDiagnostics;
  final VoidCallback onConnectDrone;
  final bool droneConnected;
  final bool serverConnected;

  @override
  Widget build(BuildContext context) {
    return GradientBackground(
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            children: <Widget>[
              Row(
                children: <Widget>[
                  const Spacer(),
                  Image.asset('assets/falcon_logo.png', height: 90),
                  const Spacer(),
                  const SizedBox(width: 110),
                ],
              ),
              const SizedBox(height: 14),
              Expanded(
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: FalconCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            const SectionTitle('System Status'),
                            const SizedBox(height: 18),
                            _StatusCard(
                              title: 'Drone -> Android',
                              status: droneConnected ? 'Connected' : '---',
                              detail: droneConnected ? 'Signal: Strong' : '---',
                              statusColor: droneConnected ? AppColors.greenOk : AppColors.textMuted,
                            ),
                            const SizedBox(height: 16),
                            _StatusCard(
                              title: 'Android -> Server',
                              status: serverConnected
                                  ? 'Connected'
                                  : 'Disconnected',
                              detail: serverConnected
                                  ? 'Flask Online'
                                  : 'Server Offline',
                              statusColor: serverConnected
                                  ? AppColors.greenOk
                                  : Colors.red,
                            ),
                            const Spacer(),
                            PrimaryButton(label: 'Connect to Drone', onPressed: onConnectDrone),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: FalconCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            const SectionTitle('Quick Actions'),
                            const Spacer(),
                            PrimaryButton(label: 'Start New Mission', onPressed: onStartMission, height: 62),
                            const SizedBox(height: 14),
                            SecondaryButton(label: 'View All Missions', onPressed: onHistory),
                            const SizedBox(height: 12),
                            SecondaryButton(label: 'System Diagnostics', onPressed: onDiagnostics),
                            const Spacer(),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Falcon Eye v2.0 | Secure Connection Active | Last Updated: 14:30 UTC',
                style: TextStyle(color: AppColors.textMuted),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusCard extends StatelessWidget {
  const _StatusCard({
    required this.title,
    required this.status,
    required this.detail,
    required this.statusColor,
  });

  final String title;
  final String status;
  final String detail;
  final Color statusColor;

  @override
  Widget build(BuildContext context) {
    return FalconPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(title, style: const TextStyle(fontSize: 18, color: AppColors.textPrimary)),
          const SizedBox(height: 8),
          Row(
            children: <Widget>[
              Text(status, style: TextStyle(color: statusColor, fontSize: 15)),
              const Spacer(),
              Text(detail, style: const TextStyle(color: AppColors.textMuted, fontSize: 14)),
            ],
          ),
        ],
      ),
    );
  }
}
