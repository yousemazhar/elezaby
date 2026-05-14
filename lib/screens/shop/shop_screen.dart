import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/product_provider.dart';
import '../../widgets/global_app_bar.dart';

class ShopScreen extends StatefulWidget {
  const ShopScreen({super.key});

  @override
  State<ShopScreen> createState() => _ShopScreenState();
}

class _ShopScreenState extends State<ShopScreen> {
  String? _activeCatId;

  static const _categories = [
    _Cat('cardiovascular', '❤️', 'Cardiovascular'),
    _Cat('psychiatric_neuro', '🧠', 'Psychiatric'),
    _Cat('respiratory_allergy', '🌬️', 'Respiratory'),
    _Cat('diabetes_metabolism', '💉', 'Diabetes'),
    _Cat('pain_inflammation', '💊', 'Pain & Inflammation'),
    _Cat('antibiotics', '🦠', 'Antibiotics'),
    _Cat('gastrointestinal', '🫃', 'Gastro'),
    _Cat('vitamins_supplements', '🌟', 'Vitamins'),
    _Cat('dermatology', '🧴', 'Dermatology'),
    _Cat('oncology', '🎗️', 'Oncology'),
    _Cat('other', '🏥', 'Other'),
  ];

  @override
  void initState() {
    super.initState();
    _activeCatId = _categories.first.id;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProductProvider>().loadProducts();
    });
  }

  @override
  Widget build(BuildContext context) {
    final active = _categories.firstWhere((c) => c.id == _activeCatId);

    return Scaffold(
      appBar: const GlobalAppBar(title: 'Shop', showBackButton: true),
      body: Column(
        children: [
          Expanded(
            child: Row(
              children: [
                // Sidebar
                Container(
                  width: 110,
                  color: AppColors.surface,
                  child: ListView.builder(
                    itemCount: _categories.length,
                    itemBuilder: (_, i) {
                      final cat = _categories[i];
                      final isActive = cat.id == _activeCatId;
                      return GestureDetector(
                        onTap: () => setState(() => _activeCatId = cat.id),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              vertical: 18, horizontal: 10),
                          decoration: BoxDecoration(
                            color: isActive
                                ? AppColors.primary
                                : Colors.transparent,
                            borderRadius: isActive
                                ? const BorderRadius.horizontal(
                                    right: Radius.circular(8))
                                : null,
                          ),
                          child: Column(
                            children: [
                              Text(cat.emoji,
                                  style: const TextStyle(fontSize: 22)),
                              const SizedBox(height: 4),
                              Text(
                                cat.name,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500,
                                  color: isActive
                                      ? Colors.white
                                      : AppColors.textMuted,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                // Content
                Expanded(
                  child: _CategoryContent(
                    category: active,
                    onNavigate: (catId) =>
                        context.push('/products', extra: {'categoryId': catId}),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Cat {
  final String id, emoji, name;
  const _Cat(this.id, this.emoji, this.name);
}

class _CategoryContent extends StatelessWidget {
  final _Cat category;
  final ValueChanged<String> onNavigate;

  const _CategoryContent(
      {required this.category, required this.onNavigate});

  static const _subMap = {
    'cardiovascular': [
      _Sub('Antihypertensives', '🩺'),
      _Sub('Anticoagulants', '🩸'),
      _Sub('Statins', '📊'),
      _Sub('Diuretics', '💧'),
      _Sub('Beta Blockers', '❤️‍🩹'),
      _Sub('Antianginals', '💓'),
    ],
    'psychiatric_neuro': [
      _Sub('Antipsychotics', '🧠'),
      _Sub('Antidepressants', '💙'),
      _Sub('Anti-epileptics', '⚡'),
      _Sub('Anxiolytics', '😴'),
      _Sub('ADHD', '🎯'),
      _Sub('Neurology', '🔬'),
    ],
    'respiratory_allergy': [
      _Sub('Antihistamines', '🌸'),
      _Sub('Bronchodilators', '🫁'),
      _Sub('Nasal Sprays', '💨'),
      _Sub('Cold & Flu', '🤧'),
      _Sub('Allergy', '🌿'),
    ],
    'diabetes_metabolism': [
      _Sub('SGLT2 Inhibitors', '💉'),
      _Sub('Glinides', '🔬'),
      _Sub('Dopamine', '🧬'),
      _Sub('Antidiabetics', '🩺'),
    ],
    'pain_inflammation': [
      _Sub('Pain Relief', '💊'),
      _Sub('NSAIDs', '🌡️'),
      _Sub('Muscle Relaxants', '💪'),
      _Sub('Local Anaesthetics', '🩺'),
      _Sub('Anti-Rheumatic', '🦴'),
      _Sub('Massage', '🤲'),
    ],
    'antibiotics': [
      _Sub('Antibiotics', '🦠'),
      _Sub('Antifungals', '🍄'),
      _Sub('Topical Anti-inf.', '🧴'),
    ],
    'gastrointestinal': [
      _Sub('Acid Relief', '🫀'),
      _Sub('Antiemetics', '🤢'),
      _Sub('Haemorrhoids', '💊'),
      _Sub('Bladder Care', '💧'),
      _Sub('Renal Stones', '🪨'),
    ],
    'vitamins_supplements': [
      _Sub('Vitamins', '🌟'),
      _Sub('Minerals', '💊'),
      _Sub('Immunity', '🛡️'),
      _Sub('Multivitamins', '🌈'),
    ],
    'dermatology': [
      _Sub('Hair Care', '💇'),
      _Sub('Skin Care', '🧴'),
      _Sub('Shampoos', '🚿'),
    ],
    'oncology': [
      _Sub('Cancer Care', '🎗️'),
      _Sub('Anti-Estrogen', '🔬'),
      _Sub('Aromatase Inh.', '💉'),
    ],
    'other': [
      _Sub('General', '🏥'),
    ],
  };

  @override
  Widget build(BuildContext context) {
    final subs = _subMap[category.id] ?? [];
    return ListView(
      padding: const EdgeInsets.fromLTRB(14, 16, 14, 100),
      children: [
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border),
            boxShadow: const [
              BoxShadow(
                  color: Color(0x140087C8),
                  blurRadius: 10,
                  offset: Offset(0, 2)),
            ],
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: AppColors.primaryLight,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(
                        child: Text(category.emoji,
                            style: const TextStyle(fontSize: 18))),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      category.name,
                      style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textDark),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: subs.length,
                gridDelegate:
                    const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  mainAxisExtent: 100,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                ),
                itemBuilder: (_, i) {
                  final sub = subs[i];
                  return GestureDetector(
                    onTap: () => onNavigate(category.id),
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 54,
                            height: 54,
                            decoration: BoxDecoration(
                              color: AppColors.surface,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: AppColors.border),
                            ),
                            child: Center(
                                child: Text(sub.emoji,
                                    style: const TextStyle(fontSize: 24))),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            sub.name,
                            style: const TextStyle(
                                fontSize: 11, color: AppColors.textDark),
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 14),
              GestureDetector(
                onTap: () => onNavigate(category.id),
                child: const Center(
                  child: Text(
                    'SEE ALL PRODUCTS',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: AppColors.primary,
                      letterSpacing: 0.8,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _Sub {
  final String name, emoji;
  const _Sub(this.name, this.emoji);
}
