class AIConfig {
  // TODO: Replace with your actual Gemini API key
  // Get your key from: https://makersuite.google.com/app/apikey
  static const String geminiApiKey = 'AIzaSyCTiNJMhz9Z71oJ9ocbK5Qa1JtRIBSvVz0';
  
  // Model configurations
  static const String textModel = 'gemini-1.5-pro-latest';
  static const String visionModel = 'gemini-1.5-pro-latest';
  
  // Temperature settings for AI responses
  static const double creativityTemperature = 0.7;
  static const double analyticalTemperature = 0.3;
  
  // Safety settings
  static const int maxOutputTokens = 2048;
  
  // Prompts
  static const String severityPrompt = '''
Analyze this civic complaint and rate its severity from 1 to 5 where:
- Level 1: Minor inconvenience, low priority (e.g., small potholes, single non-functioning streetlight)
- Level 2: Moderate issue, needs attention (e.g., multiple potholes, garbage not collected for 2-3 days)
- Level 3: Significant problem affecting community (e.g., major road damage, drainage issues, consistent garbage problems)
- Level 4: Serious issue requiring urgent action (e.g., broken traffic signals, major water leaks, widespread electrical issues)
- Level 5: Critical emergency, immediate response needed (e.g., major road collapse, sewage overflow, dangerous structural damage)

Consider:
- Public safety impact
- Number of people affected
- Urgency of resolution
- Potential for escalation
- Health and environmental concerns

Complaint Details:
Category: {category}
Title: {title}
Description: {description}

Respond with ONLY a JSON object in this exact format:
{
  "severity": <number 1-5>,
  "reason": "<brief explanation in 1-2 sentences>"
}
''';

  static const String photoVerificationPrompt = '''
Analyze this image and determine if it matches the reported complaint category.

Reported Category: {category}
Complaint Title: {title}

Categories and what they should show:
- Street Light: Non-functioning or damaged street lights, poles, or lighting fixtures
- Road Damage: Potholes, cracks, broken road surfaces, damaged pavements
- Drainage: Clogged drains, overflowing drainage systems, water logging
- Garbage Collection: Accumulated garbage, overflowing bins, littering
- Traffic Signal: Malfunctioning traffic lights, broken signals
- Illegal Parking: Vehicles parked in no-parking zones, blocking roads
- Water Supply: Water leaks, pipe bursts, no water supply issues
- Public Property: Damaged public infrastructure, vandalism, broken facilities

CRITICAL INSTRUCTION:
Check for SPAM. If the image is:
- A random internet image (memes, selfies, pets, food, screenshots)
- Totally unrelated to civic issues (e.g. a photo of a laptop, a room, a person smiling)
- Blurry or black/white screen with no content

Then you MUST respond with "matches": false, and describe it as spam/irrelevant.

Analyze the image and respond with ONLY a JSON object:
{
  "matches": <true/false>,
  "confidence": <0.0-1.0>,
  "detected_issue": "<what you see in the image>",
  "suggestion": "<If mismatch, suggest correct category or 'other'. If spam, use 'spam'>",
  "message": "<friendly message to user>"
}
''';

  static const String chatbotSystemPrompt = '''
You are RESOLVE Assistant, a helpful AI chatbot for the RESOLVE civic grievance platform.

About RESOLVE:
- RESOLVE is a citizen-centric civic complaint management system
- Citizens can report issues like potholes, street lights, garbage collection, drainage, etc.
- Issues are automatically routed to appropriate government departments
- Citizens can track complaint progress in real-time (like food delivery apps)
- AI-powered severity ranking and photo verification
- Three-pillar architecture: Citizens, Officials, and Administrators

Your role:
1. Answer questions about how to use RESOLVE
2. Explain features and functionality
3. Help with complaint categories
4. Provide tips for better complaint reporting
5. Be friendly, helpful, and encouraging
6. Keep responses concise (2-3 sentences when possible)

Guidelines:
- Be conversational and friendly
- Use emojis occasionally to be engaging
- If you don't know something specific, be honest
- Encourage civic participation
- Don't make promises about complaint resolution times
- Direct technical issues to support

Current Features:
- Photo-based complaint reporting
- Real-time progress tracking
- AI severity assessment
- Photo verification
- Department-wise routing
- Upvoting system
- Admin dashboard
- Official app for field workers
''';
}
