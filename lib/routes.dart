import 'package:flutter/material.dart';

// Auth
import 'screens/auth/language_selection_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/auth/emergency_now_screen.dart';

// Main app shell
import 'screens/home/main_shell.dart';

// Main app tab screens
import 'screens/home/home_screen.dart';
import 'screens/home/manual_report_screen.dart';
import 'screens/home/detect_screen.dart';
import 'screens/home/guidance_screen.dart';
import 'screens/home/contacts_screen.dart';
import 'screens/home/emergency_profile_screen.dart';
import 'screens/home/history_screen.dart';
import 'screens/home/assist_screen.dart';
import 'screens/home/settings_screen.dart';
import 'screens/home/notification_screen.dart';

// Shared / normal flow screens
import 'screens/flow/report_role_screen.dart';
import 'screens/flow/upload_screen.dart';
import 'screens/flow/manual_guidance_screen.dart';
import 'screens/flow/analysis_result_screen.dart';
import 'screens/flow/victim_details_screen.dart';
import 'screens/flow/sos_preview_screen.dart';
import 'screens/flow/call_script_screen.dart';
import 'screens/flow/report_status_screen.dart';
import 'screens/flow/live_tracking_screen.dart';
import 'screens/flow/report_detail_screen.dart';

// Emergency-only flow screens
import 'screens/flow/guest_manual_report_screen.dart';

import 'screens/flow/emergency_guidance_screen.dart';
// Add these later when you create them:
import 'screens/flow/emergency_upload_screen.dart';
import 'screens/flow/emergency_analysis_result_screen.dart';
// import 'screens/flow/emergency_victim_details_screen.dart';
import 'screens/flow/emergency_call_script_screen.dart';
import 'screens/flow/emergency_sos_preview_screen.dart';
import 'screens/flow/emergency_report_status_screen.dart';
import 'screens/flow/emergency_live_tracking_screen.dart';

class AppRoutes {
  // Auth / entry
  static const String languageSelection = '/language-selection';
  static const String login = '/login';
  static const String register = '/register';
  static const String emergencyNow = '/emergency-now';

  // Main signed-in shell
  static const String mainShell = '/main';

  // Main tab routes
  static const String home = '/home';
  static const manualReport = '/manual-report';
  static const String detect = '/detect';
  static const String guidance = '/guidance';
  static const String contacts = '/contacts';
  static const String emergencyProfile = '/emergency-profile';
  static const String history = '/history';
  static const String settings = '/settings';
  static const String assist = '/assist';
  static const String notifications = '/notifications';

  // Shared / current flow routes
  static const String reportRole = '/report-role';
  static const String fakeDetectionUpload = '/fake-detection-upload';
  static const String fakeDetectionResult = '/fake-detection-result';
  static const String fakedetection = '/fakedetection';
  static const String manualGuidance = '/manualguidance';
  static const String upload = '/upload';
  static const String analysisResult = '/analysis-result';
  static const String victimDetails = '/victim-details';
  static const String sosPreview = '/sos-preview';
  static const String callScript = '/call-script';
  static const String reportStatus = '/report-status';
  static const String liveTracking = '/live-tracking';
  static const String reportDetail = '/report-detail';

  // Emergency-only routes
  static const String guestManualReport = '/guest-manual-report';
  static const String emergencyGuidance = '/emergency-guidance';

  // Add these later when files are created:
  static const String emergencyUpload = '/emergency-upload';
  static const String emergencyAnalysisResult = '/emergency-analysis-result';
  static const String emergencyCallScript = '/emergency-call-script';
  // static const String emergencyVictimDetails = '/emergency-victim-details';
  static const String emergencySosPreview = '/emergency-sos-preview';
  static const String emergencyReportStatus = '/emergency-report-status';
  static const String emergencyLiveTracking = '/emergency-live-tracking';

  static Map<String, WidgetBuilder> get map => {
    // Auth / entry
    languageSelection: (_) => const LanguageSelectionScreen(),
    login: (_) => const LoginScreen(),
    register: (_) => const RegisterScreen(),
    emergencyNow: (_) => const EmergencyNowScreen(),

    // Main app shell
    mainShell: (_) => const MainShell(),

    // Main tab routes
    home: (_) => const HomeScreen(),
    manualReport: (_) => const ManualReportScreen(),
    detect: (_) => const DetectScreen(),
    guidance: (_) => const GuidanceScreen(),
    emergencyProfile: (_) => const EmergencyProfileScreen(),
    contacts: (_) => const ContactsScreen(),
    history: (_) => const HistoryScreen(),
    settings: (_) => const SettingsScreen(),
    assist: (_) => const AssistScreen(),
    notifications: (_) => const NotificationScreen(),

    // Shared / current flow
    reportRole: (_) => const ReportRoleScreen(),

    upload: (_) => const UploadScreen(),
    analysisResult: (_) => const AnalysisResultScreen(),
    victimDetails: (_) => const VictimDetailsScreen(),
    callScript: (_) => const CallScriptScreen(),
    reportStatus: (_) => const ReportStatusScreen(),
    liveTracking: (_) => const LiveTrackingScreen(),
    reportDetail: (_) => const ReportDetailScreen(),

    // Emergency-only
    guestManualReport: (_) => const GuestManualReportScreen(),
    emergencyGuidance: (_) => const EmergencyGuidanceScreen(),
    emergencyCallScript: (_) => const EmergencyCallScriptScreen(),
    // Add these later when created:
    emergencyUpload: (_) => const EmergencyUploadScreen(),
    emergencyAnalysisResult: (_) => const EmergencyAnalysisResultScreen(),
    // emergencyVictimDetails: (_) => const EmergencyVictimDetailsScreen(),
    emergencySosPreview: (_) => const EmergencySosPreviewScreen(),
    emergencyReportStatus: (_) => const EmergencyReportStatusScreen(),
    emergencyLiveTracking: (_) => const EmergencyLiveTrackingScreen(),
  };

  static Future<T?> go<T>(
    BuildContext context,
    String routeName, {
    Object? arguments,
  }) {
    return Navigator.pushNamed<T>(context, routeName, arguments: arguments);
  }

  static Future<T?> replace<T>(
    BuildContext context,
    String routeName, {
    Object? arguments,
  }) {
    return Navigator.pushReplacementNamed<T, T>(
      context,
      routeName,
      arguments: arguments,
    );
  }

  static Future<T?> clearAndGo<T>(
    BuildContext context,
    String routeName, {
    Object? arguments,
  }) {
    return Navigator.pushNamedAndRemoveUntil<T>(
      context,
      routeName,
      (route) => false,
      arguments: arguments,
    );
  }
}
