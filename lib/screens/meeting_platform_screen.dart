import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../models/models.dart';
import '../providers/app_provider.dart';
import '../widgets/common_widgets.dart';
import 'coupon_screen.dart';
import 'review_list_screen.dart';
import 'review_write_screen.dart';
import 'my_page_screen.dart';

class MeetingPlatformScreen extends StatefulWidget {
  final PhotoCard photoCard;
  final RecommendationResponse? preloadedResponse;

  const MeetingPlatformScreen({
    super.key,
    required this.photoCard,
    this.preloadedResponse,
  });

  @override
  State<MeetingPlatformScreen> createState() => _MeetingPlatformScreenState();
}

class _MeetingPlatformScreenState extends State<MeetingPlatformScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);

    // preloadedResponse가 있으면 Provider에 설정
    if (widget.preloadedResponse != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.read<AppProvider>().setRecommendationResponse(widget.preloadedResponse!);
      });
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => Navigator.popUntil(context, (route) => route.isFirst),
        ),
        title: Column(
          children: [
            Text(
              '${widget.photoCard.city} 데이트 추천 코스',
              style: AppTypography.titleMedium,
            ),
          ],
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.person_rounded),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const MyPageScreen()),
              );
            },
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: _buildTabBar(),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          _CourseView(photoCard: widget.photoCard),
          _AllPlacesView(photoCard: widget.photoCard),
          _MapView(photoCard: widget.photoCard),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppBorderRadius.full),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(AppBorderRadius.full),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent,
        labelColor: Colors.white,
        unselectedLabelColor: AppColors.textSecondary,
        labelStyle: AppTypography.labelMedium.copyWith(
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
        ),
        tabs: const [
          Tab(
            height: 40,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.timeline_rounded, size: 18),
                SizedBox(width: 6),
                Text('코스'),
              ],
            ),
          ),
          Tab(
            height: 40,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.grid_view_rounded, size: 18),
                SizedBox(width: 6),
                Text('전체'),
              ],
            ),
          ),
          Tab(
            height: 40,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.map_rounded, size: 18),
                SizedBox(width: 6),
                Text('지도'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Course View - API 추천 코스 사용
class _CourseView extends StatelessWidget {
  final PhotoCard photoCard;

  const _CourseView({required this.photoCard});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (context, provider, _) {
        final course = provider.recommendedCourse;

        if (course == null || course.stops.isEmpty) {
          return const EmptyState(
            icon: Icons.map_rounded,
            title: '추천 코스가 없습니다',
            subtitle: 'AI가 코스를 준비하지 못했습니다',
          );
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: _RecommendedCourseCard(course: course),
        );
      },
    );
  }
}

/// API 응답의 RecommendedCourse를 표시하는 카드
class _RecommendedCourseCard extends StatelessWidget {
  final RecommendedCourse course;

  const _RecommendedCourseCard({required this.course});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppBorderRadius.lg),
        boxShadow: AppShadows.small,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: AppColors.primaryGradient,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(AppBorderRadius.lg),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.route_rounded, color: Colors.white, size: 24),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        course.title,
                        style: AppTypography.titleLarge.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                if (course.totalDuration != null) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.schedule_rounded, color: Colors.white70, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        course.totalDuration!,
                        style: AppTypography.bodySmall.copyWith(color: Colors.white70),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          // Summary
          if (course.summary != null)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                course.summary!,
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          // Stops
          ...course.stops.asMap().entries.map((entry) {
            final index = entry.key;
            final stop = entry.value;
            return _CourseStopItem(
              stop: stop,
              isLast: index == course.stops.length - 1,
            );
          }),
          const SizedBox(height: 16),
        ],
      ),
    ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.1, end: 0);
  }
}

/// 코스의 각 정차지 아이템
class _CourseStopItem extends StatelessWidget {
  final CourseStop stop;
  final bool isLast;

  const _CourseStopItem({
    required this.stop,
    this.isLast = false,
  });

  String _getCategoryEmoji(String? category) {
    switch (category) {
      case '카페':
        return '☕';
      case '음식점':
        return '🍽️';
      case '관광지':
        return '🏞️';
      case '숙박':
        return '🏨';
      case '문화시설':
        return '🏛️';
      default:
        return '📍';
    }
  }

