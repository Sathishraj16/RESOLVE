import 'dart:io';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:http/http.dart' as http;
import '../core/config/ai_config.dart';
import '../models/complaint_model.dart';

class SeverityResult {
  final int severity;
  final String reason;

  SeverityResult({required this.severity, required this.reason});

  factory SeverityResult.fromJson(Map<String, dynamic> json) {
    return SeverityResult(
      severity: json['severity'] as int,
      reason: json['reason'] as String,
    );
  }
}

class PhotoVerificationResult {
  final bool matches;
  final double confidence;
  final String detectedIssue;
  final String? suggestion;
  final String message;

  PhotoVerificationResult({
    required this.matches,
    required this.confidence,
    required this.detectedIssue,
    this.suggestion,
    required this.message,
  });

  factory PhotoVerificationResult.fromJson(Map<String, dynamic> json) {
    return PhotoVerificationResult(
      matches: json['matches'] as bool,
      confidence: (json['confidence'] as num).toDouble(),
      detectedIssue: json['detected_issue'] as String,
      suggestion: json['suggestion'] as String?,
      message: json['message'] as String,
    );
  }
}

class GeminiService {
  late final GenerativeModel _textModel;
  late final GenerativeModel _visionModel;
  late final GenerativeModel _chatModel;
  String? _workingModel;
  bool _initialized = false;
  Future<void>? _initializationFuture;

  GeminiService() {
    if (AIConfig.geminiApiKey == 'YOUR_GEMINI_API_KEY_HERE') {
      throw Exception(
        'Please set your Gemini API key in lib/core/config/ai_config.dart\n'
        'Get your key from: https://makersuite.google.com/app/apikey'
      );
    }

    _initializationFuture = _initializeModels();
  }

  Future<void> _ensureInitialized() async {
    if (_initialized) return;
    await _initializationFuture;
  }

  Future<void> _initializeModels() async {
    try {
      // First, try to list available models
      debugPrint('🔍 Discovering available Gemini models...');
      final models = await _listAvailableModels();
      
      if (models.isNotEmpty) {
        debugPrint('✅ Available models: ${models.join(", ")}');
        _workingModel = models.first;
        debugPrint('✅ Selected model: $_workingModel');
      } else {
        debugPrint('⚠️ No models discovered, using fallback');
        _workingModel = 'gemini-1.5-flash';
      }
    } catch (e) {
      debugPrint('⚠️ Model discovery failed: $e');
      debugPrint('⚠️ Using fallback model: gemini-1.5-flash');
      _workingModel = 'gemini-1.5-flash';
    }

    _textModel = GenerativeModel(
      model: _workingModel!,
      apiKey: AIConfig.geminiApiKey,
      generationConfig: GenerationConfig(
        temperature: AIConfig.analyticalTemperature,
        maxOutputTokens: AIConfig.maxOutputTokens,
      ),
    );

    _visionModel = GenerativeModel(
      model: _workingModel!,
      apiKey: AIConfig.geminiApiKey,
      generationConfig: GenerationConfig(
        temperature: AIConfig.analyticalTemperature,
        maxOutputTokens: AIConfig.maxOutputTokens,
      ),
    );

    _chatModel = GenerativeModel(
      model: _workingModel!,
      apiKey: AIConfig.geminiApiKey,
      generationConfig: GenerationConfig(
        temperature: AIConfig.creativityTemperature,
        maxOutputTokens: AIConfig.maxOutputTokens,
      ),
      systemInstruction: Content.system(AIConfig.chatbotSystemPrompt),
    );
    
    _initialized = true;
    debugPrint('✅ GeminiService fully initialized with model: $_workingModel');
  }

