# 🚀 Quick Start - AI Features

## ⚡ Get Started in 3 Minutes

### Step 1: Get Gemini API Key (2 minutes)

1. Go to → **https://makersuite.google.com/app/apikey**
2. Click **"Create API Key"**
3. Copy your key

### Step 2: Add Your API Key (30 seconds)

1. Open `lib/core/config/ai_config.dart`
2. Find line 4:
   ```dart
   static const String geminiApiKey = 'YOUR_GEMINI_API_KEY_HERE';
   ```
3. Replace with your key:
   ```dart
   static const String geminiApiKey = 'AIzaSyC...your-actual-key...xyz';
   ```
4. Save file

### Step 3: Run the App (30 seconds)

```bash
flutter run -d chrome
```

## ✅ Test AI Features

### Test 1: AI Severity Ranking
1. Click **"Report Issue"** button
2. Add photo of an issue
3. Select category (e.g., "Road Damage")
4. Fill title: "Large pothole on Main Street"
5. Fill description: "Deep pothole causing vehicles to swerve. Affects 500+ commuters daily."
6. Click **Submit**
7. ✨ AI will analyze and assign severity level
8. View complaint to see AI severity badge

### Test 2: Photo Verification
1. Click **"Report Issue"**
2. Upload a photo (e.g., picture of garbage)
3. Select category: "Street Light" (wrong category on purpose)
4. Watch for verification status:
   - ⚠️ Warning appears: "Photo may not match category"
   - AI detected: "Accumulated garbage"
   - AI suggests: "Garbage Collection"
5. Change to correct category and see ✅ verification pass

### Test 3: Chatbot
1. Click the **floating chat icon** (support agent) on home screen
2. Try these questions:
   - "How do I report a complaint?"
   - "What's a severity level?"
   - "How does photo verification work?"
3. Get instant AI-powered answers!

## 🎯 What You'll See

### On Complaint Cards:
- Small severity badge showing level (L1-L5)
- Color-coded by severity (Blue → Red)

### On Complaint Details:
- Large severity badge with full explanation
- AI reasoning for the severity rating

### When Reporting:
- Real-time photo verification
- Green ✅ or orange ⚠️ status indicators
- Helpful suggestions if photo doesn't match

### Chatbot:
- Friendly AI assistant
- Remembers conversation context
- Answers questions about RESOLVE

## 💡 Pro Tips

**For Better AI Analysis:**
- Be specific in descriptions
- Mention number of people affected
- Include urgency and safety concerns
- Use clear, well-lit photos

**For Chatbot:**
- Ask specific questions
- One topic at a time
- Follow up for more details

## ❗ Troubleshooting

**If AI features don't work:**

1. Check API key is correct (no extra spaces)
2. Verify internet connection
3. Look at browser console for errors (F12)
4. Make sure you have `flutter pub get` after adding the key

**Still having issues?**
- Read full guide: `AI_FEATURES_GUIDE.md`
- Check Gemini API status
- Verify API key at https://makersuite.google.com/app/apikey

## 🎉 You're All Set!

Your RESOLVE app now has:
- ✅ AI-powered severity ranking
- ✅ Smart photo verification
- ✅ Intelligent chatbot assistant

Ready to move to Firebase and OAuth? Just let me know!

---

**Next Phase**: Firebase integration for cloud storage & OAuth authentication
