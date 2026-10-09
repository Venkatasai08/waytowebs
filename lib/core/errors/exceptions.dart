class ServerException implements Exception {
  final String message;
  ServerException([this.message = 'Server exception occurred']);
}

class ZohoAuthException implements Exception {
  final String message;
  ZohoAuthException([this.message = 'Mobile number is not verified in Zoho']);
}

class PlumberVerificationException implements Exception {
  final String message;
  PlumberVerificationException([this.message = 'Plumber verification failed']);
}

class CacheException implements Exception {
  final String message;
  CacheException([this.message = 'Cache exception occurred']);
}
