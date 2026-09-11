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

  /// No description provided for @greeting.
  ///
  /// In en, this message translates to:
  /// **'Hi, {name}'**
  String greeting(String name);

  /// No description provided for @sos.
  ///
  /// In en, this message translates to:
  /// **'SOS'**
  String get sos;

  /// No description provided for @startEmergencyReport.
  ///
  /// In en, this message translates to:
  /// **'Tap to start an emergency report'**
  String get startEmergencyReport;

  /// No description provided for @manualReport.
  ///
  /// In en, this message translates to:
  /// **'Report Emergency Manually'**
  String get manualReport;

  /// No description provided for @manualReportDescription.
  ///
  /// In en, this message translates to:
  /// **'Create an emergency report without AI analysis when needed.'**
  String get manualReportDescription;

  /// No description provided for @manualEmergencyReport.
  ///
  /// In en, this message translates to:
  /// **'Manual Emergency Report'**
  String get manualEmergencyReport;

  /// No description provided for @incidentPhoto.
  ///
  /// In en, this message translates to:
  /// **'Incident Photo'**
  String get incidentPhoto;

  /// No description provided for @noImageSelected.
  ///
  /// In en, this message translates to:
  /// **'No Image Selected'**
  String get noImageSelected;

  /// No description provided for @chooseImageFromGallery.
  ///
  /// In en, this message translates to:
  /// **'Take a photo or choose one from your gallery.'**
  String get chooseImageFromGallery;

  /// No description provided for @camera.
  ///
  /// In en, this message translates to:
  /// **'Camera'**
  String get camera;

  /// No description provided for @validating.
  ///
  /// In en, this message translates to:
  /// **'Validating...'**
  String get validating;

  /// No description provided for @emergencyImageValidation.
  ///
  /// In en, this message translates to:
  /// **'Emergency Image Validation'**
  String get emergencyImageValidation;

  /// No description provided for @warnings.
  ///
  /// In en, this message translates to:
  /// **'Warnings'**
  String get warnings;

  /// No description provided for @emergencyDetails.
  ///
  /// In en, this message translates to:
  /// **'Emergency Details'**
  String get emergencyDetails;

  /// No description provided for @emergencyType.
  ///
  /// In en, this message translates to:
  /// **'Emergency Type'**
  String get emergencyType;

  /// No description provided for @peopleInvolved.
  ///
  /// In en, this message translates to:
  /// **'People Involved'**
  String get peopleInvolved;

  /// No description provided for @victimCondition.
  ///
  /// In en, this message translates to:
  /// **'Victim Condition'**
  String get victimCondition;

  /// No description provided for @dangerPresent.
  ///
  /// In en, this message translates to:
  /// **'Danger Present'**
  String get dangerPresent;

  /// No description provided for @emergencyDescription.
  ///
  /// In en, this message translates to:
  /// **'Emergency Description'**
  String get emergencyDescription;

  /// No description provided for @emergencyDescriptionHint.
  ///
  /// In en, this message translates to:
  /// **'Briefly describe what happened...'**
  String get emergencyDescriptionHint;

  /// No description provided for @includeLiveLocation.
  ///
  /// In en, this message translates to:
  /// **'Include Live Location'**
  String get includeLiveLocation;

  /// No description provided for @continueManualGuidance.
  ///
  /// In en, this message translates to:
  /// **'Continue to Manual Guidance'**
  String get continueManualGuidance;

  /// No description provided for @flood.
  ///
  /// In en, this message translates to:
  /// **'Flood'**
  String get flood;

  /// No description provided for @buildingCollapse.
  ///
  /// In en, this message translates to:
  /// **'Building Collapse'**
  String get buildingCollapse;

  /// No description provided for @chemicalSpill.
  ///
  /// In en, this message translates to:
  /// **'Chemical Spill'**
  String get chemicalSpill;

  /// No description provided for @animalRescue.
  ///
  /// In en, this message translates to:
  /// **'Animal Rescue'**
  String get animalRescue;

  /// No description provided for @other.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get other;

  /// No description provided for @conscious.
  ///
  /// In en, this message translates to:
  /// **'Conscious'**
  String get conscious;

  /// No description provided for @unconscious.
  ///
  /// In en, this message translates to:
  /// **'Unconscious'**
  String get unconscious;

  /// No description provided for @bleeding.
  ///
  /// In en, this message translates to:
  /// **'Bleeding'**
  String get bleeding;

  /// No description provided for @trapped.
  ///
  /// In en, this message translates to:
  /// **'Trapped'**
  String get trapped;

  /// No description provided for @unknown.
  ///
  /// In en, this message translates to:
  /// **'Unknown'**
  String get unknown;

  /// No description provided for @smoke.
  ///
  /// In en, this message translates to:
  /// **'Smoke'**
  String get smoke;

  /// No description provided for @fuelLeak.
  ///
  /// In en, this message translates to:
  /// **'Fuel Leak'**
  String get fuelLeak;

  /// No description provided for @traffic.
  ///
  /// In en, this message translates to:
  /// **'Traffic'**
  String get traffic;

  /// No description provided for @none.
  ///
  /// In en, this message translates to:
  /// **'None'**
  String get none;

  /// No description provided for @imageQualityScore.
  ///
  /// In en, this message translates to:
  /// **'Image Quality Score'**
  String get imageQualityScore;

  /// No description provided for @incidentSummary.
  ///
  /// In en, this message translates to:
  /// **'Incident Summary'**
  String get incidentSummary;

  /// No description provided for @included.
  ///
  /// In en, this message translates to:
  /// **'Included'**
  String get included;

  /// No description provided for @notIncluded.
  ///
  /// In en, this message translates to:
  /// **'Not Included'**
  String get notIncluded;

  /// No description provided for @validationStatus.
  ///
  /// In en, this message translates to:
  /// **'Validation Status'**
  String get validationStatus;

  /// No description provided for @validationScore.
  ///
  /// In en, this message translates to:
  /// **'Validation Score'**
  String get validationScore;

  /// No description provided for @validationResult.
  ///
  /// In en, this message translates to:
  /// **'Validation Result'**
  String get validationResult;

  /// No description provided for @description.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get description;

  /// No description provided for @noAdditionalDescription.
  ///
  /// In en, this message translates to:
  /// **'No additional description.'**
  String get noAdditionalDescription;

  /// No description provided for @recommendedActions.
  ///
  /// In en, this message translates to:
  /// **'Recommended Actions'**
  String get recommendedActions;

  /// No description provided for @viewReportStatus.
  ///
  /// In en, this message translates to:
  /// **'View Report Status'**
  String get viewReportStatus;

  /// No description provided for @someoneNeedsHelp.
  ///
  /// In en, this message translates to:
  /// **'Someone Needs Help'**
  String get someoneNeedsHelp;

  /// No description provided for @otherEmergency.
  ///
  /// In en, this message translates to:
  /// **'Other Emergency'**
  String get otherEmergency;

  /// No description provided for @continueToAiAnalysis.
  ///
  /// In en, this message translates to:
  /// **'Continue to AI Analysis'**
  String get continueToAiAnalysis;

  /// No description provided for @validateAndAnalyze.
  ///
  /// In en, this message translates to:
  /// **'Validate & Analyze'**
  String get validateAndAnalyze;

  /// No description provided for @bystanderAssist.
  ///
  /// In en, this message translates to:
  /// **'Bystander Assist'**
  String get bystanderAssist;

  /// No description provided for @offlineEmergencyAssistance.
  ///
  /// In en, this message translates to:
  /// **'Offline Emergency Assistance'**
  String get offlineEmergencyAssistance;

  /// No description provided for @offlineMode.
  ///
  /// In en, this message translates to:
  /// **'Offline Mode'**
  String get offlineMode;

  /// No description provided for @offlineModeDescription.
  ///
  /// In en, this message translates to:
  /// **'Emergency guidance is available without internet connection.'**
  String get offlineModeDescription;

  /// No description provided for @incidentTimer.
  ///
  /// In en, this message translates to:
  /// **'Incident Timer'**
  String get incidentTimer;

  /// No description provided for @pause.
  ///
  /// In en, this message translates to:
  /// **'Pause'**
  String get pause;

  /// No description provided for @start.
  ///
  /// In en, this message translates to:
  /// **'Start'**
  String get start;

  /// No description provided for @reset.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get reset;

  /// No description provided for @cprBeat.
  ///
  /// In en, this message translates to:
  /// **'CPR Beat'**
  String get cprBeat;

  /// No description provided for @stop.
  ///
  /// In en, this message translates to:
  /// **'Stop'**
  String get stop;

  /// No description provided for @sosFlashlight.
  ///
  /// In en, this message translates to:
  /// **'SOS Flashlight'**
  String get sosFlashlight;

  /// No description provided for @sosFlashlightDescription.
  ///
  /// In en, this message translates to:
  /// **'Use your phone flashlight as an emergency signal.'**
  String get sosFlashlightDescription;

  /// No description provided for @takeChargeScene.
  ///
  /// In en, this message translates to:
  /// **'Take Charge of the Scene'**
  String get takeChargeScene;

  /// No description provided for @viewEmergencyHistory.
  ///
  /// In en, this message translates to:
  /// **'View Emergency History'**
  String get viewEmergencyHistory;

  /// No description provided for @flashlightUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Flashlight is unavailable. Close the camera and try again.'**
  String get flashlightUnavailable;

  /// No description provided for @stayCalmDescription.
  ///
  /// In en, this message translates to:
  /// **'Remain calm and assess the emergency before taking action.'**
  String get stayCalmDescription;

  /// No description provided for @stayCalmTitle.
  ///
  /// In en, this message translates to:
  /// **'Stay Calm'**
  String get stayCalmTitle;

  /// No description provided for @ensureSceneSafety.
  ///
  /// In en, this message translates to:
  /// **'Ensure Scene Safety'**
  String get ensureSceneSafety;

  /// No description provided for @ensureSceneSafetyDescription.
  ///
  /// In en, this message translates to:
  /// **'Check for fire, smoke, traffic, electricity, chemicals or other hazards.'**
  String get ensureSceneSafetyDescription;

  /// No description provided for @protectYourself.
  ///
  /// In en, this message translates to:
  /// **'Protect Yourself'**
  String get protectYourself;

  /// No description provided for @protectYourselfDescription.
  ///
  /// In en, this message translates to:
  /// **'Never become another victim. Enter only if it is safe.'**
  String get protectYourselfDescription;

  /// No description provided for @seekEmergencyHelp.
  ///
  /// In en, this message translates to:
  /// **'Seek Emergency Help'**
  String get seekEmergencyHelp;

  /// No description provided for @seekEmergencyHelpDescription.
  ///
  /// In en, this message translates to:
  /// **'Get emergency assistance immediately if the situation is life-threatening.'**
  String get seekEmergencyHelpDescription;

  /// No description provided for @giveFirstAid.
  ///
  /// In en, this message translates to:
  /// **'Give First Aid'**
  String get giveFirstAid;

  /// No description provided for @giveFirstAidDescription.
  ///
  /// In en, this message translates to:
  /// **'Provide first aid only if you know how and it is safe.'**
  String get giveFirstAidDescription;

  /// No description provided for @waitForResponders.
  ///
  /// In en, this message translates to:
  /// **'Wait for Responders'**
  String get waitForResponders;

  /// No description provided for @waitForRespondersDescription.
  ///
  /// In en, this message translates to:
  /// **'Continue monitoring the affected person until professional help arrives.'**
  String get waitForRespondersDescription;

  /// No description provided for @emergencyFirstAidGuides.
  ///
  /// In en, this message translates to:
  /// **'Emergency First Aid Guides'**
  String get emergencyFirstAidGuides;

  /// No description provided for @cprNotBreathing.
  ///
  /// In en, this message translates to:
  /// **'CPR — Not Breathing'**
  String get cprNotBreathing;

  /// No description provided for @severeBleeding.
  ///
  /// In en, this message translates to:
  /// **'Severe Bleeding'**
  String get severeBleeding;

  /// No description provided for @choking.
  ///
  /// In en, this message translates to:
  /// **'Choking'**
  String get choking;

  /// No description provided for @burns.
  ///
  /// In en, this message translates to:
  /// **'Burns'**
  String get burns;

  /// No description provided for @fractureSpineInjury.
  ///
  /// In en, this message translates to:
  /// **'Fracture / Spine Injury'**
  String get fractureSpineInjury;

  /// No description provided for @shockUnconsciousBreathing.
  ///
  /// In en, this message translates to:
  /// **'Shock / Unconscious but Breathing'**
  String get shockUnconsciousBreathing;

  /// No description provided for @poisoning.
  ///
  /// In en, this message translates to:
  /// **'Poisoning'**
  String get poisoning;

  /// No description provided for @electricShock.
  ///
  /// In en, this message translates to:
  /// **'Electric Shock'**
  String get electricShock;

  /// No description provided for @heatStroke.
  ///
  /// In en, this message translates to:
  /// **'Heat Stroke'**
  String get heatStroke;

  /// No description provided for @drowning.
  ///
  /// In en, this message translates to:
  /// **'Drowning'**
  String get drowning;

  /// No description provided for @animalBite.
  ///
  /// In en, this message translates to:
  /// **'Animal Bite'**
  String get animalBite;

  /// No description provided for @cprStep1.
  ///
  /// In en, this message translates to:
  /// **'Check for a response — tap the shoulders and call out loudly.'**
  String get cprStep1;

  /// No description provided for @cprStep2.
  ///
  /// In en, this message translates to:
  /// **'Ask someone to get emergency help and an AED.'**
  String get cprStep2;

  /// No description provided for @cprStep3.
  ///
  /// In en, this message translates to:
  /// **'Place the heel of one hand in the centre of the chest, with the other hand on top.'**
  String get cprStep3;

  /// No description provided for @cprStep4.
  ///
  /// In en, this message translates to:
  /// **'Push hard and fast, 5–6 cm deep, at 100–120 compressions per minute.'**
  String get cprStep4;

  /// No description provided for @cprStep5.
  ///
  /// In en, this message translates to:
  /// **'Do not stop until the person moves or professional help arrives.'**
  String get cprStep5;

  /// No description provided for @cprWarning.
  ///
  /// In en, this message translates to:
  /// **'Perform CPR only if the person is unresponsive and not breathing normally.'**
  String get cprWarning;

  /// No description provided for @bleedingStep1.
  ///
  /// In en, this message translates to:
  /// **'Apply firm direct pressure to the wound immediately using a clean cloth, sterile dressing, or your hand if nothing else is available.'**
  String get bleedingStep1;

  /// No description provided for @bleedingStep2.
  ///
  /// In en, this message translates to:
  /// **'Keep continuous pressure on the wound. Do not repeatedly remove the dressing to check the bleeding.'**
  String get bleedingStep2;

  /// No description provided for @bleedingStep3.
  ///
  /// In en, this message translates to:
  /// **'If blood soaks through, place another dressing on top and continue applying pressure.'**
  String get bleedingStep3;

  /// No description provided for @bleedingStep4.
  ///
  /// In en, this message translates to:
  /// **'Raise the injured arm or leg above heart level only if no fracture is suspected.'**
  String get bleedingStep4;

  /// No description provided for @bleedingStep5.
  ///
  /// In en, this message translates to:
  /// **'Get emergency medical help if bleeding cannot be controlled or is life-threatening.'**
  String get bleedingStep5;

  /// No description provided for @bleedingWarning.
  ///
  /// In en, this message translates to:
  /// **'Do not remove objects deeply embedded in a wound. Apply pressure around the object and wait for professional help.'**
  String get bleedingWarning;

  /// No description provided for @chokingStep1.
  ///
  /// In en, this message translates to:
  /// **'Ask the person if they are choking. If they can cough or speak, encourage them to keep coughing.'**
  String get chokingStep1;

  /// No description provided for @chokingStep2.
  ///
  /// In en, this message translates to:
  /// **'If they cannot cough, speak, or breathe, give up to 5 firm back blows between the shoulder blades.'**
  String get chokingStep2;

  /// No description provided for @chokingStep3.
  ///
  /// In en, this message translates to:
  /// **'If the object does not come out, give up to 5 abdominal thrusts for adults and children over 1 year old.'**
  String get chokingStep3;

  /// No description provided for @chokingStep4.
  ///
  /// In en, this message translates to:
  /// **'Continue alternating 5 back blows and 5 abdominal thrusts until the blockage is removed or the person becomes unresponsive.'**
  String get chokingStep4;

  /// No description provided for @chokingStep5.
  ///
  /// In en, this message translates to:
  /// **'If the person becomes unresponsive, get emergency help and begin CPR if they are not breathing normally.'**
  String get chokingStep5;

  /// No description provided for @chokingWarning.
  ///
  /// In en, this message translates to:
  /// **'Do not use abdominal thrusts on infants. For a pregnant person, use chest thrusts instead. Use age-appropriate first-aid techniques.'**
  String get chokingWarning;

  /// No description provided for @burnsStep1.
  ///
  /// In en, this message translates to:
  /// **'Move the person away from the heat source only if it is safe to do so.'**
  String get burnsStep1;

  /// No description provided for @burnsStep2.
  ///
  /// In en, this message translates to:
  /// **'Cool the burned area under clean, cool running water for 10–20 minutes.'**
  String get burnsStep2;

  /// No description provided for @burnsStep3.
  ///
  /// In en, this message translates to:
  /// **'Remove rings, watches, and loose clothing before swelling begins, but do not remove anything stuck to the burn.'**
  String get burnsStep3;

  /// No description provided for @burnsStep4.
  ///
  /// In en, this message translates to:
  /// **'Loosely cover the burn with a sterile non-stick dressing or clean plastic wrap.'**
  String get burnsStep4;

  /// No description provided for @burnsStep5.
  ///
  /// In en, this message translates to:
  /// **'Get urgent medical care for deep, chemical, electrical, large, or facial burns.'**
  String get burnsStep5;

  /// No description provided for @burnsWarning.
  ///
  /// In en, this message translates to:
  /// **'Do not apply toothpaste, butter, oils, creams, or ice directly onto a burn.'**
  String get burnsWarning;

  /// No description provided for @fractureStep1.
  ///
  /// In en, this message translates to:
  /// **'Tell the person to remain still and avoid moving the injured body part.'**
  String get fractureStep1;

  /// No description provided for @fractureStep2.
  ///
  /// In en, this message translates to:
  /// **'Support the injured limb with towels, clothing, or a splint only if you are trained and it is safe.'**
  String get fractureStep2;

  /// No description provided for @fractureStep3.
  ///
  /// In en, this message translates to:
  /// **'Apply a wrapped cold pack to reduce swelling. Never place ice directly on the skin.'**
  String get fractureStep3;

  /// No description provided for @fractureStep4.
  ///
  /// In en, this message translates to:
  /// **'If a spine injury is suspected, keep the head, neck, and back aligned. Do not move the person unless there is immediate danger.'**
  String get fractureStep4;

  /// No description provided for @fractureStep5.
  ///
  /// In en, this message translates to:
  /// **'Get emergency medical help for severe pain, deformity, heavy bleeding, or a suspected spine injury.'**
  String get fractureStep5;

  /// No description provided for @fractureWarning.
  ///
  /// In en, this message translates to:
  /// **'Do not attempt to straighten broken bones or move a person with a suspected spinal injury.'**
  String get fractureWarning;

  /// No description provided for @shockStep1.
  ///
  /// In en, this message translates to:
  /// **'Lay the person flat on their back unless an injury or breathing difficulty prevents it.'**
  String get shockStep1;

  /// No description provided for @shockStep2.
  ///
  /// In en, this message translates to:
  /// **'If no injury is suspected, raise the feet about 15–30 cm unless a different position is more comfortable for breathing.'**
  String get shockStep2;

  /// No description provided for @shockStep3.
  ///
  /// In en, this message translates to:
  /// **'Loosen tight clothing and keep the person warm with a blanket or jacket.'**
  String get shockStep3;

  /// No description provided for @shockStep4.
  ///
  /// In en, this message translates to:
  /// **'If the person is unresponsive but breathing normally, place them in the recovery position if it is safe to do so.'**
  String get shockStep4;

  /// No description provided for @shockStep5.
  ///
  /// In en, this message translates to:
  /// **'Monitor breathing and responsiveness continuously until professional help arrives.'**
  String get shockStep5;

  /// No description provided for @shockWarning.
  ///
  /// In en, this message translates to:
  /// **'Do not give food, drinks, or medication to an unconscious person.'**
  String get shockWarning;

  /// No description provided for @poisoningStep1.
  ///
  /// In en, this message translates to:
  /// **'Move the person away from the poisonous substance only if it is safe.'**
  String get poisoningStep1;

  /// No description provided for @poisoningStep2.
  ///
  /// In en, this message translates to:
  /// **'Identify the poison if possible and keep the container or label for medical personnel.'**
  String get poisoningStep2;

  /// No description provided for @poisoningStep3.
  ///
  /// In en, this message translates to:
  /// **'If poison is on the skin or in the eyes, rinse continuously with clean running water.'**
  String get poisoningStep3;

  /// No description provided for @poisoningStep4.
  ///
  /// In en, this message translates to:
  /// **'Get emergency help if the person is unconscious, has difficulty breathing, has seizures, or if several people are affected.'**
  String get poisoningStep4;

  /// No description provided for @poisoningStep5.
  ///
  /// In en, this message translates to:
  /// **'Follow instructions from medical professionals while waiting for help.'**
  String get poisoningStep5;

  /// No description provided for @poisoningWarning.
  ///
  /// In en, this message translates to:
  /// **'Do not force the person to vomit or give food or drink unless a medical professional instructs you to do so.'**
  String get poisoningWarning;

  /// No description provided for @electricStep1.
  ///
  /// In en, this message translates to:
  /// **'Switch off the electricity source before approaching the person, if it is safe to do so.'**
  String get electricStep1;

  /// No description provided for @electricStep2.
  ///
  /// In en, this message translates to:
  /// **'Do not touch the person, exposed wires, or wet areas until you are certain the power is off.'**
  String get electricStep2;

  /// No description provided for @electricStep3.
  ///
  /// In en, this message translates to:
  /// **'Get emergency medical help, even if the person appears well, because electrical injuries can cause hidden internal damage.'**
  String get electricStep3;

  /// No description provided for @electricStep4.
  ///
  /// In en, this message translates to:
  /// **'Once it is safe, check breathing and begin CPR only if the person is not breathing normally and you are trained to do so.'**
  String get electricStep4;

  /// No description provided for @electricStep5.
  ///
  /// In en, this message translates to:
  /// **'After the power is off, loosely cover visible burns with a sterile dressing while waiting for help.'**
  String get electricStep5;

  /// No description provided for @electricWarning.
  ///
  /// In en, this message translates to:
  /// **'Never touch a person who is still in contact with electricity.'**
  String get electricWarning;

  /// No description provided for @heatStep1.
  ///
  /// In en, this message translates to:
  /// **'Move the person to a cool or shaded area immediately.'**
  String get heatStep1;

  /// No description provided for @heatStep2.
  ///
  /// In en, this message translates to:
  /// **'Remove excess clothing to help the body cool down.'**
  String get heatStep2;

  /// No description provided for @heatStep3.
  ///
  /// In en, this message translates to:
  /// **'Cool the body using wet cloths, misting, fanning, or a cool bath.'**
  String get heatStep3;

  /// No description provided for @heatStep4.
  ///
  /// In en, this message translates to:
  /// **'Get emergency medical help immediately, especially if the person is confused, collapses, or loses consciousness.'**
  String get heatStep4;

  /// No description provided for @heatStep5.
  ///
  /// In en, this message translates to:
  /// **'Monitor breathing and responsiveness while continuing to cool the person.'**
  String get heatStep5;

  /// No description provided for @heatWarning.
  ///
  /// In en, this message translates to:
  /// **'Heat stroke is a medical emergency. Do not give the person anything to drink.'**
  String get heatWarning;

  /// No description provided for @drowningStep1.
  ///
  /// In en, this message translates to:
  /// **'Help the person out of the water only if it is safe. Use a reaching or floating object when possible.'**
  String get drowningStep1;

  /// No description provided for @drowningStep2.
  ///
  /// In en, this message translates to:
  /// **'Get emergency help as soon as the person is safely out of the water.'**
  String get drowningStep2;

  /// No description provided for @drowningStep3.
  ///
  /// In en, this message translates to:
  /// **'Check breathing. If the person is not breathing normally, begin CPR if you are trained to do so.'**
  String get drowningStep3;

  /// No description provided for @drowningStep4.
  ///
  /// In en, this message translates to:
  /// **'Use an AED if one is available and it is safe to use.'**
  String get drowningStep4;

  /// No description provided for @drowningStep5.
  ///
  /// In en, this message translates to:
  /// **'Keep the person warm and continue monitoring breathing and responsiveness until professional help arrives.'**
  String get drowningStep5;

  /// No description provided for @drowningWarning.
  ///
  /// In en, this message translates to:
  /// **'Do not try to remove water from the lungs. Focus on breathing, CPR when needed, and getting emergency help.'**
  String get drowningWarning;

  /// No description provided for @animalBiteStep1.
  ///
  /// In en, this message translates to:
  /// **'Wash a minor bite wound thoroughly with soap and clean running water.'**
  String get animalBiteStep1;

  /// No description provided for @animalBiteStep2.
  ///
  /// In en, this message translates to:
  /// **'Control bleeding by applying gentle direct pressure with a clean dressing.'**
  String get animalBiteStep2;

  /// No description provided for @animalBiteStep3.
  ///
  /// In en, this message translates to:
  /// **'Cover the wound with a clean sterile bandage.'**
  String get animalBiteStep3;

  /// No description provided for @animalBiteStep4.
  ///
  /// In en, this message translates to:
  /// **'Get medical attention for deep wounds, bites from stray or wild animals, or possible rabies exposure.'**
  String get animalBiteStep4;

  /// No description provided for @animalBiteStep5.
  ///
  /// In en, this message translates to:
  /// **'Monitor the wound for infection, such as increasing redness, swelling, pus, fever, or red streaks.'**
  String get animalBiteStep5;

  /// No description provided for @animalBiteWarning.
  ///
  /// In en, this message translates to:
  /// **'Animal bites can cause serious infection. Seek medical assessment when in doubt.'**
  String get animalBiteWarning;

  /// No description provided for @validationModelLoading.
  ///
  /// In en, this message translates to:
  /// **'AI model is still loading. Please wait.'**
  String get validationModelLoading;

  /// No description provided for @validationUploadImageFirst.
  ///
  /// In en, this message translates to:
  /// **'Please upload an image first.'**
  String get validationUploadImageFirst;

  /// No description provided for @validationImageRejectedTitle.
  ///
  /// In en, this message translates to:
  /// **'Image Rejected'**
  String get validationImageRejectedTitle;

  /// No description provided for @validationAiGeneratedRejected.
  ///
  /// In en, this message translates to:
  /// **'Rejected: AI-generated image detected.'**
  String get validationAiGeneratedRejected;

  /// No description provided for @modelClassification.
  ///
  /// In en, this message translates to:
  /// **'Model classification'**
  String get modelClassification;

  /// No description provided for @classificationAi.
  ///
  /// In en, this message translates to:
  /// **'AI'**
  String get classificationAi;

  /// No description provided for @aiConfidence.
  ///
  /// In en, this message translates to:
  /// **'AI confidence'**
  String get aiConfidence;

  /// No description provided for @validationNonEmergencyRejected.
  ///
  /// In en, this message translates to:
  /// **'Rejected: This image does not appear to show an emergency incident.'**
  String get validationNonEmergencyRejected;

  /// No description provided for @classificationNonEmergency.
  ///
  /// In en, this message translates to:
  /// **'Non-Emergency'**
  String get classificationNonEmergency;

  /// No description provided for @validationAcceptedWarningTitle.
  ///
  /// In en, this message translates to:
  /// **'Accepted With Warning'**
  String get validationAcceptedWarningTitle;

  /// No description provided for @validationImageAcceptedTitle.
  ///
  /// In en, this message translates to:
  /// **'Image Accepted'**
  String get validationImageAcceptedTitle;

  /// No description provided for @validationAcceptedWarningMessage.
  ///
  /// In en, this message translates to:
  /// **'Accepted: Likely a real emergency image, but image quality may reduce visible detail.'**
  String get validationAcceptedWarningMessage;

  /// No description provided for @validationImageAcceptedMessage.
  ///
  /// In en, this message translates to:
  /// **'Accepted: Likely a real emergency image detected.'**
  String get validationImageAcceptedMessage;

  /// No description provided for @classificationRealEmergency.
  ///
  /// In en, this message translates to:
  /// **'Real Emergency'**
  String get classificationRealEmergency;

  /// No description provided for @classificationConfidence.
  ///
  /// In en, this message translates to:
  /// **'Classification confidence'**
  String get classificationConfidence;

  /// No description provided for @validationUnavailableTitle.
  ///
  /// In en, this message translates to:
  /// **'Validation Unavailable'**
  String get validationUnavailableTitle;

  /// No description provided for @validationUnavailableMessage.
  ///
  /// In en, this message translates to:
  /// **'Unable to validate this image. Please try again.'**
  String get validationUnavailableMessage;

  /// No description provided for @uploadEmergencyImageFirst.
  ///
  /// In en, this message translates to:
  /// **'Please upload an emergency image.'**
  String get uploadEmergencyImageFirst;

  /// No description provided for @validateImageFirst.
  ///
  /// In en, this message translates to:
  /// **'Please validate the image first.'**
  String get validateImageFirst;

  /// No description provided for @imageRejected.
  ///
  /// In en, this message translates to:
  /// **'Image rejected'**
  String get imageRejected;

  /// No description provided for @fireGuidanceMoveAway.
  ///
  /// In en, this message translates to:
  /// **'Move everyone away from the fire immediately.'**
  String get fireGuidanceMoveAway;

  /// No description provided for @fireGuidanceStayLow.
  ///
  /// In en, this message translates to:
  /// **'If smoke is present, stay low to avoid inhalation.'**
  String get fireGuidanceStayLow;

  /// No description provided for @fireGuidanceNoElevators.
  ///
  /// In en, this message translates to:
  /// **'Do not use elevators during evacuation.'**
  String get fireGuidanceNoElevators;

  /// No description provided for @fireGuidanceTurnOffUtilities.
  ///
  /// In en, this message translates to:
  /// **'Turn off electricity or gas only if it is safe to do so.'**
  String get fireGuidanceTurnOffUtilities;

  /// No description provided for @fireGuidanceGetHelp.
  ///
  /// In en, this message translates to:
  /// **'Get emergency help immediately.'**
  String get fireGuidanceGetHelp;

  /// No description provided for @fireGuidanceWaitSafe.
  ///
  /// In en, this message translates to:
  /// **'Wait for firefighters in a safe location.'**
  String get fireGuidanceWaitSafe;

  /// No description provided for @fireGuidancePersonTrapped.
  ///
  /// In en, this message translates to:
  /// **'Inform emergency responders that a person is trapped inside.'**
  String get fireGuidancePersonTrapped;

  /// No description provided for @fireGuidanceFuelLeak.
  ///
  /// In en, this message translates to:
  /// **'Keep everyone away from possible ignition sources.'**
  String get fireGuidanceFuelLeak;

  /// No description provided for @profileTitle.
  ///
  /// In en, this message translates to:
  /// **'Emergency Profile'**
  String get profileTitle;

  /// No description provided for @profileSaved.
  ///
  /// In en, this message translates to:
  /// **'Emergency profile saved'**
  String get profileSaved;

  /// No description provided for @profileMedicalInfoTitle.
  ///
  /// In en, this message translates to:
  /// **'Medical information saved in your profile'**
  String get profileMedicalInfoTitle;

  /// No description provided for @profileMedicalInfoMessage.
  ///
  /// In en, this message translates to:
  /// **'Available when you submit an emergency report.'**
  String get profileMedicalInfoMessage;

  /// No description provided for @profilePersonal.
  ///
  /// In en, this message translates to:
  /// **'Personal'**
  String get profilePersonal;

  /// No description provided for @profileFullName.
  ///
  /// In en, this message translates to:
  /// **'Full Name'**
  String get profileFullName;

  /// No description provided for @profileAge.
  ///
  /// In en, this message translates to:
  /// **'Age'**
  String get profileAge;

  /// No description provided for @profileBloodGroup.
  ///
  /// In en, this message translates to:
  /// **'Blood Group'**
  String get profileBloodGroup;

  /// No description provided for @profileUnknown.
  ///
  /// In en, this message translates to:
  /// **'Unknown'**
  String get profileUnknown;

  /// No description provided for @profileAllergies.
  ///
  /// In en, this message translates to:
  /// **'Allergies'**
  String get profileAllergies;

  /// No description provided for @profileAllergiesHint.
  ///
  /// In en, this message translates to:
  /// **'Example: Penicillin, Peanuts'**
  String get profileAllergiesHint;

  /// No description provided for @profileMedicalConditions.
  ///
  /// In en, this message translates to:
  /// **'Medical Conditions'**
  String get profileMedicalConditions;

  /// No description provided for @profileMedicalConditionsHint.
  ///
  /// In en, this message translates to:
  /// **'Example: Asthma, Diabetes'**
  String get profileMedicalConditionsHint;

  /// No description provided for @profileCurrentMedication.
  ///
  /// In en, this message translates to:
  /// **'Current Medication'**
  String get profileCurrentMedication;

  /// No description provided for @profileMedicationHint.
  ///
  /// In en, this message translates to:
  /// **'Example: Ventolin inhaler'**
  String get profileMedicationHint;

  /// No description provided for @profileNextOfKin.
  ///
  /// In en, this message translates to:
  /// **'Next of Kin'**
  String get profileNextOfKin;

  /// No description provided for @profileKinNameHint.
  ///
  /// In en, this message translates to:
  /// **'Name (Relationship)'**
  String get profileKinNameHint;

  /// No description provided for @profilePhoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Phone Number'**
  String get profilePhoneNumber;

  /// No description provided for @profileSaveButton.
  ///
  /// In en, this message translates to:
  /// **'Save Emergency Profile'**
  String get profileSaveButton;

  /// No description provided for @emergencyNowTitle.
  ///
  /// In en, this message translates to:
  /// **'Emergency Now'**
  String get emergencyNowTitle;

  /// No description provided for @emergencyNowSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Start a manual report and receive immediate safety guidance.'**
  String get emergencyNowSubtitle;

  /// No description provided for @startManualReport.
  ///
  /// In en, this message translates to:
  /// **'Start Manual Emergency Report'**
  String get startManualReport;

  /// No description provided for @emergencyNowNotice.
  ///
  /// In en, this message translates to:
  /// **'This app provides reporting support and guidance. It does not contact or dispatch emergency services.'**
  String get emergencyNowNotice;

  /// No description provided for @guestFinishGuidance.
  ///
  /// In en, this message translates to:
  /// **'Finish and Return'**
  String get guestFinishGuidance;

  /// No description provided for @guestFinishGuidanceMessage.
  ///
  /// In en, this message translates to:
  /// **'You can start another report whenever needed.'**
  String get guestFinishGuidanceMessage;

  /// No description provided for @navHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get navHome;

  /// No description provided for @navDetect.
  ///
  /// In en, this message translates to:
  /// **'Detect'**
  String get navDetect;

  /// No description provided for @navTracking.
  ///
  /// In en, this message translates to:
  /// **'Tracking'**
  String get navTracking;

  /// No description provided for @navProfile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get navProfile;

  /// No description provided for @navAssist.
  ///
  /// In en, this message translates to:
  /// **'Assist'**
  String get navAssist;

  /// No description provided for @emergencyAnalysisResult.
  ///
  /// In en, this message translates to:
  /// **'Emergency Analysis Result'**
  String get emergencyAnalysisResult;

  /// No description provided for @emergencyTracking.
  ///
  /// In en, this message translates to:
  /// **'Emergency Tracking'**
  String get emergencyTracking;

  /// No description provided for @trackingSosSent.
  ///
  /// In en, this message translates to:
  /// **'SOS Sent'**
  String get trackingSosSent;

  /// No description provided for @trackingPendingConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Pending confirmation'**
  String get trackingPendingConfirmation;

  /// No description provided for @trackingEmergencyId.
  ///
  /// In en, this message translates to:
  /// **'Emergency ID'**
  String get trackingEmergencyId;

  /// No description provided for @trackingEmergencyType.
  ///
  /// In en, this message translates to:
  /// **'Emergency Type'**
  String get trackingEmergencyType;

  /// No description provided for @trackingSeverity.
  ///
  /// In en, this message translates to:
  /// **'Severity'**
  String get trackingSeverity;

  /// No description provided for @trackingAiConfidence.
  ///
  /// In en, this message translates to:
  /// **'AI Confidence'**
  String get trackingAiConfidence;

  /// No description provided for @trackingRecommendedResponders.
  ///
  /// In en, this message translates to:
  /// **'Recommended Responders'**
  String get trackingRecommendedResponders;

  /// No description provided for @trackingRealGpsLocation.
  ///
  /// In en, this message translates to:
  /// **'Real GPS Location'**
  String get trackingRealGpsLocation;

  /// No description provided for @trackingMalaysia999Flow.
  ///
  /// In en, this message translates to:
  /// **'Malaysia 999 Emergency Flow'**
  String get trackingMalaysia999Flow;

  /// No description provided for @trackingConfirmed.
  ///
  /// In en, this message translates to:
  /// **'Confirmed'**
  String get trackingConfirmed;

  /// No description provided for @trackingDispatched.
  ///
  /// In en, this message translates to:
  /// **'Dispatched'**
  String get trackingDispatched;

  /// No description provided for @trackingArriving.
  ///
  /// In en, this message translates to:
  /// **'Arriving'**
  String get trackingArriving;

  /// No description provided for @trackingCompleted.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get trackingCompleted;

  /// No description provided for @trackingCall999.
  ///
  /// In en, this message translates to:
  /// **'Call 999'**
  String get trackingCall999;

  /// No description provided for @trackingAssistanceArrived.
  ///
  /// In en, this message translates to:
  /// **'Assistance Arrived'**
  String get trackingAssistanceArrived;

  /// No description provided for @trackingCancelFalseAlarm.
  ///
  /// In en, this message translates to:
  /// **'Cancel False Alarm'**
  String get trackingCancelFalseAlarm;

  /// No description provided for @trackingShareLiveLocation.
  ///
  /// In en, this message translates to:
  /// **'Share Live Location'**
  String get trackingShareLiveLocation;

  /// No description provided for @trackingSending.
  ///
  /// In en, this message translates to:
  /// **'Sending...'**
  String get trackingSending;

  /// No description provided for @trackingSendUpdateToContacts.
  ///
  /// In en, this message translates to:
  /// **'Send Update to Emergency Contacts'**
  String get trackingSendUpdateToContacts;

  /// No description provided for @trackingBackToHome.
  ///
  /// In en, this message translates to:
  /// **'Back to Home'**
  String get trackingBackToHome;

  /// No description provided for @trackingNoActiveEmergency.
  ///
  /// In en, this message translates to:
  /// **'No active emergency'**
  String get trackingNoActiveEmergency;

  /// No description provided for @trackingNoActiveEmergencyMessage.
  ///
  /// In en, this message translates to:
  /// **'Emergency tracking will appear after an emergency report is created.'**
  String get trackingNoActiveEmergencyMessage;

  /// No description provided for @trackingLocationPermissionDenied.
  ///
  /// In en, this message translates to:
  /// **'Location permission denied'**
  String get trackingLocationPermissionDenied;

  /// No description provided for @trackingLocationUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Location unavailable'**
  String get trackingLocationUnavailable;

  /// No description provided for @trackingUnableOpenDialer.
  ///
  /// In en, this message translates to:
  /// **'Unable to open phone dialer.'**
  String get trackingUnableOpenDialer;

  /// No description provided for @trackingUnableOpenMaps.
  ///
  /// In en, this message translates to:
  /// **'Unable to open Google Maps.'**
  String get trackingUnableOpenMaps;

  /// No description provided for @trackingLoginFirst.
  ///
  /// In en, this message translates to:
  /// **'Please login first.'**
  String get trackingLoginFirst;

  /// No description provided for @trackingNoContacts.
  ///
  /// In en, this message translates to:
  /// **'No emergency contacts found.'**
  String get trackingNoContacts;

  /// No description provided for @trackingAlertSent.
  ///
  /// In en, this message translates to:
  /// **'Emergency alert sent to {count} contact(s).'**
  String trackingAlertSent(Object count);

  /// No description provided for @trackingInvalidContact.
  ///
  /// In en, this message translates to:
  /// **'Contact does not have a valid App User ID.'**
  String get trackingInvalidContact;

  /// No description provided for @trackingUpdateFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to send update: {error}'**
  String trackingUpdateFailed(Object error);

  /// No description provided for @trackingEmergencyUpdateFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to update emergency: {error}'**
  String trackingEmergencyUpdateFailed(Object error);

  /// No description provided for @trackingPending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get trackingPending;

  /// No description provided for @trackingDetailsConfirmed.
  ///
  /// In en, this message translates to:
  /// **'999 Details Confirmed'**
  String get trackingDetailsConfirmed;

  /// No description provided for @trackingResponderDispatched.
  ///
  /// In en, this message translates to:
  /// **'Responder Dispatched'**
  String get trackingResponderDispatched;

  /// No description provided for @trackingResponderArriving.
  ///
  /// In en, this message translates to:
  /// **'Responder Arriving'**
  String get trackingResponderArriving;

  /// No description provided for @trackingAssistanceArrivedStatus.
  ///
  /// In en, this message translates to:
  /// **'Assistance Arrived'**
  String get trackingAssistanceArrivedStatus;

  /// No description provided for @trackingFalseAlarmCancelled.
  ///
  /// In en, this message translates to:
  /// **'False Alarm Cancelled'**
  String get trackingFalseAlarmCancelled;

  /// No description provided for @trackingActive.
  ///
  /// In en, this message translates to:
  /// **'Tracking Active'**
  String get trackingActive;

  /// No description provided for @trackingNoLocationShared.
  ///
  /// In en, this message translates to:
  /// **'Location not shared'**
  String get trackingNoLocationShared;

  /// No description provided for @trackingEmergency.
  ///
  /// In en, this message translates to:
  /// **'Emergency'**
  String get trackingEmergency;

  /// No description provided for @trackingHigh.
  ///
  /// In en, this message translates to:
  /// **'High'**
  String get trackingHigh;

  /// No description provided for @trackingUnknown.
  ///
  /// In en, this message translates to:
  /// **'Unknown'**
  String get trackingUnknown;

  /// No description provided for @analysisLoading.
  ///
  /// In en, this message translates to:
  /// **'Analyzing image with Gemini AI...'**
  String get analysisLoading;

  /// No description provided for @analysisEvidenceDetected.
  ///
  /// In en, this message translates to:
  /// **'AI Evidence Detected'**
  String get analysisEvidenceDetected;

  /// No description provided for @analysisRecommendedResponders.
  ///
  /// In en, this message translates to:
  /// **'Recommended Responders'**
  String get analysisRecommendedResponders;

  /// No description provided for @analysisSuggestedEquipment.
  ///
  /// In en, this message translates to:
  /// **'Suggested Equipment'**
  String get analysisSuggestedEquipment;

  /// No description provided for @analysisSaving.
  ///
  /// In en, this message translates to:
  /// **'Saving...'**
  String get analysisSaving;

  /// No description provided for @analysisConfirmGetHelp.
  ///
  /// In en, this message translates to:
  /// **'Confirm & Get Help'**
  String get analysisConfirmGetHelp;

  /// No description provided for @analysisNoEmergencyIdentified.
  ///
  /// In en, this message translates to:
  /// **'No Emergency Identified'**
  String get analysisNoEmergencyIdentified;

  /// No description provided for @analysisReanalyze.
  ///
  /// In en, this message translates to:
  /// **'Re-analyze'**
  String get analysisReanalyze;

  /// No description provided for @analysisFalseAlarm.
  ///
  /// In en, this message translates to:
  /// **'False Alarm'**
  String get analysisFalseAlarm;

  /// No description provided for @analysisEmergencyDetected.
  ///
  /// In en, this message translates to:
  /// **'Emergency Detected'**
  String get analysisEmergencyDetected;

  /// No description provided for @analysisType.
  ///
  /// In en, this message translates to:
  /// **'Type'**
  String get analysisType;

  /// No description provided for @analysisSeverity.
  ///
  /// In en, this message translates to:
  /// **'Severity'**
  String get analysisSeverity;

  /// No description provided for @analysisConfidenceLevel.
  ///
  /// In en, this message translates to:
  /// **'Confidence Level'**
  String get analysisConfidenceLevel;

  /// No description provided for @analysisIncidentSummary.
  ///
  /// In en, this message translates to:
  /// **'AI Incident Summary'**
  String get analysisIncidentSummary;

  /// No description provided for @analysisNoSpecificDetails.
  ///
  /// In en, this message translates to:
  /// **'No specific details detected'**
  String get analysisNoSpecificDetails;

  /// No description provided for @analysisNoSummary.
  ///
  /// In en, this message translates to:
  /// **'No summary generated.'**
  String get analysisNoSummary;

  /// No description provided for @analysisFailed.
  ///
  /// In en, this message translates to:
  /// **'AI analysis failed'**
  String get analysisFailed;

  /// No description provided for @analysisTryAgain.
  ///
  /// In en, this message translates to:
  /// **'Try Again'**
  String get analysisTryAgain;

  /// No description provided for @cprBeatCount.
  ///
  /// In en, this message translates to:
  /// **'Beat Count'**
  String get cprBeatCount;

  /// No description provided for @manualTrackingStarting.
  ///
  /// In en, this message translates to:
  /// **'Starting...'**
  String get manualTrackingStarting;

  /// No description provided for @manualTrackingInternetRequired.
  ///
  /// In en, this message translates to:
  /// **'Internet connection is required to submit the report and view Emergency Tracking. Emergency guidance remains available offline.'**
  String get manualTrackingInternetRequired;

  /// No description provided for @manualTrackingUnableToStart.
  ///
  /// In en, this message translates to:
  /// **'Unable to start Emergency Tracking. Check your internet connection and try again.'**
  String get manualTrackingUnableToStart;
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