  /// Lists available Gemini models from the API
  Future<List<String>> _listAvailableModels() async {
    try {
      debugPrint('📡 Calling Gemini API ListModels endpoint...');
      
      // Call the official ListModels API endpoint
      final url = 'https://generativelanguage.googleapis.com/v1beta/models?key=${AIConfig.geminiApiKey}';
      final response = await http.get(Uri.parse(url));
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final models = data['models'] as List<dynamic>;
        
        debugPrint('📋 Found ${models.length} total models from API');
        
        // Filter models that support generateContent
        final availableModels = <String>[];
        for (final model in models) {
          final name = model['name'] as String;
          final supportedMethods = model['supportedGenerationMethods'] as List<dynamic>?;
          
          // Extract just the model name without the "models/" prefix
          final modelName = name.replaceFirst('models/', '');
          
          // Check if it supports generateContent
          if (supportedMethods != null && supportedMethods.contains('generateContent')) {
            availableModels.add(modelName);
            debugPrint('  ✅ $modelName - supports generateContent');
          } else {
            debugPrint('  ⚠️  $modelName - does NOT support generateContent');
          }
        }
        
        if (availableModels.isEmpty) {
          debugPrint('❌ No models support generateContent!');
        }
        
        return availableModels;
      } else {
        debugPrint('❌ ListModels API error: ${response.statusCode} - ${response.body}');
        return [];
      }
    } catch (e) {
      debugPrint('❌ Error calling ListModels API: $e');
      return [];
    }
  }

  /// Analyze complaint and assign severity level (1-5)
  Future<SeverityResult> analyzeSeverity({
    required String category,
    required String title,
    required String description,
    File? image,
  }) async {
    await _ensureInitialized();
    
    try {
      String prompt = AIConfig.severityPrompt
          .replaceAll('{category}', _getCategoryName(category))
          .replaceAll('{title}', title)
          .replaceAll('{description}', description);

      final response = await _textModel.generateContent([
        Content.text(prompt),
      ]);

      final text = response.text ?? '';
      
      // Extract JSON from response (might have markdown code blocks)
      String jsonText = text.trim();
      if (jsonText.startsWith('```json')) {
        jsonText = jsonText.substring(7);
      }
      if (jsonText.startsWith('```')) {
        jsonText = jsonText.substring(3);
      }
      if (jsonText.endsWith('```')) {
        jsonText = jsonText.substring(0, jsonText.length - 3);
      }
      jsonText = jsonText.trim();

      final jsonData = json.decode(jsonText);
      return SeverityResult.fromJson(jsonData);
    } catch (e) {
      print('Error analyzing severity: $e');
      // Fallback to medium severity if AI fails
      return SeverityResult(
        severity: 3,
        reason: 'Unable to analyze severity automatically. Defaulted to medium priority.',
      );
    }
  }

  /// Verify if photo matches the complaint category
  Future<PhotoVerificationResult> verifyPhoto({
    required File image,
    required String category,
    required String title,
  }) async {
    await _ensureInitialized();
    
    try {
      String prompt = AIConfig.photoVerificationPrompt
          .replaceAll('{category}', _getCategoryName(category))
          .replaceAll('{title}', title);

      final imageBytes = await image.readAsBytes();
      
      final response = await _visionModel.generateContent([
        Content.multi([
          TextPart(prompt),
          DataPart('image/jpeg', imageBytes),
        ]),
      ]);

      final text = response.text ?? '';
      
      // Extract JSON from response
      String jsonText = text.trim();
      if (jsonText.startsWith('```json')) {
        jsonText = jsonText.substring(7);
      }
      if (jsonText.startsWith('```')) {
        jsonText = jsonText.substring(3);
      }
      if (jsonText.endsWith('```')) {
        jsonText = jsonText.substring(0, jsonText.length - 3);
      }
      jsonText = jsonText.trim();

      final jsonData = json.decode(jsonText);
      return PhotoVerificationResult.fromJson(jsonData);
    } catch (e) {
      print('Error verifying photo: $e');
      if (e.toString().contains('API key') || e.toString().contains('403')) {
         return PhotoVerificationResult(
          matches: false,
          confidence: 1.0,
          detectedIssue: 'API Key Invalid',
          message: 'AI Service Error: Your API key is invalid or flagged. Verification failed.',
        );
      }
      // Fallback to assuming photo is correct if AI fails
      return PhotoVerificationResult(
        matches: true,
        confidence: 0.5,
        detectedIssue: 'Unable to verify photo automatically',
        message: 'Photo verification unavailable. Proceeding with submission.',
      );
    }
  }

  /// Create chat session for RESOLVE Assistant
  Future<ChatSession> createChatSession() async {
    await _ensureInitialized();
    return _chatModel.startChat();
  }

  /// Send message to chatbot
  Future<String> sendChatMessage(ChatSession chat, String message) async {
    await _ensureInitialized();
    
    try {
      final response = await chat.sendMessage(Content.text(message));
      return response.text ?? 'Sorry, I could not process that. Please try again.';
    } catch (e) {
      print('Error in chat: $e');
      if (e.toString().contains('API key') || e.toString().contains('403')) {
        return 'Configuration Error: Your API key is invalid or flagged. Please check your settings.';
      }
      return 'Sorry, I encountered an error. Please try again later.';
    }
  }

  String _getCategoryName(String category) {
    final categoryMap = {
      'streetlight': 'Street Light',
      'roadDamage': 'Road Damage',
      'drainage': 'Drainage',
      'garbageCollection': 'Garbage Collection',
      'trafficSignal': 'Traffic Signal',
      'illegalParking': 'Illegal Parking',
      'waterSupply': 'Water Supply',
      'publicProperty': 'Public Property',
      'other': 'Other',
    };
    
    return categoryMap[category] ?? category;
  }
}
