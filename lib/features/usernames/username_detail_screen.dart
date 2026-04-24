import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../../data/models/username_model.dart';
import '../../core/constants/api_constants.dart';
import '../../core/theme/app_theme.dart';

class UsernameDetailScreen extends StatelessWidget {
  final UsernameModel item;

  const UsernameDetailScreen({super.key, required this.item});

  String formatDate(String date) {
    try {
      final parsed = DateTime.parse(date);
      return DateFormat("dd MMM yyyy, HH:mm").format(parsed);
    } catch (_) {
      return date;
    }
  }

  void _copyToClipboard(BuildContext context, String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('"$text" disalin!'),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 1),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        backgroundColor: AppColors.success,
      ),
    );
  }

  void _copyAll(BuildContext context) {
    final all = item.usernames.join('\n');
    Clipboard.setData(ClipboardData(text: all));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Semua ${item.usernames.length} username disalin!'),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        backgroundColor: AppColors.success,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final styleLabel = ApiConstants.styleLabels[item.style] ?? item.style;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Hasil Generate",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            tooltip: "Salin semua",
            icon: const Icon(Icons.copy_all_rounded),
            onPressed: () => _copyAll(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.primary, AppColors.secondary],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.3),
                    blurRadius: 16,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.auto_awesome, color: Colors.white70, size: 28),
                  const SizedBox(height: 12),
                  Text(
                    '"${item.keyword}"',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _chip(styleLabel),
                      const SizedBox(width: 8),
                      _chip("${item.usernames.length} username"),
                      const SizedBox(width: 8),
                      _chip(formatDate(item.createdAt)),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // AI description
            if (item.description.isNotEmpty) ...[
              _sectionTitle("Tentang Hasil Generate"),
              const SizedBox(height: 10),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark
                      ? AppColors.darkCard
                      : AppColors.primary.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: AppColors.primary.withValues(alpha: 0.15),
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.lightbulb_outline,
                        color: AppColors.primary, size: 20),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        item.description,
                        style: const TextStyle(fontSize: 14, height: 1.6),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],

            // Username list
            Row(
              children: [
                _sectionTitle("Daftar Username"),
                const Spacer(),
                TextButton.icon(
                  onPressed: () => _copyAll(context),
                  icon: const Icon(Icons.copy_all_rounded, size: 16),
                  label: const Text("Salin Semua"),
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            ...item.usernames.asMap().entries.map((entry) {
              final index = entry.key;
              final username = entry.value;
              return _usernameCard(context, isDark, index, username);
            }),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _usernameCard(
      BuildContext context, bool isDark, int index, String username) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.12),
        ),
        boxShadow: isDark
            ? null
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
      ),
      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppColors.primary, AppColors.secondary],
            ),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(
            child: Text(
              "${index + 1}",
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ),
        ),
        title: Text(
          username,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            letterSpacing: 0.3,
          ),
        ),
        trailing: IconButton(
          icon: const Icon(Icons.copy_rounded,
              color: AppColors.primary, size: 20),
          tooltip: "Salin",
          onPressed: () => _copyToClipboard(context, username),
        ),
        onTap: () => _copyToClipboard(context, username),
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 17,
        fontWeight: FontWeight.bold,
        color: AppColors.primary,
      ),
    );
  }

  Widget _chip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: const TextStyle(color: Colors.white, fontSize: 11),
      ),
    );
  }
}
