import 'person_data.dart';

class MissionData {
  MissionData({
    this.numberOfPersons = '',
    List<PersonData>? persons,
    this.vehicle = '',
    this.lastSeenLocation = '',
    this.daysMissing = '',
  }) : persons = persons ?? <PersonData>[];

  String numberOfPersons;
  List<PersonData> persons;
  String vehicle;
  String lastSeenLocation;
  String daysMissing;

  PersonData? get primaryPerson => persons.isEmpty ? null : persons.first;

  String get targetSummary {
    final first = primaryPerson;
    final base = persons.length > 1
        ? '${persons.length} Persons'
        : [
            first?.gender,
            first?.clothingColor,
            first?.clothingType,
          ].whereType<String>().where((e) => e.isNotEmpty).join(' ').trim();
    final summary = base.isEmpty ? '1 Person' : base;
    return vehicle.isNotEmpty && vehicle != 'None' ? '$summary, $vehicle' : summary;
  }
}
