import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:bloodlink_mobile/core/theme/app_colors.dart';
import 'package:bloodlink_mobile/core/theme/app_text_styles.dart';
import 'package:bloodlink_mobile/core/widgets/blood_type_selector.dart';
import 'package:bloodlink_mobile/core/widgets/custom_button.dart';
import 'request_provider.dart';

class NewRequestScreen extends ConsumerStatefulWidget {
  const NewRequestScreen({super.key});

  @override
  ConsumerState<NewRequestScreen> createState() => _NewRequestScreenState();
}

class _NewRequestScreenState extends ConsumerState<NewRequestScreen> {
  final _formKey = GlobalKey<FormState>();

  final _patientNameController = TextEditingController();
  final _hospitalController = TextEditingController();
  final _wardController = TextEditingController();
  final _contactPhoneController = TextEditingController();
  final _notesController = TextEditingController();

  String _selectedBloodType = 'O+';
  String _selectedUrgency = 'CRITICAL';
  String _selectedRelationship = 'Family';
  int _unitsNeeded = 2;

  double _latitude = 6.9271;
  double _longitude = 79.8612;
  bool _isLocating = false;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _patientNameController.dispose();
    _hospitalController.dispose();
    _wardController.dispose();
    _contactPhoneController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _detectLocation() {
    setState(() => _isLocating = true);
    Future.delayed(const Duration(milliseconds: 600), () {
      if (mounted) {
        setState(() {
          _latitude = 6.9271; // Colombo National Hospital NHSL GPS
          _longitude = 79.8612;
          _hospitalController.text = 'National Hospital of Sri Lanka (NHSL), Colombo';
          _isLocating = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Hospital GPS pinned: National Hospital Colombo (6.9271, 79.8612)'),
            backgroundColor: AppColors.primaryNavy,
          ),
        );
      }
    });
  }

