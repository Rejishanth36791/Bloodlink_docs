import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:bloodlink_mobile/core/theme/app_colors.dart';
import 'package:bloodlink_mobile/core/theme/app_text_styles.dart';
import 'package:bloodlink_mobile/core/widgets/blood_type_selector.dart';
import 'package:bloodlink_mobile/core/widgets/custom_button.dart';
import 'bank_provider.dart';

class InventoryManagementScreen extends ConsumerStatefulWidget {
  const InventoryManagementScreen({super.key});

  @override
  ConsumerState<InventoryManagementScreen> createState() => _InventoryManagementScreenState();
}

class _InventoryManagementScreenState extends ConsumerState<InventoryManagementScreen> {
  final _formKey = GlobalKey<FormState>();

  String _selectedBloodType = 'O+';
  String _selectedComponent = 'WHOLE_BLOOD';
  bool _isAddition = true;
  int _quantity = 1;
  final _batchController = TextEditingController();
  String _selectedReason = 'ROUTINE_DONATION';
  bool _isSaving = false;

  final Map<String, String> _components = {
    'WHOLE_BLOOD': 'Whole Blood (450 mL)',
    'PRBC': 'Packed Red Blood Cells (PRBC)',
    'PLATELETS': 'Platelet Concentrate (RDP)',
    'FFP': 'Fresh Frozen Plasma (FFP)',
    'CRYOPRECIPITATE': 'Cryoprecipitate',
  };

  final Map<String, String> _reasons = {
    'ROUTINE_DONATION': 'Voluntary Donor Intake',
    'EMERGENCY_DISPATCH': 'Hospital Emergency Issue',
    'TRANSFER_IN': 'Inter-Hospital Station Transfer In',
    'TRANSFER_OUT': 'Inter-Hospital Station Transfer Out',
    'EXPIRED_DISPOSAL': 'Expiry / Cold-Chain Breach Disposal',
    'QA_QUARANTINE': 'Quality Assurance Quarantine',
  };

  @override
  void dispose() {
    _batchController.dispose();
    super.dispose();
  }

  Future<void> _submitAdjustment() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);
    try {
      final change = _isAddition ? _quantity : -_quantity;
      final repo = ref.read(bankRepositoryProvider);

      await repo.adjustInventory(
        bloodType: _selectedBloodType,
        componentType: _selectedComponent,
        quantityChange: change,
        reason: _selectedReason,
        batchNumber: _batchController.text.trim().isNotEmpty
            ? _batchController.text.trim()
            : null,
      );

      ref.invalidate(bankDashboardProvider);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Ledger updated successfully: ${change > 0 ? '+$change' : change} units of $_selectedBloodType',
            ),
            backgroundColor: AppColors.successGreen,
          ),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Adjustment failed: ${e.toString()}'),
            backgroundColor: AppColors.accentCrimson,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: const Text('Adjust Blood Ledger'),
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
              // Direction Toggle: Add or Deduct
              _buildDirectionToggle(),
              const SizedBox(height: 24),

              // Blood Type Selector
              _buildSectionHeader('1. Select Blood Group'),
              BloodTypeSelector(
                selectedType: _selectedBloodType,
                onSelected: (val) => setState(() => _selectedBloodType = val),
              ),
              const SizedBox(height: 24),

              // Component Type
              _buildSectionHeader('2. Blood Component Type'),
              DropdownButtonFormField<String>(
                initialValue: _selectedComponent,
                decoration: const InputDecoration(
                  labelText: 'Component Category',
                  prefixIcon: Icon(Icons.category_outlined),
                ),
                items: _components.entries
                    .map((e) => DropdownMenuItem(value: e.key, child: Text(e.value)))
                    .toList(),
                onChanged: (val) {
                  if (val != null) setState(() => _selectedComponent = val);
                },
              ),
              const SizedBox(height: 24),

              // Quantity Stepper
              _buildSectionHeader('3. Quantity (Units)'),
              _buildQuantitySelector(),
              const SizedBox(height: 24),

              // Clinical Reason
              _buildSectionHeader('4. Clinical Justification / Reason'),
              DropdownButtonFormField<String>(
                initialValue: _selectedReason,
                decoration: const InputDecoration(
                  labelText: 'Transaction Reason',
                  prefixIcon: Icon(Icons.assignment_outlined),
                ),
                items: _reasons.entries
                    .map((e) => DropdownMenuItem(value: e.key, child: Text(e.value)))
                    .toList(),
                onChanged: (val) {
                  if (val != null) setState(() => _selectedReason = val);
                },
              ),
              const SizedBox(height: 14),

              // Batch Barcode
              TextFormField(
                controller: _batchController,
                decoration: const InputDecoration(
                  labelText: 'Blood Bag Batch Number (Optional)',
                  hintText: 'e.g. LK-NBTS-2026-B812',
                  prefixIcon: Icon(Icons.qr_code),
                ),
              ),
              const SizedBox(height: 32),

              // Submit Button
              CustomButton(
                text: _isAddition ? 'Add Units to Ledger' : 'Deduct Units from Ledger',
                icon: _isAddition ? Icons.add_circle : Icons.remove_circle,
                variant: _isAddition ? ButtonVariant.success : ButtonVariant.dangerOutline,
                isLoading: _isSaving,
                onPressed: _submitAdjustment,
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
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(
        title,
        style: AppTextStyles.titleMedium.copyWith(
          fontWeight: FontWeight.bold,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }

  Widget _buildDirectionToggle() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Row(
        children: [
          Expanded(
            child: InkWell(
              onTap: () => setState(() => _isAddition = true),
              borderRadius: BorderRadius.circular(10),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: _isAddition ? AppColors.successGreen : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.add_circle_outline,
                      color: _isAddition ? Colors.white : AppColors.textSecondary,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Receive Stock (+)',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: _isAddition ? Colors.white : AppColors.textSecondary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: InkWell(
              onTap: () => setState(() => _isAddition = false),
              borderRadius: BorderRadius.circular(10),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: !_isAddition ? AppColors.accentCrimson : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.remove_circle_outline,
                      color: !_isAddition ? Colors.white : AppColors.textSecondary,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Issue / Deduct (-)',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: !_isAddition ? Colors.white : AppColors.textSecondary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuantitySelector() {
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
          Text(
            'Quantity Units to ${_isAddition ? 'Add' : 'Deduct'}',
            style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold),
          ),
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.remove_circle_outline, color: AppColors.primaryNavy),
                onPressed: _quantity > 1 ? () => setState(() => _quantity--) : null,
              ),
              Text(
                '$_quantity',
                style: AppTextStyles.headlineMedium.copyWith(
                  fontWeight: FontWeight.bold,
                  color: _isAddition ? AppColors.successGreen : AppColors.accentCrimson,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.add_circle_outline, color: AppColors.primaryNavy),
                onPressed: _quantity < 50 ? () => setState(() => _quantity++) : null,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
