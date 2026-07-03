import 'package:flutter/material.dart';

import '../models/mission_record.dart';
import '../theme/app_theme.dart';
import '../widgets/falcon_widgets.dart';

class MissionHistoryScreen extends StatelessWidget {
  const MissionHistoryScreen({
    required this.missions,
    required this.onClose,
    super.key,
  });

  final List<MissionRecord> missions;
  final VoidCallback onClose;

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
                  Expanded(
                    child: Text(
                      'Mission History  |  ${missions.length} Total Missions',
                      style: const TextStyle(color: AppColors.cyanSoft, fontSize: 26),
                    ),
                  ),
                  SizedBox(width: 120, child: SecondaryButton(label: 'Close', onPressed: onClose)),
                ],
              ),
            ),
            Expanded(
              child: missions.isEmpty
                  ? const Center(
                      child: Text(
                        'Mission history is empty.',
                        style: TextStyle(color: AppColors.textMuted, fontSize: 22),
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.all(18),
                      itemCount: missions.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 14),
                      itemBuilder: (BuildContext context, int index) {
                        final mission = missions[index];
                        return FalconCard(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Row(
                                children: <Widget>[
                                  Expanded(
                                    child: Text(mission.dateTime, style: const TextStyle(fontSize: 22, color: AppColors.textPrimary)),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: (mission.status == 'Completed' ? AppColors.greenOk : AppColors.yellowWarn).withOpacity(0.15),
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(
                                        color: mission.status == 'Completed' ? AppColors.greenOk : AppColors.yellowWarn,
                                      ),
                                    ),
                                    child: Text(
                                      mission.status,
                                      style: TextStyle(
                                        color: mission.status == 'Completed' ? AppColors.greenOk : AppColors.yellowWarn,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Text(mission.location, style: const TextStyle(color: AppColors.textSecondary, fontSize: 18)),
                              const SizedBox(height: 8),
                              Text(mission.target, style: const TextStyle(color: AppColors.textSecondary, fontSize: 18)),
                              const SizedBox(height: 12),
                              FalconPanel(
                                child: Text(mission.notes, style: const TextStyle(color: AppColors.textSecondary, fontSize: 16)),
                              ),
                              const SizedBox(height: 12),
                              Row(
                                children: <Widget>[
                                  Expanded(
                                    child: Text(
                                      'Duration: ${mission.duration}',
                                      style: const TextStyle(color: AppColors.textMuted, fontSize: 16),
                                    ),
                                  ),
                                  SizedBox(
                                    width: 140,
                                    child: PrimaryButton(
                                      label: 'Export',
                                      onPressed: () {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(content: Text('Exported mission ${mission.id}.')),
                                        );
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
