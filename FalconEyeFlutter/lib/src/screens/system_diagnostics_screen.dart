import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../widgets/falcon_widgets.dart';

class SystemDiagnosticsScreen extends StatefulWidget {
  const SystemDiagnosticsScreen({
    required this.onClose,
    required this.droneConnected,
    super.key,
  });

  final VoidCallback onClose;
  final bool droneConnected;

  @override
  State<SystemDiagnosticsScreen> createState() => _SystemDiagnosticsScreenState();
}

class _SystemDiagnosticsScreenState extends State<SystemDiagnosticsScreen> {
  @override
  Widget build(BuildContext context) {
    return GradientBackground(
      child: SafeArea(
        child: Column(
          children: <Widget>[
            Container(
              color: AppColors.bgSecondary,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: <Widget>[
                  const Expanded(
                    child: Text('System Diagnostics', style: TextStyle(color: AppColors.cyanSoft, fontSize: 26)),
                  ),
                  Text(widget.droneConnected ? 'Connected' : '---', style: const TextStyle(color: AppColors.textMuted, fontSize: 18)),
                  const SizedBox(width: 16),
                  SizedBox(width: 120, child: SecondaryButton(label: 'Close', onPressed: widget.onClose)),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(18),
                child: Column(
                  children: <Widget>[
                    Wrap(
                      spacing: 14,
                      runSpacing: 14,
                      children: <Widget>[
                        _metric('CPU Usage'),
                        _metric('Memory Usage'),
                        _metric('Storage'),
                        _metric('Battery Level'),
                        _metric('Temperature'),
                        _metric('Network Quality'),
                      ],
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

  Widget _metric(String title) {
    return SizedBox(
      width: 380,
      child: FalconCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(title, style: const TextStyle(color: AppColors.textSecondary, fontSize: 18)),
            const SizedBox(height: 12),
            const Text('---', style: TextStyle(color: AppColors.textPrimary, fontSize: 34)),
            const SizedBox(height: 10),
            const Text('---', style: TextStyle(color: AppColors.textMuted)),
          ],
        ),
      ),
    );
  }
}
