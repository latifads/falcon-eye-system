import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

import '../models/mission_data.dart';
import '../theme/app_theme.dart';
import '../widgets/falcon_widgets.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class LiveMissionScreen extends StatefulWidget {
  const LiveMissionScreen({
    required this.missionData,
    required this.droneConnected,
    required this.onEndMission,
    required this.onConfirmTarget,
    super.key,
  });

  final MissionData missionData;
  final bool droneConnected;
  final VoidCallback onEndMission;
  final Future<void> Function(BuildContext context, MissionData missionData) onConfirmTarget;

  @override
  State<LiveMissionScreen> createState() => _LiveMissionScreenState();
}

class _LiveMissionScreenState extends State<LiveMissionScreen> {
  late final Timer _movementTimer;
  late final Timer _frameTimer;

  double _droneX = 0.5;
  double _droneY = 0.5;
  int _step = 0;
  double? _latitude;
  double? _longitude;
  String _direction = "SEARCHING";
  double? _missionLat;
  double? _missionLng;
  int _gridWidth = 0;
  int _gridHeight = 0;
  double _searchRadius = 0;
  List<dynamic> _grid = [];

  bool _showTargetButton = false;

  String _targetConfidence = "0%";

  String _frameUrl =
      'http://10.0.2.2:5001/latest_frame';

  List<_DetectionItem> _detections = <_DetectionItem>[
    const _DetectionItem('Person', 'Not Detected', '-', '-'),
    const _DetectionItem('Vehicle', 'Not Detected', '-', '-'),
    const _DetectionItem('Footprints', 'Not Detected', '-', '-'),
  ];

  Future<void> _loadDetections() async {
    try {
      final response = await http.get(
        Uri.parse(
          'http://10.0.2.2:5001/detections',
        ),
      );

      final data = jsonDecode(response.body);

      bool personFound = false;
      bool vehicleFound = false;
      bool footprintFound = false;



      String personConfidence = '-';
      String vehicleConfidence = '-';
      String footprintConfidence = '-';

      double personConfidenceValue = 0;

      for (final item in data['detections']) {
        final label =
        item['label'].toString().toLowerCase();

        final confidence =
            '${(item['confidence'] * 100).toStringAsFixed(0)}%';

        if (label == 'person') {
          personFound = true;
          personConfidence = confidence;

          personConfidenceValue =
              item['confidence'] * 100;
        }

        if (label == 'car' ||
            label == 'vehicle' ||
            label == 'truck') {
          vehicleFound = true;
          vehicleConfidence = confidence;
        }

        if (label == 'footprint') {
          footprintFound = true;
          footprintConfidence = confidence;
        }
      }

      setState(() {
        _detections = [
          _DetectionItem(
            'Person',
            personFound
                ? 'Detected'
                : 'Not Detected',
            personConfidence,
            personConfidence,
          ),
          _DetectionItem(
            'Vehicle',
            vehicleFound
                ? 'Detected'
                : 'Not Detected',
            vehicleConfidence,
            vehicleConfidence,
          ),
          _DetectionItem(
            'Footprints',
            footprintFound
                ? 'Detected'
                : 'Not Detected',
            footprintConfidence,
            footprintConfidence,
          ),
        ];
        _showTargetButton =
            personFound &&
                personConfidenceValue >= 50;

        _targetConfidence =
            personConfidence;
      });
    } catch (_) {}

  }
  Future<void> _loadDroneLocation() async {
    try {
      final response = await http.get(
        Uri.parse(
          'http://10.0.2.2:5001/drone_location',
        ),
      );

      final data = jsonDecode(response.body);

      setState(() {
        _latitude = data['lat'];
        _longitude = data['lng'];
      });
    } catch (_) {}
  }

  Future<void> _loadDirection() async {
    try {
      final response = await http.get(
        Uri.parse(
          'http://10.0.2.2:5001/direction',
        ),
      );

      final data = jsonDecode(response.body);

      setState(() {
        _direction = data['direction'];
      });
    } catch (_) {}
  }

