import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/mbg_theme.dart';
import '../../../shared/api/api_client.dart';
import '../../../shared/models/compliance_result.dart';
import '../../../shared/widgets/widgets.dart';

class ComplianceScreen extends ConsumerStatefulWidget {
  const ComplianceScreen({super.key});

  @override
  ConsumerState<ComplianceScreen> createState() =>
      _ComplianceScreenState();
}

class _ComplianceScreenState extends ConsumerState<ComplianceScreen> {
  bool _hasNib = false,
      _hasHalalCert = false,
      _hasContract = false;
  bool _bpomCompliant = false, _sameDistrict = false;
  final _capacityCtrl = TextEditingController();
  final _servingsCtrl = TextEditingController();
  ComplianceResult? _result;
  bool _loading = false;

  @override
  void dispose() {
    _capacityCtrl.dispose();
    _servingsCtrl.dispose();
    super.dispose();
  }

  Future<void> _runCheck() async {
    setState(() => _loading = true);
    try {
      final api = ref.read(apiClientProvider);
      final data = await api.complianceCheck(
        checkType: 'sk244_supplier',
        inputs: {
          'has_nib': _hasNib,
          'has_halal_cert': _hasHalalCert,
          'has_contract': _hasContract,
          'bpom_compliant': _bpomCompliant,
          'supplier_same_district': _sameDistrict,
          'daily_capacity': int.tryParse(_capacityCtrl.text) ?? 0,
          'required_servings': int.tryParse(_servingsCtrl.text) ?? 0,
        },
      );
      setState(() => _result = ComplianceResult.fromJson(data));
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gagal menjalankan pemeriksaan.')),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colorScheme = Theme.of(context).colorScheme;

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
                  Icons.verified_user_rounded,
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
                      'Compliance Checker SK 244/2025',
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(fontWeight: FontWeight.w700),
                    ),
                    Text(
                      'Periksa kelengkapan persyaratan supplier MBG',
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
            'Persyaratan Dokumen',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 12),
          _switchTile('Memiliki NIB', _hasNib,
              (v) => setState(() => _hasNib = v), Icons.description_outlined),
          _switchTile('Sertifikat Halal', _hasHalalCert,
              (v) => setState(() => _hasHalalCert = v), Icons.verified_outlined),
          _switchTile('Kontrak dengan SPPG', _hasContract,
              (v) => setState(() => _hasContract = v), Icons.assignment_outlined),
          _switchTile('Kepatuhan BPOM', _bpomCompliant,
              (v) => setState(() => _bpomCompliant = v), Icons.science_outlined),
          _switchTile('Supplier di Kecamatan Sama', _sameDistrict,
              (v) => setState(() => _sameDistrict = v), Icons.location_on_outlined),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _capacityCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Kapasitas Harian',
                    suffixText: 'porsi',
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: _servingsCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Kebutuhan',
                    suffixText: 'porsi',
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          MbgButton(
            label: 'Periksa Kepatuhan',
            isLoading: _loading,
            onPressed: _runCheck,
            icon: Icons.verified_user_rounded,
          ),
          if (_result != null) ...[
            const SizedBox(height: 24),
            _ResultView(result: _result!, isDark: isDark),
          ],
        ],
      ),
    );
  }

  Widget _switchTile(
      String label, bool val, ValueChanged<bool> onChanged, IconData icon) {
    return Card(
      margin: const EdgeInsets.only(bottom: 6),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
        child: Row(
          children: [
            Icon(icon, size: 20, color: MBGColors.primary),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(fontSize: 14),
              ),
            ),
            Switch(value: val, onChanged: onChanged),
          ],
        ),
      ),
    );
  }
}

class _ResultView extends StatelessWidget {
  final ComplianceResult result;
  final bool isDark;

  const _ResultView({required this.result, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final (Color c, IconData i, String l) = switch (result.overallStatus) {
      'memenuhi' =>
        (MBGColors.success, Icons.check_circle_rounded, 'Memenuhi Standar'),
      'kurang' =>
        (MBGColors.warning, Icons.warning_amber_rounded, 'Kurang'),
      _ => (MBGColors.error, Icons.cancel_rounded, 'Tidak Memenuhi'),
    };

    return Column(
      children: [
        Card(
          color: c.withValues(alpha: isDark ? 0.12 : 0.06),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(i, color: c, size: 32),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l,
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          color: c,
                          fontSize: 15,
                        ),
                      ),
                      Text(
                        '${result.passedCount}/${result.totalChecks} terpenuhi',
                        style: TextStyle(
                            fontSize: 12, color: MBGColors.neutral500),
                      ),
                    ],
                  ),
                ),
                Text(
                  '${result.score}',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w800,
                    color: c,
                  ),
                ),
              ],
            ),
          ),
        ),
        if (result.recommendations.isNotEmpty) ...[
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
                  const Text(
                    'Rekomendasi',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                      color: MBGColors.warning,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...result.recommendations.map(
                    (s) => Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Text(
                        '• $s',
                        style: TextStyle(
                          fontSize: 13,
                          color: isDark
                              ? Colors.white70
                              : MBGColors.neutral800,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }
}
