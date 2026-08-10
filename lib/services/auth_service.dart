// Compatibility export.
//
// The app now has one canonical AuthService implementation under
// features/auth/services. Older imports of services/auth_service.dart keep
// working through this export while new code should import the canonical file.
export '../features/auth/services/auth_service.dart';
