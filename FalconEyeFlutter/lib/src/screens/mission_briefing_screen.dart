import 'package:flutter/material.dart';

import '../models/mission_data.dart';
import '../models/person_data.dart';
import '../theme/app_theme.dart';
import '../widgets/falcon_widgets.dart';
import '../../services/api_service.dart';

class MissionBriefingScreen extends StatefulWidget {
  const MissionBriefingScreen({
    required this.onBack,
    required this.onStartMission,
    super.key,
  });

  final VoidCallback onBack;
  final ValueChanged<MissionData> onStartMission;

  @override
  State<MissionBriefingScreen> createState() => _MissionBriefingScreenState();
}

class _MissionBriefingScreenState extends State<MissionBriefingScreen> {

  final _locationController = TextEditingController();

  final List<PersonData> _persons = <PersonData>[];

  String _numberOfPersons = '';
  String _vehicle = '';
  String _daysMissing = '';
  String? _error;

  @override
  Widget build(BuildContext context) {

    return GradientBackground(

      child: SafeArea(

        child: Padding(

          padding: const EdgeInsets.all(18),

          child: Column(

            children: <Widget>[

              Align(

                alignment: Alignment.centerLeft,

                child: TextButton(

                  onPressed: widget.onBack,

                  child: const Text(

                    '< Back to Home',

                    style: TextStyle(
                      color: AppColors.cyanSoft,
                      fontSize: 18,
                    ),
                  ),
                ),
              ),

              Image.asset(
                'assets/falcon_logo.png',
                height: 84,
              ),

              const SizedBox(height: 12),

              Expanded(

                child: FalconCard(

                  child: SingleChildScrollView(

                    child: Column(

                      crossAxisAlignment:
                      CrossAxisAlignment.start,

                      children: <Widget>[

                        const SectionTitle(
                          'Mission Briefing',
                        ),

                        const SizedBox(height: 18),

                        _buildLabel('Number of Persons'),

                        const SizedBox(height: 10),

                        Row(

                          children: <Widget>[

                            _expandedOption(
                              '1',
                              _numberOfPersons == '1',
                                  () => _setPersonCount('1'),
                            ),

                            const SizedBox(width: 12),

                            _expandedOption(
                              '2',
                              _numberOfPersons == '2',
                                  () => _setPersonCount('2'),
                            ),

                            const SizedBox(width: 12),

                            _expandedOption(
                              '3+',
                              _numberOfPersons == '3+',
                                  () => _setPersonCount('3+'),
                            ),
                          ],
                        ),

                        for (var i = 0;
                        i < _persons.length;
                        i++) ...<Widget>[

                          const SizedBox(height: 16),

                          _PersonEditor(

                            index: i,

                            person: _persons[i],

                            showTitle:
                            _persons.length > 1,

                            onChanged: () =>
                                setState(() {}),
                          ),
                        ],

                        if (_numberOfPersons == '3+') ...<Widget>[

                          const SizedBox(height: 12),

                          SecondaryButton(

                            label: 'Add Another Person',

                            onPressed: () => setState(
                                  () => _persons.add(
                                PersonData(),
                              ),
                            ),

                            color: AppColors.cyanSoft,
                          ),
                        ],

                        const SizedBox(height: 18),

                        _buildLabel('Vehicle (if any)'),

                        const SizedBox(height: 10),

                        _optionWrap(

                          <String>[
                            'Car',
                            'Truck',
                            'Motorcycle',
                            'None'
                          ],

                          _vehicle,

                              (v) {
                            setState(() => _vehicle = v);
                          },
                        ),

                        const SizedBox(height: 18),

                        _buildLabel('Last Seen Location'),

                        const SizedBox(height: 10),

                        TextField(

                          controller:
                          _locationController,

                          decoration: const InputDecoration(
                            hintText:
                            'Enter location or coordinates...',
                          ),

                          onChanged: (_) =>
                              setState(() => _error = null),
                        ),

                        const SizedBox(height: 18),

                        _buildLabel('Days Missing'),

                        const SizedBox(height: 10),

                        Row(

                          children: <Widget>[

                            _expandedOption(

                              '1 day',

                              _daysMissing == '1 day',

                                  () => setState(
                                    () => _daysMissing = '1 day',
                              ),
                            ),

                            const SizedBox(width: 12),

                            _expandedOption(

                              '2 days',

                              _daysMissing == '2 days',

                                  () => setState(
                                    () => _daysMissing = '2 days',
                              ),
                            ),

                            const SizedBox(width: 12),

                            _expandedOption(

                              '3+ days',

                              _daysMissing == '3+ days',

                                  () => setState(
                                    () => _daysMissing = '3+ days',
                              ),
                            ),
                          ],
                        ),

                        if (_error != null) ...<Widget>[

                          const SizedBox(height: 16),

                          FalconPanel(

                            child: Text(

                              _error!,

                              style: const TextStyle(
                                color: AppColors.redError,
                              ),
                            ),
                          ),
                        ],

                        const SizedBox(height: 18),

                        PrimaryButton(
                          label: 'START MISSION',
                          onPressed: _submit,
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 10),

              const Text(

                'Drone Deployment System v2.0 | Secure Connection Active',

                style: TextStyle(
                  color: AppColors.textMuted,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) => Text(

    text,

    style: const TextStyle(
      color: AppColors.textSecondary,
      fontSize: 16,
    ),
  );

  Widget _expandedOption(

      String label,
      bool selected,
      VoidCallback onPressed,

      ) {

    return Expanded(

      child: SelectChipButton(

        label: label,

        selected: selected,

        onPressed: onPressed,
      ),
    );
  }

  Widget _optionWrap(

      List<String> options,
      String selected,
      ValueChanged<String> onSelected,

      ) {

    return Wrap(

      spacing: 12,

      runSpacing: 10,

      children: options

          .map(

            (option) => SizedBox(

          width: 220,

          child: SelectChipButton(

            label: option,

            selected: selected == option,

            onPressed: () => onSelected(option),
          ),
        ),
      )

          .toList(),
    );
  }

  void _setPersonCount(String value) {

    setState(() {

      _numberOfPersons = value;

      final count =
      value == '3+' ? 3 : int.parse(value);

      _persons

        ..clear()

        ..addAll(

          List<PersonData>.generate(
            count,
                (_) => PersonData(),
          ),
        );

      _error = null;
    });
  }

  Future<void> _submit() async {

    print("SUBMIT CLICKED");

    if (_numberOfPersons.isEmpty) {

      setState(() => _error =
      'Select the number of persons before starting the mission.');

      return;
    }

    final firstPerson = _persons.first;

    print("CALLING API");

    ApiService.startMission(
      gender: firstPerson.gender.toLowerCase(),

      ageRange: firstPerson.ageRange.toLowerCase(),

      daysMissing: _daysMissing,

      vehicle: _vehicle,

      clothingColor:
      firstPerson.clothingColor.toLowerCase(),

      clothingType:
      firstPerson.clothingType.toLowerCase(),

      lastSeenLocation:
      _locationController.text.trim(),
    );

    print("API FINISHED");

    widget.onStartMission(

      MissionData(

        numberOfPersons:
        _numberOfPersons,

        persons:
        List<PersonData>.from(_persons),

        vehicle:
        _vehicle.isEmpty
            ? 'None'
            : _vehicle,

        lastSeenLocation:
        _locationController.text.trim(),

        daysMissing:
        _daysMissing.isEmpty
            ? 'Unknown'
            : _daysMissing,
      ),
    );
  }
}

class _PersonEditor extends StatelessWidget {

  const _PersonEditor({

    required this.index,
    required this.person,
    required this.showTitle,
    required this.onChanged,
  });

  final int index;
  final PersonData person;
  final bool showTitle;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {

    return FalconPanel(

      child: Column(

        crossAxisAlignment:
        CrossAxisAlignment.start,

        children: <Widget>[

          if (showTitle)

            Text(

              'Person ${index + 1}',

              style: const TextStyle(
                color: AppColors.cyanSoft,
                fontSize: 20,
              ),
            ),

          const SizedBox(height: 12),

          const Text(
            'Gender',
            style: TextStyle(
              color: AppColors.textSecondary,
            ),
          ),

          const SizedBox(height: 8),

          Row(

            children: <Widget>[

              Expanded(

                child: SelectChipButton(

                  label: 'Male',

                  selected:
                  person.gender == 'Male',

                  onPressed: () {

                    person.gender = 'Male';

                    onChanged();
                  },
                ),
              ),

              const SizedBox(width: 12),

              Expanded(

                child: SelectChipButton(

                  label: 'Female',

                  selected:
                  person.gender == 'Female',

                  onPressed: () {

                    person.gender = 'Female';

                    onChanged();
                  },
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          const Text(
            'Age Range',
            style: TextStyle(
              color: AppColors.textSecondary,
            ),
          ),

          const SizedBox(height: 8),

          Wrap(

            spacing: 12,
            runSpacing: 10,

            children: <String>[
              'Child',
              'Adult',
              'Elderly'
            ]

                .map(

                  (option) => SizedBox(

                width: 220,

                child: SelectChipButton(

                  label: option,

                  selected:
                  person.ageRange == option,

                  onPressed: () {

                    person.ageRange = option;

                    onChanged();
                  },
                ),
              ),
            )

                .toList(),
          ),

          const SizedBox(height: 14),

          const Text(
            'Clothing Color',
            style: TextStyle(
              color: AppColors.textSecondary,
            ),
          ),

          const SizedBox(height: 8),

          Wrap(

            spacing: 12,
            runSpacing: 10,

            children: <String>[
              'Red',
              'Blue',
              'Green',
              'Dark',
              'Light',
              'Unknown'
            ]

                .map(

                  (option) => SizedBox(

                width: 180,

                child: SelectChipButton(

                  label: option,

                  selected:
                  person.clothingColor == option,

                  onPressed: () {

                    person.clothingColor = option;

                    onChanged();
                  },
                ),
              ),
            )

                .toList(),
          ),

          const SizedBox(height: 14),

          const Text(
            'Clothing Type',
            style: TextStyle(
              color: AppColors.textSecondary,
            ),
          ),

          const SizedBox(height: 8),

          Wrap(

            spacing: 12,
            runSpacing: 10,

            children: <String>[
              'Shirt',
              'Jacket',
              'Pants',
              'Dress',
              'Thobe',
              'Abaya',
              'Other'
            ]

                .map(

                  (option) => SizedBox(

                width: 160,

                child: SelectChipButton(

                  label: option,

                  selected:
                  person.clothingType == option,

                  onPressed: () {

                    person.clothingType = option;

                    onChanged();
                  },
                ),
              ),
            )

                .toList(),
          ),
        ],
      ),
    );
  }
}