import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:flutter_image_compress/flutter_image_compress.dart';

class EmergencyAiResult {
  final String incidentCategory;

  final String incidentSubType;

  final String emergencyType;
  final int confidence;
  final String severity;
  final List<String> evidence;
  final String summary;
  final List<String> responders;
  final List<String> equipment;
  final List<String> safetySteps;

  EmergencyAiResult({
    required this.incidentCategory,
    required this.incidentSubType,
    required this.emergencyType,
    required this.confidence,
    required this.severity,
    required this.evidence,
    required this.summary,
    required this.responders,
    required this.equipment,
    required this.safetySteps,
  });

  factory EmergencyAiResult.fromJson(Map<String, dynamic> json) {
    return EmergencyAiResult(
      incidentCategory: json["incidentCategory"]?.toString() ?? "Non-Emergency",

      incidentSubType: json["incidentSubType"]?.toString() ?? "Unknown",
      emergencyType: json['emergencyType']?.toString() ?? 'Unknown',
      confidence: int.tryParse(json['confidence'].toString()) ?? 0,
      severity: json['severity']?.toString() ?? 'Medium',
      evidence: List<String>.from(json['evidence'] ?? []),
      summary: json['summary']?.toString() ?? '',
      responders: List<String>.from(json['responders'] ?? []),
      equipment: List<String>.from(json['equipment'] ?? []),
      safetySteps: List<String>.from(json['safetySteps'] ?? []),
    );
  }
}

class AiEmergencyService {
  static const String _apiKey = String.fromEnvironment('GEMINI_API_KEY');

  static Uri get _geminiUri => Uri.parse(
    'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent?key=$_apiKey',
  );

  static void _checkApiKey() {
    if (_apiKey.isEmpty) {
      throw Exception('Missing Gemini API key.');
    }
  }

  static Future<String> _callGeminiText(String prompt) async {
    _checkApiKey();

    final response = await http.post(
      _geminiUri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'contents': [
          {
            'parts': [
              {'text': prompt},
            ],
          },
        ],
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('AI request failed: ${response.body}');
    }

    final body = jsonDecode(response.body);
    final text = body['candidates']?[0]?['content']?['parts']?[0]?['text'];

    if (text == null) {
      throw Exception('No AI response found.');
    }

    return text.toString().trim();
  }

  static Future<EmergencyAiResult> analyzeImage(
    File imageFile, {
    required String role,
  }) async {
    _checkApiKey();

    final targetPath = '${imageFile.path}_compressed.jpg';

    final compressedFile = await FlutterImageCompress.compressAndGetFile(
      imageFile.absolute.path,
      targetPath,
      quality: 60,
      format: CompressFormat.jpeg,
    );

    final bytes = compressedFile != null
        ? await compressedFile.readAsBytes()
        : await imageFile.readAsBytes();

    final base64Image = base64Encode(bytes);

    const prompt = '''
Analyze this image as an Emergency Decision Support System.

Determine:

• incidentCategory
• incidentSubType
• emergencyType
• confidence
• severity
• evidence
• summary
• responders
• equipment
• safetySteps

Return ONLY valid JSON.

{
  "incidentCategory":"Human | Animal | Environmental | Infrastructure | Non-Emergency",

  "incidentSubType":"Medical | Accident | Fire | Crime | Animal Rescue | Animal Observation | Flood | Gas Leak | Landslide | Electrical Hazard | Building Collapse | Unknown",

  "emergencyType":"Medical | Accident | Fire | Crime | Hazard | Animal Rescue | Flood | Gas Leak | Building Collapse | Electrical Hazard | Landslide | Unknown",

  "confidence":0,

  "severity":"Low | Medium | High",

  "evidence":["short evidence"],

  "summary":"short summary",

  "responders":["Fire Department"],

  "equipment":["First Aid Kit"],

  "safetySteps":["step1","step2"]
}

Rules:

1. First determine whether this is:

Human

Animal

Environmental

Infrastructure

Non-Emergency

Return it as incidentCategory.

2. Then determine the exact incident subtype.

Examples

Medical

Accident

Fire

Crime

Animal Rescue

Animal Observation

Flood

Gas Leak

Building Collapse

Electrical Hazard

Landslide

Unknown

Return it as incidentSubType.

3. Determine emergencyType as the primary emergency category.

Use:

Medical

Accident

Fire

Crime

Hazard

Animal Rescue

Unknown

Examples:

Building Collapse → Hazard

Gas Leak → Hazard

Flood → Hazard

Electrical Hazard → Hazard

Landslide → Hazard

Animal Observation → Unknown

Animal Rescue → Animal Rescue

4. Confidence must be 0–100.

5. Severity must be Low, Medium or High.

6. Responders must be empty only if emergencyType is Unknown.

7. Equipment must be empty only if emergencyType is Unknown.

8. Safety steps must be empty only if emergencyType is Unknown.

9. Return ONLY valid JSON.


''';

    http.Response? response;
    Object? lastError;

    for (int attempt = 1; attempt <= 2; attempt++) {
      try {
        response = await http
            .post(
              _geminiUri,
              headers: {'Content-Type': 'application/json'},
              body: jsonEncode({
                'contents': [
                  {
                    'parts': [
                      {'text': prompt},
                      {
                        'inline_data': {
                          'mime_type': 'image/jpeg',
                          'data': base64Image,
                        },
                      },
                    ],
                  },
                ],
              }),
            )
            .timeout(const Duration(seconds: 75));

        if (response.statusCode == 200) break;

        lastError = 'AI request failed: ${response.body}';
      } catch (e) {
        lastError = e;
      }
    }

    if (response == null || response.statusCode != 200) {
      throw Exception('AI analysis failed. Please retry. Details: $lastError');
    }

    final body = jsonDecode(response.body);
    final text = body['candidates']?[0]?['content']?['parts']?[0]?['text'];

    if (text == null) {
      throw Exception('No AI response found. Please retry.');
    }

    final cleaned = text
        .toString()
        .replaceAll('```json', '')
        .replaceAll('```', '')
        .trim();

    try {
      return EmergencyAiResult.fromJson(jsonDecode(cleaned));
    } catch (e) {
      throw Exception('AI returned invalid format. Please retry.');
    }
  }

  static Future<String> generateCallScript({
    required String emergencyType,
    required String severity,
    required String location,
    required List<String> evidence,
    required List<String> responders,
    required List<String> equipment,
    required String role,
    String victimCount = 'Unknown',
  }) async {
    final prompt =
        '''
Generate a clear emergency call script for calling 999 / 112.

Reporter Role: $role
Emergency Type: $emergencyType
Severity: $severity
Location: $location
Victim Count: $victimCount
Evidence: ${evidence.join(", ")}
Recommended Responders: ${responders.join(", ")}
Suggested Equipment: ${equipment.join(", ")}

Instructions:
- Keep it short and easy to speak.
- Include location, emergency type, severity, possible injuries, and urgency.
- Mention recommended responders.
- Mention suggested equipment if useful.
- Use simple English.
- Output only the call script. No markdown.
''';

    return _callGeminiText(prompt);
  }
}
