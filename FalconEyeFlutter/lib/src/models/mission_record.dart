class MissionRecord {
  MissionRecord({
    required this.id,
    required this.dateTime,
    required this.location,
    required this.status,
    required this.target,
    required this.duration,
    required this.found,
    required this.notes,
  });

  final int id;
  String dateTime;
  String location;
  String status;
  String target;
  String duration;
  bool found;
  String notes;

  Map<String, dynamic> toJson() => {
        'id': id,
        'dateTime': dateTime,
        'location': location,
        'status': status,
        'target': target,
        'duration': duration,
        'found': found,
        'notes': notes,
      };

  factory MissionRecord.fromJson(Map<String, dynamic> json) => MissionRecord(
        id: json['id'] as int,
        dateTime: json['dateTime'] as String,
        location: json['location'] as String,
        status: json['status'] as String,
        target: json['target'] as String,
        duration: json['duration'] as String,
        found: json['found'] as bool,
        notes: json['notes'] as String,
      );
}
