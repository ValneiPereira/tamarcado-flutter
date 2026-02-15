class RouteNames {
  RouteNames._();

  // Auth
  static const String login = '/';
  static const String chooseType = '/choose-type';
  static const String registerClient = '/register-client';
  static const String registerProfessional = '/register-professional';
  static const String forgotPassword = '/forgot-password';
  static const String resetPassword = '/reset-password';

  // Client
  static const String clientHome = '/client/home';
  static const String professionalDetail = '/client/professional/:id';
  static const String clientAppointments = '/client/appointments';
  static const String clientProfile = '/client/profile';
  static const String clientEditProfile = '/client/edit-profile';
  static const String clientAddresses = '/client/addresses';
  static const String clientChangePassword = '/client/change-password';

  // Professional
  static const String professionalDashboard = '/professional/dashboard';
  static const String professionalAppointments = '/professional/appointments';
  static const String professionalProfile = '/professional/profile';
  static const String professionalServices = '/professional/services';
  static const String professionalEditProfile = '/professional/edit-profile';
  static const String professionalAddress = '/professional/address';
  static const String professionalChangePassword = '/professional/change-password';
}
