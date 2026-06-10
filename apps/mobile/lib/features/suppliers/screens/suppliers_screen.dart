import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/mbg_theme.dart';
import '../../../shared/api/api_client.dart';
import '../../../shared/models/supplier.dart';
import '../../../shared/widgets/widgets.dart';

class SuppliersScreen extends ConsumerStatefulWidget {
  const SuppliersScreen({super.key});

  @override
  ConsumerState<SuppliersScreen> createState() => _SuppliersScreenState();
}

class _SuppliersScreenState extends ConsumerState<SuppliersScreen> {
  final _searchCtrl = TextEditingController();
  List<Supplier> _suppliers = [];
  bool _loading = false;
  bool _verifiedOnly = false;
  String? _category;

  static const _categories = [
    'Semua',
    'sayur',
    'buah',
    'daging',
    'ikan',
    'bumbu',
    'katering'
  ];

  @override
  void initState() {
    super.initState();
    _search();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _search() async {
    setState(() => _loading = true);
    try {
      final api = ref.read(apiClientProvider);
      final data = await api.searchSuppliers(
        query:
            _searchCtrl.text.trim().isEmpty ? null : _searchCtrl.text.trim(),
        category: _category,
        verifiedOnly: _verifiedOnly,
      );
      final list = (data['suppliers'] as List<dynamic>?) ?? [];
      setState(() => _suppliers = list
          .map((e) => Supplier.fromJson(e as Map<String, dynamic>))
          .toList());
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gagal memuat supplier.')),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
          child: TextField(
            controller: _searchCtrl,
            onSubmitted: (_) => _search(),
            decoration: InputDecoration(
              hintText: 'Cari supplier...',
              prefixIcon: const Icon(Icons.search_rounded, size: 20),
              suffixIcon: IconButton(
                icon: Icon(
                  _verifiedOnly
                      ? Icons.filter_alt_rounded
                      : Icons.filter_alt_outlined,
                  size: 20,
                  color: _verifiedOnly ? MBGColors.primary : null,
                ),
                onPressed: () {
                  setState(() => _verifiedOnly = !_verifiedOnly);
                  _search();
                },
              ),
            ),
          ),
        ),
        SizedBox(
          height: 44,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            children: _categories.map((c) {
              final sel = (c == 'Semua' && _category == null) || c == _category;
              return Padding(
                padding: const EdgeInsets.only(right: 6),
                child: FilterChip(
                  label: Text(c,
                      style: TextStyle(
                        fontSize: 12,
                        color: sel ? Colors.white : null,
                      )),
                  selected: sel,
                  onSelected: (_) {
                    setState(() => _category = c == 'Semua' ? null : c);
                    _search();
                  },
                ),
              );
            }).toList(),
          ),
        ),
        if (_verifiedOnly)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Row(
              children: [
                Icon(Icons.verified_rounded,
                    size: 14, color: MBGColors.primary),
                const SizedBox(width: 4),
                Text(
                  'Hanya supplier terverifikasi',
                  style: TextStyle(
                      fontSize: 11, color: MBGColors.primary),
                ),
              ],
            ),
          ),
        Expanded(
          child: _loading
              ? const Center(
                  child: MbgLoadingIndicator(message: 'Memuat supplier...'))
              : _suppliers.isEmpty
                  ? Center(
                      child: Text(
                        'Belum ada supplier ditemukan.',
                        style: TextStyle(color: MBGColors.neutral500),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _suppliers.length,
                      itemBuilder: (_, i) =>
                          _SupplierCard(supplier: _suppliers[i]),
                    ),
        ),
      ],
    );
  }
}

class _SupplierCard extends StatelessWidget {
  final Supplier supplier;
  const _SupplierCard({required this.supplier});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.all(14),
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
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.store_rounded,
                      color: MBGColors.primary, size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              supplier.name,
                              style: const TextStyle(
                                  fontWeight: FontWeight.w600, fontSize: 14),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (supplier.verified) ...[
                            const SizedBox(width: 4),
                            const Icon(Icons.verified_rounded,
                                size: 16, color: MBGColors.primary),
                          ],
                        ],
                      ),
                      Text(
                        '${supplier.district}, ${supplier.city}',
                        style: TextStyle(
                            fontSize: 12, color: MBGColors.neutral500),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 6,
              runSpacing: 4,
              children: supplier.categories
                  .map(
                    (c) => Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: MBGColors.primary.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        c,
                        style: const TextStyle(
                          fontSize: 11,
                          color: MBGColors.primary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Kapasitas: ${supplier.dailyCapacity} porsi/hari',
                  style:
                      TextStyle(fontSize: 12, color: MBGColors.neutral500),
                ),
                Row(
                  children: [
                    SizedBox(
                      width: 40,
                      height: 4,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(2),
                        child: LinearProgressIndicator(
                          value: supplier.profileCompleteness / 100,
                          backgroundColor: MBGColors.neutral200
                              .withValues(alpha: 0.3),
                          valueColor:
                              const AlwaysStoppedAnimation(MBGColors.primary),
                        ),
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${supplier.profileCompleteness}%',
                      style: TextStyle(
                          fontSize: 10, color: MBGColors.neutral500),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
