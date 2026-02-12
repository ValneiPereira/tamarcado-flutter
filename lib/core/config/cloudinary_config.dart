class CloudinaryConfig {
  CloudinaryConfig._();

  static const String cloudName = 'deacxqwqw';
  static const String uploadPreset = 'scheduly_avatars';
  static const String folder = 'avatars';

  static const List<String> fallbackPresets = [
    'scheduly_avatars',
    'avatars',
    'unsigned_upload',
    'ml_default',
  ];

  static String get uploadUrl =>
      'https://api.cloudinary.com/v1_1/$cloudName/image/upload';
}
