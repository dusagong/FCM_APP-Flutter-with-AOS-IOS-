import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../models/models.dart';
import '../providers/app_provider.dart';
import '../widgets/common_widgets.dart';
import 'review_write_screen.dart';

class CouponScreen extends StatelessWidget {
  const CouponScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const CustomAppBar(title: '나의 쿠폰함'),
      body: Consumer<AppProvider>(
        builder: (context, provider, _) {
          final coupons = provider.coupons;

          if (coupons.isEmpty) {
            return const EmptyState(
              icon: Icons.local_offer_rounded,
              title: '아직 받은 쿠폰이 없습니다',
              subtitle: '만남승강장에서 쿠폰을 받아보세요!',
            );
          }

          // Sort: unused first, then by received date
          final sortedCoupons = List<Coupon>.from(coupons)
            ..sort((a, b) {
              if (a.isUsed != b.isUsed) {
                return a.isUsed ? 1 : -1;
              }
              return b.receivedAt.compareTo(a.receivedAt);
            });

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: sortedCoupons.length,
            itemBuilder: (context, index) {
              return _CouponCard(
                coupon: sortedCoupons[index],
                index: index,
              );
            },
          );
        },
      ),
    );
  }
}

class _CouponCard extends StatelessWidget {
  final Coupon coupon;
  final int index;

