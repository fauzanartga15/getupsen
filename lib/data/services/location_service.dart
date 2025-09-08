// File: lib/data/services/location_service.dart
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';

class LocationService extends GetxService {
  static LocationService get instance => Get.find<LocationService>();

  // Reactive variables
  var currentPosition = Rxn<Position>();
  var isLocationEnabled = false.obs;
  var locationPermissionStatus = Rx<PermissionStatus>(PermissionStatus.denied);

  @override
  void onInit() {
    super.onInit();
    _checkLocationPermission();
  }

  // Check location permission
  Future<void> _checkLocationPermission() async {
    final status = await Permission.location.status;
    locationPermissionStatus.value = status;

    if (status.isGranted) {
      await _checkLocationService();
    }
  }

  // Check if location service is enabled
  Future<void> _checkLocationService() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    isLocationEnabled.value = serviceEnabled;
  }

  // Request location permission
  Future<bool> requestLocationPermission() async {
    try {
      final status = await Permission.location.request();
      locationPermissionStatus.value = status;

      if (status.isGranted) {
        await _checkLocationService();
        return true;
      } else if (status.isDenied) {
        print("❌ Location permission denied");
        return false;
      } else if (status.isPermanentlyDenied) {
        print("❌ Location permission permanently denied");
        // Bisa redirect ke settings
        await openAppSettings();
        return false;
      }

      return false;
    } catch (e) {
      print("❌ Error requesting location permission: $e");
      return false;
    }
  }

  // Get current location
  Future<Position?> getCurrentLocation() async {
    try {
      // Check permissions first
      if (!locationPermissionStatus.value.isGranted) {
        final granted = await requestLocationPermission();
        if (!granted) return null;
      }

      // Check if location service is enabled
      if (!isLocationEnabled.value) {
        final serviceEnabled = await Geolocator.isLocationServiceEnabled();
        if (!serviceEnabled) {
          print("❌ Location service is disabled");
          return null;
        }
        isLocationEnabled.value = true;
      }

      final LocationSettings locationSettings = LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 100,
        timeLimit: Duration(seconds: 10),
      );

      // Get position with timeout
      final position = await Geolocator.getCurrentPosition(
        locationSettings: locationSettings,
      );

      currentPosition.value = position;
      print("✅ Location obtained: ${position.latitude}, ${position.longitude}");
      return position;
    } catch (e) {
      print("❌ Error getting location: $e");
      return null;
    }
  }

  // Get location with retry
  Future<Position?> getCurrentLocationWithRetry({int maxRetries = 3}) async {
    for (int i = 0; i < maxRetries; i++) {
      final position = await getCurrentLocation();
      if (position != null) return position;

      print("🔄 Retry getting location ${i + 1}/$maxRetries");
      await Future.delayed(Duration(seconds: 2));
    }

    return null;
  }

  // Check if location data is available
  bool get hasLocation => currentPosition.value != null;

  // Get current coordinates
  Map<String, double>? get coordinates {
    final pos = currentPosition.value;
    if (pos == null) return null;

    return {'latitude': pos.latitude, 'longitude': pos.longitude};
  }

  // Get location accuracy info
  String getLocationInfo() {
    final pos = currentPosition.value;
    if (pos == null) return 'No location data';

    return 'Lat: ${pos.latitude.toStringAsFixed(6)}, '
        'Lng: ${pos.longitude.toStringAsFixed(6)}, '
        'Accuracy: ${pos.accuracy.toStringAsFixed(1)}m';
  }
}
