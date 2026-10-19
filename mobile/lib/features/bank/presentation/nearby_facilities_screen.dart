import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:bloodlink_mobile/core/theme/app_colors.dart';
import 'package:bloodlink_mobile/core/theme/app_text_styles.dart';
import 'package:bloodlink_mobile/core/widgets/custom_button.dart';

class BloodFacility {
  final String id;
  final String name;
  final String category;
  final String address;
  final String district;
  final String phone;
  final String hours;
  final double distanceKm;
  final bool isOpen247;

  const BloodFacility({
    required this.id,
    required this.name,
    required this.category,
    required this.address,
    required this.district,
    required this.phone,
    required this.hours,
    required this.distanceKm,
    this.isOpen247 = false,
  });
}

final nearbyFacilitiesProvider = Provider<List<BloodFacility>>((ref) {
  return const [
    BloodFacility(
      id: 'NBTS-NBC',
      name: 'National Blood Center (NBC)',
      category: 'National Apex Transfusion Center',
      address: '555/5 Elvitigala Mawatha, Colombo 05',
      district: 'Colombo',
      phone: '011 269 1111',
      hours: 'Open 24/7 (Emergency & Voluntary)',
      distanceKm: 1.8,
      isOpen247: true,
    ),
    BloodFacility(
      id: 'NBTS-NHSL',
      name: 'National Hospital of Sri Lanka (NHSL)',
      category: 'Tertiary Trauma Blood Bank',
      address: 'Regent Street, Colombo 10',
      district: 'Colombo',
      phone: '011 269 1111',
      hours: 'Open 24/7',
      distanceKm: 3.4,
      isOpen247: true,
    ),
    BloodFacility(
      id: 'NBTS-CSTH',
      name: 'Colombo South Teaching Hospital (Kalubowila)',
      category: 'Cluster Transfusion Center',
      address: 'Hospital Road, Kalubowila',
      district: 'Colombo',
      phone: '011 276 3064',
      hours: '08:00 AM - 06:00 PM',
      distanceKm: 5.2,
      isOpen247: false,
    ),
    BloodFacility(
      id: 'NBTS-CNTH',
      name: 'Colombo North Teaching Hospital (Ragama)',
      category: 'Gampaha District Apex Bank',
      address: 'Ragama Rd, Ragama',
      district: 'Gampaha',
      phone: '011 295 9261',
      hours: 'Open 24/7',
      distanceKm: 14.6,
      isOpen247: true,
    ),
    BloodFacility(
      id: 'NBTS-KANDY',
      name: 'National Hospital Kandy (General Hospital)',
      category: 'Central Province Regional Hub',
      address: 'William Gopallawa Mawatha, Kandy',
      district: 'Kandy',
      phone: '081 222 2261',
      hours: 'Open 24/7',
      distanceKm: 114.0,
      isOpen247: true,
    ),
    BloodFacility(
      id: 'NBTS-GALLE',
      name: 'Teaching Hospital Karapitiya',
      category: 'Southern Province Regional Hub',
      address: 'Labuduwa Road, Galle',
      district: 'Galle',
      phone: '091 223 2250',
      hours: 'Open 24/7',
      distanceKm: 118.5,
      isOpen247: true,
    ),
  ];
});

class NearbyFacilitiesScreen extends ConsumerStatefulWidget {
  const NearbyFacilitiesScreen({super.key});

  @override
  ConsumerState<NearbyFacilitiesScreen> createState() => _NearbyFacilitiesScreenState();
}

class _NearbyFacilitiesScreenState extends ConsumerState<NearbyFacilitiesScreen> {
  String _searchQuery = '';
  String _selectedDistrict = 'ALL';

  @override
  Widget build(BuildContext context) {
    final facilities = ref.watch(nearbyFacilitiesProvider);

    final filtered = facilities.where((f) {
      if (_selectedDistrict != 'ALL' && f.district != _selectedDistrict) {
        return false;
      }
      if (_searchQuery.isNotEmpty) {
        final q = _searchQuery.toLowerCase();
        return f.name.toLowerCase().contains(q) ||
            f.address.toLowerCase().contains(q) ||
            f.district.toLowerCase().contains(q);
      }
      return true;
    }).toList();

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: const Text('Authorized Blood Banks'),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => context.pop(),
        ),
      ),
      body: Column(
        children: [
          // Search & Filter
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
            child: Column(
              children: [
                TextField(
                  decoration: const InputDecoration(
                    hintText: 'Search hospital or blood center...',
                    prefixIcon: Icon(Icons.search),
                    contentPadding: EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                  ),
                  onChanged: (val) => setState(() => _searchQuery = val),
                ),
                const SizedBox(height: 10),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildDistrictChip('All Centers', 'ALL'),
                      _buildDistrictChip('Colombo', 'Colombo'),
                      _buildDistrictChip('Gampaha', 'Gampaha'),
                      _buildDistrictChip('Kandy', 'Kandy'),
                      _buildDistrictChip('Galle', 'Galle'),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Facilities List
          Expanded(
            child: filtered.isEmpty
                ? Center(
                    child: Text(
                      'No facilities match your search criteria.',
                      style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: filtered.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 14),
                    itemBuilder: (context, index) {
                      return _buildFacilityCard(filtered[index]);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildDistrictChip(String label, String value) {
    final isSelected = _selectedDistrict == value;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (_) => setState(() => _selectedDistrict = value),
        selectedColor: AppColors.primaryNavy.withValues(alpha: 0.12),
        checkmarkColor: AppColors.primaryNavy,
        labelStyle: AppTextStyles.caption.copyWith(
          color: isSelected ? AppColors.primaryNavy : AppColors.textSecondary,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: isSelected ? AppColors.primaryNavy : AppColors.borderLight,
          ),
        ),
      ),
    );
  }

  Widget _buildFacilityCard(BloodFacility facility) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.borderLight),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.primaryNavy.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.local_hospital, color: AppColors.primaryNavy, size: 26),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            facility.name,
                            style: AppTextStyles.titleMedium.copyWith(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        if (facility.isOpen247)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.successGreen.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              '24/7 OPEN',
                              style: AppTextStyles.caption.copyWith(
                                color: AppColors.successGreen,
                                fontWeight: FontWeight.bold,
                                fontSize: 9,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      facility.category,
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.secondaryTeal,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      facility.address,
                      style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const Divider(height: 20),
          Row(
            children: [
              const Icon(Icons.access_time, size: 16, color: AppColors.primaryNavy),
              const SizedBox(width: 6),
              Text(
                facility.hours,
                style: AppTextStyles.caption.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const Spacer(),
              const Icon(Icons.near_me, size: 16, color: AppColors.primaryNavy),
              const SizedBox(width: 4),
              Text(
                '${facility.distanceKm} km away',
                style: AppTextStyles.caption.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryNavy,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: CustomButton(
                  text: 'Call Center (${facility.phone})',
                  icon: Icons.phone,
                  variant: ButtonVariant.primary,
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Calling ${facility.name} hotline: ${facility.phone}'),
                        backgroundColor: AppColors.primaryNavy,
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
