import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ms.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('ms')
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Emergency AI'**
  String get appTitle;

  /// No description provided for @chooseLanguage.
  ///
  /// In en, this message translates to:
  /// **'Choose Language'**
  String get chooseLanguage;

  /// No description provided for @chooseLanguageSub.
  ///
  /// In en, this message translates to:
  /// **'Please choose your app language'**
  String get chooseLanguageSub;

  /// No description provided for @changeLater.
  ///
  /// In en, this message translates to:
  /// **'You can change language later in Settings'**
  String get changeLater;

  /// No description provided for @chooseLanguageSheet.
  ///
  /// In en, this message translates to:
  /// **'Choose Language'**
  String get chooseLanguageSheet;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @languageChangedEnglish.
  ///
  /// In en, this message translates to:
  /// **'Language changed to English'**
  String get languageChangedEnglish;

  /// No description provided for @languageChangedMalay.
  ///
  /// In en, this message translates to:
  /// **'Language changed to Bahasa Melayu'**
  String get languageChangedMalay;

  /// No description provided for @login.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get login;

  /// No description provided for @register.
  ///
  /// In en, this message translates to:
  /// **'Register'**
  String get register;

  /// No description provided for @signIn.
  ///
  /// In en, this message translates to:
  /// **'Sign In'**
  String get signIn;

  /// No description provided for @createAccount.
  ///
  /// In en, this message translates to:
  /// **'Create Account'**
  String get createAccount;

  /// No description provided for @logOut.
  ///
  /// In en, this message translates to:
  /// **'Log Out'**
  String get logOut;

  /// No description provided for @welcomeBack.
  ///
  /// In en, this message translates to:
  /// **'Welcome Back'**
  String get welcomeBack;

  /// No description provided for @signInEmergencyApp.
  ///
  /// In en, this message translates to:
  /// **'Sign in to Emergency AI App'**
  String get signInEmergencyApp;

  /// No description provided for @dontHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account?'**
  String get dontHaveAccount;

  /// No description provided for @alreadyHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Already have an account?'**
  String get alreadyHaveAccount;

  /// No description provided for @registerDesc.
  ///
  /// In en, this message translates to:
  /// **'Register to save reports, manage contacts, and get personalized AI assistance.'**
  String get registerDesc;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @emailAddress.
  ///
  /// In en, this message translates to:
  /// **'Email address'**
  String get emailAddress;

  /// No description provided for @emailRequired.
  ///
  /// In en, this message translates to:
  /// **'Email is required'**
  String get emailRequired;

  /// No description provided for @enterValidEmail.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid email'**
  String get enterValidEmail;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @passwordRequired.
  ///
  /// In en, this message translates to:
  /// **'Password is required'**
  String get passwordRequired;

  /// No description provided for @minimum6Characters.
  ///
  /// In en, this message translates to:
  /// **'Minimum 6 characters'**
  String get minimum6Characters;

  /// No description provided for @forgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot Password?'**
  String get forgotPassword;

  /// No description provided for @forgotPasswordLater.
  ///
  /// In en, this message translates to:
  /// **'Forgot Password: implement later'**
  String get forgotPasswordLater;

  /// No description provided for @fullName.
  ///
  /// In en, this message translates to:
  /// **'Full Name'**
  String get fullName;

  /// No description provided for @phoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Phone Number'**
  String get phoneNumber;

  /// No description provided for @phoneRequired.
  ///
  /// In en, this message translates to:
  /// **'Phone number is required'**
  String get phoneRequired;

  /// No description provided for @enterValidPhone.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid phone number'**
  String get enterValidPhone;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @profileUpdated.
  ///
  /// In en, this message translates to:
  /// **'Profile updated'**
  String get profileUpdated;

  /// No description provided for @idCardVerification.
  ///
  /// In en, this message translates to:
  /// **'ID Card Verification'**
  String get idCardVerification;

  /// No description provided for @idVerificationDesc.
  ///
  /// In en, this message translates to:
  /// **'Upload your MyKad / Passport for identity verification. This helps verify your identity during emergencies.'**
  String get idVerificationDesc;

  /// No description provided for @uploadFront.
  ///
  /// In en, this message translates to:
  /// **'Upload Front'**
  String get uploadFront;

  /// No description provided for @uploadBack.
  ///
  /// In en, this message translates to:
  /// **'Upload Back'**
  String get uploadBack;

  /// No description provided for @accountCreatedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Account created successfully'**
  String get accountCreatedSuccessfully;

  /// No description provided for @dataEncryptedSecure.
  ///
  /// In en, this message translates to:
  /// **'Your data is encrypted and stored securely'**
  String get dataEncryptedSecure;

  /// No description provided for @homeTitle.
  ///
  /// In en, this message translates to:
  /// **'Emergency AI'**
  String get homeTitle;

  /// No description provided for @locationActive.
  ///
  /// In en, this message translates to:
  /// **'Location Active • LIVE'**
  String get locationActive;

  /// No description provided for @holdToActivate.
  ///
  /// In en, this message translates to:
  /// **'Hold to activate'**
  String get holdToActivate;

  /// No description provided for @fastResponse.
  ///
  /// In en, this message translates to:
  /// **'Fast emergency response and AI-assisted detection.'**
  String get fastResponse;

  /// No description provided for @uploadIncidentPhotoAI.
  ///
  /// In en, this message translates to:
  /// **'Upload Incident Photo (AI Analysis)'**
  String get uploadIncidentPhotoAI;

  /// No description provided for @emergencyCategories.
  ///
  /// In en, this message translates to:
  /// **'Emergency Categories'**
  String get emergencyCategories;

  /// No description provided for @reportNow.
  ///
  /// In en, this message translates to:
  /// **'Report Now'**
  String get reportNow;

  /// No description provided for @whatItMayInvolve.
  ///
  /// In en, this message translates to:
  /// **'What it may involve'**
  String get whatItMayInvolve;

  /// No description provided for @accident.
  ///
  /// In en, this message translates to:
  /// **'Accident'**
  String get accident;

  /// No description provided for @accidentDesc.
  ///
  /// In en, this message translates to:
  /// **'Car crash, road accident, or vehicle collision.'**
  String get accidentDesc;

  /// No description provided for @accidentPoint1.
  ///
  /// In en, this message translates to:
  /// **'Vehicle collision'**
  String get accidentPoint1;

  /// No description provided for @accidentPoint2.
  ///
  /// In en, this message translates to:
  /// **'Road traffic accident'**
  String get accidentPoint2;

  /// No description provided for @accidentPoint3.
  ///
  /// In en, this message translates to:
  /// **'Motorcycle or car crash'**
  String get accidentPoint3;

  /// No description provided for @accidentPoint4.
  ///
  /// In en, this message translates to:
  /// **'Damaged vehicle scene'**
  String get accidentPoint4;

  /// No description provided for @fire.
  ///
  /// In en, this message translates to:
  /// **'Fire'**
  String get fire;

  /// No description provided for @fireDesc.
  ///
  /// In en, this message translates to:
  /// **'Fire outbreak, smoke, or explosion risk.'**
  String get fireDesc;

  /// No description provided for @firePoint1.
  ///
  /// In en, this message translates to:
  /// **'Smoke from building or vehicle'**
  String get firePoint1;

  /// No description provided for @firePoint2.
  ///
  /// In en, this message translates to:
  /// **'Open fire or burning object'**
  String get firePoint2;

  /// No description provided for @firePoint3.
  ///
  /// In en, this message translates to:
  /// **'Electrical fire risk'**
  String get firePoint3;

  /// No description provided for @firePoint4.
  ///
  /// In en, this message translates to:
  /// **'Explosion danger'**
  String get firePoint4;

  /// No description provided for @medical.
  ///
  /// In en, this message translates to:
  /// **'Medical'**
  String get medical;

  /// No description provided for @medicalDesc.
  ///
  /// In en, this message translates to:
  /// **'Injury, fainting, or health emergency.'**
  String get medicalDesc;

  /// No description provided for @medicalPoint1.
  ///
  /// In en, this message translates to:
  /// **'Person fainted'**
  String get medicalPoint1;

  /// No description provided for @medicalPoint2.
  ///
  /// In en, this message translates to:
  /// **'Injury or bleeding'**
  String get medicalPoint2;

  /// No description provided for @medicalPoint3.
  ///
  /// In en, this message translates to:
  /// **'Breathing difficulty'**
  String get medicalPoint3;

  /// No description provided for @medicalPoint4.
  ///
  /// In en, this message translates to:
  /// **'Unconscious patient'**
  String get medicalPoint4;

  /// No description provided for @crime.
  ///
  /// In en, this message translates to:
  /// **'Crime'**
  String get crime;

  /// No description provided for @crimeDesc.
  ///
  /// In en, this message translates to:
  /// **'Robbery, violence, or suspicious activity.'**
  String get crimeDesc;

  /// No description provided for @crimePoint1.
  ///
  /// In en, this message translates to:
  /// **'Theft or robbery'**
  String get crimePoint1;

  /// No description provided for @crimePoint2.
  ///
  /// In en, this message translates to:
  /// **'Fight or violence'**
  String get crimePoint2;

  /// No description provided for @crimePoint3.
  ///
  /// In en, this message translates to:
  /// **'Threatening situation'**
  String get crimePoint3;

  /// No description provided for @crimePoint4.
  ///
  /// In en, this message translates to:
  /// **'Suspicious activity nearby'**
  String get crimePoint4;

  /// No description provided for @hazard.
  ///
  /// In en, this message translates to:
  /// **'Hazard'**
  String get hazard;

  /// No description provided for @hazardDesc.
  ///
  /// In en, this message translates to:
  /// **'Flood, gas leak, fallen tree, or dangerous environment.'**
  String get hazardDesc;

  /// No description provided for @hazardPoint1.
  ///
  /// In en, this message translates to:
  /// **'Flooded area'**
  String get hazardPoint1;

  /// No description provided for @hazardPoint2.
  ///
  /// In en, this message translates to:
  /// **'Gas leak suspicion'**
  String get hazardPoint2;

  /// No description provided for @hazardPoint3.
  ///
  /// In en, this message translates to:
  /// **'Fallen tree or debris'**
  String get hazardPoint3;

  /// No description provided for @hazardPoint4.
  ///
  /// In en, this message translates to:
  /// **'Unsafe environment'**
  String get hazardPoint4;

  /// No description provided for @reportRoleHeader.
  ///
  /// In en, this message translates to:
  /// **'Emergency Report'**
  String get reportRoleHeader;

  /// No description provided for @whoNeedsHelp.
  ///
  /// In en, this message translates to:
  /// **'Who Needs Help?'**
  String get whoNeedsHelp;

  /// No description provided for @selectYourRole.
  ///
  /// In en, this message translates to:
  /// **'Select your role so we can assist you better.'**
  String get selectYourRole;

  /// No description provided for @iNeedHelp.
  ///
  /// In en, this message translates to:
  /// **'I Need Help'**
  String get iNeedHelp;

  /// No description provided for @iAmVictim.
  ///
  /// In en, this message translates to:
  /// **'You are the victim or in danger.'**
  String get iAmVictim;

  /// No description provided for @someoneElseNeedsHelp.
  ///
  /// In en, this message translates to:
  /// **'Someone Else Needs Help'**
  String get someoneElseNeedsHelp;

  /// No description provided for @reportingAnotherPerson.
  ///
  /// In en, this message translates to:
  /// **'You are reporting for another person.'**
  String get reportingAnotherPerson;

  /// No description provided for @continueText.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueText;

  /// No description provided for @uploadReport.
  ///
  /// In en, this message translates to:
  /// **'Upload Report'**
  String get uploadReport;

  /// No description provided for @uploadIncidentPhoto.
  ///
  /// In en, this message translates to:
  /// **'Upload Incident Photo'**
  String get uploadIncidentPhoto;

  /// No description provided for @uploadIncidentPhotoDesc.
  ///
  /// In en, this message translates to:
  /// **'Take or upload a photo so AI can analyze the emergency situation quickly.'**
  String get uploadIncidentPhotoDesc;

  /// No description provided for @reportingAsVictim.
  ///
  /// In en, this message translates to:
  /// **'Reporting as: Victim'**
  String get reportingAsVictim;

  /// No description provided for @reportingAsWitness.
  ///
  /// In en, this message translates to:
  /// **'Reporting as: Witness'**
  String get reportingAsWitness;

  /// No description provided for @noPhotoSelected.
  ///
  /// In en, this message translates to:
  /// **'No photo selected'**
  String get noPhotoSelected;

  /// No description provided for @captureOrUpload.
  ///
  /// In en, this message translates to:
  /// **'Capture or upload an incident image'**
  String get captureOrUpload;

  /// No description provided for @photoSelected.
  ///
  /// In en, this message translates to:
  /// **'Photo selected'**
  String get photoSelected;

  /// No description provided for @takePhoto.
  ///
  /// In en, this message translates to:
  /// **'Take Photo'**
  String get takePhoto;

  /// No description provided for @gallery.
  ///
  /// In en, this message translates to:
  /// **'Gallery'**
  String get gallery;

  /// No description provided for @uploadGallery.
  ///
  /// In en, this message translates to:
  /// **'Upload Gallery'**
  String get uploadGallery;

  /// No description provided for @includeGps.
  ///
  /// In en, this message translates to:
  /// **'Include GPS Location'**
  String get includeGps;

  /// No description provided for @shareLocation.
  ///
  /// In en, this message translates to:
  /// **'Share your current location with the report'**
  String get shareLocation;

  /// No description provided for @includeLocationReport.
  ///
  /// In en, this message translates to:
  /// **'Include location in report'**
  String get includeLocationReport;

  /// No description provided for @aiAnalysisInfo.
  ///
  /// In en, this message translates to:
  /// **'AI analysis will detect: emergency type, severity, responders, safety guidance, and SOS details.'**
  String get aiAnalysisInfo;

  /// No description provided for @analyzeNow.
  ///
  /// In en, this message translates to:
  /// **'Analyze Now'**
  String get analyzeNow;

  /// No description provided for @emergencyNow.
  ///
  /// In en, this message translates to:
  /// **'EMERGENCY NOW'**
  String get emergencyNow;

  /// No description provided for @noLoginRequired.
  ///
  /// In en, this message translates to:
  /// **'(No Login Required)'**
  String get noLoginRequired;

  /// No description provided for @emergencyModeNoLogin.
  ///
  /// In en, this message translates to:
  /// **'Emergency mode allows calling and sending location without account.'**
  String get emergencyModeNoLogin;

  /// No description provided for @secureEncryptedAi.
  ///
  /// In en, this message translates to:
  /// **'Secure • Encrypted • AI-assisted'**
  String get secureEncryptedAi;

  /// No description provided for @emergencySos.
  ///
  /// In en, this message translates to:
  /// **'Emergency SOS'**
  String get emergencySos;

  /// No description provided for @fastEmergencyResponse.
  ///
  /// In en, this message translates to:
  /// **'Fast emergency response'**
  String get fastEmergencyResponse;

  /// No description provided for @tapToCallEmergency.
  ///
  /// In en, this message translates to:
  /// **'Tap to call emergency services immediately.'**
  String get tapToCallEmergency;

  /// No description provided for @quickAiDetection.
  ///
  /// In en, this message translates to:
  /// **'Quick AI Detection'**
  String get quickAiDetection;

  /// No description provided for @police.
  ///
  /// In en, this message translates to:
  /// **'Police'**
  String get police;

  /// No description provided for @ambulance.
  ///
  /// In en, this message translates to:
  /// **'Ambulance'**
  String get ambulance;

  /// No description provided for @fireDepartment.
  ///
  /// In en, this message translates to:
  /// **'Fire Department'**
  String get fireDepartment;

  /// No description provided for @emergencyUpload.
  ///
  /// In en, this message translates to:
  /// **'Emergency Upload'**
  String get emergencyUpload;

  /// No description provided for @uploadEmergencyPhoto.
  ///
  /// In en, this message translates to:
  /// **'Upload Emergency Photo'**
  String get uploadEmergencyPhoto;

  /// No description provided for @uploadEmergencyPhotoDesc.
  ///
  /// In en, this message translates to:
  /// **'Take or upload a photo so AI can quickly assess the emergency.'**
  String get uploadEmergencyPhotoDesc;

  /// No description provided for @tapUploadOrCapture.
  ///
  /// In en, this message translates to:
  /// **'Tap below to upload or capture'**
  String get tapUploadOrCapture;

  /// No description provided for @pleaseSelectPhotoFirst.
  ///
  /// In en, this message translates to:
  /// **'Please select or capture a photo first'**
  String get pleaseSelectPhotoFirst;

  /// No description provided for @aiAnalysisResult.
  ///
  /// In en, this message translates to:
  /// **'AI Analysis Result'**
  String get aiAnalysisResult;

  /// No description provided for @emergencyAiResult.
  ///
  /// In en, this message translates to:
  /// **'Emergency AI Result'**
  String get emergencyAiResult;

  /// No description provided for @emergencyDetected.
  ///
  /// In en, this message translates to:
  /// **'Emergency Detected'**
  String get emergencyDetected;

  /// No description provided for @confidenceLevel.
  ///
  /// In en, this message translates to:
  /// **'Confidence Level'**
  String get confidenceLevel;

  /// No description provided for @aiEvidenceDetected.
  ///
  /// In en, this message translates to:
  /// **'AI Evidence Detected'**
  String get aiEvidenceDetected;

  /// No description provided for @aiIncidentSummary.
  ///
  /// In en, this message translates to:
  /// **'AI Incident Summary'**
  String get aiIncidentSummary;

  /// No description provided for @generatedSummaryVictim.
  ///
  /// In en, this message translates to:
  /// **'Possible vehicle collision detected. Signs of smoke and debris visible. Injured risk assessed as high. Immediate assistance recommended.'**
  String get generatedSummaryVictim;

  /// No description provided for @generatedSummaryWitness.
  ///
  /// In en, this message translates to:
  /// **'Possible vehicle collision detected. Signs of smoke and debris visible. Emergency assistance may be needed for another person.'**
  String get generatedSummaryWitness;

  /// No description provided for @damagedVehicleDetected.
  ///
  /// In en, this message translates to:
  /// **'Damaged vehicle detected'**
  String get damagedVehicleDetected;

  /// No description provided for @smokeDetected.
  ///
  /// In en, this message translates to:
  /// **'Smoke detected'**
  String get smokeDetected;

  /// No description provided for @debrisDetected.
  ///
  /// In en, this message translates to:
  /// **'Debris on road detected'**
  String get debrisDetected;

  /// No description provided for @injuredPersonDetected.
  ///
  /// In en, this message translates to:
  /// **'Possible injured person detected'**
  String get injuredPersonDetected;

  /// No description provided for @mlObjectDetection.
  ///
  /// In en, this message translates to:
  /// **'ML Object Detection (EmergencyNet v2)'**
  String get mlObjectDetection;

  /// No description provided for @aiGuidanceAutoGenerated.
  ///
  /// In en, this message translates to:
  /// **'AI Guidance (Auto-generated)'**
  String get aiGuidanceAutoGenerated;

  /// No description provided for @possibleVehicleCollisionHelp.
  ///
  /// In en, this message translates to:
  /// **'Possible vehicle collision detected. Help is recommended immediately.'**
  String get possibleVehicleCollisionHelp;

  /// No description provided for @timestamp.
  ///
  /// In en, this message translates to:
  /// **'Timestamp'**
  String get timestamp;

  /// No description provided for @location.
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get location;

  /// No description provided for @aiModel.
  ///
  /// In en, this message translates to:
  /// **'AI Model'**
  String get aiModel;

  /// No description provided for @detectedLocation.
  ///
  /// In en, this message translates to:
  /// **'Detected Location'**
  String get detectedLocation;

  /// No description provided for @confirmGetHelp.
  ///
  /// In en, this message translates to:
  /// **'Confirm & Get Help'**
  String get confirmGetHelp;

  /// No description provided for @reAnalyze.
  ///
  /// In en, this message translates to:
  /// **'Re-analyze'**
  String get reAnalyze;

  /// No description provided for @type.
  ///
  /// In en, this message translates to:
  /// **'Type'**
  String get type;

  /// No description provided for @high.
  ///
  /// In en, this message translates to:
  /// **'High'**
  String get high;

  /// No description provided for @medium.
  ///
  /// In en, this message translates to:
  /// **'Medium'**
  String get medium;

  /// No description provided for @low.
  ///
  /// In en, this message translates to:
  /// **'Low'**
  String get low;

  /// No description provided for @severity.
  ///
  /// In en, this message translates to:
  /// **'Severity'**
  String get severity;

  /// No description provided for @safetyGuidance.
  ///
  /// In en, this message translates to:
  /// **'Safety Guidance'**
  String get safetyGuidance;

  /// No description provided for @emergencyGuidance.
  ///
  /// In en, this message translates to:
  /// **'Emergency Guidance'**
  String get emergencyGuidance;

  /// No description provided for @detailedGuidanceVictim.
  ///
  /// In en, this message translates to:
  /// **'Detailed AI-assisted guidance for the victim.'**
  String get detailedGuidanceVictim;

  /// No description provided for @detailedGuidanceWitness.
  ///
  /// In en, this message translates to:
  /// **'Detailed AI-assisted guidance for a witness/helper.'**
  String get detailedGuidanceWitness;

  /// No description provided for @immediateSafetySteps.
  ///
  /// In en, this message translates to:
  /// **'Immediate Safety Steps'**
  String get immediateSafetySteps;

  /// No description provided for @quickEmergencyGuidance.
  ///
  /// In en, this message translates to:
  /// **'Quick Emergency Guidance'**
  String get quickEmergencyGuidance;

  /// No description provided for @suggestedEquipment.
  ///
  /// In en, this message translates to:
  /// **'Suggested Equipment'**
  String get suggestedEquipment;

  /// No description provided for @recommendedResponders.
  ///
  /// In en, this message translates to:
  /// **'Recommended Responders'**
  String get recommendedResponders;

  /// No description provided for @viewWhatToSay.
  ///
  /// In en, this message translates to:
  /// **'View What To Say (Call Script)'**
  String get viewWhatToSay;

  /// No description provided for @sendAutoSos.
  ///
  /// In en, this message translates to:
  /// **'Send Auto SOS Message'**
  String get sendAutoSos;

  /// No description provided for @stayCalm.
  ///
  /// In en, this message translates to:
  /// **'Stay calm, assess danger'**
  String get stayCalm;

  /// No description provided for @stayCalmAssessScene.
  ///
  /// In en, this message translates to:
  /// **'Stay calm and assess the scene'**
  String get stayCalmAssessScene;

  /// No description provided for @moveSafe.
  ///
  /// In en, this message translates to:
  /// **'Move to a safe area if possible'**
  String get moveSafe;

  /// No description provided for @moveSafeArea.
  ///
  /// In en, this message translates to:
  /// **'Move to a safe area if possible'**
  String get moveSafeArea;

  /// No description provided for @dontMoveInjured.
  ///
  /// In en, this message translates to:
  /// **'Do not move injured persons'**
  String get dontMoveInjured;

  /// No description provided for @dontMoveSeriouslyInjured.
  ///
  /// In en, this message translates to:
  /// **'Do not move seriously injured persons'**
  String get dontMoveSeriouslyInjured;

  /// No description provided for @hazardLights.
  ///
  /// In en, this message translates to:
  /// **'Turn on hazard lights to warn others'**
  String get hazardLights;

  /// No description provided for @warnOthersNearby.
  ///
  /// In en, this message translates to:
  /// **'Turn on hazard lights or warn others nearby'**
  String get warnOthersNearby;

  /// No description provided for @fireStayLow.
  ///
  /// In en, this message translates to:
  /// **'If fire/smoke: stay low, leave area'**
  String get fireStayLow;

  /// No description provided for @callEmergency.
  ///
  /// In en, this message translates to:
  /// **'Call emergency services immediately'**
  String get callEmergency;

  /// No description provided for @firstAidKit.
  ///
  /// In en, this message translates to:
  /// **'First Aid Kit'**
  String get firstAidKit;

  /// No description provided for @flashlight.
  ///
  /// In en, this message translates to:
  /// **'Flashlight'**
  String get flashlight;

  /// No description provided for @reflectiveVest.
  ///
  /// In en, this message translates to:
  /// **'Reflective Vest'**
  String get reflectiveVest;

  /// No description provided for @fireExtinguisher.
  ///
  /// In en, this message translates to:
  /// **'Fire Extinguisher'**
  String get fireExtinguisher;

  /// No description provided for @powerBank.
  ///
  /// In en, this message translates to:
  /// **'Power Bank'**
  String get powerBank;

  /// No description provided for @emergencyBlanket.
  ///
  /// In en, this message translates to:
  /// **'Emergency Blanket'**
  String get emergencyBlanket;

  /// No description provided for @possibleInjuredPersonsDetected.
  ///
  /// In en, this message translates to:
  /// **'Possible injured persons detected'**
  String get possibleInjuredPersonsDetected;

  /// No description provided for @roadTrafficAccidentSupport.
  ///
  /// In en, this message translates to:
  /// **'Road traffic accident support needed'**
  String get roadTrafficAccidentSupport;

  /// No description provided for @sosMessagePreview.
  ///
  /// In en, this message translates to:
  /// **'SOS Message Preview'**
  String get sosMessagePreview;

  /// No description provided for @emergencySosPreview.
  ///
  /// In en, this message translates to:
  /// **'Emergency SOS Preview'**
  String get emergencySosPreview;

  /// No description provided for @message.
  ///
  /// In en, this message translates to:
  /// **'Message'**
  String get message;

  /// No description provided for @sosMessage.
  ///
  /// In en, this message translates to:
  /// **'SOS Message'**
  String get sosMessage;

  /// No description provided for @sendingTo.
  ///
  /// In en, this message translates to:
  /// **'Sending to'**
  String get sendingTo;

  /// No description provided for @sendViaSms.
  ///
  /// In en, this message translates to:
  /// **'Send via SMS'**
  String get sendViaSms;

  /// No description provided for @sendViaWhatsapp.
  ///
  /// In en, this message translates to:
  /// **'Send via WhatsApp'**
  String get sendViaWhatsapp;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @generatedByAiLocation.
  ///
  /// In en, this message translates to:
  /// **'Generated by AI + Location Services'**
  String get generatedByAiLocation;

  /// No description provided for @autoSosOnlyVictim.
  ///
  /// In en, this message translates to:
  /// **'Auto SOS message is only available when you selected \"I Need Help\". If you are helping someone else, you can still use guidance and call support.'**
  String get autoSosOnlyVictim;

  /// No description provided for @autoSosVictimOnly.
  ///
  /// In en, this message translates to:
  /// **'Auto SOS message is only available when you selected \"I Need Help\". If you are helping someone else, you can still use guidance and call support.'**
  String get autoSosVictimOnly;

  /// No description provided for @callScript.
  ///
  /// In en, this message translates to:
  /// **'Call Script'**
  String get callScript;

  /// No description provided for @emergencyCallScript.
  ///
  /// In en, this message translates to:
  /// **'Emergency Call Script'**
  String get emergencyCallScript;

  /// No description provided for @readThisScript.
  ///
  /// In en, this message translates to:
  /// **'Read this script during the emergency call.'**
  String get readThisScript;

  /// No description provided for @readScriptDuringCall.
  ///
  /// In en, this message translates to:
  /// **'Read this script during the emergency call.'**
  String get readScriptDuringCall;

  /// No description provided for @explainSituation.
  ///
  /// In en, this message translates to:
  /// **'Use this script to explain the situation clearly.'**
  String get explainSituation;

  /// No description provided for @useScriptClearlyExplain.
  ///
  /// In en, this message translates to:
  /// **'Use this script to clearly explain the emergency situation.'**
  String get useScriptClearlyExplain;

  /// No description provided for @emergencyCallGuide.
  ///
  /// In en, this message translates to:
  /// **'Emergency Call Guide'**
  String get emergencyCallGuide;

  /// No description provided for @speakCalmly.
  ///
  /// In en, this message translates to:
  /// **'Speak calmly and read the key details clearly.'**
  String get speakCalmly;

  /// No description provided for @speakClearlyImportantDetails.
  ///
  /// In en, this message translates to:
  /// **'Speak calmly and read the important details clearly.'**
  String get speakClearlyImportantDetails;

  /// No description provided for @whatToSay.
  ///
  /// In en, this message translates to:
  /// **'What To Say'**
  String get whatToSay;

  /// No description provided for @victimScript.
  ///
  /// In en, this message translates to:
  /// **'Victim Script'**
  String get victimScript;

  /// No description provided for @witnessScript.
  ///
  /// In en, this message translates to:
  /// **'Witness Script'**
  String get witnessScript;

  /// No description provided for @importantDetails.
  ///
  /// In en, this message translates to:
  /// **'Important Details To Mention'**
  String get importantDetails;

  /// No description provided for @reportStatus.
  ///
  /// In en, this message translates to:
  /// **'Report Status'**
  String get reportStatus;

  /// No description provided for @nextSosPreview.
  ///
  /// In en, this message translates to:
  /// **'Next: SOS Preview'**
  String get nextSosPreview;

  /// No description provided for @yourExactLocation.
  ///
  /// In en, this message translates to:
  /// **'Your exact location'**
  String get yourExactLocation;

  /// No description provided for @typeOfEmergency.
  ///
  /// In en, this message translates to:
  /// **'Type of emergency'**
  String get typeOfEmergency;

  /// No description provided for @numberOfInjuredPeople.
  ///
  /// In en, this message translates to:
  /// **'Number of injured people'**
  String get numberOfInjuredPeople;

  /// No description provided for @dangerAroundArea.
  ///
  /// In en, this message translates to:
  /// **'Danger around the area'**
  String get dangerAroundArea;

  /// No description provided for @equipmentRespondersNeed.
  ///
  /// In en, this message translates to:
  /// **'Equipment responders may need'**
  String get equipmentRespondersNeed;

  /// No description provided for @yourContactNumberIfAsked.
  ///
  /// In en, this message translates to:
  /// **'Your contact number if asked'**
  String get yourContactNumberIfAsked;

  /// No description provided for @helloNeedEmergencyHelp.
  ///
  /// In en, this message translates to:
  /// **'Hello, I need emergency help.'**
  String get helloNeedEmergencyHelp;

  /// No description provided for @helloWantReportEmergency.
  ///
  /// In en, this message translates to:
  /// **'Hello, I want to report an emergency.'**
  String get helloWantReportEmergency;

  /// No description provided for @iAmVictimEmergency.
  ///
  /// In en, this message translates to:
  /// **'I am the victim of an emergency situation.'**
  String get iAmVictimEmergency;

  /// No description provided for @iAmWitnessEmergency.
  ///
  /// In en, this message translates to:
  /// **'I am a witness/helper at the scene.'**
  String get iAmWitnessEmergency;

  /// No description provided for @aiDetectedEmergency.
  ///
  /// In en, this message translates to:
  /// **'The AI detection says it may be an accident and the severity is high.'**
  String get aiDetectedEmergency;

  /// No description provided for @myCurrentLocationIs.
  ///
  /// In en, this message translates to:
  /// **'My current location is:'**
  String get myCurrentLocationIs;

  /// No description provided for @victimCurrentLocationIs.
  ///
  /// In en, this message translates to:
  /// **'The victim\'s current location is:'**
  String get victimCurrentLocationIs;

  /// No description provided for @pleaseSendResponders.
  ///
  /// In en, this message translates to:
  /// **'Please send the appropriate responders immediately.'**
  String get pleaseSendResponders;

  /// No description provided for @recommendedRespondersText.
  ///
  /// In en, this message translates to:
  /// **'Recommended responders: Ambulance and Police.'**
  String get recommendedRespondersText;

  /// No description provided for @suggestedEquipmentBring.
  ///
  /// In en, this message translates to:
  /// **'Suggested equipment to bring:'**
  String get suggestedEquipmentBring;

  /// No description provided for @urgentAssistanceLine.
  ///
  /// In en, this message translates to:
  /// **'I am in need of urgent assistance. Please stay on the line with me.'**
  String get urgentAssistanceLine;

  /// No description provided for @injuredPersonsHere.
  ///
  /// In en, this message translates to:
  /// **'There may be injured person(s) here. Please respond as soon as possible.'**
  String get injuredPersonsHere;

  /// No description provided for @readLiveLocation.
  ///
  /// In en, this message translates to:
  /// **'[Read the live location here]'**
  String get readLiveLocation;

  /// No description provided for @callingEmergencyServices.
  ///
  /// In en, this message translates to:
  /// **'Calling emergency services.'**
  String get callingEmergencyServices;

  /// No description provided for @sosEmergencyDetected.
  ///
  /// In en, this message translates to:
  /// **'SOS! Emergency detected.'**
  String get sosEmergencyDetected;

  /// No description provided for @victimsInjured.
  ///
  /// In en, this message translates to:
  /// **'Victims: {count} persons injured'**
  String victimsInjured(Object count);

  /// No description provided for @victims.
  ///
  /// In en, this message translates to:
  /// **'Victims'**
  String get victims;

  /// No description provided for @conditionLabel.
  ///
  /// In en, this message translates to:
  /// **'Condition'**
  String get conditionLabel;

  /// No description provided for @condition.
  ///
  /// In en, this message translates to:
  /// **'Condition'**
  String get condition;

  /// No description provided for @dangerLabel.
  ///
  /// In en, this message translates to:
  /// **'Danger'**
  String get dangerLabel;

  /// No description provided for @danger.
  ///
  /// In en, this message translates to:
  /// **'Danger'**
  String get danger;

  /// No description provided for @notesLabel.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get notesLabel;

  /// No description provided for @notes.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get notes;

  /// No description provided for @pleaseSendHelpImmediately.
  ///
  /// In en, this message translates to:
  /// **'Please send help immediately.'**
  String get pleaseSendHelpImmediately;

  /// No description provided for @emergencyReportStatus.
  ///
  /// In en, this message translates to:
  /// **'Emergency Report Status'**
  String get emergencyReportStatus;

  /// No description provided for @emergencyAlertSentTitle.
  ///
  /// In en, this message translates to:
  /// **'Emergency Alert Sent'**
  String get emergencyAlertSentTitle;

  /// No description provided for @emergencyProcessReady.
  ///
  /// In en, this message translates to:
  /// **'Emergency Process Ready'**
  String get emergencyProcessReady;

  /// No description provided for @processReadyDesc.
  ///
  /// In en, this message translates to:
  /// **'Your emergency details have been prepared and are ready for response actions.'**
  String get processReadyDesc;

  /// No description provided for @emergencyPreparedReady.
  ///
  /// In en, this message translates to:
  /// **'Your emergency details have been prepared and are ready for response actions.'**
  String get emergencyPreparedReady;

  /// No description provided for @emergencyAlertSentDesc2.
  ///
  /// In en, this message translates to:
  /// **'Your SOS message and emergency details have been prepared and sent successfully.'**
  String get emergencyAlertSentDesc2;

  /// No description provided for @emergencyDetectedStatus.
  ///
  /// In en, this message translates to:
  /// **'Emergency detected'**
  String get emergencyDetectedStatus;

  /// No description provided for @emergencyDetectedStatusDesc.
  ///
  /// In en, this message translates to:
  /// **'AI has classified the incident as high priority'**
  String get emergencyDetectedStatusDesc;

  /// No description provided for @locationSharedStatus.
  ///
  /// In en, this message translates to:
  /// **'Location shared'**
  String get locationSharedStatus;

  /// No description provided for @locationSharedStatusDesc.
  ///
  /// In en, this message translates to:
  /// **'Current GPS coordinates attached to the report'**
  String get locationSharedStatusDesc;

  /// No description provided for @sosReadyStatus.
  ///
  /// In en, this message translates to:
  /// **'SOS ready'**
  String get sosReadyStatus;

  /// No description provided for @sosReadyStatusDesc.
  ///
  /// In en, this message translates to:
  /// **'Emergency message has been generated'**
  String get sosReadyStatusDesc;

  /// No description provided for @contactsNotifiedStatus.
  ///
  /// In en, this message translates to:
  /// **'Contacts notified'**
  String get contactsNotifiedStatus;

  /// No description provided for @contactsNotifiedStatusDesc.
  ///
  /// In en, this message translates to:
  /// **'Emergency contacts can be informed immediately'**
  String get contactsNotifiedStatusDesc;

  /// No description provided for @callSupportReadyStatus.
  ///
  /// In en, this message translates to:
  /// **'Call support ready'**
  String get callSupportReadyStatus;

  /// No description provided for @callSupportReadyStatusDesc.
  ///
  /// In en, this message translates to:
  /// **'Emergency call script is prepared for 999 / 112'**
  String get callSupportReadyStatusDesc;

  /// No description provided for @locationShared.
  ///
  /// In en, this message translates to:
  /// **'Location shared'**
  String get locationShared;

  /// No description provided for @locationSharedDesc.
  ///
  /// In en, this message translates to:
  /// **'Current GPS coordinates attached to the report'**
  String get locationSharedDesc;

  /// No description provided for @locationAttached.
  ///
  /// In en, this message translates to:
  /// **'Location attached'**
  String get locationAttached;

  /// No description provided for @locationAttachedDesc.
  ///
  /// In en, this message translates to:
  /// **'GPS location is included in the report'**
  String get locationAttachedDesc;

  /// No description provided for @sosReady.
  ///
  /// In en, this message translates to:
  /// **'SOS ready'**
  String get sosReady;

  /// No description provided for @sosReadyDesc.
  ///
  /// In en, this message translates to:
  /// **'Emergency message has been generated'**
  String get sosReadyDesc;

  /// No description provided for @sosSentSuccess.
  ///
  /// In en, this message translates to:
  /// **'SOS sent'**
  String get sosSentSuccess;

  /// No description provided for @sosSentSuccessDesc.
  ///
  /// In en, this message translates to:
  /// **'Emergency message has been sent successfully'**
  String get sosSentSuccessDesc;

  /// No description provided for @contactsNotified.
  ///
  /// In en, this message translates to:
  /// **'Contacts notified'**
  String get contactsNotified;

  /// No description provided for @contactsNotifiedDesc.
  ///
  /// In en, this message translates to:
  /// **'Emergency contacts can be informed immediately'**
  String get contactsNotifiedDesc;

  /// No description provided for @contactsPreparedNotified.
  ///
  /// In en, this message translates to:
  /// **'Selected emergency contacts were prepared/notified'**
  String get contactsPreparedNotified;

  /// No description provided for @callSupportReady.
  ///
  /// In en, this message translates to:
  /// **'Call support ready'**
  String get callSupportReady;

  /// No description provided for @callSupportReadyDesc.
  ///
  /// In en, this message translates to:
  /// **'Emergency call script is prepared for 999 / 112'**
  String get callSupportReadyDesc;

  /// No description provided for @callSupportReadyNow.
  ///
  /// In en, this message translates to:
  /// **'Emergency call options are available now'**
  String get callSupportReadyNow;

  /// No description provided for @preparedResponseSummary.
  ///
  /// In en, this message translates to:
  /// **'Prepared Response Summary'**
  String get preparedResponseSummary;

  /// No description provided for @quickSummary.
  ///
  /// In en, this message translates to:
  /// **'Quick Summary'**
  String get quickSummary;

  /// No description provided for @emergencyTypeLabel.
  ///
  /// In en, this message translates to:
  /// **'Emergency Type'**
  String get emergencyTypeLabel;

  /// No description provided for @severityLabel.
  ///
  /// In en, this message translates to:
  /// **'Severity'**
  String get severityLabel;

  /// No description provided for @locationLabel.
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get locationLabel;

  /// No description provided for @respondersLabel.
  ///
  /// In en, this message translates to:
  /// **'Responders'**
  String get respondersLabel;

  /// No description provided for @aiModelLabel.
  ///
  /// In en, this message translates to:
  /// **'AI Model'**
  String get aiModelLabel;

  /// No description provided for @backToHome.
  ///
  /// In en, this message translates to:
  /// **'Back to Home'**
  String get backToHome;

  /// No description provided for @backToApp.
  ///
  /// In en, this message translates to:
  /// **'Back to App'**
  String get backToApp;

  /// No description provided for @viewLiveTracking.
  ///
  /// In en, this message translates to:
  /// **'View Live Tracking'**
  String get viewLiveTracking;

  /// No description provided for @notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// No description provided for @emergencyAlertSent.
  ///
  /// In en, this message translates to:
  /// **'Emergency alert sent'**
  String get emergencyAlertSent;

  /// No description provided for @emergencyAlertSentDesc.
  ///
  /// In en, this message translates to:
  /// **'Your SOS message was sent to emergency contacts.'**
  String get emergencyAlertSentDesc;

  /// No description provided for @responderUpdate.
  ///
  /// In en, this message translates to:
  /// **'Responder update'**
  String get responderUpdate;

  /// No description provided for @responderUpdateDesc.
  ///
  /// In en, this message translates to:
  /// **'Ambulance is on the way to your location.'**
  String get responderUpdateDesc;

  /// No description provided for @locationSharedNotif.
  ///
  /// In en, this message translates to:
  /// **'Location shared'**
  String get locationSharedNotif;

  /// No description provided for @locationSharedNotifDesc.
  ///
  /// In en, this message translates to:
  /// **'Your live GPS location has been attached successfully.'**
  String get locationSharedNotifDesc;

  /// No description provided for @safetyGuidanceReady.
  ///
  /// In en, this message translates to:
  /// **'Safety guidance ready'**
  String get safetyGuidanceReady;

  /// No description provided for @safetyGuidanceReadyDesc.
  ///
  /// In en, this message translates to:
  /// **'AI generated immediate safety steps for the incident.'**
  String get safetyGuidanceReadyDesc;

  /// No description provided for @reminder.
  ///
  /// In en, this message translates to:
  /// **'Reminder'**
  String get reminder;

  /// No description provided for @reminderDesc.
  ///
  /// In en, this message translates to:
  /// **'Review your emergency contacts and notification settings.'**
  String get reminderDesc;

  /// No description provided for @justNow.
  ///
  /// In en, this message translates to:
  /// **'Just now'**
  String get justNow;

  /// No description provided for @minAgo5.
  ///
  /// In en, this message translates to:
  /// **'5 min ago'**
  String get minAgo5;

  /// No description provided for @minAgo12.
  ///
  /// In en, this message translates to:
  /// **'12 min ago'**
  String get minAgo12;

  /// No description provided for @minAgo20.
  ///
  /// In en, this message translates to:
  /// **'20 min ago'**
  String get minAgo20;

  /// No description provided for @dayAgo1.
  ///
  /// In en, this message translates to:
  /// **'1 day ago'**
  String get dayAgo1;

  /// No description provided for @allNotificationsMarkedRead.
  ///
  /// In en, this message translates to:
  /// **'All notifications marked as read'**
  String get allNotificationsMarkedRead;

  /// No description provided for @allNotificationsCleared.
  ///
  /// In en, this message translates to:
  /// **'All notifications cleared'**
  String get allNotificationsCleared;

  /// No description provided for @emergencyUpdates.
  ///
  /// In en, this message translates to:
  /// **'Emergency Updates'**
  String get emergencyUpdates;

  /// No description provided for @emergencyUpdatesDesc.
  ///
  /// In en, this message translates to:
  /// **'Stay updated with alerts, responder progress, and app reminders.'**
  String get emergencyUpdatesDesc;

  /// No description provided for @noNotificationsYet.
  ///
  /// In en, this message translates to:
  /// **'No Notifications Yet'**
  String get noNotificationsYet;

  /// No description provided for @noNotificationsYetDesc.
  ///
  /// In en, this message translates to:
  /// **'Emergency alerts, responder updates, and reminders will appear here.'**
  String get noNotificationsYetDesc;

  /// No description provided for @reportHistory.
  ///
  /// In en, this message translates to:
  /// **'Report History'**
  String get reportHistory;

  /// No description provided for @all.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get all;

  /// No description provided for @reportDetailTitle.
  ///
  /// In en, this message translates to:
  /// **'Report #1'**
  String get reportDetailTitle;

  /// No description provided for @aiPrediction.
  ///
  /// In en, this message translates to:
  /// **'AI Prediction'**
  String get aiPrediction;

  /// No description provided for @messageSentTo.
  ///
  /// In en, this message translates to:
  /// **'Message Sent To'**
  String get messageSentTo;

  /// No description provided for @status.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get status;

  /// No description provided for @exportPdf.
  ///
  /// In en, this message translates to:
  /// **'Export PDF'**
  String get exportPdf;

  /// No description provided for @markFalseAlarm.
  ///
  /// In en, this message translates to:
  /// **'Mark as False Alarm'**
  String get markFalseAlarm;

  /// No description provided for @deleteRecord.
  ///
  /// In en, this message translates to:
  /// **'Delete Record'**
  String get deleteRecord;

  /// No description provided for @sent.
  ///
  /// In en, this message translates to:
  /// **'Sent'**
  String get sent;

  /// No description provided for @cancelled.
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get cancelled;

  /// No description provided for @falseAlarm.
  ///
  /// In en, this message translates to:
  /// **'False Alarm'**
  String get falseAlarm;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @darkMode.
  ///
  /// In en, this message translates to:
  /// **'Dark Mode'**
  String get darkMode;

  /// No description provided for @lightMode.
  ///
  /// In en, this message translates to:
  /// **'Light Mode'**
  String get lightMode;

  /// No description provided for @manageProfilePrefs.
  ///
  /// In en, this message translates to:
  /// **'Manage your profile and app preferences'**
  String get manageProfilePrefs;

  /// No description provided for @pushNotifications.
  ///
  /// In en, this message translates to:
  /// **'Push Notifications'**
  String get pushNotifications;

  /// No description provided for @receiveEmergencyAlerts.
  ///
  /// In en, this message translates to:
  /// **'Receive emergency alerts and updates'**
  String get receiveEmergencyAlerts;

  /// No description provided for @soundAlerts.
  ///
  /// In en, this message translates to:
  /// **'Sound Alerts'**
  String get soundAlerts;

  /// No description provided for @playSoundUrgent.
  ///
  /// In en, this message translates to:
  /// **'Play sound for urgent notifications'**
  String get playSoundUrgent;

  /// No description provided for @vibrationAlerts.
  ///
  /// In en, this message translates to:
  /// **'Vibration Alerts'**
  String get vibrationAlerts;

  /// No description provided for @vibrateEmergencyAlerts.
  ///
  /// In en, this message translates to:
  /// **'Vibrate when emergency alerts arrive'**
  String get vibrateEmergencyAlerts;

  /// No description provided for @appearanceLanguage.
  ///
  /// In en, this message translates to:
  /// **'Appearance & Language'**
  String get appearanceLanguage;

  /// No description provided for @darkTheme.
  ///
  /// In en, this message translates to:
  /// **'Dark Theme'**
  String get darkTheme;

  /// No description provided for @switchDarkMode.
  ///
  /// In en, this message translates to:
  /// **'Switch between light and dark mode'**
  String get switchDarkMode;

  /// No description provided for @emergencyPreferences.
  ///
  /// In en, this message translates to:
  /// **'Emergency Preferences'**
  String get emergencyPreferences;

  /// No description provided for @shareLiveLocation.
  ///
  /// In en, this message translates to:
  /// **'Share Live Location'**
  String get shareLiveLocation;

  /// No description provided for @attachGpsEmergency.
  ///
  /// In en, this message translates to:
  /// **'Attach your GPS location during emergency'**
  String get attachGpsEmergency;

  /// No description provided for @autoSosMessage.
  ///
  /// In en, this message translates to:
  /// **'Auto SOS Message'**
  String get autoSosMessage;

  /// No description provided for @autoPrepareSosVictim.
  ///
  /// In en, this message translates to:
  /// **'Automatically prepare SOS message for victim'**
  String get autoPrepareSosVictim;

  /// No description provided for @more.
  ///
  /// In en, this message translates to:
  /// **'More'**
  String get more;

  /// No description provided for @privacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacyPolicy;

  /// No description provided for @privacyPolicyDesc.
  ///
  /// In en, this message translates to:
  /// **'View privacy and data handling information'**
  String get privacyPolicyDesc;

  /// No description provided for @helpSupport.
  ///
  /// In en, this message translates to:
  /// **'Help & Support'**
  String get helpSupport;

  /// No description provided for @helpSupportDesc.
  ///
  /// In en, this message translates to:
  /// **'Get app help and contact support'**
  String get helpSupportDesc;

  /// No description provided for @aboutApp.
  ///
  /// In en, this message translates to:
  /// **'About App'**
  String get aboutApp;

  /// No description provided for @aboutAppDesc.
  ///
  /// In en, this message translates to:
  /// **'Emergency AI version 1.0'**
  String get aboutAppDesc;

  /// No description provided for @privacyComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy coming soon'**
  String get privacyComingSoon;

  /// No description provided for @helpComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Help & Support coming soon'**
  String get helpComingSoon;

  /// No description provided for @aboutComingSoon.
  ///
  /// In en, this message translates to:
  /// **'About App coming soon'**
  String get aboutComingSoon;

  /// No description provided for @editProfile.
  ///
  /// In en, this message translates to:
  /// **'Edit Profile'**
  String get editProfile;

  /// No description provided for @liveEmergencyTracking.
  ///
  /// In en, this message translates to:
  /// **'Live Emergency Tracking'**
  String get liveEmergencyTracking;

  /// No description provided for @emergencyTrackingActive.
  ///
  /// In en, this message translates to:
  /// **'Emergency Tracking Active'**
  String get emergencyTrackingActive;

  /// No description provided for @trackingActiveDesc.
  ///
  /// In en, this message translates to:
  /// **'Your status and location are being monitored for response support.'**
  String get trackingActiveDesc;

  /// No description provided for @emergencyTrackingDesc.
  ///
  /// In en, this message translates to:
  /// **'Your emergency alert is active and your location is being tracked for response support.'**
  String get emergencyTrackingDesc;

  /// No description provided for @trackEmergencyProgress.
  ///
  /// In en, this message translates to:
  /// **'Track emergency progress, responder updates, and your current location.'**
  String get trackEmergencyProgress;

  /// No description provided for @elapsedTime.
  ///
  /// In en, this message translates to:
  /// **'Elapsed Time'**
  String get elapsedTime;

  /// No description provided for @liveStatus.
  ///
  /// In en, this message translates to:
  /// **'Live Status'**
  String get liveStatus;

  /// No description provided for @sosSent.
  ///
  /// In en, this message translates to:
  /// **'SOS Sent'**
  String get sosSent;

  /// No description provided for @sosSentDesc.
  ///
  /// In en, this message translates to:
  /// **'Emergency message prepared and sent'**
  String get sosSentDesc;

  /// No description provided for @waitingResponse.
  ///
  /// In en, this message translates to:
  /// **'Waiting Response'**
  String get waitingResponse;

  /// No description provided for @responseConfirmed.
  ///
  /// In en, this message translates to:
  /// **'Response Confirmed'**
  String get responseConfirmed;

  /// No description provided for @helpComing.
  ///
  /// In en, this message translates to:
  /// **'Help Coming'**
  String get helpComing;

  /// No description provided for @responseUpdated.
  ///
  /// In en, this message translates to:
  /// **'Emergency response is being updated'**
  String get responseUpdated;

  /// No description provided for @estimatedArrival.
  ///
  /// In en, this message translates to:
  /// **'Estimated Arrival'**
  String get estimatedArrival;

  /// No description provided for @currentLocation.
  ///
  /// In en, this message translates to:
  /// **'Current Location'**
  String get currentLocation;

  /// No description provided for @responderProgress.
  ///
  /// In en, this message translates to:
  /// **'Responder Progress'**
  String get responderProgress;

  /// No description provided for @incidentAnalyzedAi.
  ///
  /// In en, this message translates to:
  /// **'Incident analyzed by AI'**
  String get incidentAnalyzedAi;

  /// No description provided for @safetyGuidanceGenerated.
  ///
  /// In en, this message translates to:
  /// **'Safety guidance generated'**
  String get safetyGuidanceGenerated;

  /// No description provided for @callScriptPrepared.
  ///
  /// In en, this message translates to:
  /// **'Call script prepared'**
  String get callScriptPrepared;

  /// No description provided for @respondersEnRoute.
  ///
  /// In en, this message translates to:
  /// **'Responders en route'**
  String get respondersEnRoute;

  /// No description provided for @assistanceArriving.
  ///
  /// In en, this message translates to:
  /// **'Assistance arriving'**
  String get assistanceArriving;

  /// No description provided for @callAgain.
  ///
  /// In en, this message translates to:
  /// **'Call Again'**
  String get callAgain;

  /// No description provided for @shareLocationAction.
  ///
  /// In en, this message translates to:
  /// **'Share Location'**
  String get shareLocationAction;

  /// No description provided for @locationSharedMessage.
  ///
  /// In en, this message translates to:
  /// **'Location shared'**
  String get locationSharedMessage;

  /// No description provided for @cancelEmergency.
  ///
  /// In en, this message translates to:
  /// **'Cancel Emergency'**
  String get cancelEmergency;

  /// No description provided for @cancelEmergencyTitle.
  ///
  /// In en, this message translates to:
  /// **'Cancel Emergency?'**
  String get cancelEmergencyTitle;

  /// No description provided for @cancelEmergencyDesc.
  ///
  /// In en, this message translates to:
  /// **'This will stop live tracking and return to the main app.'**
  String get cancelEmergencyDesc;

  /// No description provided for @no.
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get no;

  /// No description provided for @yesCancel.
  ///
  /// In en, this message translates to:
  /// **'Yes, Cancel'**
  String get yesCancel;

  /// No description provided for @callContact.
  ///
  /// In en, this message translates to:
  /// **'Call Contact'**
  String get callContact;

  /// No description provided for @sendTestSos.
  ///
  /// In en, this message translates to:
  /// **'Send Test SOS'**
  String get sendTestSos;

  /// No description provided for @deleteContact.
  ///
  /// In en, this message translates to:
  /// **'Delete Contact'**
  String get deleteContact;

  /// No description provided for @call999.
  ///
  /// In en, this message translates to:
  /// **'CALL 999'**
  String get call999;

  /// No description provided for @victimCallLine1.
  ///
  /// In en, this message translates to:
  /// **'Hello, I need emergency help.'**
  String get victimCallLine1;

  /// No description provided for @victimCallLine2.
  ///
  /// In en, this message translates to:
  /// **'I am the victim of an emergency situation.'**
  String get victimCallLine2;

  /// No description provided for @victimCallLine3.
  ///
  /// In en, this message translates to:
  /// **'The AI detection says it may be an accident and the severity is high.'**
  String get victimCallLine3;

  /// No description provided for @victimCallLine4.
  ///
  /// In en, this message translates to:
  /// **'My current location is:'**
  String get victimCallLine4;

  /// No description provided for @victimCallLine5.
  ///
  /// In en, this message translates to:
  /// **'Please send the appropriate responders immediately.'**
  String get victimCallLine5;

  /// No description provided for @victimCallLine6.
  ///
  /// In en, this message translates to:
  /// **'Recommended responders: Ambulance and Police.'**
  String get victimCallLine6;

  /// No description provided for @victimCallLine7.
  ///
  /// In en, this message translates to:
  /// **'Suggested equipment to bring:'**
  String get victimCallLine7;

  /// No description provided for @victimCallLine8.
  ///
  /// In en, this message translates to:
  /// **'I am in need of urgent assistance. Please stay on the line with me.'**
  String get victimCallLine8;

  /// No description provided for @witnessCallLine1.
  ///
  /// In en, this message translates to:
  /// **'Hello, I want to report an emergency.'**
  String get witnessCallLine1;

  /// No description provided for @witnessCallLine2.
  ///
  /// In en, this message translates to:
  /// **'I am a witness/helper at the scene.'**
  String get witnessCallLine2;

  /// No description provided for @witnessCallLine3.
  ///
  /// In en, this message translates to:
  /// **'The AI detection says it may be an accident and the severity is high.'**
  String get witnessCallLine3;

  /// No description provided for @witnessCallLine4.
  ///
  /// In en, this message translates to:
  /// **'The victim\'s current location is:'**
  String get witnessCallLine4;

  /// No description provided for @witnessCallLine5.
  ///
  /// In en, this message translates to:
  /// **'Please send the appropriate responders immediately.'**
  String get witnessCallLine5;

  /// No description provided for @witnessCallLine6.
  ///
  /// In en, this message translates to:
  /// **'Recommended responders: Ambulance and Police.'**
  String get witnessCallLine6;

  /// No description provided for @witnessCallLine7.
  ///
  /// In en, this message translates to:
  /// **'Suggested equipment to bring:'**
  String get witnessCallLine7;

  /// No description provided for @witnessCallLine8.
  ///
  /// In en, this message translates to:
  /// **'There may be injured person(s) here. Please respond as soon as possible.'**
  String get witnessCallLine8;

  /// No description provided for @calling999112.
  ///
  /// In en, this message translates to:
  /// **'Calling 999 / 112'**
  String get calling999112;

  /// No description provided for @emergencyLiveTracking.
  ///
  /// In en, this message translates to:
  /// **'Emergency Live Tracking'**
  String get emergencyLiveTracking;

  /// No description provided for @noReportsYet.
  ///
  /// In en, this message translates to:
  /// **'No reports yet'**
  String get noReportsYet;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['en', 'ms'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en': return AppLocalizationsEn();
    case 'ms': return AppLocalizationsMs();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
