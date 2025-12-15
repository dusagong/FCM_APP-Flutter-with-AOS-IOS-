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

// 지도 탭 이동 및 포커싱 알림
class MoveToMapNotification extends Notification {
  final double latitude;
  final double longitude;
  final String? label;

  MoveToMapNotification({
    required this.latitude,
    required this.longitude,
    this.label,
  });
}

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
  NLatLng? _focusedTarget; // 지도 포커스 좌표

  @override
  void initState() {
    super.initState();
    debugPrint('🎬 [ACTION] MeetingPlatformScreen 진입 - ${widget.photoCard.city}');
    _tabController = TabController(length: 3, vsync: this);

    // 탭 변경 리스너 추가
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        final tabNames = ['추천코스', '전체장소', '지도'];
        debugPrint('🎬 [ACTION] 탭 전환: ${tabNames[_tabController.index]}');
      }
    });

    // preloadedResponse가 있으면 Provider에 설정하고 스탬프 생성
    if (widget.preloadedResponse != null) {
      debugPrint('🎬 [ACTION] 사전 로드된 추천 데이터 적용');
      debugPrint('🎬 [ACTION]   - spots: ${widget.preloadedResponse!.spots.length}개');
      debugPrint('🎬 [ACTION]   - course: ${widget.preloadedResponse!.course != null ? '있음' : '없음'}');

      WidgetsBinding.instance.addPostFrameCallback((_) {
        final provider = context.read<AppProvider>();
        provider.setRecommendationResponse(widget.preloadedResponse!);

        // 코스가 있으면 스탬프 자동 생성
        final course = widget.preloadedResponse!.course;
        if (course != null) {
          debugPrint('🎬 [ACTION] 스탬프 자동 생성 - ${course.stops.length}개 정차지');
          provider.createCourseStamp(
            photoCardId: widget.photoCard.id,
            course: course,
            province: widget.photoCard.province,
            city: widget.photoCard.city,
          );
        }
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
      body: NotificationListener<MoveToMapNotification>(
        onNotification: (notification) {
          setState(() {
            _focusedTarget = NLatLng(notification.latitude, notification.longitude);
          });
          _tabController.animateTo(2); // 지도 탭으로 이동
          return true;
        },
        child: TabBarView(
          controller: _tabController,
          physics: const NeverScrollableScrollPhysics(),
          children: [
            _CourseView(photoCard: widget.photoCard),
            _AllPlacesView(photoCard: widget.photoCard),
            _MapView(
              photoCard: widget.photoCard,
              focusedTarget: _focusedTarget,
            ),
          ],
        ),
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
                if (course.totalDuration != null || course.totalDistanceKm != null) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      if (course.totalDuration != null) ...[
                        const Icon(Icons.schedule_rounded, color: Colors.white70, size: 16),
                        const SizedBox(width: 4),
                        Text(
                          course.totalDuration!,
                          style: AppTypography.bodySmall.copyWith(color: Colors.white70),
                        ),
                      ],
                      if (course.totalDuration != null && course.totalDistanceKm != null)
                        const SizedBox(width: 12),
                      if (course.totalDistanceKm != null) ...[
                        const Icon(Icons.straighten_rounded, color: Colors.white70, size: 16),
                        const SizedBox(width: 4),
                        Text(
                          '총 ${course.totalDistanceKm!.toStringAsFixed(1)}km',
                          style: AppTypography.bodySmall.copyWith(color: Colors.white70),
                        ),
                      ],
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
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Timeline - 고정 너비로 일관된 정렬 유지 (이동시간 배지 포함)
            SizedBox(
              width: 70,
              child: Column(
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
                  Expanded(
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        const _RailTrackVertical(),
                        if (!isLast && stop.travelTimeToNext != null)
                          Container(
                            color: AppColors.background,
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: _TravelTimeBadge(
                              travelTime: stop.travelTimeToNext!,
                              distanceKm: stop.distanceToNextKm,
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
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
                    // 리뷰보기/쿠폰받기 버튼
                    const SizedBox(height: 12),
                    _CourseStopActionButtons(stop: stop),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 코스 정차지용 액션 버튼
class _CourseStopActionButtons extends StatelessWidget {
  final CourseStop stop;

  const _CourseStopActionButtons({required this.stop});

  void _showCouponReceivedModal(BuildContext context, String placeName) {
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
              Text(
                '쿠폰을 받았습니다!',
                style: AppTypography.headlineSmall.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppBorderRadius.md),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.store_rounded, color: AppColors.primary, size: 20),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        placeName,
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
              Text(
                '쿠폰함에서 확인하고\n매장에서 사용해보세요!',
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        side: BorderSide(color: AppColors.primary.withValues(alpha: 0.5)),
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
                          MaterialPageRoute(builder: (_) => const CouponScreen()),
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

  void _showStampEarnedModal(BuildContext context, String placeName) {
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
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: const Color(0xFF9C27B0).withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.approval_rounded,
                  color: Color(0xFF9C27B0),
                  size: 40,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                '스탬프가 적립되었습니다!',
                style: AppTypography.headlineSmall.copyWith(
                  color: const Color(0xFF9C27B0),
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: const Color(0xFF9C27B0).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppBorderRadius.md),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.location_on_rounded, color: Color(0xFF9C27B0), size: 20),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        placeName,
                        style: AppTypography.titleMedium.copyWith(
                          color: const Color(0xFF9C27B0),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '리뷰 작성 완료!',
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF9C27B0),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppBorderRadius.md),
                    ),
                    elevation: 0,
                  ),
                  child: const Text('확인'),
                ),
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
        final hasCoupon = provider.hasCouponByName(stop.name);
        // 관광지만 제외하고 쿠폰받기 가능
        final hasCouponCategory = stop.category != '관광지';

        return Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            // 1. 쿠폰받기 (관광지 제외) 또는 리뷰작성 (관광지)
            if (hasCouponCategory)
              _ActionButton(
                label: hasCoupon ? '쿠폰받음' : '쿠폰받기',
                icon: hasCoupon ? Icons.check_circle : Icons.local_offer_outlined,
                isPrimary: !hasCoupon,
                isDisabled: hasCoupon,
                onTap: hasCoupon
                    ? null
                    : () {
                        debugPrint('🎬 [ACTION] 쿠폰받기 클릭 - ${stop.name}');
                        provider.addCouponByName(stop.name, stop.category ?? '장소');
                        provider.updateStampCouponProgress(stop.name);
                        _showCouponReceivedModal(context, stop.name);
                      },
              )
            else
              _ActionButton(
                label: '리뷰작성',
                icon: Icons.edit_outlined,
                isPrimary: true,
                onTap: () async {
                  debugPrint('🎬 [ACTION] 리뷰작성 클릭 - ${stop.name}');
                  final result = await Navigator.push<bool>(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ReviewWriteScreen(
                        placeName: stop.name,
                        placeCategory: stop.category,
                      ),
                    ),
                  );
                  if (result == true && context.mounted) {
                    debugPrint('🎬 [ACTION] 리뷰 작성 완료 - ${stop.name}');
                    context.read<AppProvider>().updateStampReviewProgress(stop.name);
                    _showStampEarnedModal(context, stop.name);
                  }
                },
              ),
            // 2. 리뷰보기
            _ActionButton(
              label: '리뷰보기',
              icon: Icons.rate_review_outlined,
              onTap: () {
                debugPrint('🎬 [ACTION] 리뷰보기 클릭 - ${stop.name}');
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ReviewListScreen(
                      placeName: stop.name,
                      placeCategory: stop.category,
                    ),
                  ),
                );
              },
            ),
            // 3. 지도 보기 버튼 (좌표 정보가 있을 때만)
            if (stop.hasLocation)
              _ActionButton(
                label: '지도',
                icon: Icons.map_outlined,
                onTap: () {
                  debugPrint('🎬 [ACTION] 지도보기 클릭 - ${stop.name} (${stop.latitude}, ${stop.longitude})');
                  MoveToMapNotification(
                    latitude: stop.latitude!,
                    longitude: stop.longitude!,
                    label: stop.name,
                  ).dispatch(context);
                },
              ),
          ],
        );
      },
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
                  // Review Count
                  Row(
                    children: [
                      const Icon(Icons.rate_review_rounded, size: 14, color: AppColors.textTertiary),
                      const SizedBox(width: 4),
                      Text(
                        '리뷰 ${place.reviewCount}개',
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
                        side: BorderSide(color: AppColors.primary.withValues(alpha: 0.5)),
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
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
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
              size: 12,
              color: isDisabled
                  ? AppColors.textTertiary
                  : isPrimary
                      ? Colors.white
                      : AppColors.textSecondary,
            ),
            const SizedBox(width: 3),
            Text(
              label,
              style: AppTypography.labelSmall.copyWith(
                color: isDisabled
                    ? AppColors.textTertiary
                    : isPrimary
                        ? Colors.white
                        : AppColors.textSecondary,
                fontWeight: FontWeight.w600,
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 이동시간 표시 배지 (타임라인에서 정차지 사이에 표시)
class _TravelTimeBadge extends StatelessWidget {
  final String travelTime;
  final double? distanceKm;

  const _TravelTimeBadge({
    required this.travelTime,
    this.distanceKm,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.info.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppBorderRadius.sm),
        border: Border.all(
          color: AppColors.info.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 이동시간
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.directions_car_rounded,
                size: 12,
                color: AppColors.info,
              ),
              const SizedBox(width: 4),
              Text(
                travelTime,
                style: AppTypography.labelSmall.copyWith(
                  color: AppColors.info,
                  fontWeight: FontWeight.w600,
                  fontSize: 10,
                ),
              ),
            ],
          ),
          // 거리 (있을 때만)
          if (distanceKm != null) ...[
            const SizedBox(height: 2),
            Text(
              '${distanceKm!.toStringAsFixed(1)}km',
              style: AppTypography.labelSmall.copyWith(
                color: AppColors.info.withValues(alpha: 0.7),
                fontWeight: FontWeight.w500,
                fontSize: 9,
              ),
            ),
          ],
        ],
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
                // 리뷰보기/쿠폰받기 버튼
                const SizedBox(height: 12),
                _SpotActionButtons(spot: spot),
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

/// 전체 목록 장소용 액션 버튼
class _SpotActionButtons extends StatelessWidget {
  final SpotWithLocation spot;

  const _SpotActionButtons({required this.spot});

  void _showCouponReceivedModal(BuildContext context, String placeName) {
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
              Text(
                '쿠폰을 받았습니다!',
                style: AppTypography.headlineSmall.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppBorderRadius.md),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.store_rounded, color: AppColors.primary, size: 20),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        placeName,
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
              Text(
                '쿠폰함에서 확인하고\n매장에서 사용해보세요!',
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        side: BorderSide(color: AppColors.primary.withValues(alpha: 0.5)),
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
                          MaterialPageRoute(builder: (_) => const CouponScreen()),
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

  void _showStampEarnedModal(BuildContext context, String placeName) {
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
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: const Color(0xFF9C27B0).withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.approval_rounded,
                  color: Color(0xFF9C27B0),
                  size: 40,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                '스탬프가 적립되었습니다!',
                style: AppTypography.headlineSmall.copyWith(
                  color: const Color(0xFF9C27B0),
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: const Color(0xFF9C27B0).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppBorderRadius.md),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.location_on_rounded, color: Color(0xFF9C27B0), size: 20),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        placeName,
                        style: AppTypography.titleMedium.copyWith(
                          color: const Color(0xFF9C27B0),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '리뷰 작성 완료!',
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF9C27B0),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppBorderRadius.md),
                    ),
                    elevation: 0,
                  ),
                  child: const Text('확인'),
                ),
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
        final hasCoupon = provider.hasCouponByName(spot.name);
        // 관광지만 제외하고 쿠폰받기 가능
        final hasCouponCategory = spot.category != '관광지';

        return Row(
          children: [
            // 1. 쿠폰받기 (관광지 제외) 또는 리뷰작성 (관광지)
            if (hasCouponCategory)
              _ActionButton(
                label: hasCoupon ? '쿠폰받음' : '쿠폰받기',
                icon: hasCoupon ? Icons.check_circle : Icons.local_offer_outlined,
                isPrimary: !hasCoupon,
                isDisabled: hasCoupon,
                onTap: hasCoupon
                    ? null
                    : () {
                        provider.addCouponByName(spot.name, spot.category ?? '장소');
                        provider.updateStampCouponProgress(spot.name);
                        _showCouponReceivedModal(context, spot.name);
                      },
              )
            else
              _ActionButton(
                label: '리뷰작성',
                icon: Icons.edit_outlined,
                isPrimary: true,
                onTap: () async {
                  final result = await Navigator.push<bool>(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ReviewWriteScreen(
                        placeName: spot.name,
                        placeCategory: spot.category,
                      ),
                    ),
                  );
                  if (result == true && context.mounted) {
                    context.read<AppProvider>().updateStampReviewProgress(spot.name);
                    _showStampEarnedModal(context, spot.name);
                  }
                },
              ),
            const SizedBox(width: 8),
            // 2. 리뷰보기
            _ActionButton(
              label: '리뷰보기',
              icon: Icons.rate_review_outlined,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ReviewListScreen(
                      placeName: spot.name,
                      placeCategory: spot.category,
                    ),
                  ),
                );
              },
            ),
            // 3. 지도 보기 버튼 (좌표 정보가 있을 때만)
            if (spot.hasLocation) ...[
              const SizedBox(width: 8),
              _ActionButton(
                label: '지도',
                icon: Icons.map_outlined,
                onTap: () {
                  MoveToMapNotification(
                    latitude: spot.latitude!,
                    longitude: spot.longitude!,
                    label: spot.name,
                  ).dispatch(context);
                },
              ),
            ],
          ],
        );
      },
    );
  }
}

