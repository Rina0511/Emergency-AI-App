import 'package:flutter/material.dart';
import 'app_language.dart';

class AppStrings {
  static String homeTitle(BuildContext context) =>
      AppLanguage.isMalay(context) ? 'AI Kecemasan' : 'Emergency AI';

  static String locationActive(BuildContext context) =>
      AppLanguage.isMalay(context)
      ? 'Lokasi Aktif • LANGSUNG'
      : 'Location Active • LIVE';

  static String holdToActivate(BuildContext context) =>
      AppLanguage.isMalay(context)
      ? 'Tekan lama untuk aktifkan'
      : 'Hold to activate';

  static String fastResponse(BuildContext context) =>
      AppLanguage.isMalay(context)
      ? 'Respons kecemasan pantas dan pengesanan dibantu AI.'
      : 'Fast emergency response and AI-assisted detection.';

  static String uploadIncidentPhotoAI(BuildContext context) =>
      AppLanguage.isMalay(context)
      ? 'Muat Naik Gambar Insiden (Analisis AI)'
      : 'Upload Incident Photo (AI Analysis)';

  static String emergencyCategories(BuildContext context) =>
      AppLanguage.isMalay(context)
      ? 'Kategori Kecemasan'
      : 'Emergency Categories';

  static String reportNow(BuildContext context) =>
      AppLanguage.isMalay(context) ? 'Lapor Sekarang' : 'Report Now';

  static String whatItMayInvolve(BuildContext context) =>
      AppLanguage.isMalay(context)
      ? 'Apa yang mungkin terlibat'
      : 'What it may involve';

  static String uploadReport(BuildContext context) =>
      AppLanguage.isMalay(context) ? 'Muat Naik Laporan' : 'Upload Report';

  static String uploadIncidentPhoto(BuildContext context) =>
      AppLanguage.isMalay(context)
      ? 'Muat Naik Gambar Insiden'
      : 'Upload Incident Photo';

  static String uploadIncidentPhotoDesc(BuildContext context) =>
      AppLanguage.isMalay(context)
      ? 'Ambil atau muat naik gambar supaya AI boleh menganalisis situasi kecemasan dengan cepat.'
      : 'Take or upload a photo so AI can analyze the emergency situation quickly.';

  static String reportingAsVictim(BuildContext context) =>
      AppLanguage.isMalay(context)
      ? 'Melapor sebagai: Mangsa'
      : 'Reporting as: Victim';

  static String reportingAsWitness(BuildContext context) =>
      AppLanguage.isMalay(context)
      ? 'Melapor sebagai: Saksi'
      : 'Reporting as: Witness';

  static String noPhotoSelected(BuildContext context) =>
      AppLanguage.isMalay(context)
      ? 'Tiada gambar dipilih'
      : 'No photo selected';

  static String captureOrUpload(BuildContext context) =>
      AppLanguage.isMalay(context)
      ? 'Ambil atau muat naik gambar insiden'
      : 'Capture or upload an incident image';

  static String photoSelected(BuildContext context) =>
      AppLanguage.isMalay(context) ? 'Gambar dipilih' : 'Photo selected';

  static String takePhoto(BuildContext context) =>
      AppLanguage.isMalay(context) ? 'Ambil Gambar' : 'Take Photo';

  static String gallery(BuildContext context) =>
      AppLanguage.isMalay(context) ? 'Galeri' : 'Gallery';

  static String includeGps(BuildContext context) => AppLanguage.isMalay(context)
      ? 'Sertakan Lokasi GPS'
      : 'Include GPS Location';

  static String shareLocation(BuildContext context) =>
      AppLanguage.isMalay(context)
      ? 'Kongsi lokasi semasa anda bersama laporan'
      : 'Share your current location with the report';

  static String aiAnalysisInfo(BuildContext context) =>
      AppLanguage.isMalay(context)
      ? 'Analisis AI akan mengesan: jenis kecemasan, tahap keterukan, responden, panduan keselamatan, dan butiran SOS.'
      : 'AI analysis will detect: emergency type, severity, responders, safety guidance, and SOS details.';

  static String analyzeNow(BuildContext context) =>
      AppLanguage.isMalay(context) ? 'Analisis Sekarang' : 'Analyze Now';

  static String safetyGuidance(BuildContext context) =>
      AppLanguage.isMalay(context) ? 'Panduan Keselamatan' : 'Safety Guidance';

  static String detailedGuidanceVictim(BuildContext context) =>
      AppLanguage.isMalay(context)
      ? 'Panduan terperinci dibantu AI untuk mangsa.'
      : 'Detailed AI-assisted guidance for the victim.';

  static String detailedGuidanceWitness(BuildContext context) =>
      AppLanguage.isMalay(context)
      ? 'Panduan terperinci dibantu AI untuk saksi/pembantu.'
      : 'Detailed AI-assisted guidance for a witness/helper.';

  static String immediateSafetySteps(BuildContext context) =>
      AppLanguage.isMalay(context)
      ? 'Langkah Keselamatan Segera'
      : 'Immediate Safety Steps';

  static String suggestedEquipment(BuildContext context) =>
      AppLanguage.isMalay(context)
      ? 'Peralatan Disyorkan'
      : 'Suggested Equipment';