  void _showTargetDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return Dialog(
          backgroundColor: AppColors.bgSecondary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Container(
            width: 600,
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                // Header
                const Text(
                  'Target Found!',
                  style: TextStyle(
                    color: AppColors.cyanSoft,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 20),

                // Confidence Level
                FalconPanel(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Confidence Level',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _targetConfidence,
                        style: const TextStyle(
                          color: Colors.greenAccent,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      LinearProgressIndicator(
                        value: (double.tryParse(
                          _targetConfidence.replaceAll('%', ''),
                        ) ??
                            0) /
                            100,                        color: Colors.greenAccent,
                        backgroundColor: Colors.grey.shade800,
                        minHeight: 8,
                        borderRadius: BorderRadius.circular(4),
                      ),

                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // GPS Coordinates
                FalconPanel(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'GPS Coordinates',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Latitude: ${_latitude?.toStringAsFixed(6) ?? "---"}°',
                        style: const TextStyle(color: AppColors.textPrimary),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Longitude: ${_longitude?.toStringAsFixed(6) ?? "---"}°',
                        style: const TextStyle(color: AppColors.textPrimary),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Target Profile Match
                FalconPanel(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        'Target Profile Match',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 16,
                        ),
                      ),
                      SizedBox(height: 12),
                      Text('Gender: ---'),
                      SizedBox(height: 6),
                      Text('Age Range: ---'),
                      SizedBox(height: 6),
                      Text('Clothing: ---'),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Buttons
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.greenAccent,
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        onPressed: () {
                          Navigator.pop(context);
                          _showMissionCompletedDialog();
                        },
                        child: const Text('Confirm Target'),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey.shade700,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Continue Search'),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Warning
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.yellow.shade800.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    '⚠️ Please verify the target visually before confirming. False positives may occur in desert environments.',
                    style: TextStyle(
                      color: Colors.yellowAccent,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }


  void _showMissionCompletedDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return Dialog(
          backgroundColor: AppColors.bgSecondary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Container(
            width: 650,
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [

                const Icon(
                  Icons.verified,
                  color: Colors.green,
                  size: 80,
                ),

                const SizedBox(height: 16),

                const Text(
                  'MISSION COMPLETED',
                  style: TextStyle(
                    color: AppColors.cyanSoft,
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 20),

                Text(
                  'Target Confirmed\nConfidence: $_targetConfidence',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 18,
                  ),
                ),

                const SizedBox(height: 20),

                FalconPanel(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      const Text(
                        'GPS Coordinates',
                        style: TextStyle(
                          color: AppColors.cyanSoft,
                          fontSize: 18,
                        ),
                      ),

                      const SizedBox(height: 12),

                      Text(
                        'Latitude: ${_latitude?.toStringAsFixed(6) ?? "---"}',
                      ),

                      const SizedBox(height: 8),

                      Text(
                        'Longitude: ${_longitude?.toStringAsFixed(6) ?? "---"}',
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      widget.onEndMission();
                    },
                    child: const Text(
                      'Return to Dashboard',
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _loadMissionLocation() async {
    print("LOADING LOCATION");
    try {
      final response = await http.get(
        Uri.parse(
          'http://10.0.2.2:5001/get_grid',
        ),
      );

      print(response.statusCode);
      print(response.body);

      final data = jsonDecode(response.body);
      print(data);
      final location =
      data['last_seen_location'];

      debugPrint(
        'MISSION LOCATION = $location',
      );

      final coords = location
          .replaceAll('(', '')
          .replaceAll(')', '')
          .split(',');

      setState(() {
        _missionLat =
            double.parse(coords[0].trim());

        _missionLng =
            double.parse(coords[1].trim());
      });
    } catch (e) {
      debugPrint(
        'Mission location error: $e',
      );
    }
  }
  Future<void> _loadGridData() async {
    print("LOADING GRID");
    try {
      final response = await http.get(
        Uri.parse(
          'http://10.0.2.2:5001/get_grid',
        ),
      );

      final data = jsonDecode(response.body);

      _grid = data['grid'];

      setState(() {
        _gridWidth = data['grid_width'];
        _gridHeight = data['grid_height'];
        _searchRadius =
            (data['radius'] as num).toDouble();
      });
      print("SEARCH RADIUS = $_searchRadius");

      print("GRID WIDTH = $_gridWidth");
      print("GRID HEIGHT = $_gridHeight");
      print("GRID LENGTH = ${_grid.length}");

    } catch (e) {
      debugPrint('$e');
    }

    print("GRID WIDTH = $_gridWidth");
    print("GRID HEIGHT = $_gridHeight");
    print("RADIUS = $_searchRadius");
  }
  @override
  void initState() {
    super.initState();

    _loadMissionLocation();
    _loadGridData();

    _frameTimer = Timer.periodic(
      const Duration(milliseconds: 100),
          (_) {
        if (!mounted) return;

        setState(() {
          _frameUrl =
          'http://10.0.2.2:5001/latest_frame?ts=${DateTime.now().millisecondsSinceEpoch}';
        });
      },
    );

    _movementTimer = Timer.periodic(
      const Duration(seconds: 2),
          (_) {
        setState(() {
          _step++;
          _droneX = 0.5 + 0.18 * sin(_step / 2);
          _droneY = 0.5 + 0.14 * cos(_step / 3);
        });
      },
    );

    Timer.periodic(
      const Duration(seconds: 1),
          (_) => _loadDetections(),
    );

    Timer.periodic(
      const Duration(seconds: 1),
          (_) => _loadDirection(),
    );

    Timer.periodic(
      const Duration(seconds: 1),
          (_) => _loadDroneLocation(),
    );

  }

  @override
  void dispose() {
    _frameTimer.cancel();
    _movementTimer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final first = widget.missionData.primaryPerson;
    final headerLocation = widget.missionData.lastSeenLocation.isEmpty ? 'No last seen location provided' : widget.missionData.lastSeenLocation;
    final suggestedDirection = _buildSuggestedDirection();

    return GradientBackground(
      child: SafeArea(
        child: Column(
          children: <Widget>[
            Container(
              color: AppColors.bgSecondary,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: <Widget>[
                  const Text('LIVE', style: TextStyle(color: AppColors.redError, fontSize: 22)),
                  const SizedBox(width: 14),
                  const Text('| Mission Active |', style: TextStyle(color: AppColors.textSecondary, fontSize: 18)),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text(
                      headerLocation,
                      style: const TextStyle(color: AppColors.cyanSoft, fontSize: 18),
                    ),
                  ),
                  if (_showTargetButton) ...[
                    ElevatedButton.icon(
                      onPressed: _showTargetDialog,
                      icon: const Icon(
                        Icons.track_changes,
                        color: Colors.white,
                      ),
                      label: Text(
                        'TARGET FOUND ($_targetConfidence)',
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 14,
                        ),
                      ),
                    ),

                    const SizedBox(width: 16),
                  ],

                  SizedBox(
                    width: 160,
                    child: SecondaryButton(
                      label: 'End Mission',
                      onPressed: widget.onEndMission,
                      color: Colors.white,
                      background: AppColors.redError,
                    ),
                  ),

                  ],

              ),
            ),
            Expanded(
              child: Row(
                children: <Widget>[
                  SizedBox(
                    width: 260,
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          const SectionTitle('Telemetry'),
                          const SizedBox(height: 14),
                          _MetricPanel(label: 'Battery', value: widget.droneConnected ? '---' : '---', progress: 0),
                          const SizedBox(height: 12),
                          const _SimplePanel(label: 'Altitude', value: '---'),
                          const SizedBox(height: 12),
                          const _SimplePanel(label: 'Temperature', value: '---'),
                          const SizedBox(height: 16),
                          FalconPanel(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                const Text('Target Profile', style: TextStyle(color: AppColors.cyanSoft, fontSize: 16)),
                                const SizedBox(height: 10),
                                Text(
                                  'Gender: ${first?.gender.isNotEmpty == true ? first!.gender : 'N/A'}\n'
                                  'Age Range: ${first?.ageRange.isNotEmpty == true ? first!.ageRange : 'N/A'}\n'
                                  'Persons: ${widget.missionData.numberOfPersons.isEmpty ? 'N/A' : widget.missionData.numberOfPersons}\n'
                                  'Clothing: ${((first?.clothingColor ?? '') + ' ' + (first?.clothingType ?? '')).trim().isEmpty ? 'N/A' : ((first?.clothingColor ?? '') + ' ' + (first?.clothingType ?? '')).trim()}'
                                  '${widget.missionData.vehicle.isNotEmpty && widget.missionData.vehicle != 'None' ? '\nVehicle: ${widget.missionData.vehicle}' : ''}',
                                  style: const TextStyle(color: AppColors.textSecondary, height: 1.5),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    child: Stack(
                      children: <Widget>[
                        Positioned.fill(
                          child: Image.network(
                            'http://10.0.2.2:5001/latest_frame?${DateTime.now().millisecondsSinceEpoch}',
                            fit: BoxFit.cover,
                            gaplessPlayback: true,
                            errorBuilder: (context, error, stackTrace) {
                              return const Center(
                                child: Text(
                                  'Waiting for video...',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),

                        Positioned(
                          top: 16,
                          left: 16,
                          child: FalconPanel(
                            child: Text(
                              widget.droneConnected
                                  ? 'GPS Position\nLat: ---\nLon: ---'
                                  : 'GPS Position\nLat: ---\nLon: ---',
                              style: const TextStyle(
                                color: AppColors.cyanSoft,
                                height: 1.5,
                              ),
                            ),
                          ),
                        ),

                        Positioned(
                          top: 16,
                          right: 16,
                          child: const FalconPanel(
                            child: Text(
                              '--- FPS\n--- ms',
                              style: TextStyle(
                                color: AppColors.textMuted,
                                height: 1.5,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    width: 340,
                    child: Column(
                      children: <Widget>[
                        Expanded(
                          child: SingleChildScrollView(
                            padding: const EdgeInsets.all(14),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                const SectionTitle('Detections'),
                                const SizedBox(height: 14),
                                for (final detection in _detections) ...<Widget>[
                                  _DetectionCard(
                                    title: detection.title,
                                    subtitle: detection.subtitle,
                                    meta: detection.meta,
                                    confidence: detection.confidence,
                                  ),
                                  const SizedBox(height: 12),
                                ],
                                FalconPanel(
                                  child: SizedBox(
                                    height: 140,
                                    child: Stack(
                                      children: <Widget>[
                                        const Align(
                                          alignment: Alignment.topLeft,
                                          child: Text(
                                            'Suggested Direction',
                                            style: TextStyle(color: AppColors.cyanSoft, fontSize: 16),
                                          ),
                                        ),
                                        AnimatedAlign(
                                          duration: const Duration(seconds: 2),
                                          alignment: Alignment(
                                            (_droneX - 0.5) * 1.4,
                                            (_droneY - 0.5) * 1.4,
                                          ),
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                                            decoration: BoxDecoration(
                                              color: AppColors.bgSecondary,
                                              borderRadius: BorderRadius.circular(12),
                                              border: Border.all(color: AppColors.strokePrimary),
                                            ),
                                            child: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [

                                                Icon(
                                                  _direction == "LEFT"
                                                      ? Icons.arrow_back
                                                      : _direction == "RIGHT"
                                                      ? Icons.arrow_forward
                                                      : _direction == "FORWARD"
                                                      ? Icons.arrow_upward
                                                      : Icons.search,
                                                  size: 40,
                                                  color: AppColors.cyanSoft,
                                                ),

                                                const SizedBox(height: 8),

                                                Text(
                                                  _direction == "LEFT"
                                                      ? "Move Left"
                                                      : _direction == "RIGHT"
                                                      ? "Move Right"
                                                      : _direction == "FORWARD"
                                                      ? "Move Forward"
                                                      : "Searching",
                                                  style: const TextStyle(
                                                    color: AppColors.textPrimary,
                                                    fontSize: 15,
                                                  ),
                                                ),
                                              ],
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
                        ),
                        Padding(
                          padding: const EdgeInsets.all(14),
                          child: Column(
                            children: <Widget>[
                              Row(
                                children: <Widget>[
                                  const SectionTitle('Mini Map'),
                                  const Spacer(),
                                  TextButton(
                                    onPressed: () => _showMapDialog(context),
                                    child: const Text('Full View', style: TextStyle(color: AppColors.cyanSoft)),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              GestureDetector(
                                onTap: () => _showMapDialog(context),
                                child: Container(
                                  height: 220,
                                  decoration: BoxDecoration(
                                    color: AppColors.bgTertiary,
                                    borderRadius: BorderRadius.circular(14),
                                    border: Border.all(color: AppColors.strokeSecondary, width: 2),
                                  ),
                                  child: const Center(
                                    child: Text(
                                      'Map preview unavailable\nuntil the drone is connected.',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(color: AppColors.textMuted, fontSize: 18),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _buildSuggestedDirection() {
    if ((_droneX - 0.5).abs() < 0.05 && (_droneY - 0.5).abs() < 0.05) {
      return 'Hold position';
    }
    final vertical = _droneY < 0.45
        ? 'North'
        : _droneY > 0.55
            ? 'South'
            : '';
    final horizontal = _droneX < 0.45
        ? 'West'
        : _droneX > 0.55
            ? 'East'
            : '';
    return [vertical, horizontal].where((e) => e.isNotEmpty).join('-');
  }

  Future<void> _showMapDialog(BuildContext context) async {

    bool showGrid = true;
    bool showHeatmap = true;
    bool showPath = true;

    await showDialog<void>(
      context: context,
      barrierColor: Colors.black87,
      builder: (BuildContext context) {
        final MapController mapController = MapController();
        return StatefulBuilder(
          builder: (BuildContext context, void Function(void Function()) setState) {
            return Dialog.fullscreen(
              backgroundColor: AppColors.bgPrimary,
              child: Stack(
                children: <Widget>[
                  Positioned.fill(
                    child: FlutterMap(
                      mapController: mapController,
                      options: MapOptions(
                        initialCenter: LatLng(
                          _missionLat ?? 26.4207,
                          _missionLng ?? 50.0888,
                        ),
                        initialZoom: 15,
                      ),
                      children: [

                        TileLayer(
                          urlTemplate:
                          'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                          userAgentPackageName:
                          'com.falconeye.app',
                        ),
                        CircleLayer(
                          circles: [
                            CircleMarker(
                              point: LatLng(
                                _missionLat ?? 26.4207,
                                _missionLng ?? 50.0888,
                              ),
                              radius: _searchRadius,
                              useRadiusInMeter: true,
                              color: Colors.cyan.withOpacity(0.15),
                              borderColor: Colors.cyanAccent,
                              borderStrokeWidth: 2,
                            ),
                          ],
                        ),
                        MarkerLayer(
                          markers: [
                            Marker(
                              point: LatLng(
                                _missionLat ?? 26.4207,
                                _missionLng ?? 50.0888,
                              ),
                              width: 90,
                              height: 90,
                              child: const Icon(
                                Icons.location_pin,
                                color: Colors.red,
                                size: 50,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  if (showGrid &&
                      _gridWidth > 0 &&
                      _gridHeight > 0)

                    Positioned.fill(
                      child: GridOverlay(
                        rows: _gridHeight,
                        cols: _gridWidth,
                      ),
                    ),
                  if (showHeatmap) Positioned.fill(child: Container(color: const Color(0x223ED36A))),
                  if (showPath) Positioned.fill(child: Container(color: const Color(0x11ED4337))),
                  SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: <Widget>[
                          const Expanded(
                            child: Text(
                              'Map View - Search Area Overview',
                              style: TextStyle(color: AppColors.cyanSoft, fontSize: 28),
                            ),
                          ),
                          _mapToggle(
                            'Grid',
                            showGrid,
                                () {

                              print("GRID PRESSED");

                              setState(() {
                                showGrid = !showGrid;
                              });

                              if (showGrid) {

                                mapController.move(
                                  LatLng(
                                    _missionLat ?? 26.4207,
                                    _missionLng ?? 50.0888,
                                  ),
                                  13,
                                );
                              } else {

                                mapController.move(
                                  LatLng(
                                    _missionLat ?? 26.4207,
                                    _missionLng ?? 50.0888,
                                  ),
                                  15,
                                );

                              }
                            },
                          ),                          const SizedBox(width: 8),
                          _mapToggle('Heatmap', showHeatmap, () => setState(() => showHeatmap = !showHeatmap)),
                          const SizedBox(width: 8),
                          _mapToggle('Path', showPath, () => setState(() => showPath = !showPath)),
                          const SizedBox(width: 8),
                          SizedBox(width: 120, child: SecondaryButton(label: 'Close', onPressed: () => Navigator.of(context).pop())),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _mapToggle(String label, bool selected, VoidCallback onTap) {
    return SizedBox(
      width: 120,
      child: SelectChipButton(label: label, selected: selected, onPressed: onTap),
    );
  }
}

extension on Object {
  double? operator /(int other) {}
}

class _MetricPanel extends StatelessWidget {
  const _MetricPanel({required this.label, required this.value, required this.progress});

  final String label;
  final String value;
  final double progress;

  @override
  Widget build(BuildContext context) {
    return FalconPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 16)),
          const SizedBox(height: 8),
          Text(value, style: const TextStyle(color: AppColors.textPrimary, fontSize: 22)),
          const SizedBox(height: 10),
          LinearProgressIndicator(
            value: progress,
            color: AppColors.greenOk,
            backgroundColor: AppColors.strokeSecondary,
            minHeight: 8,
          ),
        ],
      ),
    );
  }
}

class _SimplePanel extends StatelessWidget {
  const _SimplePanel({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return FalconPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 16)),
          const SizedBox(height: 8),
          Text(value, style: const TextStyle(color: AppColors.textPrimary, fontSize: 22)),
        ],
      ),
    );
  }
}

class _DetectionCard extends StatelessWidget {
  const _DetectionCard({
    required this.title,
    required this.subtitle,
    required this.meta,
    required this.confidence,
  });

  final String title;
  final String subtitle;
  final String meta;
  final String confidence;

  @override
  Widget build(BuildContext context) {
    return FalconPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Text(title, style: const TextStyle(color: AppColors.textPrimary, fontSize: 20)),
              const Spacer(),
              Text(confidence, style: const TextStyle(color: AppColors.cyanSoft, fontSize: 18)),
            ],
          ),
          const SizedBox(height: 8),
          Text(subtitle, style: const TextStyle(color: AppColors.textSecondary)),
          const SizedBox(height: 4),
          Text(meta, style: const TextStyle(color: AppColors.textMuted)),
        ],
      ),
    );
  }
}

class _DetectionItem {
  const _DetectionItem(this.title, this.subtitle, this.meta, this.confidence);

  final String title;
  final String subtitle;
  final String meta;
  final String confidence;
}

class GridOverlay extends StatelessWidget {

  final int rows;
  final int cols;

  const GridOverlay({
    super.key,
    required this.rows,
    required this.cols,
  });

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: CustomPaint(
        painter: GridPainter(
          rows: rows,
          cols: cols,
        ),
        size: Size.infinite,
      ),
    );
  }
}

class GridPainter extends CustomPainter {

  final int rows;
  final int cols;

  GridPainter({
    required this.rows,
    required this.cols,
  });

  @override
  void paint(Canvas canvas, Size size) {

    final paint = Paint()
      ..color = Colors.cyanAccent
      ..strokeWidth = 1.5;

    final rowHeight = size.height / rows;
    final colWidth = size.width / cols;

    for (int i = 0; i <= rows; i++) {
      canvas.drawLine(
        Offset(0, rowHeight * i),
        Offset(size.width, rowHeight * i),
        paint,
      );
    }

    for (int j = 0; j <= cols; j++) {
      canvas.drawLine(
        Offset(colWidth * j, 0),
        Offset(colWidth * j, size.height),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}