  const _CouponCard({
    required this.coupon,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppBorderRadius.lg),
        boxShadow: AppShadows.small,
        border: coupon.isUsed
            ? Border.all(color: AppColors.border)
            : null,
      ),
      child: Opacity(
        opacity: coupon.isUsed ? 0.6 : 1.0,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with place name
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: coupon.isUsed
                    ? AppColors.surfaceVariant
                    : AppColors.primary.withValues(alpha: 0.1),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(AppBorderRadius.lg),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: coupon.isUsed
                          ? AppColors.textTertiary
                          : AppColors.primary,
                      borderRadius: BorderRadius.circular(AppBorderRadius.md),
                    ),
                    child: const Icon(
                      Icons.store_rounded,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      coupon.placeName,
                      style: AppTypography.titleMedium.copyWith(
                        color: coupon.isUsed
                            ? AppColors.textSecondary
                            : AppColors.textPrimary,
                      ),
                    ),
                  ),
                  if (coupon.isUsed)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.textTertiary,
                        borderRadius: BorderRadius.circular(AppBorderRadius.sm),
                      ),
                      child: Text(
                        '사용완료',
                        style: AppTypography.labelSmall.copyWith(
                          color: Colors.white,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            // Content
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Coupon description
                  Row(
                    children: [
                      const Icon(
                        Icons.card_giftcard_rounded,
                        color: AppColors.secondary,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          coupon.description,
                          style: AppTypography.titleLarge.copyWith(
                            color: coupon.isUsed
                                ? AppColors.textSecondary
                                : AppColors.secondary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // Location
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on_outlined,
                        color: AppColors.textTertiary,
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${coupon.province} ${coupon.city}',
                        style: AppTypography.bodySmall,
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  // Date
                  Row(
                    children: [
                      Icon(
                        coupon.isUsed
                            ? Icons.check_circle_outline
                            : Icons.access_time_rounded,
                        color: AppColors.textTertiary,
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        coupon.isUsed
                            ? '사용일: ${coupon.formattedUsedDate}'
                            : '발급일: ${coupon.formattedReceivedDate}',
                        style: AppTypography.bodySmall,
                      ),
                    ],
                  ),
                  // Use button
                  if (!coupon.isUsed) ...[
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => _showUseCouponModal(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(AppBorderRadius.md),
                          ),
                        ),
                        child: const Text('사용하기'),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(
          delay: Duration(milliseconds: 100 * index),
          duration: 300.ms,
        ).slideY(begin: 0.1, end: 0);
  }

  void _showUseCouponModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _CouponPinModal(coupon: coupon),
    );
  }
}

class _CouponPinModal extends StatefulWidget {
  final Coupon coupon;

  const _CouponPinModal({required this.coupon});

  @override
  State<_CouponPinModal> createState() => _CouponPinModalState();
}

class _CouponPinModalState extends State<_CouponPinModal> {
  final List<TextEditingController> _controllers = List.generate(
    4,
    (_) => TextEditingController(),
  );
  final List<FocusNode> _focusNodes = List.generate(4, (_) => FocusNode());
  String _error = '';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNodes[0].requestFocus();
    });
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  String get _pin => _controllers.map((c) => c.text).join();

  void _onDigitChanged(int index, String value) {
    if (value.isNotEmpty && index < 3) {
      _focusNodes[index + 1].requestFocus();
    }
    setState(() => _error = '');
  }

  Future<void> _submit() async {
    if (_pin.length != 4) {
      setState(() => _error = 'PIN 4자리를 모두 입력해주세요');
      return;
    }

    setState(() => _isLoading = true);

    await Future.delayed(const Duration(milliseconds: 500));

    if (!mounted) return;

    final provider = context.read<AppProvider>();
    final success = provider.useCoupon(widget.coupon.id, _pin);

    if (success) {
      Navigator.pop(context);
      _showReviewPromptModal(context);
    } else {
      setState(() {
        _error = '비밀번호가 올바르지 않습니다';
        _isLoading = false;
        for (var controller in _controllers) {
          controller.clear();
        }
        _focusNodes[0].requestFocus();
      });
    }
  }

  void _showReviewPromptModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => _ReviewPromptModal(coupon: widget.coupon),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppBorderRadius.xxl),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),
            // Icon
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.lock_outline_rounded,
                color: AppColors.primary,
                size: 32,
              ),
            ),
            const SizedBox(height: 16),
            // Title
            Text(
              '쿠폰 사용하기',
              style: AppTypography.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              '사장님 비밀번호를 입력해주세요',
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 24),
            // PIN Input
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(4, (index) {
                return Container(
                  width: 56,
                  height: 64,
                  margin: const EdgeInsets.symmetric(horizontal: 6),
                  child: TextField(
                    controller: _controllers[index],
                    focusNode: _focusNodes[index],
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    maxLength: 1,
                    obscureText: true,
                    style: AppTypography.displaySmall,
                    decoration: InputDecoration(
                      counterText: '',
                      filled: true,
                      fillColor: AppColors.surfaceVariant,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppBorderRadius.md),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppBorderRadius.md),
                        borderSide: const BorderSide(
                          color: AppColors.primary,
                          width: 2,
                        ),
                      ),
                    ),
                    onChanged: (value) => _onDigitChanged(index, value),
                  ),
                );
              }),
            ),
            // Error
            if (_error.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(
                _error,
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.error,
                ),
              ),
            ],
            const SizedBox(height: 24),
            // Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppBorderRadius.md),
                      ),
                    ),
                    child: const Text('취소'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppBorderRadius.md),
                      ),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Text('확인'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

class _ReviewPromptModal extends StatelessWidget {
  final Coupon coupon;

  const _ReviewPromptModal({required this.coupon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppBorderRadius.xxl),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Success animation
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.success.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.check_circle_rounded,
              color: AppColors.success,
              size: 48,
            ),
          ).animate().scale(
                begin: const Offset(0.5, 0.5),
                end: const Offset(1, 1),
                duration: 400.ms,
                curve: Curves.elasticOut,
              ),
          const SizedBox(height: 16),
          Text(
            '쿠폰이 사용되었습니다!',
            style: AppTypography.headlineSmall,
          ),
          const SizedBox(height: 24),
          // Prompt
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.surfaceVariant,
              borderRadius: BorderRadius.circular(AppBorderRadius.lg),
            ),
            child: Column(
              children: [
                const Text(
                  '✨',
                  style: TextStyle(fontSize: 32),
                ),
                const SizedBox(height: 12),
                Text(
                  '방문 경험을 기록해보세요!',
                  style: AppTypography.titleMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  '소중한 추억을 리뷰로 남겨주시면\n다른 여행자들에게 큰 도움이 됩니다 💝',
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          // Buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppBorderRadius.md),
                    ),
                  ),
                  child: const Text('나중에'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    final provider = context.read<AppProvider>();
                    final place = provider.getPlaceById(coupon.placeId);
                    if (place != null) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ReviewWriteScreen(place: place),
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppBorderRadius.md),
                    ),
                  ),
                  child: const Text('리뷰 작성하기'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
