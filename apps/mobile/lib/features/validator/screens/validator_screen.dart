import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/mbg_theme.dart';
import '../../../shared/api/api_client.dart';
import '../../../shared/constants.dart';
import '../../../shared/models/nutrition_result.dart';
import '../../../shared/widgets/widgets.dart';

class ValidatorScreen extends ConsumerStatefulWidget {
  const ValidatorScreen({super.key});

  @override
  ConsumerState<ValidatorScreen> createState() => _ValidatorScreenState();
}

class _ValidatorScreenState extends ConsumerState<ValidatorScreen> {
  final _menuCtrl = TextEditingController();
  String _recipientGroup = 'sd';
  ValidationResult? _result;
  bool _loading = false;

  @override
  void dispose() {
    _menuCtrl.dispose();
    super.dispose();
  }

  Future<void> _validate() async {
    if (_menuCtrl.text.trim().isEmpty) return;
    setState(() => _loading = true);
    try {
      final api = ref.read(apiClientProvider);
      final data = await api.validateMenu(
        menu: _menuCtrl.text.trim(),
        recipientGroup: _recipientGroup,
      );
      setState(() => _result = ValidationResult.fromJson(data));
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gagal memvalidasi menu. Coba lagi.')),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: MBGColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.restaurant_menu_rounded,
                  color: MBGColors.primary,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Validator Menu Gizi',
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(fontWeight: FontWeight.w700),
                    ),
                    Text(
                      'Analisis nilai gizi berdasarkan standar MBG',
                      style: TextStyle(
                          fontSize: 12, color: MBGColors.neutral500),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Text(
            'Kelompok Penerima Manfaat',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 10),
          SegmentedButton<String>(
            segments: AppConstants.recipientGroups.map(
              (g) => ButtonSegment(
                value: g.value,
                label: Text(g.label, style: const TextStyle(fontSize: 11)),
                icon: Icon(g.icon, size: 18),
              ),
            ).toList(),
            selected: {_recipientGroup},
            onSelectionChanged: (v) =>
                setState(() => _recipientGroup = v.first),
            showSelectedIcon: false,
          ),
          const SizedBox(height: 20),
          Text(
            'Rencana Menu',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _menuCtrl,
            maxLines: 5,
            decoration: InputDecoration(
              hintText:
                  'Contoh: nasi putih 200g, ayam goreng 75g, tempe orek 50g, sayur bayam 100g, pisang 1 buah...',
              hintMaxLines: 3,
              hintStyle: TextStyle(
                fontSize: 13,
                color: MBGColors.neutral500.withValues(alpha: 0.7),
              ),
            ),
          ),
          const SizedBox(height: 20),
          MbgButton(
            label: _loading ? 'Menganalisis...' : 'Validasi Menu',
            isLoading: _loading,
            onPressed: _validate,
            icon: Icons.health_and_safety_rounded,
          ),
          if (_result != null) ...[
            const SizedBox(height: 24),
            _ResultSection(result: _result!),
          ],
        ],
      ),
    );
  }
}

class _ResultSection extends StatelessWidget {
  final ValidationResult result;
  const _ResultSection({required this.result});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    Color statusColor;
    IconData statusIcon;
    String statusLabel;
    switch (result.status) {
      case 'memenuhi':
        statusColor = MBGColors.success;
        statusIcon = Icons.check_circle_rounded;
        statusLabel = 'Memenuhi Standar';
      case 'kurang':
        statusColor = MBGColors.warning;
        statusIcon = Icons.warning_amber_rounded;
        statusLabel = 'Kurang';
      default:
        statusColor = MBGColors.error;
        statusIcon = Icons.cancel_rounded;
        statusLabel = 'Tidak Memenuhi';
    }

    return Column(
      children: [
        Card(
          color: statusColor.withValues(alpha: isDark ? 0.12 : 0.06),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(statusIcon, color: statusColor, size: 28),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        statusLabel,
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          color: statusColor,
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        result.regulation,
                        style: TextStyle(
                            fontSize: 11, color: MBGColors.neutral500),
                      ),
                    ],
                  ),
                ),
                Column(
                  children: [
                    Text(
                      '${result.score}',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        color: statusColor,
                      ),
                    ),
                    Text(
                      '/100',
                      style: TextStyle(
                          fontSize: 11, color: MBGColors.neutral500),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 14),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Rincian Nilai Gizi',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                ),
                const SizedBox(height: 14),
                ...result.nutrients.map((n) => _NutrientBar(nutrient: n)),
              ],
            ),
          ),
        ),
        if (result.suggestions.isNotEmpty) ...[
          const SizedBox(height: 14),
          Card(
            color: isDark
                ? const Color(0xFF2D2510)
                : const Color(0xFFFFFBEB),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(
                color: MBGColors.warning.withValues(alpha: 0.2),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.lightbulb_outline,
                          size: 16, color: MBGColors.warning),
                      const SizedBox(width: 6),
                      const Text(
                        'Rekomendasi',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                          color: MBGColors.warning,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ...result.suggestions.map(
                    (s) => Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            margin:
                                const EdgeInsets.only(top: 6, right: 8),
                            decoration: const BoxDecoration(
                              color: MBGColors.warning,
                              shape: BoxShape.circle,
                            ),
                          ),
                          Expanded(
                            child: Text(
                              s,
                              style: TextStyle(
                                fontSize: 13,
                                height: 1.4,
                                color: isDark
                                    ? Colors.white70
                                    : MBGColors.neutral800,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
        const SizedBox(height: 14),
        MbgButton(
          label: 'Reset',
          isOutlined: true,
          icon: Icons.refresh_rounded,
          onPressed: () {},
        ),
      ],
    );
  }
}

class _NutrientBar extends StatelessWidget {
  final NutrientResult nutrient;
  const _NutrientBar({required this.nutrient});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final pct = nutrient.percentage.clamp(0, 150).toDouble();

    Color barColor;
    switch (nutrient.status) {
      case 'memenuhi':
        barColor = MBGColors.success;
      case 'kurang':
        barColor = MBGColors.warning;
      default:
        barColor = MBGColors.error;
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                nutrient.name,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: isDark ? Colors.white : MBGColors.onSurface,
                ),
              ),
              Text(
                '${nutrient.value.toStringAsFixed(1)} / ${nutrient.standard.toStringAsFixed(0)} ${nutrient.unit}  ${nutrient.percentage.toStringAsFixed(0)}%',
                style: TextStyle(
                  fontSize: 11,
                  color: barColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: pct / 150,
              minHeight: 6,
              backgroundColor:
                  isDark ? Colors.white12 : MBGColors.neutral200.withValues(alpha: 0.5),
              valueColor: AlwaysStoppedAnimation<Color>(barColor),
            ),
          ),
        ],
      ),
    );
  }
}
