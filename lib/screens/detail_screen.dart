import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../providers/restaurant_provider.dart';
import 'dart:ui';
import 'dart:async';

class DetailScreen extends StatefulWidget {
  const DetailScreen({super.key});

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _slideAnimation;
  final Completer<GoogleMapController> _mapController = Completer();
  Set<Marker> _markers = {};

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.2, 0.8, curve: Curves.easeOut),
      ),
    );

    _slideAnimation = Tween<double>(begin: 50, end: 0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.2, 0.8, curve: Curves.easeOut),
      ),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  // 電話をかける関数
  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri launchUri = Uri(scheme: 'tel', path: phoneNumber);
    await _launchUrl(launchUri);
  }

  // 地図アプリを開く関数
  Future<void> _openMap(
    double latitude,
    double longitude,
    String address,
  ) async {
    final url = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude',
    );
    await _launchUrl(url);
  }

  // URLを開く共通関数
  Future<void> _launchUrl(Uri url) async {
    try {
      if (!await launchUrl(url)) {
        throw Exception('Could not launch $url');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('アプリを起動できませんでした: $e'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final restaurant = ModalRoute.of(context)!.settings.arguments as Restaurant;
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;
    final textTheme = theme.textTheme;

    // マーカーの設定
    _markers = {
      Marker(
        markerId: MarkerId(restaurant.id),
        position: LatLng(restaurant.latitude, restaurant.longitude),
        infoWindow: InfoWindow(
          title: restaurant.name,
          snippet: restaurant.address,
        ),
      ),
    };

    return Scaffold(
      body: Stack(
        children: [
          // 背景画像
          SizedBox(
            height: size.height * 0.5,
            width: double.infinity,
            child: Hero(
              tag: 'restaurant_image_${restaurant.id}',
              child:
                  restaurant.imageUrl.isNotEmpty
                      ? CachedNetworkImage(
                        imageUrl: restaurant.imageUrl,
                        fit: BoxFit.cover,
                        placeholder:
                            (context, url) => Container(
                              color: theme.colorScheme.primary.withOpacity(0.2),
                              child: const Center(
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              ),
                            ),
                        errorWidget:
                            (context, url, error) => Container(
                              color: theme.colorScheme.primary,
                              child: const Center(
                                child: Icon(
                                  Icons.image_not_supported,
                                  color: Colors.white,
                                  size: 48,
                                ),
                              ),
                            ),
                      )
                      : Container(
                        color: theme.colorScheme.primary,
                        child: const Center(
                          child: Icon(
                            Icons.restaurant,
                            color: Colors.white,
                            size: 64,
                          ),
                        ),
                      ),
            ),
          ),

          // グラデーションオーバーレイ
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: size.height * 0.5,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.2),
                    Colors.black.withOpacity(0.5),
                  ],
                  stops: const [0.7, 1.0],
                ),
              ),
            ),
          ),

          // メインコンテンツ
          CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // AppBar
              SliverAppBar(
                expandedHeight: 120,
                backgroundColor: Colors.transparent,
                elevation: 0,
                pinned: true,
                stretch: true,
                flexibleSpace: ClipRect(
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                    child: Container(color: Colors.black.withOpacity(0.1)),
                  ),
                ),
                leading: IconButton(
                  icon: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.arrow_back, color: Colors.white),
                  ),
                  onPressed: () => Navigator.pop(context),
                ),
                actions: [
                  IconButton(
                    icon: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.share, color: Colors.white),
                    ),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('シェア機能は準備中です'),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                  ),
                  const SizedBox(width: 8),
                ],
              ),

              // 店舗名
              SliverToBoxAdapter(
                child: AnimatedBuilder(
                  animation: _animationController,
                  builder: (context, child) {
                    return Transform.translate(
                      offset: Offset(0, _slideAnimation.value),
                      child: Opacity(
                        opacity: _fadeAnimation.value,
                        child: child,
                      ),
                    );
                  },
                  child: Container(
                    padding: EdgeInsets.only(
                      top:
                          size.height * 0.4 -
                          120, // 背景画像の高さから最初のSliverAppBarの高さを引く
                      left: 24,
                      right: 24,
                      bottom: 20,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 店舗名
                        Text(
                          restaurant.name,
                          style: textTheme.headlineLarge?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            shadows: [
                              const Shadow(
                                offset: Offset(0, 1),
                                blurRadius: 3,
                                color: Colors.black54,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),
                        // アクセス
                        Row(
                          children: [
                            const Icon(
                              Icons.directions,
                              color: Colors.white,
                              size: 18,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                restaurant.access,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  shadows: [
                                    Shadow(
                                      offset: Offset(0, 1),
                                      blurRadius: 3,
                                      color: Colors.black54,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // 詳細情報
              SliverToBoxAdapter(
                child: AnimatedBuilder(
                  animation: _animationController,
                  builder: (context, child) {
                    return Transform.translate(
                      offset: Offset(0, _slideAnimation.value * 1.5),
                      child: Opacity(
                        opacity: _fadeAnimation.value,
                        child: child,
                      ),
                    );
                  },
                  child: Container(
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(32),
                        topRight: Radius.circular(32),
                      ),
                    ),
                    padding: const EdgeInsets.only(top: 24, bottom: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 詳細情報セクション
                        _buildInfoSection(
                          context,
                          icon: Icons.location_on,
                          title: '住所',
                          content: restaurant.address,
                          theme: theme,
                        ),
                        const SizedBox(height: 24),

                        _buildInfoSection(
                          context,
                          icon: Icons.access_time,
                          title: '営業時間',
                          content: restaurant.openTime,
                          theme: theme,
                        ),
                        const SizedBox(height: 30),

                        // 電話番号（あれば表示）
                        if (restaurant.tel.isNotEmpty) ...[
                          _buildInfoSection(
                            context,
                            icon: Icons.phone,
                            title: '電話番号',
                            content: restaurant.tel,
                            theme: theme,
                          ),
                          const SizedBox(height: 30),
                        ],

                        // 地図と位置情報
                        _buildMapSection(context, restaurant, theme),
                        const SizedBox(height: 30),

                        // アクションボタン
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: _buildActionButtons(
                            context,
                            restaurant,
                            theme,
                          ),
                        ),

                        const SizedBox(height: 48),

                        // フッター
                        const Center(
                          child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 24),
                            child: Text(
                              'Powered by ホットペッパー グルメ',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoSection(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String content,
    required ThemeData theme,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: theme.colorScheme.primary, size: 20),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey[200]!, width: 1),
            ),
            child: Text(
              content,
              style: const TextStyle(fontSize: 15, height: 1.5),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMapSection(
    BuildContext context,
    Restaurant restaurant,
    ThemeData theme,
  ) {
    final LatLng restaurantLocation = LatLng(
      restaurant.latitude,
      restaurant.longitude,
    );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.map,
                  color: theme.colorScheme.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                '地図',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            height: 200,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Stack(
                children: [
                  // Google Map
                  GoogleMap(
                    initialCameraPosition: CameraPosition(
                      target: restaurantLocation,
                      zoom: 16,
                    ),
                    markers: _markers,
                    onMapCreated: (GoogleMapController controller) {
                      _mapController.complete(controller);
                    },
                    myLocationEnabled: false,
                    myLocationButtonEnabled: false,
                    zoomControlsEnabled: false,
                    mapToolbarEnabled: false,
                  ),

                  // タップ検出用のInkWell
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap:
                          () => _openMap(
                            restaurant.latitude,
                            restaurant.longitude,
                            restaurant.address,
                          ),
                      splashColor: theme.colorScheme.primary.withOpacity(0.3),
                      highlightColor: theme.colorScheme.primary.withOpacity(
                        0.1,
                      ),
                      child: Container(),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(
    BuildContext context,
    Restaurant restaurant,
    ThemeData theme,
  ) {
    // 電話番号を常に「0000000000」に設定
    const String phoneNumber = "0000000000";

    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton.icon(
            onPressed:
                () => _openMap(
                  restaurant.latitude,
                  restaurant.longitude,
                  restaurant.address,
                ),
            icon: const Icon(Icons.map, size: 20),
            label: const Text(
              '地図で見る',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.colorScheme.primary,
              foregroundColor: Colors.white,
              elevation: 4,
              shadowColor: theme.colorScheme.primary.withOpacity(0.4),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
        ),

        // 電話ボタンを常に表示、常に「0000000000」を使用
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton.icon(
            onPressed: () => _makePhoneCall(phoneNumber),
            icon: const Icon(Icons.phone, size: 20),
            label: const Text(
              '電話をかける',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: theme.colorScheme.primary,
              elevation: 2,
              shadowColor: Colors.black.withOpacity(0.1),
              side: BorderSide(color: theme.colorScheme.primary, width: 2),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