  Color _getCategoryColor(String? category) {
    switch (category) {
      case '카페':
        return AppColors.cafe;
      case '음식점':
        return AppColors.restaurant;
      case '관광지':
        return AppColors.tourism;
      case '숙박':
        return AppColors.accentTeal;
      default:
        return AppColors.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Timeline
          Column(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: _getCategoryColor(stop.category),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    '${stop.order}',
                    style: AppTypography.labelMedium.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              if (!isLast)
                Container(
                  width: 2,
                  height: 100,
                  color: AppColors.border,
                ),
            ],
          ),
          const SizedBox(width: 12),
          // Content
          Expanded(
            child: Container(
              margin: const EdgeInsets.only(bottom: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Category & Time
                  Row(
                    children: [
                      CategoryBadge(
                        label: stop.category ?? '장소',
                        color: _getCategoryColor(stop.category),
                        emoji: _getCategoryEmoji(stop.category),
                      ),
                      const Spacer(),
                      if (stop.time != null)
                        Text(
                          stop.time!,
                          style: AppTypography.labelSmall.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // Name
                  Text(
                    stop.name,
                    style: AppTypography.titleMedium,
                  ),
                  // Address
                  if (stop.address != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      stop.address!,
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                  // Duration
                  if (stop.duration != null) ...[
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.timer_outlined, size: 14, color: AppColors.textTertiary),
                        const SizedBox(width: 4),
                        Text(
                          stop.duration!,
                          style: AppTypography.labelSmall,
                        ),
                      ],
                    ),
                  ],
                  // Reason (추천 이유)
                  if (stop.reason != null) ...[
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(AppBorderRadius.sm),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.favorite_rounded, size: 14, color: AppColors.primary),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              stop.reason!,
                              style: AppTypography.bodySmall.copyWith(
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  // Tip
                  if (stop.tip != null) ...[
                    const SizedBox(height: 6),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.lightbulb_outline_rounded, size: 14, color: AppColors.warning),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            stop.tip!,
                            style: AppTypography.labelSmall.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CourseCard extends StatelessWidget {
  final Course course;
  final int index;

  const _CourseCard({
    required this.course,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    final timeSlot = course.timeSlot;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppBorderRadius.lg),
        boxShadow: AppShadows.small,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _getTimeSlotColor(timeSlot).withValues(alpha: 0.1),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(AppBorderRadius.lg),
              ),
            ),
            child: Row(
              children: [
                Text(
                  timeSlot.emoji,
                  style: const TextStyle(fontSize: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${timeSlot.label} ${timeSlot.timeRange}',
                        style: AppTypography.labelMedium.copyWith(
                          color: _getTimeSlotColor(timeSlot),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        timeSlot.title,
                        style: AppTypography.titleMedium,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Description
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              timeSlot.description,
              style: AppTypography.bodySmall,
            ),
          ),
          // Places
          ...course.places.asMap().entries.map((entry) {
            final placeIndex = entry.key;
            final place = entry.value;
            return _PlaceItem(
              place: place,
              index: placeIndex + 1,
              isLast: placeIndex == course.places.length - 1,
            );
          }),
          // Estimated time
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                const Icon(Icons.schedule_rounded,
                    size: 16, color: AppColors.textSecondary),
                const SizedBox(width: 4),
                Text(
                  '예상 소요시간: ${course.estimatedTime}',
                  style: AppTypography.labelSmall,
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn(
          delay: Duration(milliseconds: 100 * index),
          duration: 300.ms,
        ).slideY(begin: 0.1, end: 0);
  }

  Color _getTimeSlotColor(TimeSlot slot) {
    switch (slot) {
      case TimeSlot.morning:
        return AppColors.morning;
      case TimeSlot.lunch:
        return AppColors.info;
      case TimeSlot.afternoon:
        return AppColors.accentTeal;
      case TimeSlot.evening:
        return AppColors.evening;
    }
  }
}

class _PlaceItem extends StatelessWidget {
  final Place place;
  final int index;
  final bool isLast;

  const _PlaceItem({
    required this.place,
    required this.index,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
          // Rail Track Timeline
          SizedBox(
            width: 40,
            child: Column(
              children: [
                // Station Node
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.primary,
                      width: 3,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.2),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      '$index',
                      style: AppTypography.labelMedium.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
                // Rail Track
                if (!isLast)
                  Expanded(
                    child: CustomPaint(
                      painter: _RailLinePainter(),
                      size: const Size(32, double.infinity),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          // Content
          Expanded(
            child: Container(
              margin: const EdgeInsets.only(bottom: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Category badge
                  CategoryBadge(
                    label: place.category.label,
                    color: _getCategoryColor(place.category),
                    emoji: place.category.emoji,
                  ),
                  const SizedBox(height: 8),
                  // Name
                  Text(
                    place.name,
                    style: AppTypography.titleMedium,
                  ),
                  const SizedBox(height: 4),
                  // Rating
                  Row(
                    children: [
                      RatingStars(rating: place.rating, size: 14),
                      const SizedBox(width: 4),
                      Text(
                        '${place.rating}',
                        style: AppTypography.labelSmall.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        ' (${place.reviewCount}개 리뷰)',
                        style: AppTypography.labelSmall,
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  // Description
                  Text(
                    place.description,
                    style: AppTypography.bodySmall,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 12),
                  // Action buttons
                  _PlaceActionButtons(place: place),
                ],
              ),
            ),
          ),
        ],
      ),
      ),
    );
  }

  Color _getCategoryColor(PlaceCategory category) {
    switch (category) {
      case PlaceCategory.cafe:
        return AppColors.cafe;
      case PlaceCategory.restaurant:
        return AppColors.restaurant;
      case PlaceCategory.tourism:
        return AppColors.tourism;
      case PlaceCategory.culture:
        return AppColors.culture;
    }
  }
}

class _PlaceActionButtons extends StatelessWidget {
  final Place place;

  const _PlaceActionButtons({required this.place});

  void _showCouponReceivedModal(BuildContext context, Place place) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppBorderRadius.xl),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Success icon - Blue Theme
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.card_giftcard_rounded,
                  color: AppColors.primary,
                  size: 40,
                ),
              ),
              const SizedBox(height: 20),
              // Title
              Text(
                '쿠폰을 받았습니다!',
                style: AppTypography.headlineSmall.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              // Place name
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppBorderRadius.md),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.store_rounded,
                      color: AppColors.primary,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        place.name,
                        style: AppTypography.titleMedium.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              // Description
              Text(
                '쿠폰함에서 확인하고\n매장에서 사용해보세요!',
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              // Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        side: BorderSide(color: AppColors.primary.withOpacity(0.5)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppBorderRadius.md),
                        ),
                      ),
                      child: const Text('닫기', style: TextStyle(color: AppColors.primary)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const CouponScreen(),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppBorderRadius.md),
                        ),
                        elevation: 0,
                      ),
                      child: const Text('쿠폰함 보기'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (context, provider, _) {
        final hasCoupon = provider.hasCoupon(place.id);

        return Row(
          children: [
            // Review button
            _ActionButton(
              label: '리뷰보기',
              icon: Icons.rate_review_outlined,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ReviewListScreen(place: place),
                  ),
                );
              },
            ),
            const SizedBox(width: 8),
            // Second button based on category
            if (place.category.hasCoupon)
              _ActionButton(
                label: hasCoupon ? '쿠폰받음' : '쿠폰받기',
                icon: hasCoupon ? Icons.check_circle : Icons.local_offer_outlined,
                isPrimary: !hasCoupon,
                isDisabled: hasCoupon,
                onTap: hasCoupon
                    ? null
                    : () {
                        provider.addCoupon(place);
                        _showCouponReceivedModal(context, place);
                      },
              )
            else
              _ActionButton(
                label: '리뷰작성',
                icon: Icons.edit_outlined,
                isPrimary: true,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ReviewWriteScreen(place: place),
                    ),
                  );
                },
              ),
          ],
        );
      },
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback? onTap;
  final bool isPrimary;
  final bool isDisabled;

  const _ActionButton({
    required this.label,
    required this.icon,
    this.onTap,
    this.isPrimary = false,
    this.isDisabled = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isDisabled ? null : onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isPrimary ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(AppBorderRadius.sm),
          border: Border.all(
            color: isDisabled
                ? AppColors.border
                : isPrimary
                    ? AppColors.primary
                    : AppColors.textSecondary,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 14,
              color: isDisabled
                  ? AppColors.textTertiary
                  : isPrimary
                      ? Colors.white
                      : AppColors.textSecondary,
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: AppTypography.labelSmall.copyWith(
                color: isDisabled
                    ? AppColors.textTertiary
                    : isPrimary
                        ? Colors.white
                        : AppColors.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// All Places View - API 추천 장소 사용
class _AllPlacesView extends StatelessWidget {
  final PhotoCard photoCard;

  const _AllPlacesView({required this.photoCard});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (context, provider, _) {
        final spots = provider.recommendedSpots;

        if (spots.isEmpty) {
          return const EmptyState(
            icon: Icons.store_rounded,
            title: '추천 장소가 없습니다',
            subtitle: 'AI가 장소를 찾지 못했습니다',
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: spots.length,
          itemBuilder: (context, index) {
            return _SpotCard(
              spot: spots[index],
              index: index,
            );
          },
        );
      },
    );
  }
}

/// API 응답의 SpotWithLocation을 표시하는 카드
class _SpotCard extends StatelessWidget {
  final SpotWithLocation spot;
  final int index;

  const _SpotCard({
    required this.spot,
    required this.index,
  });

  String _getCategoryEmoji(String? category) {
    switch (category) {
      case '카페':
        return '☕';
      case '음식점':
        return '🍽️';
      case '관광지':
        return '🏞️';
      case '숙박':
        return '🏨';
      case '문화시설':
        return '🏛️';
      case '축제/행사':
        return '🎉';
      case '레포츠':
        return '🏄';
      case '쇼핑':
        return '🛍️';
      default:
        return '📍';
    }
  }

  Color _getCategoryColor(String? category) {
    switch (category) {
      case '카페':
        return AppColors.cafe;
      case '음식점':
        return AppColors.restaurant;
      case '관광지':
        return AppColors.tourism;
      case '숙박':
        return AppColors.accentTeal;
      case '문화시설':
        return AppColors.culture;
      default:
        return AppColors.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppBorderRadius.lg),
        boxShadow: AppShadows.small,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image (이미지가 있는 경우에만)
          if (spot.imageUrl != null && spot.imageUrl!.isNotEmpty)
            Container(
              height: 160,
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(AppBorderRadius.lg),
                ),
              ),
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(AppBorderRadius.lg),
                ),
                child: Image.network(
                  spot.imageUrl!,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  errorBuilder: (_, __, ___) => const Center(
                    child: Icon(Icons.image_rounded, size: 48, color: AppColors.textTertiary),
                  ),
                ),
              ),
            ),
          // Content
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Category
                CategoryBadge(
                  label: spot.category ?? '장소',
                  color: _getCategoryColor(spot.category),
                  emoji: _getCategoryEmoji(spot.category),
                ),
                const SizedBox(height: 8),
                // Name
                Text(spot.name, style: AppTypography.titleLarge),
                // Address
                if (spot.address != null) ...[
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.location_on_outlined, size: 14, color: AppColors.textSecondary),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          spot.address!,
                          style: AppTypography.bodySmall.copyWith(
                            color: AppColors.textSecondary,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
                // Tel
                if (spot.tel != null && spot.tel!.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.phone_outlined, size: 14, color: AppColors.textSecondary),
                      const SizedBox(width: 4),
                      Text(
                        spot.tel!,
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ],
                // Location indicator (좌표가 있는 경우)
                if (spot.hasLocation) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.success.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(AppBorderRadius.sm),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.map_outlined, size: 12, color: AppColors.success),
                        const SizedBox(width: 4),
                        Text(
                          '지도에서 보기 가능',
                          style: AppTypography.labelSmall.copyWith(
                            color: AppColors.success,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn(
          delay: Duration(milliseconds: 100 * index),
          duration: 300.ms,
        ).slideY(begin: 0.1, end: 0);
  }
}

// Map View with NaverMap - API 추천 장소 사용
class _MapView extends StatefulWidget {
  final PhotoCard photoCard;

  const _MapView({required this.photoCard});

  @override
  State<_MapView> createState() => _MapViewState();
}

class _MapViewState extends State<_MapView> {
  NaverMapController? _mapController;

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }

  NLatLng _getInitialPosition(List<SpotWithLocation> spots) {
    // 장소 목록에서 좌표가 있는 첫 번째 장소의 위치를 기준으로 함
    for (final spot in spots) {
      if (spot.hasLocation) {
        return NLatLng(spot.latitude!, spot.longitude!);
      }
    }
    // 기본값: 강릉시 중심
    return const NLatLng(37.7519, 128.8760);
  }

  Color _getCategoryColor(String? category) {
    switch (category) {
      case '카페':
        return AppColors.cafe;
      case '음식점':
        return AppColors.restaurant;
      case '관광지':
        return AppColors.tourism;
      case '숙박':
        return AppColors.accentTeal;
      case '문화시설':
        return AppColors.culture;
      default:
        return AppColors.primary;
    }
  }

  String _getCategoryEmoji(String? category) {
    switch (category) {
      case '카페':
        return '☕';
      case '음식점':
        return '🍽️';
      case '관광지':
        return '🏞️';
      case '숙박':
        return '🏨';
      case '문화시설':
        return '🏛️';
      default:
        return '📍';
    }
  }

  void _addMarkers(List<SpotWithLocation> spots) async {
    if (_mapController == null) return;

    final markers = <NMarker>[];

    for (int i = 0; i < spots.length; i++) {
      final spot = spots[i];
      if (spot.hasLocation) {
        final marker = NMarker(
          id: spot.contentId ?? 'spot_$i',
          position: NLatLng(spot.latitude!, spot.longitude!),
        );

        marker.setOnTapListener((overlay) {
          _showSpotBottomSheet(context, spot);
        });

        markers.add(marker);
      }
    }

    await _mapController!.addOverlayAll(markers.toSet());
  }

  /// 코스 경로선 추가
  void _addCourseRoute(RecommendedCourse? course) async {
    if (_mapController == null || course == null) return;

    // 좌표가 있는 정차지만 필터링 (순서대로)
    final stopsWithLocation = course.stops
        .where((stop) => stop.hasLocation)
        .toList()
      ..sort((a, b) => a.order.compareTo(b.order));

    if (stopsWithLocation.length < 2) return;

    // 경로 좌표 생성
    final coords = stopsWithLocation
        .map((stop) => NLatLng(stop.latitude!, stop.longitude!))
        .toList();

    // 점선 경로 (#9bfa6c보다 진한 초록색)
    const routeColor = Color(0xFF5BD936);
    final polyline = NPolylineOverlay(
      id: 'course_route',
      coords: coords,
      color: routeColor,
      width: 4,
      lineCap: NLineCap.round,
      lineJoin: NLineJoin.round,
      pattern: [10, 6], // 점선 패턴
    );
    await _mapController!.addOverlay(polyline);

    // 코스 마커 추가
    final courseMarkers = <NMarker>[];
    for (int i = 0; i < stopsWithLocation.length; i++) {
      final stop = stopsWithLocation[i];

      final marker = NMarker(
        id: 'course_${stop.order}',
        position: NLatLng(stop.latitude!, stop.longitude!),
        caption: NOverlayCaption(
          text: '${stop.order}. ${stop.name}',
          textSize: 12,
          color: AppColors.textPrimary,
          haloColor: Colors.white,
        ),
      );

      marker.setOnTapListener((overlay) {
        _showCourseStopBottomSheet(context, stop);
      });

      courseMarkers.add(marker);
    }

    await _mapController!.addOverlayAll(courseMarkers.toSet());
  }

  void _showCourseStopBottomSheet(BuildContext context, CourseStop stop) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppBorderRadius.xl),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 순서 배지
            Row(
              children: [
                Container(
                  width: 28,
                  height: 28,
                  decoration: const BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      '${stop.order}',
                      style: AppTypography.labelMedium.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                CategoryBadge(
                  label: stop.category ?? '장소',
                  color: _getCategoryColor(stop.category),
                  emoji: _getCategoryEmoji(stop.category),
                ),
                const Spacer(),
                if (stop.time != null)
                  Text(
                    stop.time!,
                    style: AppTypography.labelSmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Text(stop.name, style: AppTypography.headlineSmall),
            if (stop.address != null) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.location_on_outlined, size: 16, color: AppColors.textSecondary),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      stop.address!,
                      style: AppTypography.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
            ],
            if (stop.reason != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(AppBorderRadius.sm),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.favorite_rounded, size: 16, color: AppColors.primary),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        stop.reason!,
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  void _showSpotBottomSheet(BuildContext context, SpotWithLocation spot) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppBorderRadius.xl),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CategoryBadge(
              label: spot.category ?? '장소',
              color: _getCategoryColor(spot.category),
              emoji: _getCategoryEmoji(spot.category),
            ),
            const SizedBox(height: 8),
            Text(spot.name, style: AppTypography.headlineSmall),
            if (spot.address != null) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.location_on_outlined, size: 16, color: AppColors.textSecondary),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      spot.address!,
                      style: AppTypography.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
            ],
            if (spot.tel != null && spot.tel!.isNotEmpty) ...[
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(Icons.phone_outlined, size: 16, color: AppColors.textSecondary),
                  const SizedBox(width: 4),
                  Text(
                    spot.tel!,
                    style: AppTypography.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (context, provider, _) {
        final spots = provider.recommendedSpots;

        final spotsWithCoords = spots.where((s) => s.hasLocation).toList();

        if (spotsWithCoords.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.map_rounded,
                  size: 80,
                  color: AppColors.textTertiary.withValues(alpha: 0.5),
                ),
                const SizedBox(height: 16),
                Text(
                  '지도 데이터가 없습니다',
                  style: AppTypography.titleMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          );
        }

        return Stack(
          children: [
            NaverMap(
              options: NaverMapViewOptions(
                initialCameraPosition: NCameraPosition(
                  target: _getInitialPosition(spotsWithCoords),
                  zoom: 12,
                ),
                mapType: NMapType.basic,
                activeLayerGroups: [
                  NLayerGroup.building,
                  NLayerGroup.traffic,
                ],
                rotationGesturesEnable: true,
                scrollGesturesEnable: true,
                tiltGesturesEnable: true,
                zoomGesturesEnable: true,
                stopGesturesEnable: true,
                consumeSymbolTapEvents: false,
                logoClickEnable: false,
              ),
              onMapReady: (controller) {
                _mapController = controller;
                _addMarkers(spotsWithCoords);
                // 코스 경로선 추가
                _addCourseRoute(provider.recommendedCourse);
              },
            ),
            // 장소 개수 표시
            Positioned(
              top: 16,
              left: 16,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(AppBorderRadius.full),
                  boxShadow: AppShadows.small,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.place_rounded, color: AppColors.primary, size: 18),
                    const SizedBox(width: 6),
                    Text(
                      '${spotsWithCoords.length}개 장소',
                      style: AppTypography.labelMedium.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // 확대/축소 버튼
            Positioned(
              top: 16,
              right: 16,
              child: Column(
                children: [
                  _ZoomButton(
                    icon: Icons.add,
                    onTap: () {
                      _mapController?.updateCamera(
                        NCameraUpdate.zoomIn(),
                      );
                    },
                  ),
                  const SizedBox(height: 8),
                  _ZoomButton(
                    icon: Icons.remove,
                    onTap: () {
                      _mapController?.updateCamera(
                        NCameraUpdate.zoomOut(),
                      );
                    },
                  ),
                ],
              ),
            ),
            // 장소 목록 버튼
            Positioned(
              bottom: 24,
              left: 16,
              right: 16,
              child: _SpotListChips(
                spots: spotsWithCoords,
                course: provider.recommendedCourse,
                onSpotTap: (spot) {
                  if (_mapController != null && spot.hasLocation) {
                    _mapController!.updateCamera(
                      NCameraUpdate.withParams(
                        target: NLatLng(spot.latitude!, spot.longitude!),
                        zoom: 15,
                      ),
                    );
                    _showSpotBottomSheet(context, spot);
                  }
                },
                onCourseStopTap: (stop) {
                  if (_mapController != null && stop.hasLocation) {
                    _mapController!.updateCamera(
                      NCameraUpdate.withParams(
                        target: NLatLng(stop.latitude!, stop.longitude!),
                        zoom: 15,
                      ),
                    );
                    _showCourseStopBottomSheet(context, stop);
                  }
                },
              ),
            ),
          ],
        );
      },
    );
  }
}

