import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:me_mpr/utils/utils.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:me_mpr/models/therapist.dart';
import 'package:me_mpr/utils/app_colors.dart';
// import 'package:url_launcher/url_launcher.dart';

class TherapistMap extends StatefulWidget {
  final List<Therapist> therapists;

  const TherapistMap({super.key, required this.therapists});

  @override
  State<TherapistMap> createState() => _TherapistMapState();
}

class _TherapistMapState extends State<TherapistMap> {
  final MapController _mapController = MapController();
  LatLng? _currentPosition;
  bool _isLoadingLocation = true;
  String? _locationError;
  List<Marker> _markers = [];

  // Default initial camera position (Kalyan example)
  static final LatLng _kInitialPosition = LatLng(19.2312, 73.1302);

  @override
  void initState() {
    super.initState();
    _determinePosition();
  }

  Future<void> _determinePosition() async {
    // Ensure widget is still mounted before starting async work
    if (!mounted) return;

    setState(() {
      _isLoadingLocation = true;
      _locationError = null;
    });

    // 1. Check Location Permission
    var status = await Permission.locationWhenInUse.status;
    if (status.isDenied) {
      status = await Permission.locationWhenInUse.request();
    }

    if (!mounted) return; // Check again after await

    if (status.isDenied || status.isPermanentlyDenied) {
      setState(() {
        _isLoadingLocation = false;
        _locationError =
            'Location permissions denied. Please enable them in app settings.';
      });
      _buildMarkers(null); // Build markers without user location
      return;
    }

    // 2. Check if Location Services are Enabled
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!mounted) return;

    if (!serviceEnabled) {
      setState(() {
        _isLoadingLocation = false;
        _locationError = 'Location services are disabled. Please enable GPS.';
      });
      _buildMarkers(null); // Build markers without user location
      return;
    }

    // 3. Get Current Location
    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      if (!mounted) return;

      _currentPosition = LatLng(position.latitude, position.longitude);
      setState(() {
        _isLoadingLocation = false;
        _locationError = null; // Clear previous errors
      });
      _buildMarkers(_currentPosition); // Build markers WITH user location
      _updateMapCamera(); // Move camera after markers are built
    } catch (e) {
      print("Error getting location: $e");
      if (!mounted) return;
      setState(() {
        _isLoadingLocation = false;
        _locationError = 'Failed to get current location.'; // Simpler error
      });
      _buildMarkers(
        null,
      ); // Still build therapist markers even if user location fails
    }
  }

  void _updateMapCamera() {
    // Ensure mapController is ready and position exists
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // --- FIX: Removed the incorrect '.ready' check ---
      if (_currentPosition != null) {
        try {
          // Attempt to move the map
          _mapController.move(_currentPosition!, 14.0);
        } catch (e) {
          // Catch potential errors if map isn't fully ready yet (though onMapReady helps)
          print("Error moving map camera: $e");
        }
      }
    });
  }

  void _buildMarkers(LatLng? userLocation) {
    final List<Marker> markers = [];

    // Add user marker
    if (userLocation != null) {
      markers.add(
        Marker(
          point: userLocation,
          width: 40,
          height: 40,
          child: const Tooltip(
            message: 'Your Location',
            child: Icon(
              Icons.person_pin_circle,
              color: AppColors.primary,
              size: 40,
            ),
          ),
        ),
      );
    }

    // Add therapist markers
    for (var therapist in widget.therapists) {
      markers.add(
        Marker(
          point: LatLng(therapist.latitude, therapist.longitude),
          width: 40,
          height: 40,
          child: Tooltip(
            message: therapist.name,
            child: IconButton(
              padding: EdgeInsets.zero,
              icon: const Icon(
                Icons.location_pin,
                color: AppColors.error,
                size: 40,
              ),
              onPressed: () => _showTherapistDetails(context, therapist),
            ),
          ),
        ),
      );
    }
    // IMPORTANT: Check if mounted before calling setState in async gaps
    if (mounted) {
      setState(() {
        _markers = markers;
      });
    }
  }

  void _showTherapistDetails(BuildContext context, Therapist therapist) {
    // ... (showModalBottomSheet logic remains the same) ...
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.fromLTRB(
          20,
          20,
          20,
          MediaQuery.of(context).viewInsets.bottom + 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  therapist.name,
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              therapist.specialization,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w500,
              ),
            ),
            const Divider(height: 24),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.location_on_outlined,
                  size: 18,
                  color: AppColors.secondaryText,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    therapist.address,
                    style: const TextStyle(color: AppColors.secondaryText),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.link_rounded,
                  size: 18,
                  color: AppColors.secondaryText,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    therapist.contact,
                    style: const TextStyle(color: AppColors.secondaryText),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.call_outlined),
                label: const Text('Contact Therapist'),
                onPressed: () {
                  // --- FIX: Call the reusable contact options function ---
                  showContactOptions(context, therapist.contact);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget mapContent;

    if (_isLoadingLocation) {
      mapContent = const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 8),
            Text(
              'Getting location...',
              style: TextStyle(color: AppColors.secondaryText),
            ),
          ],
        ),
      );
    } else if (_locationError != null) {
      // Show error if there is one
      mapContent = Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.location_off_rounded,
                size: 40,
                color: AppColors.error,
              ),
              const SizedBox(height: 8),
              Text(
                _locationError!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppColors.error),
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: _determinePosition,
                child: const Text('Retry Location'),
              ),
            ],
          ),
        ),
      );
    } else {
      // Show map if no error (even if _currentPosition is null, use default)
      mapContent = FlutterMap(
        mapController: _mapController,
        options: MapOptions(
          initialCenter: _currentPosition ?? _kInitialPosition,
          initialZoom: _currentPosition != null ? 14.0 : 12.0,
          interactionOptions: const InteractionOptions(
            flags: InteractiveFlag.all & ~InteractiveFlag.rotate,
          ),
          // Add callback to ensure camera update happens after map is ready
          onMapReady: () {
            _updateMapCamera();
          },
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName:
                'com.example.me_mpr', // Ensure this is correct
            tileBuilder: (context, tileWidget, tile) {
              return Stack(
                children: [
                  tileWidget,
                  Positioned(
                    bottom: 2,
                    right: 2,
                    child: Text(
                      '',
                      style: TextStyle(
                        fontSize: 9,
                        color: Colors.black.withOpacity(0.6),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
          MarkerLayer(markers: _markers),
        ],
      );
    }

    // Main widget structure
    return AspectRatio(
      aspectRatio: 16 / 9,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.border.withOpacity(0.3),
            border: Border.all(color: AppColors.border),
            borderRadius: BorderRadius.circular(16),
          ),
          child: mapContent,
        ),
      ),
    );
  }
}
