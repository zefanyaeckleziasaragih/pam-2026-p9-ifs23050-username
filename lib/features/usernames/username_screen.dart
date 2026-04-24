import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../core/constants/api_constants.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/theme_notifier.dart';
import '../../data/models/username_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/username_provider.dart';
import 'username_detail_screen.dart';

class UsernameScreen extends StatefulWidget {
  const UsernameScreen({super.key});

  @override
  State<UsernameScreen> createState() => _UsernameScreenState();
}

class _UsernameScreenState extends State<UsernameScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    final auth = context.read<AuthProvider>();
    final provider = context.read<UsernameProvider>();
    provider.fetchHistory(auth.token!);

    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 100) {
        provider.fetchHistory(auth.token!);
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _refresh() async {
    final auth = context.read<AuthProvider>();
    final provider = context.read<UsernameProvider>();
    provider.reset();
    await provider.fetchHistory(auth.token!);
  }

  void _showGenerateDialog() {
    final keywordController = TextEditingController();
    String selectedStyle = ApiConstants.styles.first;
    int selectedTotal = 5;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Consumer<UsernameProvider>(
              builder: (context, provider, _) {
                return Container(
                  padding: EdgeInsets.only(
                    left: 24,
                    right: 24,
                    top: 24,
                    bottom: MediaQuery.of(context).viewInsets.bottom + 32,
                  ),
                  decoration: BoxDecoration(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? AppColors.darkSurface
                        : Colors.white,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(28),
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Handle bar
                      Center(
                        child: Container(
                          width: 40,
                          height: 4,
                          decoration: BoxDecoration(
                            color: Colors.grey.withValues(alpha: 0.3),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      const Text(
                        "✨ Generate Username",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        "Masukkan kata kunci dan pilih gaya username",
                        style: TextStyle(color: Colors.grey, fontSize: 13),
                      ),
                      const SizedBox(height: 20),

                      // Keyword input
                      TextField(
                        controller: keywordController,
                        autofocus: true,
                        decoration: const InputDecoration(
                          labelText: "Kata kunci / tema",
                          hintText: "Contoh: naga, bintang, coding...",
                          prefixIcon: Icon(Icons.search_rounded),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Style selector
                      const Text(
                        "Gaya Username",
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: ApiConstants.styles.map((style) {
                          final label =
                              ApiConstants.styleLabels[style] ?? style;
                          final isSelected = selectedStyle == style;
                          return GestureDetector(
                            onTap: () =>
                                setSheetState(() => selectedStyle = style),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 8),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? AppColors.primary
                                    : AppColors.primary.withValues(alpha: 0.08),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: isSelected
                                      ? AppColors.primary
                                      : AppColors.primary
                                      .withValues(alpha: 0.2),
                                ),
                              ),
                              child: Text(
                                label,
                                style: TextStyle(
                                  color: isSelected
                                      ? Colors.white
                                      : AppColors.primary,
                                  fontSize: 13,
                                  fontWeight: isSelected
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 16),

                      // Total slider
                      Row(
                        children: [
                          const Text(
                            "Jumlah Username:",
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 6),
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              "$selectedTotal",
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ],
                      ),
                      Slider(
                        value: selectedTotal.toDouble(),
                        min: 3,
                        max: 15,
                        divisions: 12,
                        activeColor: AppColors.primary,
                        onChanged: (v) =>
                            setSheetState(() => selectedTotal = v.round()),
                      ),

                      const SizedBox(height: 8),

                      // Generate button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: provider.isGenerating
                              ? null
                              : () async {
                            if (keywordController.text.trim().isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                      "Masukkan kata kunci terlebih dahulu"),
                                  backgroundColor: Colors.redAccent,
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                              return;
                            }
                            final token =
                            context.read<AuthProvider>().token!;
                            final result =
                            await provider.generate(
                              token,
                              keywordController.text.trim(),
                              selectedStyle,
                              selectedTotal,
                            );

                            if (!sheetContext.mounted) return;
                            Navigator.pop(sheetContext);

                            if (result != null && context.mounted) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => UsernameDetailScreen(
                                      item: result),
                                ),
                              );
                            } else if (provider.errorMessage != null &&
                                context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content:
                                  Text(provider.errorMessage!),
                                  backgroundColor: Colors.redAccent,
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                            }
                          },
                          child: provider.isGenerating
                              ? const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                height: 18,
                                width: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              ),
                              SizedBox(width: 10),
                              Text("AI sedang bekerja..."),
                            ],
                          )
                              : const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.auto_awesome, size: 18),
                              SizedBox(width: 8),
                              Text(
                                "Generate Sekarang",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  void _confirmDelete(UsernameModel item) {
    final auth = context.read<AuthProvider>();
    final provider = context.read<UsernameProvider>();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text("Hapus Riwayat"),
        content: Text('Hapus generate untuk kata kunci "${item.keyword}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Batal"),
          ),
          ElevatedButton(
            style:
            ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () {
              provider.delete(auth.token!, item.id);
              Navigator.pop(context);
            },
            child: const Text("Hapus"),
          ),
        ],
      ),
    );
  }

  String formatDate(String date) {
    try {
      final parsed = DateTime.parse(date);
      return DateFormat('dd MMM yyyy').format(parsed);
    } catch (_) {
      return date;
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final provider = context.watch<UsernameProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final username = auth.user?.username ?? 'User';
    final historyCount = provider.history.length;

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 16,
        title: const Text(
          "UsernameAI",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
        ),
        actions: [
          IconButton(
            tooltip: "Ubah tema",
            icon: Icon(
              isDark ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
            ),
            onPressed: () => context.read<ThemeNotifier>().toggleTheme(),
          ),
          IconButton(
            tooltip: "Keluar",
            icon: const Icon(Icons.logout),
            onPressed: () {
              auth.logout();
              context.read<UsernameProvider>().reset();
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showGenerateDialog,
        icon: const Icon(Icons.auto_awesome),
        label: const Text("Generate Username"),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: Stack(
        children: [
          RefreshIndicator(
            onRefresh: _refresh,
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.only(bottom: 120, top: 8),
              itemCount: _itemCount(provider),
              itemBuilder: (context, index) {
                // index 0: welcome card
                if (index == 0) {
                  return Column(
                    children: [
                      _buildWelcomeCard(username, historyCount),
                      const SizedBox(height: 8),
                    ],
                  );
                }

                // Error or empty state
                if (provider.history.isEmpty && !provider.isLoading) {
                  if (provider.errorMessage != null) {
                    return _buildErrorState(provider.errorMessage!);
                  }
                  return _buildEmptyState();
                }

                // Initial loading state (no history yet)
                if (provider.history.isEmpty && provider.isLoading) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 60),
                    child: Center(
                      child: CircularProgressIndicator(color: AppColors.primary),
                    ),
                  );
                }

                final itemIndex = index - 1;
                if (itemIndex < provider.history.length) {
                  return _buildHistoryCard(
                      provider.history[itemIndex], itemIndex, isDark);
                }

                // Loading more indicator
                return const Padding(
                  padding: EdgeInsets.all(20),
                  child: Center(child: CircularProgressIndicator()),
                );
              },
            ),
          ),

          // Full-screen generating overlay
          if (provider.isGenerating)
            Container(
              color: Colors.black.withValues(alpha: 0.45),
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 32, vertical: 24),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkSurface : Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircularProgressIndicator(color: AppColors.primary),
                      SizedBox(height: 16),
                      Text(
                        "AI sedang generate username...",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 4),
                      Text(
                        "Mohon tunggu sebentar",
                        style: TextStyle(color: Colors.grey, fontSize: 12),
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

  int _itemCount(UsernameProvider provider) {
    if (provider.history.isEmpty && !provider.isLoading) return 2; // welcome + empty state
    if (provider.history.isEmpty && provider.isLoading) return 2;  // welcome + loading spinner
    return 1 + provider.history.length + (provider.isLoading ? 1 : 0);
  }

  Widget _buildWelcomeCard(String username, int count) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, AppColors.secondary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.3),
            blurRadius: 14,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(Icons.auto_awesome,
                color: Colors.white, size: 28),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Halo, $username 👋",
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 17,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$count riwayat generate • tarik untuk refresh',
                  style:
                  const TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 48),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark
            ? AppColors.darkCard
            : Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.person_search_rounded,
            size: 72,
            color: AppColors.primary.withValues(alpha: 0.35),
          ),
          const SizedBox(height: 16),
          const Text(
            "Belum ada riwayat",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            "Tekan tombol Generate untuk membuat\nusername unik pertamamu!",
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String message) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 48),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark
            ? AppColors.darkCard
            : Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.cloud_off_rounded,
            size: 72,
            color: Colors.redAccent.withValues(alpha: 0.6),
          ),
          const SizedBox(height: 16),
          const Text(
            "Gagal memuat data",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.redAccent,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.grey, fontSize: 13),
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: _refresh,
            icon: const Icon(Icons.refresh_rounded, size: 18),
            label: const Text("Coba Lagi"),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryCard(UsernameModel item, int index, bool isDark) {
    final styleLabel = ApiConstants.styleLabels[item.style] ?? item.style;

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => UsernameDetailScreen(item: item),
        ),
      ),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkCard : Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: isDark
              ? null
              : [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            // Number badge
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.primary, AppColors.secondary],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Center(
                child: Text(
                  "#${index + 1}",
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 14),

            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '"${item.keyword}"',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  // Preview usernames
                  Text(
                    item.usernames.take(3).join(" • "),
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      _styleBadge(styleLabel),
                      const SizedBox(width: 8),
                      Icon(Icons.person_rounded,
                          size: 12, color: Colors.grey[500]),
                      const SizedBox(width: 3),
                      Text(
                        "${item.usernames.length} username",
                        style: TextStyle(
                            fontSize: 11, color: Colors.grey[500]),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        formatDate(item.createdAt),
                        style: TextStyle(
                            fontSize: 11, color: Colors.grey[500]),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Delete button
            IconButton(
              icon: const Icon(Icons.delete_outline,
                  color: Colors.redAccent, size: 20),
              onPressed: () => _confirmDelete(item),
            ),
          ],
        ),
      ),
    );
  }

  Widget _styleBadge(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 11,
          color: AppColors.primary,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}