import 'package:geolocator/geolocator.dart';

Future<Position> _getCurrentLocation() async {
  bool serviceEnabled;
  LocationPermission permission;

  serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) {
    return Future.error('O serviço de localização está desativado.');
  }

  permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
      return Future.error('Permissão de localização foi negada.');
    }
  }

  if (permission == LocationPermission.deniedForever) {
    return Future.error(
        'Permissões de localização foram negadas permanentemente, não podemos solicitar permissões.');
  }

  return await Geolocator.getCurrentPosition();
}
