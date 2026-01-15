# 🤖 AI Features Setup Guide

## Overview

RESOLVE now includes powerful AI features using Google's Gemini API:

1. **🎯 AI Severity Ranking** - Automatically analyzes complaints and assigns severity levels (1-5)
2. **📸 AI Photo Verification** - Validates uploaded photos match the complaint category
3. **💬 RESOLVE Assistant Chatbot** - AI-powered helper to answer questions about the app

---

## 🚀 Quick Setup

### Step 1: Get Your Gemini API Key

1. Visit [Google AI Studio](https://makersuite.google.com/app/apikey)
2. Sign in with your Google account
3. Click **"Get API Key"** or **"Create API Key"**
4. Copy your API key

### Step 2: Configure the App

1. Open `lib/core/config/ai_config.dart`
2. Replace the placeholder with your actual API key:

```dart
static const String geminiApiKey = 'YOUR_ACTUAL_GEMINI_API_KEY_HERE';
```

3. Save the file

### Step 3: Run the App

```bash
flutter run -d chrome
```

That's it! AI features are now active. 🎉

---

## 📋 Features in Detail

### 1. AI Severity Ranking 🎯

**What it does:**
- Analyzes complaint title, description, and category
- Assigns severity level from 1-5
- Provides reasoning for the rating

**Severity Levels:**
- **Level 1 (Minor)**: Small inconveniences, low priority
  - Example: Single non-functioning streetlight
  - Color: 🔵 Blue

- **Level 2 (Moderate)**: Issues needing attention
  - Example: Multiple potholes, garbage not collected for 2-3 days
  - Color: 🟢 Green

- **Level 3 (Significant)**: Problems affecting community
  - Example: Major road damage, drainage issues
  - Color: 🟠 Orange

- **Level 4 (Serious)**: Urgent action required
  - Example: Broken traffic signals, major water leaks
  - Color: 🔴 Deep Orange

- **Level 5 (Critical)**: Emergency, immediate response needed
  - Example: Road collapse, sewage overflow, dangerous damage
  - Color: 🔴 Red

**Where to see it:**
- Complaint cards show severity badge with level (e.g., "L3")
- Complaint detail screen shows full severity assessment
- AI explains why it assigned that level

**How it works:**
1. User fills complaint form (title + description + category)
2. When submitting, AI analyzes the content
3. AI considers:
   - Public safety impact
   - Number of people affected
   - Urgency of resolution
   - Health and environmental concerns
4. Assigns severity level with explanation
5. Saved with complaint data

### 2. AI Photo Verification 📸

**What it does:**
- Checks if uploaded photo matches selected category
- Provides confidence score (0-100%)
- Suggests correct category if mismatch detected

**How it works:**
1. User uploads photo
2. User selects category (e.g., "Road Damage")
3. AI analyzes the image
4. If mismatch detected:
   - Shows warning message
   - Explains what it sees in the photo
   - Suggests correct category
5. User can keep or change category

**Example Scenarios:**

✅ **Match Found:**
```
Category: Road Damage
Photo: Shows pothole
Result: ✓ Photo verified - Matches category
```

⚠️ **Mismatch Detected:**
```
Category: Street Light
Photo: Shows garbage pile
Result: Photo may not match selected category
Detected: Accumulated garbage and waste
Suggestion: Try "Garbage Collection" category
```

**Where to see it:**
- Report complaint screen shows verification status
- Green checkmark for match
- Orange warning for mismatch
- Real-time verification as you select categories

### 3. RESOLVE Assistant Chatbot 💬

**What it does:**
- Answers questions about RESOLVE
- Helps with complaint reporting
- Explains features and functionality
- Provides tips for better results

**Features:**
- Natural conversation interface
- Remembers context within chat session
- Friendly and helpful responses
- Available 24/7

**Example Questions:**
- "How do I report a complaint?"
- "What categories are available?"
- "How can I track my complaint?"
- "What's the difference between severity levels?"
- "Tips for taking good photos?"
- "How long does resolution take?"

**Where to access:**
- Floating chat button on home screen (support agent icon)
- Opens full-screen chat interface
- Type your question and get instant AI-powered answers

---

## 💡 Usage Tips

### For Best AI Severity Results:

1. **Be Descriptive**: More details = better analysis
   ```
   ❌ Bad: "Road problem"
   ✅ Good: "Large pothole on Main Street causing vehicles to swerve into opposite lane"
   ```

2. **Mention Impact**: Tell how many people are affected
   ```
   ✅ "Affects 500+ daily commuters during rush hour"
   ```

3. **Note Urgency**: Explain why it's urgent (if it is)
   ```
   ✅ "Water pipe burst, flooding basement, needs immediate attention"
   ```

4. **Safety Concerns**: Always mention if there's danger
   ```
   ✅ "Exposed electrical wires near children's park"
   ```

### For Best Photo Verification:

1. **Take Clear Photos**: Good lighting, focus on the issue
2. **Show Context**: Include surroundings to help AI understand
3. **Avoid Blurry Images**: Hold phone steady
4. **Center the Issue**: Make the problem the main focus
5. **Select Category After**: Upload photo first, then choose category for auto-verification

### Chatbot Tips:

1. **Ask Specific Questions**: 
   - ❌ "Help"
   - ✅ "How do I change my complaint category?"

2. **One Topic at a Time**: Easier for AI to provide focused answers

3. **Follow-up Questions**: AI remembers context, so you can ask follow-ups

---

## 🔧 Configuration Options

### Adjust AI Behavior

Edit `lib/core/config/ai_config.dart`:

```dart
// Change AI temperature (creativity vs accuracy)
static const double creativityTemperature = 0.7;  // For chatbot (0-1)
static const double analyticalTemperature = 0.3;  // For analysis (0-1)

// Higher = more creative/varied responses
// Lower = more focused/consistent responses

// Maximum response length
static const int maxOutputTokens = 2048;
```

### Customize Prompts

The AI prompts can be customized in the same file:
- `severityPrompt` - How severity is analyzed
- `photoVerificationPrompt` - How photos are verified
- `chatbotSystemPrompt` - Chatbot personality and knowledge

---

## 🐛 Troubleshooting

### "AI features unavailable" Error

**Cause**: Invalid or missing API key

**Solution**:
1. Check `lib/core/config/ai_config.dart`
2. Verify API key is correct (no extra spaces/quotes)
3. Ensure you have internet connection
4. Check API key is active at [Google AI Studio](https://makersuite.google.com/app/apikey)

### AI Responses are Slow

**Normal**: First request may take 3-5 seconds
**If consistently slow**:
- Check internet connection
- Try reducing `maxOutputTokens` in config
- Check Gemini API status

### Photo Verification Not Working

**Solutions**:
1. Ensure photo is under 10MB
2. Use common image formats (JPG, PNG)
3. Check internet connection
4. Try a clearer photo

### Chatbot Gives Generic Answers

**Causes**:
- Question is too vague
- No specific context provided

**Solutions**:
- Ask more specific questions
- Provide context in your question
- Try rephrasing

---

## 📊 AI Usage Limits

### Free Tier (Gemini API):
- **60 requests per minute**
- **1,500 requests per day**
- **Unlimited requests per month** (with rate limits)

**Perfect for development and moderate usage!**

For production with high traffic, consider:
- Implementing caching for common questions
- Rate limiting on your backend
- Upgrading to paid Gemini API tier if needed

---

## 🎨 UI Components

### Severity Badge
```dart
// Small badge (for cards)
SeverityBadge(severity: 3, showLabel: false)

// Large badge (for detail screens)
SeverityBadgeLarge(
  severity: 3,
  reason: 'Significant impact on daily commute',
)
```

### Photo Verification Status
Automatically shown in ReportComplaintScreen:
- 🟢 Green checkmark = Verified match
- 🟠 Orange warning = Possible mismatch
- ⏳ Loading spinner = Analyzing...

---

## 🔐 Security Best Practices

1. **Never commit API keys to Git**:
   ```bash
   # Add to .gitignore
   lib/core/config/ai_config.dart
   ```

2. **Use environment variables in production**:
   ```dart
   static String get geminiApiKey => 
       const String.fromEnvironment('GEMINI_API_KEY',
           defaultValue: 'YOUR_GEMINI_API_KEY_HERE');
   ```

3. **Implement backend proxy** (for production):
   - Don't expose API key in client app
   - Route requests through your backend
   - Add authentication and rate limiting

---

## 📱 Platform Support

| Feature | Web | Android | iOS |
|---------|-----|---------|-----|
| Severity Ranking | ✅ | ✅ | ✅ |
| Photo Verification | ✅ | ✅ | ✅ |
| Chatbot | ✅ | ✅ | ✅ |

All AI features work across all platforms!

---

## 🚀 Next Steps

Now that AI features are set up, you can:

1. **Test the Features**:
   - Report a test complaint to see AI severity
   - Try different categories to test photo verification
   - Chat with RESOLVE Assistant

2. **Move to Firebase** (next phase):
   - Store complaints with AI data
   - Implement user authentication
   - Enable real-time updates

3. **Customize**:
   - Adjust severity criteria in prompts
   - Modify chatbot personality
   - Add more categories

---

## 📚 Additional Resources

- [Gemini API Documentation](https://ai.google.dev/docs)
- [Flutter Gemini Package](https://pub.dev/packages/google_generative_ai)
- [Prompt Engineering Guide](https://ai.google.dev/docs/prompt_best_practices)

---

## 💬 Need Help?

- Check Gemini API status
- Review console logs for errors
- Ask RESOLVE Assistant (it knows how it works!)
- Check `lib/services/gemini_service.dart` for implementation details

---

**Enjoy your AI-powered civic platform! 🎉**
