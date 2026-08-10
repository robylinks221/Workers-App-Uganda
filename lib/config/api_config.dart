class ApiConfig {
  ApiConfig._();

  static const String baseUrl = 'http://localhost/api';

  static const String guestWorkers = '$baseUrl/guest/workers';
  static const String guestServiceCategories =
      '$baseUrl/guest/service-categories';
  static String guestWorkerProfile(int workerId) =>
      '$baseUrl/guest/workers/$workerId/profile';

  static const String login = '$baseUrl/login';
  static const String register = '$baseUrl/register';
  static const String logout = '$baseUrl/logout';
  static const String me = '$baseUrl/me';
  static const String notifications = '$baseUrl/notifications';
  static const String notificationUnreadCount =
      '$baseUrl/notifications/unread-count';
  static const String notificationReadAll = '$baseUrl/notifications/read-all';
  static String notification(int id) => '$baseUrl/notifications/$id';
  static String notificationRead(int id) => '$baseUrl/notifications/$id/read';

  static const String deviceTokens = '$baseUrl/device-tokens';

  static const String accountStatus = '$baseUrl/account/status';
  static const String accountAppeals = '$baseUrl/account/appeals';
  static const String accountDeactivate = '$baseUrl/account/deactivate';
  static const String accountRequestDeletion =
      '$baseUrl/account/request-deletion';

  static const String adminDashboard = '$baseUrl/admin/dashboard';
  static const String adminWorkerVerifications =
      '$baseUrl/admin/worker-verifications';
  static const String adminUsers = '$baseUrl/admin/users';
  static const String adminAccountAppeals = '$baseUrl/admin/account-appeals';

  static String adminApproveAppeal(int id) =>
      '$baseUrl/admin/account-appeals/$id/approve';

  static String adminRejectAppeal(int id) =>
      '$baseUrl/admin/account-appeals/$id/reject';
  static String adminUser(int userId) => '$baseUrl/admin/users/$userId';
  static String adminSuspendUser(int userId) =>
      '$baseUrl/admin/users/$userId/suspend';
  static String adminActivateUser(int userId) =>
      '$baseUrl/admin/users/$userId/activate';
  static String adminDeactivateUser(int userId) =>
      '$baseUrl/admin/users/$userId/deactivate';
  static String adminWorkerVerification(int profileId) =>
      '$baseUrl/admin/worker-verifications/$profileId';
  static String adminApproveWorker(int profileId) =>
      '$baseUrl/admin/worker-verifications/$profileId/approve';
  static String adminRejectWorker(int profileId) =>
      '$baseUrl/admin/worker-verifications/$profileId/reject';

  static const String serviceCategories = '$baseUrl/service-categories';

  static const String workerProfile = '$baseUrl/worker/profile';
  static const String workerVerificationResubmit =
      '$baseUrl/worker/profile/resubmit-verification';
  static const String workerDashboard = '$baseUrl/worker/dashboard';
  static const String workerHome = '$baseUrl/worker/home';
  static const String workerApplications = '$baseUrl/worker/applications';
  static const String workerWorkWanted = '$baseUrl/worker/work-wanted';
  static const String homeownerWorkWanted = '$baseUrl/homeowner/work-wanted';
  static String workWantedPost(int id) => '$baseUrl/worker/work-wanted/$id';
  static String workWantedStatus(int id) =>
      '$baseUrl/worker/work-wanted/$id/status';

  static String workerJob(int jobId) => '$baseUrl/worker/jobs/$jobId';

  static String workerApply(int jobId) => '$baseUrl/worker/jobs/$jobId/apply';

  static String workerWithdrawApplication(int applicationId) =>
      '$baseUrl/worker/applications/$applicationId/withdraw';

  static String workerAcceptInvitation(int applicationId) =>
      '$baseUrl/worker/invitations/$applicationId/accept';

  static String workerDeclineInvitation(int applicationId) =>
      '$baseUrl/worker/invitations/$applicationId/decline';

  static String workerActiveJob(int jobId) =>
      '$baseUrl/worker/active-jobs/$jobId';

  static String workerStartJob(int jobId) =>
      '$baseUrl/worker/active-jobs/$jobId/start';

  static String workerCompleteJob(int jobId) =>
      '$baseUrl/worker/active-jobs/$jobId/complete';

  static const String homeownerProfile = '$baseUrl/homeowner/profile';

  static const String homeownerJobs = '$baseUrl/homeowner/jobs';

  static String homeownerJob(int jobId) => '$baseUrl/homeowner/jobs/$jobId';

  static String homeownerJobApplications(int jobId) =>
      '$baseUrl/homeowner/jobs/$jobId/applications';

  static String homeownerAcceptApplication(int applicationId) =>
      '$baseUrl/homeowner/applications/$applicationId/accept';

  static String homeownerDeclineApplication(int applicationId) =>
      '$baseUrl/homeowner/applications/$applicationId/decline';

  static String homeownerConfirmCompletion(int jobId) =>
      '$baseUrl/homeowner/jobs/$jobId/confirm-completion';

  static String homeownerReviewJob(int jobId) =>
      '$baseUrl/homeowner/jobs/$jobId/review';

  static String homeownerInviteWorker(int jobId) =>
      '$baseUrl/homeowner/jobs/$jobId/invite-worker';

  static const String conversations = '$baseUrl/conversations';

  static String conversation(int id) => '$baseUrl/conversations/$id';

  static String conversationMessages(int id) =>
      '$baseUrl/conversations/$id/messages';

  static String markConversationRead(int id) =>
      '$baseUrl/conversations/$id/read';

  static String archiveConversation(int id) =>
      '$baseUrl/conversations/$id/archive';

  static String restoreConversation(int id) =>
      '$baseUrl/conversations/$id/restore';

  static String message(int id) => '$baseUrl/messages/$id';

  static const String hiringAvailableJobs = '$baseUrl/hiring/available-jobs';
  static const String hiringRequests = '$baseUrl/hiring/requests';
  static const String directHiringOffers = '$baseUrl/hiring/direct-offers';
  static const String quickHiringRequests = '$baseUrl/hiring/quick-requests';
  static const String homeownerHiringRequests = '$baseUrl/hiring/homeowner';
  static const String workerHiringRequests = '$baseUrl/hiring/worker';

  static String hiringRequest(int requestId) =>
      '$baseUrl/hiring/requests/$requestId';

  static String acceptHiringRequest(int requestId) =>
      '$baseUrl/hiring/requests/$requestId/accept';

  static String declineHiringRequest(int requestId) =>
      '$baseUrl/hiring/requests/$requestId/decline';

  static String cancelHiringRequest(int requestId) =>
      '$baseUrl/hiring/requests/$requestId/cancel';

  static String completeHiringRequest(int requestId) =>
      '$baseUrl/hiring/requests/$requestId/complete';

  static String workerIdentityAccessStatus(int workerId) =>
      '$baseUrl/identity-access/workers/$workerId';

  static String requestWorkerIdentityAccess(int workerId) =>
      '$baseUrl/identity-access/workers/$workerId/request';

  static String homeownerWorkerIdentityDocument(int workerId, String side) =>
      '$baseUrl/identity-access/workers/$workerId/document/$side';

  static String adminWorkerIdentityDocument(int profileId, String side) =>
      '$baseUrl/admin/worker-verifications/$profileId/id/$side';

  static const String mediaBaseUrl = '$baseUrl/media';

  static String storageUrl(String? path) {
    if (path == null || path.trim().isEmpty) {
      return '';
    }

    final value = path.trim();
    const oldPrefix = 'http://localhost/storage/';

    if (value.startsWith(oldPrefix)) {
      return '$mediaBaseUrl/'
          '${value.substring(oldPrefix.length)}';
    }

    if (value.startsWith('$mediaBaseUrl/')) {
      return value;
    }

    if (value.startsWith('http://') || value.startsWith('https://')) {
      return value;
    }

    final clean = value.startsWith('/') ? value.substring(1) : value;

    return '$mediaBaseUrl/$clean';
  }

  static String workerWithdrawActiveJob(int jobId) =>
      '$baseUrl/worker/active-jobs/$jobId/withdraw';

  static String homeownerCancelActiveJob(int jobId) =>
      '$baseUrl/homeowner/active-jobs/$jobId/cancel';
}
