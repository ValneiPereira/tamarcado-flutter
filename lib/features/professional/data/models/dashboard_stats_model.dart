class ProfessionalDashboardModel {
  final int todayAppointments;
  final int pendingAppointments;
  final double averageRating;
  final int totalRatings;
  final double monthRevenue;
  final int completedThisMonth;

  const ProfessionalDashboardModel({
    this.todayAppointments = 0,
    this.pendingAppointments = 0,
    this.averageRating = 0,
    this.totalRatings = 0,
    this.monthRevenue = 0,
    this.completedThisMonth = 0,
  });

  factory ProfessionalDashboardModel.fromJson(Map<String, dynamic> json) {
    return ProfessionalDashboardModel(
      todayAppointments: json['todayAppointments'] as int? ?? 0,
      pendingAppointments: json['pendingAppointments'] as int? ?? 0,
      averageRating: (json['averageRating'] as num?)?.toDouble() ?? 0,
      totalRatings: json['totalRatings'] as int? ?? 0,
      monthRevenue: (json['monthRevenue'] as num?)?.toDouble() ?? 0,
      completedThisMonth: json['completedThisMonth'] as int? ?? 0,
    );
  }
}

class ClientDashboardModel {
  final int upcomingAppointments;
  final int completedAppointments;
  final String? favoriteCategory;

  const ClientDashboardModel({
    this.upcomingAppointments = 0,
    this.completedAppointments = 0,
    this.favoriteCategory,
  });

  factory ClientDashboardModel.fromJson(Map<String, dynamic> json) {
    return ClientDashboardModel(
      upcomingAppointments: json['upcomingAppointments'] as int? ?? 0,
      completedAppointments: json['completedAppointments'] as int? ?? 0,
      favoriteCategory: json['favoriteCategory'] as String?,
    );
  }
}
