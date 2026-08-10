class WorkerHomeData {
  const WorkerHomeData({
    required this.profileCompleted,
    required this.user,
    required this.profile,
    required this.summary,
    required this.activeJobs,
    required this.recommendedJobs,
    required this.urgentJobs,
    required this.nearbyJobs,
    required this.recentJobs,
  });

  final bool profileCompleted;
  final WorkerHomeUser user;
  final WorkerHomeProfile profile;
  final WorkerHomeSummary summary;
  final List<WorkerHomeJob> activeJobs;
  final List<WorkerHomeJob> recommendedJobs;
  final List<WorkerHomeJob> urgentJobs;
  final List<WorkerHomeJob> nearbyJobs;
  final List<WorkerHomeJob> recentJobs;

  factory WorkerHomeData.fromJson(Map<String, dynamic> json) {
    final worker = _asMap(json['worker']);

    return WorkerHomeData(
      profileCompleted: json['profile_completed'] == true,
      user: WorkerHomeUser.fromJson(_asMap(worker['user'])),
      profile: WorkerHomeProfile.fromJson(_asMap(worker['profile'])),
      summary: WorkerHomeSummary.fromJson(_asMap(json['summary'])),
      activeJobs: _jobList(json['active_jobs']),
      recommendedJobs: _jobList(json['recommended_jobs']),
      urgentJobs: _jobList(json['urgent_jobs']),
      nearbyJobs: _jobList(json['nearby_jobs']),
      recentJobs: _jobList(json['recent_jobs']),
    );
  }
}

class WorkerHomeUser {
  const WorkerHomeUser({
    required this.id,
    required this.fullName,
    required this.profilePhoto,
    required this.location,
    required this.isVerified,
  });

  final int id;
  final String fullName;
  final String? profilePhoto;
  final String? location;
  final bool isVerified;

  factory WorkerHomeUser.fromJson(Map<String, dynamic> json) {
    return WorkerHomeUser(
      id: _asInt(json['id']),
      fullName: _asString(json['full_name']),
      profilePhoto: _asNullableString(json['profile_photo']),
      location: _asNullableString(json['location']),
      isVerified: json['is_verified'] == true,
    );
  }
}

class WorkerHomeProfile {
  const WorkerHomeProfile({
    required this.district,
    required this.availability,
    required this.rating,
    required this.jobsCompleted,
  });

  final String district;
  final String availability;
  final double rating;
  final int jobsCompleted;

  factory WorkerHomeProfile.fromJson(Map<String, dynamic> json) {
    return WorkerHomeProfile(
      district: _asString(json['district']),
      availability: _asString(json['availability']),
      rating: _asDouble(json['rating']),
      jobsCompleted: _asInt(json['jobs_completed']),
    );
  }
}

class WorkerHomeSummary {
  const WorkerHomeSummary({
    required this.pendingApplications,
    required this.activeJobs,
    required this.availableJobs,
  });

  final int pendingApplications;
  final int activeJobs;
  final int availableJobs;

  factory WorkerHomeSummary.fromJson(Map<String, dynamic> json) {
    return WorkerHomeSummary(
      pendingApplications: _asInt(json['pending_applications']),
      activeJobs: _asInt(json['active_jobs']),
      availableJobs: _asInt(json['available_jobs']),
    );
  }
}

class WorkerHomeJob {
  const WorkerHomeJob({
    required this.id,
    required this.title,
    required this.category,
    required this.description,
    required this.address,
    required this.district,
    required this.startDate,
    required this.startTime,
    required this.duration,
    required this.budgetType,
    required this.budgetAmount,
    required this.status,
    required this.isUrgent,
    required this.postedAt,
    required this.homeowner,
  });

  final int id;
  final String title;
  final String category;
  final String description;
  final String address;
  final String district;
  final String startDate;
  final String startTime;
  final String duration;
  final String budgetType;
  final double budgetAmount;
  final String status;
  final bool isUrgent;
  final String postedAt;
  final WorkerHomeHomeowner? homeowner;

  factory WorkerHomeJob.fromJson(Map<String, dynamic> json) {
    final homeownerMap = _asMap(json['homeowner']);

    return WorkerHomeJob(
      id: _asInt(json['id']),
      title: _asString(json['title']),
      category: _asString(json['category']),
      description: _asString(json['description']),
      address: _asString(json['address']),
      district: _asString(json['district']),
      startDate: _asString(json['start_date']),
      startTime: _asString(json['start_time']),
      duration: _asString(json['duration']),
      budgetType: _asString(json['budget_type']),
      budgetAmount: _asDouble(json['budget_amount']),
      status: _asString(json['status']),
      isUrgent: json['is_urgent'] == true,
      postedAt: _asString(json['posted_at']),
      homeowner:
          homeownerMap.isEmpty
              ? null
              : WorkerHomeHomeowner.fromJson(homeownerMap),
    );
  }
}

class WorkerHomeHomeowner {
  const WorkerHomeHomeowner({
    required this.id,
    required this.fullName,
    required this.profilePhoto,
    required this.location,
    required this.isVerified,
  });

  final int id;
  final String fullName;
  final String? profilePhoto;
  final String? location;
  final bool isVerified;

  factory WorkerHomeHomeowner.fromJson(Map<String, dynamic> json) {
    return WorkerHomeHomeowner(
      id: _asInt(json['id']),
      fullName: _asString(json['full_name']),
      profilePhoto: _asNullableString(json['profile_photo']),
      location: _asNullableString(json['location']),
      isVerified: json['is_verified'] == true,
    );
  }
}

List<WorkerHomeJob> _jobList(dynamic value) {
  if (value is! List) return const [];

  return value
      .whereType<Map>()
      .map((item) => WorkerHomeJob.fromJson(Map<String, dynamic>.from(item)))
      .toList();
}

Map<String, dynamic> _asMap(dynamic value) {
  if (value is Map<String, dynamic>) return value;
  if (value is Map) return Map<String, dynamic>.from(value);
  return <String, dynamic>{};
}

String _asString(dynamic value) => value?.toString() ?? '';

String? _asNullableString(dynamic value) {
  final text = value?.toString().trim() ?? '';
  return text.isEmpty ? null : text;
}

int _asInt(dynamic value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value?.toString() ?? '') ?? 0;
}

double _asDouble(dynamic value) {
  if (value is double) return value;
  if (value is num) return value.toDouble();
  return double.tryParse(value?.toString() ?? '') ?? 0;
}
