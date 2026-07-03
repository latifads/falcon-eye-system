import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/mission_data.dart';
import '../models/mission_record.dart';

class MissionRepository {
  static const _storageKey = 'falconeye_missions';

  Future<List<MissionRecord>> loadMissions() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_storageKey);
    if (raw == null || raw.isEmpty) {
      return <MissionRecord>[];
    }
    final decoded = jsonDecode(raw) as List<dynamic>;
    return decoded
        .map((item) => MissionRecord.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<MissionRecord> createMission(MissionData missionData) async {
    final missions = await loadMissions();
    final record = MissionRecord(
      id: DateTime.now().millisecondsSinceEpoch,
      dateTime: _formatNow(),
      location: missionData.lastSeenLocation.isEmpty ? 'Unknown Sector' : missionData.lastSeenLocation,
      status: 'In Progress',
      target: missionData.targetSummary,
      duration: '0 min',
      found: false,
      notes: 'Mission started and drone deployed.',
    );
    missions.insert(0, record);
    await _save(missions);
    return record;
  }

  Future<void> completeMission({
    required int missionId,
    required bool found,
    required String duration,
    required String notes,
  }) async {
    final missions = await loadMissions();
    final match = missions.where((m) => m.id == missionId).firstOrNull;
    if (match != null) {
      match.status = 'Completed';
      match.found = found;
      match.duration = duration;
      match.notes = notes;
      await _save(missions);
    }
  }

  Future<void> _save(List<MissionRecord> missions) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _storageKey,
      jsonEncode(missions.map((m) => m.toJson()).toList()),
    );
  }

  String _formatNow() {
    final now = DateTime.now();
    final two = (int v) => v.toString().padLeft(2, '0');
    return '${now.year}-${two(now.month)}-${two(now.day)} ${two(now.hour)}:${two(now.minute)}';
  }
}

extension<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
