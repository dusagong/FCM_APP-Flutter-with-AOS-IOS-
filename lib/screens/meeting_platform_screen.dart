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

  const MeetingPlatformScreen({
    super.key,
    required this.photoCard,
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
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(AppBorderRadius.full),
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(AppBorderRadius.full),
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent,
        labelColor: Colors.white,
        unselectedLabelColor: AppColors.textSecondary,
        labelStyle: AppTypography.labelMedium.copyWith(fontWeight: FontWeight.w600),
        tabs: const [
          Tab(text: '코스'),
          Tab(text: '전체'),
          Tab(text: '지도'),
        ],
      ),
    );
  }
}

// Course View - Time-based courses
class _CourseView extends StatelessWidget {
  final PhotoCard photoCard;

  const _CourseView({required this.photoCard});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (context, provider, _) {
        final courses = provider.generateCourses(
          photoCard.province,
          photoCard.city,
        );

        if (courses.isEmpty) {
          return const EmptyState(
            icon: Icons.map_rounded,
            title: '추천 코스가 없습니다',
            subtitle: '해당 지역의 장소 정보가 준비 중입니다',
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: courses.length,
          itemBuilder: (context, index) {
            return _CourseCard(
              course: courses[index],
              index: index,
            );
          },
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
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Timeline
          Column(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    '$index',
                    style: AppTypography.labelSmall.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              if (!isLast)
                Container(
                  width: 2,
                  height: 80,
                  color: AppColors.border,
                ),
            ],
          ),
          const SizedBox(width: 12),
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
              // Success icon - 녹색 테마
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: AppColors.secondary.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.card_giftcard_rounded,
                  color: AppColors.secondary,
                  size: 40,
                ),
              ),
              const SizedBox(height: 20),
              // Title
              Text(
                '쿠폰을 받았습니다!',
                style: AppTypography.headlineSmall.copyWith(
                  color: AppColors.secondary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              // Place name
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: AppColors.secondary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppBorderRadius.md),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.store_rounded,
                      color: AppColors.secondary,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        place.name,
                        style: AppTypography.titleMedium.copyWith(
                          color: AppColors.secondaryDark,
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
                        side: const BorderSide(color: AppColors.secondary),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppBorderRadius.md),
                        ),
                      ),
                      child: Text('닫기', style: TextStyle(color: AppColors.secondary)),
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
                        backgroundColor: AppColors.secondary,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppBorderRadius.md),
                        ),
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

// All Places View
class _AllPlacesView extends StatelessWidget {
  final PhotoCard photoCard;

  const _AllPlacesView({required this.photoCard});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (context, provider, _) {
        final places = provider.getPlacesByDestination(
          photoCard.province,
          photoCard.city,
        );

        if (places.isEmpty) {
          return const EmptyState(
            icon: Icons.store_rounded,
            title: '등록된 장소가 없습니다',
            subtitle: '해당 지역의 장소 정보가 준비 중입니다',
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: places.length,
          itemBuilder: (context, index) {
            return _PlaceCard(
              place: places[index],
              index: index,
            );
          },
        );
      },
    );
  }
}

class _PlaceCard extends StatelessWidget {
  final Place place;
  final int index;

  const _PlaceCard({
    required this.place,
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
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image
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
                place.imageUrl,
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
                  label: place.category.label,
                  color: _getCategoryColor(place.category),
                  emoji: place.category.emoji,
                ),
                const SizedBox(height: 8),
                // Name
                Text(place.name, style: AppTypography.titleLarge),
                const SizedBox(height: 4),
                // Rating
                Row(
                  children: [
                    RatingStars(rating: place.rating, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      '${place.rating}',
                      style: AppTypography.labelMedium.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      ' (${place.reviewCount}개 리뷰)',
                      style: AppTypography.bodySmall,
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                // Description
                Text(
                  place.description,
                  style: AppTypography.bodyMedium,
                ),
                const SizedBox(height: 16),
                // Actions
                _PlaceActionButtons(place: place),
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

// Map View with NaverMap
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

  NLatLng _getInitialPosition(List<Place> places) {
    // 장소 목록에서 좌표가 있는 첫 번째 장소의 위치를 기준으로 함
    for (final place in places) {
      if (place.latitude != null && place.longitude != null) {
        return NLatLng(place.latitude!, place.longitude!);
      }
    }
    // 기본값: 강릉시 중심
    return const NLatLng(37.7519, 128.8760);
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

  void _addMarkers(List<Place> places) async {
    if (_mapController == null) return;

    final markers = <NMarker>[];

    for (final place in places) {
      if (place.latitude != null && place.longitude != null) {
        final marker = NMarker(
          id: place.id,
          position: NLatLng(place.latitude!, place.longitude!),
        );

        marker.setOnTapListener((overlay) {
          _showPlaceBottomSheet(context, place);
        });

        markers.add(marker);
      }
    }

    await _mapController!.addOverlayAll(markers.toSet());
  }

  void _showPlaceBottomSheet(BuildContext context, Place place) {
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
              label: place.category.label,
              color: _getCategoryColor(place.category),
              emoji: place.category.emoji,
            ),
            const SizedBox(height: 8),
            Text(place.name, style: AppTypography.headlineSmall),
            const SizedBox(height: 4),
            Row(
              children: [
                RatingStars(rating: place.rating, size: 16),
                const SizedBox(width: 8),
                Text('${place.rating} (${place.reviewCount}개 리뷰)'),
              ],
            ),
            const SizedBox(height: 8),
            Text(place.description, style: AppTypography.bodyMedium),
            const SizedBox(height: 16),
            _PlaceActionButtons(place: place),
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
        final places = provider.getPlacesByDestination(
          widget.photoCard.province,
          widget.photoCard.city,
        );

        final placesWithCoords = places.where(
          (p) => p.latitude != null && p.longitude != null
        ).toList();

        if (placesWithCoords.isEmpty) {
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
                  target: _getInitialPosition(placesWithCoords),
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
                logoClickEnable: false,
              ),
              onMapReady: (controller) {
                _mapController = controller;
                _addMarkers(placesWithCoords);
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
                      '${placesWithCoords.length}개 장소',
                      style: AppTypography.labelMedium.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // 장소 목록 버튼
            Positioned(
              bottom: 24,
              left: 16,
              right: 16,
              child: _PlaceListChips(
                places: placesWithCoords,
                onPlaceTap: (place) {
                  if (_mapController != null && place.latitude != null && place.longitude != null) {
                    _mapController!.updateCamera(
                      NCameraUpdate.withParams(
                        target: NLatLng(place.latitude!, place.longitude!),
                        zoom: 15,
                      ),
                    );
                    _showPlaceBottomSheet(context, place);
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

class _PlaceListChips extends StatelessWidget {
  final List<Place> places;
  final Function(Place) onPlaceTap;

  const _PlaceListChips({
    required this.places,
    required this.onPlaceTap,
  });

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

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: places.length,
        itemBuilder: (context, index) {
          final place = places[index];
          return GestureDetector(
            onTap: () => onPlaceTap(place),
            child: Container(
              margin: EdgeInsets.only(right: index < places.length - 1 ? 8 : 0),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(AppBorderRadius.full),
                boxShadow: AppShadows.small,
                border: Border.all(
                  color: _getCategoryColor(place.category).withValues(alpha: 0.3),
                  width: 1.5,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    place.category.emoji,
                    style: const TextStyle(fontSize: 14),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    place.name,
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