  Future<void> _submitRequest() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);
    try {
      final repo = ref.read(requestRepositoryProvider);
      final created = await repo.createRequest(
        patientName: _patientNameController.text.trim(),
        relationship: _selectedRelationship,
        bloodType: _selectedBloodType,
        unitsNeeded: _unitsNeeded,
        urgency: _selectedUrgency,
        hospitalName: _hospitalController.text.trim(),
        wardNumber: _wardController.text.trim().isNotEmpty ? _wardController.text.trim() : null,
        notes: _notesController.text.trim().isNotEmpty ? _notesController.text.trim() : null,
        latitude: _latitude,
        longitude: _longitude,
        contactPhone: _contactPhoneController.text.trim(),
      );

      ref.invalidate(myRequestsProvider);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Blood request dispatched to AI Neural Engine!'),
            backgroundColor: AppColors.successGreen,
          ),
        );
        context.pushReplacement('/matches/${created.id}');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Submission failed: ${e.toString()}'),
            backgroundColor: AppColors.accentCrimson,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: const Text('Create Emergency Request'),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Clinical Urgency Selector Card
              _buildUrgencySelector(),
              const SizedBox(height: 24),

              // Step 1: Patient Information
              _buildSectionHeader('1. Patient Information'),
              TextFormField(
                controller: _patientNameController,
                decoration: const InputDecoration(
                  labelText: 'Patient Full Name *',
                  hintText: 'Enter patient full legal name',
                  prefixIcon: Icon(Icons.person_outline),
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'Patient name is required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      initialValue: _selectedRelationship,
                      decoration: const InputDecoration(
                        labelText: 'Relationship to Patient',
                        prefixIcon: Icon(Icons.family_restroom),
                      ),
                      items: ['Self', 'Family', 'Doctor', 'Nurse', 'Friend', 'Other']
                          .map((r) => DropdownMenuItem(value: r, child: Text(r)))
                          .toList(),
                      onChanged: (val) {
                        if (val != null) setState(() => _selectedRelationship = val);
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _contactPhoneController,
                      keyboardType: TextInputType.phone,
                      decoration: const InputDecoration(
                        labelText: 'Emergency Phone *',
                        hintText: '+94 7X XXX XXXX',
                        prefixIcon: Icon(Icons.phone),
                      ),
                      validator: (val) {
                        if (val == null || val.trim().isEmpty) {
                          return 'Phone is required';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Step 2: Blood Type & Required Units
              _buildSectionHeader('2. Blood Group & Quantity Required'),
              BloodTypeSelector(
                selectedType: _selectedBloodType,
                onSelected: (val) => setState(() => _selectedBloodType = val),
              ),
              const SizedBox(height: 16),
              _buildUnitsStepper(),
              const SizedBox(height: 24),

              // Step 3: Hospital & Destination Location
              _buildSectionHeader('3. Hospital & Clinical Location'),
              TextFormField(
                controller: _hospitalController,
                decoration: InputDecoration(
                  labelText: 'Hospital Name *',
                  hintText: 'e.g. National Hospital of Sri Lanka, Colombo',
                  prefixIcon: const Icon(Icons.local_hospital_outlined),
                  suffixIcon: IconButton(
                    icon: _isLocating
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.my_location, color: AppColors.primaryNavy),
                    onPressed: _detectLocation,
                    tooltip: 'Pin current hospital location',
                  ),
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'Hospital name is required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _wardController,
                decoration: const InputDecoration(
                  labelText: 'Ward / Bed / Room (Optional)',
                  hintText: 'e.g. Ward 12, ICU Bed 4',
                  prefixIcon: Icon(Icons.meeting_room_outlined),
                ),
              ),
              const SizedBox(height: 24),

              // Step 4: Clinical Justification Notes
              _buildSectionHeader('4. Clinical Notes / Justification'),
              TextFormField(
                controller: _notesController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Clinical Reason (Optional)',
                  hintText: 'e.g. Scheduled emergency surgery, acute hemorrhage, dengue platelet drop',
                  prefixIcon: Icon(Icons.notes),
                ),
              ),
              const SizedBox(height: 32),

              // Submit Button
              CustomButton(
                text: 'Dispatch Request to Neural AI Engine',
                icon: Icons.rocket_launch,
                variant: ButtonVariant.primary,
                isLoading: _isSubmitting,
                onPressed: _submitRequest,
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: AppTextStyles.titleMedium.copyWith(
          fontWeight: FontWeight.bold,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }

  Widget _buildUrgencySelector() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.emergency, color: AppColors.accentCrimson, size: 20),
              const SizedBox(width: 8),
              Text(
                'Clinical Urgency Level',
                style: AppTextStyles.titleMedium.copyWith(fontSize: 15, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _buildUrgencyChip('CRITICAL', 'Under 1 Hour', AppColors.accentCrimson),
              const SizedBox(width: 8),
              _buildUrgencyChip('URGENT', 'Under 6 Hours', Colors.orange.shade800),
              const SizedBox(width: 8),
              _buildUrgencyChip('NORMAL', 'Elective / 24h', AppColors.primaryNavy),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildUrgencyChip(String code, String subtitle, Color color) {
    final isSelected = _selectedUrgency == code;
    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _selectedUrgency = code),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
          decoration: BoxDecoration(
            color: isSelected ? color.withValues(alpha: 0.12) : AppColors.surfaceLight,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? color : AppColors.borderLight,
              width: isSelected ? 1.5 : 1,
            ),
          ),
          child: Column(
            children: [
              Text(
                code,
                style: AppTextStyles.caption.copyWith(
                  fontWeight: FontWeight.bold,
                  color: isSelected ? color : AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: AppTextStyles.caption.copyWith(
                  fontSize: 9,
                  color: isSelected ? color : AppColors.textSecondary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUnitsStepper() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Number of Blood Bags (Units)',
                style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold),
              ),
              Text(
                '1 Unit = ~450 mL whole blood',
                style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
              ),
            ],
          ),
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.remove_circle_outline, color: AppColors.primaryNavy),
                onPressed: _unitsNeeded > 1 ? () => setState(() => _unitsNeeded--) : null,
              ),
              Text(
                '$_unitsNeeded',
                style: AppTextStyles.headlineMedium.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryNavy,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.add_circle_outline, color: AppColors.primaryNavy),
                onPressed: _unitsNeeded < 10 ? () => setState(() => _unitsNeeded++) : null,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
