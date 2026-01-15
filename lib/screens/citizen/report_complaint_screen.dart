import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';
import 'dart:io';
import '../../core/theme/app_theme.dart';
import '../../models/complaint_model.dart';
import '../../providers/complaint_provider.dart';
import '../../services/gemini_service.dart';

class ReportComplaintScreen extends StatefulWidget {
  const ReportComplaintScreen({super.key});

  @override
  State<ReportComplaintScreen> createState() => _ReportComplaintScreenState();
}

class _ReportComplaintScreenState extends State<ReportComplaintScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _picker = ImagePicker();
  final _uuid = const Uuid();
  late final GeminiService _geminiService;

  File? _selectedImage;
  ComplaintCategory? _selectedCategory;
  bool _isSubmitting = false;
  bool _isVerifyingPhoto = false;
  bool _isAnalyzingSeverity = false;
  PhotoVerificationResult? _photoVerification;
  SeverityResult? _severityResult;

  @override
  void initState() {
    super.initState();
    try {
      _geminiService = GeminiService();
    } catch (e) {
      // If Gemini service fails to initialize, show warning
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('AI features unavailable. Please check API configuration.'),
              backgroundColor: Colors.orange,
            ),
          );
        }
      });
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final pickedFile = await _picker.pickImage(
        source: source,
        maxWidth: 1200,
        imageQuality: 85,
      );
      if (pickedFile != null) {
        setState(() {
          _selectedImage = File(pickedFile.path);
          _photoVerification = null; // Reset verification when new image is picked
        });
        
        // Auto-verify photo if category is selected
        if (_selectedCategory != null) {
          _verifyPhoto();
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error picking image: $e')),
      );
    }
  }

  Future<void> _verifyPhoto() async {
    if (_selectedImage == null || _selectedCategory == null) return;

    setState(() => _isVerifyingPhoto = true);

    try {
      final result = await _geminiService.verifyPhoto(
        image: _selectedImage!,
        category: _selectedCategory!.toString().split('.').last,
        title: _titleController.text.isEmpty ? 'Untitled' : _titleController.text,
      );

      setState(() {
        _photoVerification = result;
        _isVerifyingPhoto = false;
      });

      // Show message if photo doesn't match
      if (!result.matches) {
        if (result.suggestion?.toLowerCase().contains('spam') == true) {
          _showSpamErrorDialog(result);
          setState(() {
            _selectedImage = null; // Clear spam image
            _photoVerification = null;
          });
        } else if (result.confidence > 0.6) {
          _showPhotoMismatchDialog(result);
        }
      }
    } catch (e) {
      setState(() => _isVerifyingPhoto = false);
      print('Photo verification error: $e');
    }
  }

  void _showSpamErrorDialog(PhotoVerificationResult result) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.error_outline, color: Colors.red),
            const SizedBox(width: 12),
            const Text('Invalid Image Detected'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(result.message),
            const SizedBox(height: 12),
            Text(
              'Reason: ${result.detectedIssue}',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
            const Text(
              'Please upload a photo of a civic issue (e.g., pothole, garbage, streetlight).',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Okay'),
          ),
        ],
      ),
    );
  }

  void _showPhotoMismatchDialog(PhotoVerificationResult result) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.warning_amber, color: Colors.orange[700]),
            const SizedBox(width: 12),
            const Text('Photo Mismatch'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(result.message),
            const SizedBox(height: 12),
            Text(
              'Detected: ${result.detectedIssue}',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
            if (result.suggestion != null) ...[
              const SizedBox(height: 8),
              Text(
                'Suggestion: ${result.suggestion}',
                style: TextStyle(color: Colors.grey[700]),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Keep Current Category'),
          ),
          if (result.suggestion != null && result.suggestion != 'other')
            ElevatedButton(
              onPressed: () {
                // Update category based on AI suggestion
                Navigator.pop(context);
                // Find matching category (simplified)
                setState(() {
                  // This would need better mapping logic
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryOrange,
              ),
              child: const Text('Update Category'),
            ),
        ],
      ),
    );
  }

  Future<void> _analyzeSeverity() async {
    if (_titleController.text.isEmpty || _descriptionController.text.isEmpty) {
      return;
    }

    setState(() => _isAnalyzingSeverity = true);

    try {
      final result = await _geminiService.analyzeSeverity(
        category: _selectedCategory!.toString().split('.').last,
        title: _titleController.text,
        description: _descriptionController.text,
        image: _selectedImage,
      );

      setState(() {
        _severityResult = result;
        _isAnalyzingSeverity = false;
      });
    } catch (e) {
      setState(() => _isAnalyzingSeverity = false);
      print('Severity analysis error: $e');
    }
  }

  void _showImageSourcePicker() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt, color: AppTheme.primaryOrange),
              title: const Text('Take Photo'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library, color: AppTheme.primaryOrange),
              title: const Text('Choose from Gallery'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Future<void> _submitComplaint() async {
    if (!_formKey.currentState!.validate() || _selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all required fields')),
      );
      return;
    }

    if (_selectedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add a photo of the issue')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    // Analyze severity before submitting if not already done
    if (_severityResult == null && _selectedCategory != null) {
      await _analyzeSeverity();
    }

    final complaint = Complaint(
      id: _uuid.v4(),
      userId: '1',
      title: _titleController.text,
      description: _descriptionController.text,
      category: _selectedCategory!,
      priority: ComplaintPriority.medium,
      status: ComplaintStatus.submitted,
      imageUrls: [_selectedImage!.path],
      latitude: 12.9716,
      longitude: 77.5946,
      address: 'Auto-detected location',
      createdAt: DateTime.now(),
      statusHistory: [
        StatusUpdate(
          status: ComplaintStatus.submitted,
          timestamp: DateTime.now(),
          note: 'Complaint submitted',
        ),
      ],
      upvotes: 0,
      aiSeverity: _severityResult?.severity,
      aiSeverityReason: _severityResult?.reason,
      photoVerified: _photoVerification?.matches ?? true,
    );

    final provider = Provider.of<ComplaintProvider>(context, listen: false);
    final success = await provider.submitComplaint(complaint);

    setState(() => _isSubmitting = false);

    if (success && mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.lightOrange,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_circle,
                  color: AppTheme.primaryOrange,
                  size: 60,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Complaint Submitted!',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Your complaint has been received and will be processed shortly.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  context.go('/citizen-home');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryOrange,
                  minimumSize: const Size(double.infinity, 48),
                ),
                child: const Text('Back to Home'),
              ),
            ],
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Report Issue'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Info Card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.lightOrange,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline, color: AppTheme.darkOrange),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Report civic issues in 2 simple steps!',
                        style: TextStyle(
                          color: AppTheme.darkOrange,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              // Photo Upload
              GestureDetector(
                onTap: _showImageSourcePicker,
                child: Container(
                  height: 200,
                  decoration: BoxDecoration(
                    color: AppTheme.backgroundLight,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppTheme.dividerColor, width: 2),
                  ),
                  child: _selectedImage != null
                      ? Stack(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Image.file(
                                _selectedImage!,
                                width: double.infinity,
                                height: double.infinity,
                                fit: BoxFit.cover,
                              ),
                            ),
                            Positioned(
                              top: 8,
                              right: 8,
                              child: CircleAvatar(
                                backgroundColor: Colors.black54,
                                child: IconButton(
                                  icon: const Icon(Icons.close, color: Colors.white, size: 20),
                                  onPressed: () => setState(() => _selectedImage = null),
                                ),
                              ),
                            ),
                          ],
                        )
                      : Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.add_a_photo,
                              size: 48,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'Add Photo',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey[600],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Tap to take or choose photo',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[500],
                              ),
                            ),
                          ],
                        ),
                ),
              ),
              const SizedBox(height: 24),
              // Category Selection
              const Text(
                'Category',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: ComplaintCategory.values.map((category) {
                  final isSelected = _selectedCategory == category;
                  return ChoiceChip(
                    label: Text(_getCategoryName(category)),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() => _selectedCategory = category);
                      // Auto-verify photo when category changes
                      if (_selectedImage != null) {
                        _verifyPhoto();
                      }
                    },
                    selectedColor: AppTheme.lightOrange,
                    backgroundColor: AppTheme.backgroundLight,
                    labelStyle: TextStyle(
                      color: isSelected ? AppTheme.darkOrange : AppTheme.textSecondary,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                    ),
                  );
                }).toList(),
              ),
              
              // Photo verification status
              if (_isVerifyingPhoto)
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Row(
                    children: [
                      const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'AI verifying photo...',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              
              if (_photoVerification != null && !_isVerifyingPhoto)
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: _photoVerification!.matches
                          ? Colors.green[50]
                          : Colors.orange[50],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: _photoVerification!.matches
                            ? Colors.green
                            : Colors.orange,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          _photoVerification!.matches
                              ? Icons.check_circle
                              : Icons.warning_amber,
                          color: _photoVerification!.matches
                              ? Colors.green
                              : Colors.orange[700],
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _photoVerification!.matches
                                ? '✓ Photo verified - Matches category'
                                : 'Photo may not match selected category',
                            style: TextStyle(
                              fontSize: 12,
                              color: _photoVerification!.matches
                                  ? Colors.green[800]
                                  : Colors.orange[800],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              
              const SizedBox(height: 24),
              // Title
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Title',
                  hintText: 'Brief description of the issue',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a title';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              // Description
              TextFormField(
                controller: _descriptionController,
                maxLines: 4,
                decoration: const InputDecoration(
                  labelText: 'Description (Optional)',
                  hintText: 'Add more details about the issue',
                  alignLabelWithHint: true,
                ),
              ),
              const SizedBox(height: 32),
              // Submit Button
              ElevatedButton(
                onPressed: _isSubmitting ? null : _submitComplaint,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryOrange,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  minimumSize: const Size(double.infinity, 56),
                ),
                child: _isSubmitting
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Text(
                        'Submit Complaint',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getCategoryName(ComplaintCategory category) {
    switch (category) {
      case ComplaintCategory.streetlight:
        return 'Street Light';
      case ComplaintCategory.roadDamage:
        return 'Road Damage';
      case ComplaintCategory.drainage:
        return 'Drainage';
      case ComplaintCategory.garbageCollection:
        return 'Garbage';
      case ComplaintCategory.waterSupply:
        return 'Water Supply';
      case ComplaintCategory.trafficSignal:
        return 'Traffic Signal';
      case ComplaintCategory.illegalParking:
        return 'Illegal Parking';
      case ComplaintCategory.publicProperty:
        return 'Public Property';
      case ComplaintCategory.other:
        return 'Other';
    }
  }
}