/// API 응답 SpotWithLocation용 하단 칩 목록
class _SpotListChips extends StatelessWidget {
  final List<SpotWithLocation> spots;
  final RecommendedCourse? course;
  final Function(SpotWithLocation) onSpotTap;
  final Function(CourseStop)? onCourseStopTap;

  const _SpotListChips({
    required this.spots,
    this.course,
    required this.onSpotTap,
    this.onCourseStopTap,
  });

  Color _getCategoryColor(String? category) {
    switch (category) {
      case '카페':
        return AppColors.cafe;
      case '음식점':
        return AppColors.restaurant;
      case '관광지':
        return AppColors.tourism;
      case '숙박':
        return AppColors.accentTeal;
      case '문화시설':
        return AppColors.culture;
      default:
        return AppColors.primary;
    }
  }

  String _getCategoryEmoji(String? category) {
    switch (category) {
      case '카페':
        return '☕';
      case '음식점':
        return '🍽️';
      case '관광지':
        return '🏞️';
      case '숙박':
        return '🏨';
      case '문화시설':
        return '🏛️';
      default:
        return '📍';
    }
  }

  @override
  Widget build(BuildContext context) {
    // 코스 정차지 (좌표 있는 것만, 순서대로)
    final courseStops = course?.stops
            .where((stop) => stop.hasLocation)
            .toList()
          ?..sort((a, b) => a.order.compareTo(b.order));
    final courseStopCount = courseStops?.length ?? 0;
    final totalCount = courseStopCount + spots.length;

    return SizedBox(
      height: 44,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: totalCount,
        itemBuilder: (context, index) {
          // 먼저 코스 정차지 표시
          if (index < courseStopCount) {
            final stop = courseStops![index];
            return GestureDetector(
              onTap: () => onCourseStopTap?.call(stop),
              child: Container(
                margin: EdgeInsets.only(right: index < totalCount - 1 ? 8 : 0),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: const Color(0xFF5BD936), // 코스 경로 색상과 동일
                  borderRadius: BorderRadius.circular(AppBorderRadius.full),
                  boxShadow: AppShadows.small,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 20,
                      height: 20,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          '${stop.order}',
                          style: AppTypography.labelSmall.copyWith(
                            color: const Color(0xFF5BD936),
                            fontWeight: FontWeight.bold,
                            fontSize: 11,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      stop.name,
                      style: AppTypography.labelSmall.copyWith(
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ).animate().fadeIn(
                  delay: Duration(milliseconds: 50 * index),
                  duration: 200.ms,
                ).slideX(begin: 0.2, end: 0);
          }

          // 그 다음 일반 장소 표시
          final spotIndex = index - courseStopCount;
          final spot = spots[spotIndex];
          return GestureDetector(
            onTap: () => onSpotTap(spot),
            child: Container(
              margin: EdgeInsets.only(right: index < totalCount - 1 ? 8 : 0),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(AppBorderRadius.full),
                boxShadow: AppShadows.small,
                border: Border.all(
                  color: _getCategoryColor(spot.category).withValues(alpha: 0.3),
                  width: 1.5,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _getCategoryEmoji(spot.category),
                    style: const TextStyle(fontSize: 14),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    spot.name,
                    style: AppTypography.labelSmall.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ).animate().fadeIn(
                delay: Duration(milliseconds: 50 * index),
                duration: 200.ms,
              ).slideX(begin: 0.2, end: 0);
        },
      ),
    );
  }
}

class _RailLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final railPaint = Paint()
      ..color = AppColors.primary.withOpacity(0.5)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    final tiePaint = Paint()
      ..color = AppColors.primary.withOpacity(0.3)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    // Draw main rails (two parallel lines)
    final double centerX = size.width / 2;
    final double railOffset = 6.0;

    canvas.drawLine(
      Offset(centerX - railOffset, 0),
      Offset(centerX - railOffset, size.height),
      railPaint,
    );

    canvas.drawLine(
      Offset(centerX + railOffset, 0),
      Offset(centerX + railOffset, size.height),
      railPaint,
    );

    // Draw cross ties (sleepers)
    final double tieSpacing = 12.0;
    final double tieWidth = 20.0;

    for (double y = 4; y < size.height; y += tieSpacing) {
      canvas.drawLine(
        Offset(centerX - tieWidth / 2, y),
        Offset(centerX + tieWidth / 2, y),
        tiePaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// 지도 확대/축소 버튼
class _ZoomButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _ZoomButton({
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: AppShadows.small,
        ),
        child: Icon(
          icon,
          color: AppColors.textPrimary,
          size: 22,
        ),
      ),
    );
  }
}
