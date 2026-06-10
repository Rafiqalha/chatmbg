import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme/mbg_theme.dart';
import '../../../shared/widgets/widgets.dart';
import '../../auth/providers/auth_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final email = auth.user?.email ?? 'Pengguna';
    final name =
        auth.user?.userMetadata?['full_name'] as String? ?? 'Pengguna MBGBrain';

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: MBGColors.primary.withValues(alpha: 0.1),
                  child: Text(
                    name[0].toUpperCase(),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: MBGColors.primary,
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: const TextStyle(
                            fontWeight: FontWeight.w600, fontSize: 15),
                      ),
                      Text(
                        email,
                        style: TextStyle(
                            fontSize: 12, color: MBGColors.neutral500),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),
        _tile(Icons.person_outlined, 'Profil', 'Kelola informasi akun',
            isDark, () {}),
        _tile(Icons.key_outlined, 'API Key', 'Kelola API key Anda',
            isDark, () {}),
        _tile(Icons.history_rounded, 'Riwayat', 'Lihat riwayat query',
            isDark, () {}),
        _tile(Icons.notifications_outlined, 'Notifikasi',
            'Atur preferensi notifikasi', isDark, () {}),
        _tile(Icons.help_outline, 'Bantuan', 'FAQ dan dukungan',
            isDark, () {}),
        _tile(Icons.info_outline, 'Tentang', 'MBGBrain v1.0.0',
            isDark, () {}),
        const SizedBox(height: 24),
        MbgButton(
          label: 'Keluar',
          isOutlined: true,
          icon: Icons.logout_rounded,
          onPressed: () async {
            await ref.read(authProvider.notifier).signOut();
            if (context.mounted) context.go('/login');
          },
        ),
        const SizedBox(height: 16),
        Center(
          child: Text(
            'MBGBrain v1.0.0 • AI Intelligence MBG Indonesia',
            style: TextStyle(fontSize: 11, color: MBGColors.neutral500),
          ),
        ),
      ],
    );
  }

  Widget _tile(
      IconData icon, String title, String sub, bool isDark, VoidCallback onTap) {
    return Card(
      margin: const EdgeInsets.only(bottom: 6),
      child: ListTile(
        leading: Icon(icon, size: 22, color: MBGColors.primary),
        title: Text(title,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
        subtitle: Text(sub,
            style: TextStyle(fontSize: 12, color: MBGColors.neutral500)),
        trailing: Icon(Icons.chevron_right_rounded,
            size: 20, color: MBGColors.neutral500),
        onTap: onTap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
