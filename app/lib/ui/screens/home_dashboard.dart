import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../core/constants.dart';
import '../../services/battery_optimization_service.dart';
import 'room_upload_screen.dart';
import 'saved_screen.dart';
import 'profile_screen.dart';

class HomeDashboard extends StatefulWidget {
  const HomeDashboard({super.key});

  @override
  State<HomeDashboard> createState() => _HomeDashboardState();
}

class _HomeDashboardState extends State<HomeDashboard> with TickerProviderStateMixin {
  int _currentIndex = 0;
  late AnimationController _bannerController;
  late Animation<double> _bannerFade;
  late Animation<Offset> _bannerSlide;

  @override
  void initState() {
    super.initState();
    
    // Check and prompt for battery optimization whitelist
    WidgetsBinding.instance.addPostFrameCallback((_) {
      BatteryOptimizationService.promptIfNeeded(context);
    });

    _bannerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _bannerFade = CurvedAnimation(parent: _bannerController, curve: Curves.easeOut);
    _bannerSlide = Tween<Offset>(begin: const Offset(0, 0.12), end: Offset.zero)
        .animate(CurvedAnimation(parent: _bannerController, curve: Curves.easeOut));
    _bannerController.forward();
  }

  @override
  void dispose() {
    _bannerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: IndexedStack(
        index: _currentIndex,
        children: [
          _buildHomeBody(context),
          const SavedScreen(),
          const ProfileScreen(),
        ],
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: AppColors.divider.withValues(alpha: 0.5), width: 0.5),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (i) => setState(() => _currentIndex = i),
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.transparent,
        elevation: 0,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.tertiaryText,
        selectedLabelStyle: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 11),
        unselectedLabelStyle: GoogleFonts.inter(fontSize: 11),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home_rounded),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite_outline_rounded),
            activeIcon: Icon(Icons.favorite_rounded),
            label: 'Saved',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline_rounded),
            activeIcon: Icon(Icons.person_rounded),
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  Widget _buildHomeBody(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final firstName = (user?.displayName ?? 'there').split(' ').first;

    return SafeArea(
      child: CustomScrollView(
        slivers: [
          // ── Sticky Top Bar ──────────────────────
          SliverAppBar(
            pinned: true,
            floating: true,
            backgroundColor: AppColors.background,
            elevation: 0,
            scrolledUnderElevation: 1,
            shadowColor: Colors.black.withValues(alpha: 0.06),
            titleSpacing: 24,
            toolbarHeight: 64,
            title: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _getGreeting(),
                        style: GoogleFonts.inter(
                            color: AppColors.secondaryText,
                            fontSize: 12,
                            fontWeight: FontWeight.w400),
                      ),
                      Text(
                        firstName,
                        style: GoogleFonts.playfairDisplay(
                            color: AppColors.primaryText,
                            fontSize: 20,
                            fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
                ),
                // Notification bell
                GestureDetector(
                  onTap: () {},
                  child: Container(
                    width: 42, height: 42,
                    margin: const EdgeInsets.only(right: 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(13),
                      border: Border.all(color: AppColors.divider, width: 0.5),
                    ),
                    child: const Icon(Icons.notifications_none_rounded,
                        color: AppColors.primaryText, size: 20),
                  ),
                ),
              ],
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Hero Banner ─────────────────────────
                  FadeTransition(
                    opacity: _bannerFade,
                    child: SlideTransition(
                      position: _bannerSlide,
                      child: _buildHeroBanner(context),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // ── Section: Discover ──────────────────
                  _sectionHeader('Discover'),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _buildFeatureCard(
                          context,
                          icon: Icons.auto_awesome_rounded,
                          label: 'AI Analysis',
                          sublabel: 'Upload & style',
                          color: AppColors.primary,
                          onTap: () => Navigator.push(context,
                              MaterialPageRoute(builder: (_) => const RoomUploadScreen())),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildFeatureCard(
                          context,
                          icon: Icons.view_in_ar_rounded,
                          label: 'AR Preview',
                          sublabel: 'Try in space',
                          color: const Color(0xFF6366F1),
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: const Text('Analyze a room first to access AR Preview'),
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _buildFeatureCard(
                          context,
                          icon: Icons.palette_rounded,
                          label: 'Color Match',
                          sublabel: 'Find harmony',
                          color: AppColors.accent,
                          onTap: () => Navigator.push(context,
                              MaterialPageRoute(builder: (_) => const RoomUploadScreen())),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildFeatureCard(
                          context,
                          icon: Icons.favorite_rounded,
                          label: 'Saved Items',
                          sublabel: 'Your wishlist',
                          color: const Color(0xFFEC4899),
                          onTap: () => Navigator.push(context,
                              MaterialPageRoute(builder: (_) => const SavedScreen())),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),

                  // ── Section: How It Works ──────────────
                  _sectionHeader('How It Works'),
                  const SizedBox(height: 16),
                  _buildStepCard(
                    step: '01',
                    title: 'Photograph Your Room',
                    description: 'Take or upload a clear photo of any room in your home.',
                    icon: Icons.camera_alt_rounded,
                  ),
                  const SizedBox(height: 12),
                  _buildStepCard(
                    step: '02',
                    title: 'AI Analyzes the Style',
                    description: 'Our trained model identifies your decor style, color palette, and existing furniture.',
                    icon: Icons.psychology_rounded,
                  ),
                  const SizedBox(height: 12),
                  _buildStepCard(
                    step: '03',
                    title: 'Get Recommendations',
                    description: 'Browse curated 3D products that perfectly match your aesthetic.',
                    icon: Icons.auto_awesome_rounded,
                  ),
                  const SizedBox(height: 12),
                  _buildStepCard(
                    step: '04',
                    title: 'Preview in AR',
                    description: 'Place any item in your real room using Augmented Reality before buying.',
                    icon: Icons.view_in_ar_rounded,
                  ),
                  const SizedBox(height: 32),

                  // ── Section: Style Inspiration ─────────
                  _sectionHeader('Style Inspiration'),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 120,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: [
                        _buildStyleChip('Minimalist', const Color(0xFF78909C)),
                        _buildStyleChip('Bohemian', const Color(0xFFAD6F3B)),
                        _buildStyleChip('Scandinavian', const Color(0xFF5D8A66)),
                        _buildStyleChip('Industrial', const Color(0xFF607D8B)),
                        _buildStyleChip('Modern', const Color(0xFF7E57C2)),
                      ],
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

  // ── Hero Banner ─────────────────────────────────────────────────────────────

  Widget _buildHeroBanner(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const RoomUploadScreen()),
      ),
      child: Container(
        width: double.infinity,
        height: 200,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: const LinearGradient(
            colors: [Color(0xFF1B5E5F), Color(0xFF0E3D3E), Color(0xFF0A2C2D)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.35),
              blurRadius: 28,
              offset: const Offset(0, 14),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Decorative circles
            Positioned(
              right: -20, top: -20,
              child: Container(
                width: 160, height: 160,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.04),
                ),
              ),
            ),
            Positioned(
              right: 30, bottom: -40,
              child: Container(
                width: 120, height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.accent.withValues(alpha: 0.08),
                ),
              ),
            ),
            // Content
            Padding(
              padding: const EdgeInsets.all(28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: AppColors.accent.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                              color: AppColors.accent.withValues(alpha: 0.3), width: 0.5),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.auto_awesome, color: AppColors.accentLight, size: 12),
                            const SizedBox(width: 5),
                            Text('AI-Powered',
                                style: GoogleFonts.inter(
                                    color: AppColors.accentLight,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 0.4)),
                          ],
                        ),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Transform Your\nLiving Space',
                          style: GoogleFonts.playfairDisplay(
                              color: Colors.white,
                              fontSize: 26,
                              fontWeight: FontWeight.w700,
                              height: 1.1)),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text('Analyze a Room',
                                    style: GoogleFonts.inter(
                                        color: AppColors.primary,
                                        fontWeight: FontWeight.w700,
                                        fontSize: 13)),
                                const SizedBox(width: 6),
                                const Icon(Icons.arrow_forward_rounded,
                                    color: AppColors.primary, size: 16),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Feature Cards ────────────────────────────────────────────────────────────

  Widget _buildFeatureCard(BuildContext context,
      {required IconData icon,
      required String label,
      required String sublabel,
      required Color color,
      required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 1.0, end: 1.0),
        duration: const Duration(milliseconds: 150),
        builder: (_, scale, child) => Transform.scale(scale: scale, child: child),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.divider, width: 0.5),
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.06),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44, height: 44,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Icon(icon, color: color, size: 22),
              ),
              const SizedBox(height: 14),
              Text(label,
                  style: GoogleFonts.inter(
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                      color: AppColors.primaryText)),
              const SizedBox(height: 2),
              Text(sublabel,
                  style: GoogleFonts.inter(
                      fontSize: 11,
                      color: AppColors.secondaryText)),
            ],
          ),
        ),
      ),
    );
  }

  // ── Step Card ────────────────────────────────────────────────────────────────

  Widget _buildStepCard(
      {required String step, required String title, required String description, required IconData icon}) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.divider, width: 0.5),
      ),
      child: Row(
        children: [
          Column(
            children: [
              Container(
                width: 48, height: 48,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: AppColors.primary, size: 22),
              ),
              const SizedBox(height: 6),
              Text(step,
                  style: GoogleFonts.inter(
                      color: AppColors.tertiaryText,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5)),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: GoogleFonts.inter(
                        fontWeight: FontWeight.w700, fontSize: 14, color: AppColors.primaryText)),
                const SizedBox(height: 4),
                Text(description,
                    style: GoogleFonts.inter(
                        color: AppColors.secondaryText, fontSize: 12, height: 1.45)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Style Chips ──────────────────────────────────────────────────────────────

  Widget _buildStyleChip(String name, Color color) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const RoomUploadScreen()),
      ),
      child: Container(
        width: 110,
        margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          color: color.withValues(alpha: 0.1),
          border: Border.all(color: color.withValues(alpha: 0.25), width: 1),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 46, height: 46,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.style_rounded, color: color, size: 22),
            ),
            const SizedBox(height: 10),
            Text(name,
                style: GoogleFonts.inter(
                    color: color,
                    fontWeight: FontWeight.w700,
                    fontSize: 12)),
          ],
        ),
      ),
    );
  }

  // ── Helpers ─────────────────────────────────────────────────────────────────

  Widget _sectionHeader(String title) {
    return Text(title,
        style: GoogleFonts.playfairDisplay(
            color: AppColors.primaryText, fontSize: 20, fontWeight: FontWeight.w700));
  }

  String _getGreeting() {
    final h = DateTime.now().hour;
    if (h < 12) return 'Good Morning ☀️';
    if (h < 17) return 'Good Afternoon 🌤️';
    return 'Good Evening 🌙';
  }
}