  static String recommendedResponders(BuildContext context) =>
      AppLanguage.isMalay(context)
      ? 'Responden Disyorkan'
      : 'Recommended Responders';

  static String call999(BuildContext context) =>
      AppLanguage.isMalay(context) ? 'Hubungi 999 / 112' : 'Call 999 / 112';

  static String sendAutoSos(BuildContext context) =>
      AppLanguage.isMalay(context)
      ? 'Hantar Mesej SOS Automatik'
      : 'Send Auto SOS Message';

  static String viewWhatToSay(BuildContext context) =>
      AppLanguage.isMalay(context)
      ? 'Lihat Apa Yang Perlu Dikatakan (Skrip Panggilan)'
      : 'View What To Say (Call Script)';

  static String callScript(BuildContext context) =>
      AppLanguage.isMalay(context) ? 'Skrip Panggilan' : 'Call Script';

  static String readThisScript(BuildContext context) =>
      AppLanguage.isMalay(context)
      ? 'Baca skrip ini semasa membuat panggilan kecemasan.'
      : 'Read this script during the emergency call.';

  static String explainSituation(BuildContext context) =>
      AppLanguage.isMalay(context)
      ? 'Gunakan skrip ini untuk menerangkan situasi dengan jelas.'
      : 'Use this script to explain the situation clearly.';

  static String emergencyCallGuide(BuildContext context) =>
      AppLanguage.isMalay(context)
      ? 'Panduan Panggilan Kecemasan'
      : 'Emergency Call Guide';

  static String speakCalmly(BuildContext context) =>
      AppLanguage.isMalay(context)
      ? 'Bercakap dengan tenang dan baca butiran penting dengan jelas.'
      : 'Speak calmly and read the key details clearly.';

  static String whatToSay(BuildContext context) =>
      AppLanguage.isMalay(context) ? 'Apa Yang Perlu Dikatakan' : 'What To Say';

  static String victimScript(BuildContext context) =>
      AppLanguage.isMalay(context) ? 'Skrip Mangsa' : 'Victim Script';

  static String witnessScript(BuildContext context) =>
      AppLanguage.isMalay(context) ? 'Skrip Saksi' : 'Witness Script';

  static String importantDetails(BuildContext context) =>
      AppLanguage.isMalay(context)
      ? 'Butiran Penting Untuk Dinyatakan'
      : 'Important Details To Mention';

  static String reportStatus(BuildContext context) =>
      AppLanguage.isMalay(context) ? 'Status Laporan' : 'Report Status';

  static String sosMessagePreview(BuildContext context) =>
      AppLanguage.isMalay(context)
      ? 'Pratonton Mesej SOS'
      : 'SOS Message Preview';

  static String message(BuildContext context) =>
      AppLanguage.isMalay(context) ? 'Mesej' : 'Message';

  static String sendingTo(BuildContext context) =>
      AppLanguage.isMalay(context) ? 'Dihantar kepada' : 'Sending to';

  static String sendViaSms(BuildContext context) =>
      AppLanguage.isMalay(context) ? 'Hantar melalui SMS' : 'Send via SMS';

  static String sendViaWhatsapp(BuildContext context) =>
      AppLanguage.isMalay(context)
      ? 'Hantar melalui WhatsApp'
      : 'Send via WhatsApp';

  static String cancel(BuildContext context) =>
      AppLanguage.isMalay(context) ? 'Batal' : 'Cancel';

  static String chooseLanguage(BuildContext context) =>
      AppLanguage.isMalay(context) ? 'Pilih Bahasa' : 'Choose Language';

  static String chooseLanguageSub(BuildContext context) =>
      AppLanguage.isMalay(context)
      ? 'Sila pilih bahasa aplikasi'
      : 'Please choose your app language';

  static String changeLater(BuildContext context) =>
      AppLanguage.isMalay(context)
      ? 'Anda boleh tukar bahasa kemudian di Tetapan'
      : 'You can change language later in Settings';

  static String reportRoleHeader(BuildContext context) =>
      AppLanguage.isMalay(context) ? 'Laporan Kecemasan' : 'Emergency Report';

  static String whoNeedsHelp(BuildContext context) =>
      AppLanguage.isMalay(context)
      ? 'Siapa Perlukan Bantuan?'
      : 'Who Needs Help?';

  static String selectYourRole(BuildContext context) =>
      AppLanguage.isMalay(context)
      ? 'Pilih peranan anda supaya kami dapat membantu dengan lebih baik.'
      : 'Select your role so we can assist you better.';

  static String iNeedHelp(BuildContext context) =>
      AppLanguage.isMalay(context) ? 'Saya Perlukan Bantuan' : 'I Need Help';

  static String iAmVictim(BuildContext context) => AppLanguage.isMalay(context)
      ? 'Anda ialah mangsa atau dalam bahaya.'
      : 'You are the victim or in danger.';

  static String someoneElseNeedsHelp(BuildContext context) =>
      AppLanguage.isMalay(context)
      ? 'Orang Lain Perlukan Bantuan'
      : 'Someone Else Needs Help';

  static String reportingAnotherPerson(BuildContext context) =>
      AppLanguage.isMalay(context)
      ? 'Anda melaporkan bagi pihak orang lain.'
      : 'You are reporting for another person.';

  static String continueText(BuildContext context) =>
      AppLanguage.isMalay(context) ? 'Teruskan' : 'Continue';
}