// Map View with NaverMap - API 추천 장소 사용
class _MapView extends StatefulWidget {
  final PhotoCard photoCard;
  final NLatLng? focusedTarget;

  const _MapView({
    required this.photoCard,
    this.focusedTarget,
  });

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

  @override
  void didUpdateWidget(_MapView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.focusedTarget != null &&
        widget.focusedTarget != oldWidget.focusedTarget &&
        _mapController != null) {
      _moveCamera(widget.focusedTarget!);
    }
  }

  void _moveCamera(NLatLng target) {
    final cameraUpdate = NCameraUpdate.withParams(
      target: target,
      zoom: 16,
    );
    cameraUpdate.setAnimation(animation: NCameraAnimation.fly, duration: const Duration(milliseconds: 1500));
    _mapController!.updateCamera(cameraUpdate);
  }

  NLatLng _getInitialPosition(List<SpotWithLocation> spots) {
    // 포커스 타겟이 있으면 거기로
    if (widget.focusedTarget != null) {
      return widget.focusedTarget!;
    }

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

  void _addMarkers(List<SpotWithLocation> spots, {RecommendedCourse? course}) async {
    if (_mapController == null) return;

    // 코스에 포함된 장소 이름 목록 (제외 대상)
    final courseStopNames = course?.stops.map((s) => s.name).toSet() ?? <String>{};

    final markers = <NMarker>[];

    for (int i = 0; i < spots.length; i++) {
      final spot = spots[i];

      // 코스에 포함된 장소는 스킵 (코스 마커로 대체됨)
      if (courseStopNames.contains(spot.name)) continue;

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

    // 점선 경로 (파란색으로 통일)
    const blueColor = Color(0xFF2196F3);
    final polyline = NPolylineOverlay(
      id: 'course_route',
      coords: coords,
      color: blueColor,
      width: 4,
      lineCap: NLineCap.round,
      lineJoin: NLineJoin.round,
      pattern: [10, 6], // 점선 패턴
    );
    await _mapController!.addOverlay(polyline);

    // 🔴 구간별 거리 라벨 추가 (점선 위에 거리 표시)
    debugPrint('[MAP] Adding distance labels for ${stopsWithLocation.length} stops');
    for (int i = 0; i < stopsWithLocation.length - 1; i++) {
      if (!mounted) return;
      final currentStop = stopsWithLocation[i];
      final nextStop = stopsWithLocation[i + 1];

      debugPrint('[MAP] Stop $i: ${currentStop.name}, distanceToNextKm: ${currentStop.distanceToNextKm}');

      // 거리 정보가 있는 경우에만 표시
      if (currentStop.distanceToNextKm != null) {
        // 두 지점의 중간점 계산
        final midLat = (currentStop.latitude! + nextStop.latitude!) / 2;
        final midLng = (currentStop.longitude! + nextStop.longitude!) / 2;

        final distanceText = '${currentStop.distanceToNextKm!.toStringAsFixed(1)}km';

        // 거리 라벨 아이콘 생성
        final distanceIcon = await NOverlayImage.fromWidget(
          widget: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: blueColor, width: 1.5),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 4,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Text(
              distanceText,
              style: const TextStyle(
                color: Color(0xFF2196F3),
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          size: const Size(60, 24),
          context: context,
        );

        if (!mounted) return;

        final distanceMarker = NMarker(
          id: 'distance_${i}_${i + 1}',
          position: NLatLng(midLat, midLng),
          icon: distanceIcon,
        );

        await _mapController!.addOverlay(distanceMarker);
        debugPrint('[MAP] Added distance marker: $distanceText at ($midLat, $midLng)');
      } else {
        debugPrint('[MAP] Skip distance marker for stop $i: distanceToNextKm is null');
      }
    }

    // 코스 마커 추가 (파란색으로 구분)
    final courseMarkers = <NMarker>[];

    for (int i = 0; i < stopsWithLocation.length; i++) {
      if (!mounted) return;
      final stop = stopsWithLocation[i];

      // 보라색 마커 아이콘 생성
      final icon = await NOverlayImage.fromWidget(
        widget: Container(
          width: 36,
          height: 36,
          decoration: const BoxDecoration(
            color: blueColor,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 4,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Center(
            child: Text(
              '${stop.order}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        size: const Size(36, 36),
        context: context,
      );

      if (!mounted) return;

      final marker = NMarker(
        id: 'course_${stop.order}',
        position: NLatLng(stop.latitude!, stop.longitude!),
        icon: icon,
        caption: NOverlayCaption(
          text: stop.name,
          textSize: 12,
          color: blueColor,
          haloColor: Colors.white,
        ),
      );

      marker.setOnTapListener((overlay) {
        _showCourseStopBottomSheet(context, stop);
      });

      courseMarkers.add(marker);
    }

    if (!mounted) return;
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
                // 코스 경로선 및 마커 추가 (먼저 추가해야 일반 마커에서 제외 가능)
                _addCourseRoute(provider.recommendedCourse);
                // 일반 마커 추가 (코스 장소 제외)
                _addMarkers(spotsWithCoords, course: provider.recommendedCourse);
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

class _RailTrackVertical extends StatelessWidget {
  final double? height;
  
  const _RailTrackVertical({this.height});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 14,
      height: height ?? double.infinity,
      child: CustomPaint(
        painter: _RailTrackPainter(color: AppColors.border),
      ),
    );
  }
}

class _RailTrackPainter extends CustomPainter {
  final Color color;
  
  _RailTrackPainter({this.color = const Color(0xFFE0E0E0)});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    // Defines
    const double railWidth = 2.0;
    // const double trackWidth = 14.0; // Implicit from size.width
    const double sleeperHeight = 2.0;
    const double sleeperSpacing = 4.0; // Denser sleepers

    // Draw Left Rail
    canvas.drawRect(Rect.fromLTWH(0, 0, railWidth, size.height), paint);

    // Draw Right Rail
    canvas.drawRect(Rect.fromLTWH(size.width - railWidth, 0, railWidth, size.height), paint);

    // Draw Sleepers (Ties)
    double y = 2.0;
    while (y < size.height) {
      canvas.drawRect(Rect.fromLTWH(0, y, size.width, sleeperHeight), paint);
      y += sleeperSpacing + sleeperHeight;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
