class WorkerDashboardData {
  const WorkerDashboardData({
    required this.profileCompleted,
    required this.user,
    required this.profile,
    required this.statistics,
    required this.earnings,
    required this.incomingRequests,
    required this.pendingApplications,
    required this.activeJobs,
    required this.recentActivity,
  });

  final bool profileCompleted;
  final WorkerDashboardUser user;
  final WorkerDashboardProfile profile;
  final WorkerDashboardStatistics statistics;
  final WorkerDashboardEarnings earnings;
  final List<Map<String, dynamic>> incomingRequests;
  final List<Map<String, dynamic>> pendingApplications;
  final List<Map<String, dynamic>> activeJobs;
  final List<Map<String, dynamic>> recentActivity;

  factory WorkerDashboardData.fromJson(Map<String, dynamic> json) {
    final worker = _asMap(json['worker']);

    return WorkerDashboardData(
      profileCompleted: json['profile_completed'] == true,
      user: WorkerDashboardUser.fromJson(_asMap(worker['user'])),
      profile: WorkerDashboardProfile.fromJson(_asMap(worker['profile'])),
      statistics: WorkerDashboardStatistics.fromJson(
        _asMap(json['statistics']),
      ),
      earnings: WorkerDashboardEarnings.fromJson(_asMap(json['earnings'])),
      incomingRequests: _asMapList(json['incoming_requests']),
      pendingApplications: _asMapList(json['pending_applications']),
      activeJobs: _asMapList(json['active_jobs']),
      recentActivity: _asMapList(json['recent_activity']),
    );
  }
}

class WorkerDashboardUser {
  const WorkerDashboardUser({
    required this.id,
    required this.fullName,
    required this.phone,
    required this.email,
    required this.role,
    required this.profilePhoto,
    required this.location,
    required this.isVerified,
  });

  final int id;
  final String fullName;
  final String phone;
  final String email;
  final String role;
  final String? profilePhoto;
  final String? location;
  final bool isVerified;

  factory WorkerDashboardUser.fromJson(Map<String, dynamic> json) {
    return WorkerDashboardUser(
      id: _asInt(json['id']),
      fullName: _asString(json['full_name']),
      phone: _asString(json['phone']),
      email: _asString(json['email']),
      role: _asString(json['role']),
      profilePhoto: _asNullableString(json['profile_photo']),
      location: _asNullableString(json['location']),
      isVerified: json['is_verified'] == true,
    );
  }
}

class WorkerDashboardProfile {
  const WorkerDashboardProfile({
    required this.id,
    required this.userId,
    required this.age,
    required this.religion,
    required this.gender,
    required this.district,
    required this.workType,
    required this.bio,
    required this.experienceYears,
    required this.availability,
    required this.rating,
    required this.totalReviews,
    required this.jobsCompleted,
    required this.profileCompleted,
    required this.galleryImages,
  });

  final int id;
  final int userId;
  final int age;
  final String religion;
  final String gender;
  final String district;
  final String workType;
  final String? bio;
  final int experienceYears;
  final String availability;
  final double rating;
  final int totalReviews;
  final int jobsCompleted;
  final bool profileCompleted;
  final List<WorkerDashboardGalleryImage> galleryImages;

  factory WorkerDashboardProfile.fromJson(Map<String, dynamic> json) {
    final gallery = json['gallery_images'];

    return WorkerDashboardProfile(
      id: _asInt(json['id']),
      userId: _asInt(json['user_id']),
      age: _asInt(json['age']),
      religion: _asString(json['religion']),
      gender: _asString(json['gender']),
      district: _asString(json['district']),
      workType: _asString(json['work_type']),
      bio: _asNullableString(json['bio']),
      experienceYears: _asInt(json['experience_years']),
      availability: _asString(json['availability']),
      rating: _asDouble(json['rating']),
      totalReviews: _asInt(json['total_reviews']),
      jobsCompleted: _asInt(json['jobs_completed']),
      profileCompleted: json['profile_completed'] == true,
      galleryImages:
          gallery is List
              ? gallery
                  .whereType<Map>()
                  .map(
                    (item) => WorkerDashboardGalleryImage.fromJson(
                      Map<String, dynamic>.from(item),
                    ),
                  )
                  .toList()
              : const [],
    );
  }
}

class WorkerDashboardGalleryImage {
  const WorkerDashboardGalleryImage({
    required this.id,
    required this.imagePath,
    required this.position,
  });

  final int id;
  final String imagePath;
  final int position;

  factory WorkerDashboardGalleryImage.fromJson(Map<String, dynamic> json) {
    return WorkerDashboardGalleryImage(
      id: _asInt(json['id']),
      imagePath: _asString(json['image_path']),
      position: _asInt(json['position']),
    );
  }
}

class WorkerDashboardStatistics {
  const WorkerDashboardStatistics({
    required this.jobsCompleted,
    required this.rating,
    required this.totalReviews,
    required this.pendingApplications,
    required this.acceptedApplications,
    required this.activeJobs,
  });

  final int jobsCompleted;
  final double rating;
  final int totalReviews;
  final int pendingApplications;
  final int acceptedApplications;
  final int activeJobs;

  factory WorkerDashboardStatistics.fromJson(Map<String, dynamic> json) {
    return WorkerDashboardStatistics(
      jobsCompleted: _asInt(json['jobs_completed']),
      rating: _asDouble(json['rating']),
      totalReviews: _asInt(json['total_reviews']),
      pendingApplications: _asInt(json['pending_applications']),
      acceptedApplications: _asInt(json['accepted_applications']),
      activeJobs: _asInt(json['active_jobs']),
    );
  }
}

class WorkerDashboardEarnings {
  const WorkerDashboardEarnings({
    required this.currency,
    required this.thisMonth,
    required this.pending,
    required this.total,
  });

  final String currency;
  final double thisMonth;
  final double pending;
  final double total;

  factory WorkerDashboardEarnings.fromJson(Map<String, dynamic> json) {
    return WorkerDashboardEarnings(
      currency: _asString(json['currency']),
      thisMonth: _asDouble(json['this_month']),
      pending: _asDouble(json['pending']),
      total: _asDouble(json['total']),
    );
  }
}

Map<String, dynamic> _asMap(dynamic value) {
  if (value is Map<String, dynamic>) {
    return value;
  }

  if (value is Map) {
    return Map<String, dynamic>.from(value);
  }

  return <String, dynamic>{};
}

List<Map<String, dynamic>> _asMapList(dynamic value) {
  if (value is! List) {
    return <Map<String, dynamic>>[];
  }

  return value
      .whereType<Map>()
      .map((item) => Map<String, dynamic>.from(item))
      .toList();
}

String _asString(dynamic value) {
  return value?.toString() ?? '';
}

String? _asNullableString(dynamic value) {
  if (value == null) {
    return null;
  }

  final text = value.toString().trim();

  return text.isEmpty ? null : text;
}

int _asInt(dynamic value) {
  if (value is int) {
    return value;
  }

  if (value is num) {
    return value.toInt();
  }

  return int.tryParse(value?.toString() ?? '') ?? 0;
}

double _asDouble(dynamic value) {
  if (value is double) {
    return value;
  }

  if (value is num) {
    return value.toDouble();
  }

  return double.tryParse(value?.toString() ?? '') ?? 0;
}
