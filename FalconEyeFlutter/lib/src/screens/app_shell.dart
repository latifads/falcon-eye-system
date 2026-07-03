import 'package:flutter/material.dart';

import '../data/mission_repository.dart';
import '../models/mission_data.dart';
import '../models/mission_record.dart';
import 'home_screen.dart';
import 'live_mission_screen.dart';
import 'login_screen.dart';
import 'mission_briefing_screen.dart';
import 'mission_history_screen.dart';
import 'system_diagnostics_screen.dart';
import '../../services/api_service.dart';

enum AppScreen {
  login,
  home,
  missionBriefing,
  liveMission,
  history,
  diagnostics,
}

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  final MissionRepository _repository = MissionRepository();
  AppScreen _screen = AppScreen.login;
  MissionData? _currentMission;
  MissionRecord? _currentMissionRecord;
  List<MissionRecord> _missions = <MissionRecord>[];
  DateTime? _missionStartTime;
  bool _droneConnected = false;

  @override
  void initState() {
    super.initState();
    _loadMissions();
  }

  @override
  Widget build(BuildContext context) {
    Widget child;
    switch (_screen) {
      case AppScreen.login:
        child = LoginScreen(onLogin: () => setState(() => _screen = AppScreen.home));
        break;
      case AppScreen.home:
        child = HomeScreen(
    onStartMission: () {

    setState(() => _screen = AppScreen.missionBriefing);

          },          onHistory: () => setState(() => _screen = AppScreen.history),
          onDiagnostics: () => setState(() => _screen = AppScreen.diagnostics),
          droneConnected: _droneConnected,
          serverConnected: true,
          onConnectDrone: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Drone not connected yet. Status will stay as --- until a real connection is available.')),
            );
          },
        );
        break;
      case AppScreen.missionBriefing:
        child = MissionBriefingScreen(
          onBack: () => setState(() => _screen = AppScreen.home),
          onStartMission: (MissionData mission) async {
            final record = await _repository.createMission(mission);
            setState(() {
              _currentMission = mission;
              _currentMissionRecord = record;
              _missionStartTime = DateTime.now();
              _screen = AppScreen.liveMission;
            });
            await _loadMissions();
          },
        );
        break;
      case AppScreen.liveMission:
        child = LiveMissionScreen(
          missionData: _currentMission!,
          droneConnected: _droneConnected,
          onEndMission: () async {
            await _completeCurrentMission(
              found: false,
              notes: 'Mission ended by operator without target confirmation.',
            );
            if (!mounted) return;
            setState(() => _screen = AppScreen.home);
          },
          onConfirmTarget: (BuildContext context, MissionData missionData) async {
            await _completeCurrentMission(
              found: true,
              notes: 'Target confirmed by operator and mission closed successfully.',
            );
            if (!mounted) return;
            setState(() => _screen = AppScreen.home);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Target confirmed. Returning to home.')),
            );
          },
        );
        break;
      case AppScreen.history:
        child = MissionHistoryScreen(
          missions: _missions,
          onClose: () => setState(() => _screen = AppScreen.home),
        );
        break;
      case AppScreen.diagnostics:
        child = SystemDiagnosticsScreen(
          onClose: () => setState(() => _screen = AppScreen.home),
          droneConnected: _droneConnected,
        );
        break;
    }
    return Scaffold(body: child);
  }

  Future<void> _loadMissions() async {
    final missions = await _repository.loadMissions();
    if (mounted) {
      setState(() => _missions = missions);
    }
  }

  Future<void> _completeCurrentMission({
    required bool found,
    required String notes,
  }) async {
    final record = _currentMissionRecord;
    if (record == null) return;
    final startedAt = _missionStartTime ?? DateTime.now();
    final minutes = DateTime.now().difference(startedAt).inMinutes;
    await _repository.completeMission(
      missionId: record.id,
      found: found,
      duration: '${minutes <= 0 ? 1 : minutes} min',
      notes: notes,
    );
    await _loadMissions();
  }
}
