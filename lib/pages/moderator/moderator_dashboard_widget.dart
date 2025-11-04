import '/auth/firebase_auth/auth_util.dart';
import '/backend/admin_service.dart';
import '/backend/backend.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'moderator_dashboard_model.dart';
export 'moderator_dashboard_model.dart';

class ModeratorDashboardWidget extends StatefulWidget {
  const ModeratorDashboardWidget({super.key});

  static String routeName = 'ModeratorDashboard';
  static String routePath = '/moderator/dashboard';

  @override
  State<ModeratorDashboardWidget> createState() => _ModeratorDashboardWidgetState();
}

class _ModeratorDashboardWidgetState extends State<ModeratorDashboardWidget>
    with TickerProviderStateMixin {
  late ModeratorDashboardModel _model;
  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => ModeratorDashboardModel());
    _model.tabBarController = TabController(vsync: this, length: 3, initialIndex: 0);
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<AdminUsersRecord?>(
      future: AdminService.getAdminUser(currentUserReference!),
      builder: (context, adminSnapshot) {
        if (!adminSnapshot.hasData) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        
        final adminUser = adminSnapshot.data;
        if (adminUser == null || !adminUser.isActive || adminUser.role != AdminService.roleModerator) {
          return Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.block, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text('Access Denied', style: FlutterFlowTheme.of(context).headlineMedium),
                  const SizedBox(height: 8),
                  Text('Moderator access required', style: FlutterFlowTheme.of(context).bodyMedium),
                ],
              ),
            ),
          );
        }
        
        return Scaffold(
          key: scaffoldKey,
          backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
          body: Row(
            children: [
              // Sidebar Navigation (Desktop)
              if (MediaQuery.of(context).size.width > 768)
                _buildSidebar(),
              // Main Content
              Expanded(
                child: Column(
                  children: [
                    _buildTopBar(),
                    Expanded(
                      child: _buildContent(),
                    ),
                  ],
                ),
              ),
            ],
          ),
          // Mobile Bottom Navigation
          bottomNavigationBar: MediaQuery.of(context).size.width <= 768
              ? _buildMobileBottomNav()
              : null,
          // Mobile Drawer
          drawer: MediaQuery.of(context).size.width <= 768
              ? _buildMobileDrawer()
              : null,
        );
      },
    );
  }

  // Sidebar for desktop
  Widget _buildSidebar() {
    return Container(
      width: 260,
      decoration: BoxDecoration(
        color: FlutterFlowTheme.of(context).secondaryBackground,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(2, 0),
          ),
        ],
      ),
      child: Column(
        children: [
          // Logo/Header - Compact (matches header height)
          Container(
            height: 64, // Match header height
            padding: const EdgeInsets.symmetric(horizontal: 20),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: FlutterFlowTheme.of(context).alternate,
                  width: 1,
                ),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF9800), // Orange for moderator
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.shield, color: Colors.white, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Moderator Panel',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: FlutterFlowTheme.of(context).primaryText,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Navigation Items
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
              children: [
                _buildNavItem(Icons.dashboard_outlined, 'Overview', 0),
                _buildNavItem(Icons.flag_outlined, 'Moderation Queue', 1),
                _buildNavItem(Icons.inventory_2_outlined, 'Reported Content', 2),
              ],
            ),
          ),
          // Logout Button - Compact
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(
                  color: FlutterFlowTheme.of(context).alternate,
                  width: 1,
                ),
              ),
            ),
            child: InkWell(
              onTap: () async {
                GoRouter.of(context).prepareAuthEvent();
                await authManager.signOut();
                if (mounted) {
                  context.goNamedAuth('Login', context.mounted);
                }
              },
              borderRadius: BorderRadius.circular(8),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                child: Row(
                  children: [
                    const Icon(Icons.logout, color: Colors.red, size: 20),
                    const SizedBox(width: 12),
                    Text(
                      'Logout',
                      style: GoogleFonts.inter(
                        color: Colors.red,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
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

  Widget _buildNavItem(IconData icon, String title, int index) {
    final isSelected = _model.tabBarController?.index == index;
    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      decoration: BoxDecoration(
        color: isSelected ? const Color(0xFFFF9800).withValues(alpha: 0.1) : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
      ),
      child: InkWell(
        onTap: () {
          setState(() {
            _model.tabBarController?.animateTo(index);
          });
        },
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            children: [
              Icon(
                icon,
                size: 20,
                color: isSelected ? const Color(0xFFFF9800) : FlutterFlowTheme.of(context).secondaryText,
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: isSelected ? const Color(0xFFFF9800) : FlutterFlowTheme.of(context).secondaryText,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Top Bar
  Widget _buildTopBar() {
    final isMobile = MediaQuery.of(context).size.width <= 768;
    return Container(
      height: 64,
      padding: EdgeInsets.symmetric(horizontal: isMobile ? 16 : 24),
      decoration: BoxDecoration(
        color: FlutterFlowTheme.of(context).secondaryBackground,
        border: Border(
          bottom: BorderSide(
            color: FlutterFlowTheme.of(context).alternate,
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          if (isMobile)
            IconButton(
              icon: const Icon(Icons.menu),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              onPressed: () => scaffoldKey.currentState?.openDrawer(),
            ),
          if (isMobile) const SizedBox(width: 8),
          Expanded(
            child: Text(
              _getPageTitle(),
              style: GoogleFonts.inter(
                fontSize: isMobile ? 18 : 24,
                fontWeight: FontWeight.bold,
                color: FlutterFlowTheme.of(context).primaryText,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          // User Profile - Clickable
          FutureBuilder<UsersRecord?>(
            future: UsersRecord.getDocumentOnce(currentUserReference!),
            builder: (context, snapshot) {
              final user = snapshot.data;
              return InkWell(
                onTap: () {
                  context.pushNamed('profile');
                },
                borderRadius: BorderRadius.circular(20),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (!isMobile) ...[
                        Text(
                          user?.displayName ?? 'Moderator',
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(width: 12),
                      ],
                      CircleAvatar(
                        radius: isMobile ? 16 : 18,
                        backgroundColor: const Color(0xFFFF9800),
                        backgroundImage: user?.photoUrl != null && user!.photoUrl.isNotEmpty
                            ? NetworkImage(user.photoUrl)
                            : null,
                        child: user?.photoUrl == null || user!.photoUrl.isEmpty
                            ? Text(
                                (user?.displayName ?? 'M')[0].toUpperCase(),
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: isMobile ? 14 : 16,
                                ),
                              )
                            : null,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  String _getPageTitle() {
    final isMobile = MediaQuery.of(context).size.width <= 768;
    switch (_model.tabBarController?.index ?? 0) {
      case 0:
        return isMobile ? 'Overview' : 'Moderator Overview';
      case 1:
        return isMobile ? 'Queue' : 'Moderation Queue';
      case 2:
        return isMobile ? 'Reports' : 'Reported Content';
      default:
        return isMobile ? 'Moderator' : 'Moderator Dashboard';
    }
  }

  Widget _buildContent() {
    return TabBarView(
      controller: _model.tabBarController,
      children: [
        _buildOverviewTab(),
        _buildModerationQueueTab(),
        _buildReportedContentTab(),
      ],
    );
  }

  Widget _buildMobileBottomNav() {
    return BottomNavigationBar(
      currentIndex: _model.tabBarController?.index ?? 0,
      onTap: (index) {
        setState(() {
          _model.tabBarController?.animateTo(index);
        });
      },
      type: BottomNavigationBarType.fixed,
      selectedItemColor: const Color(0xFFFF9800),
      unselectedItemColor: FlutterFlowTheme.of(context).secondaryText,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: 'Overview'),
        BottomNavigationBarItem(icon: Icon(Icons.flag), label: 'Queue'),
        BottomNavigationBarItem(icon: Icon(Icons.report), label: 'Reports'),
      ],
    );
  }

  Widget _buildMobileDrawer() {
    return Drawer(
      child: Column(
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(color: Color(0xFFFF9800)),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.shield, color: Color(0xFFFF9800), size: 24),
                ),
                const SizedBox(width: 12),
                Text(
                  'Moderator Panel',
                  style: GoogleFonts.inter(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                _buildNavItem(Icons.dashboard_outlined, 'Overview', 0),
                _buildNavItem(Icons.flag_outlined, 'Moderation Queue', 1),
                _buildNavItem(Icons.inventory_2_outlined, 'Reported Content', 2),
              ],
            ),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(
                  color: FlutterFlowTheme.of(context).alternate,
                  width: 1,
                ),
              ),
            ),
            child: InkWell(
              onTap: () async {
                GoRouter.of(context).prepareAuthEvent();
                await authManager.signOut();
                if (mounted) {
                  context.goNamedAuth('Login', context.mounted);
                }
              },
              borderRadius: BorderRadius.circular(8),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                child: Row(
                  children: [
                    const Icon(Icons.logout, color: Colors.red, size: 20),
                    const SizedBox(width: 12),
                    Text(
                      'Logout',
                      style: GoogleFonts.inter(
                        color: Colors.red,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
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

  Widget _buildOverviewTab() {
    return FutureBuilder<Map<String, dynamic>>(
      future: AdminService.getDashboardStats(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final stats = snapshot.data!;
        final isDesktop = MediaQuery.of(context).size.width > 768;
        
        return SingleChildScrollView(
          padding: EdgeInsets.all(isDesktop ? 24 : 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Stats Grid - Compact
              LayoutBuilder(
                builder: (context, constraints) {
                  final crossAxisCount = constraints.maxWidth > 1200 ? 3 : constraints.maxWidth > 768 ? 2 : 1;
                  return GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: crossAxisCount,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: crossAxisCount == 1 ? 3 : 2.2,
                    children: [
                      _buildStatCard('Pending Reviews', stats['pending_moderations']?.toString() ?? '0', Icons.flag, const Color(0xFFEA4335)),
                      _buildStatCard('Total Products', stats['total_products']?.toString() ?? '0', Icons.inventory_2, const Color(0xFF34A853)),
                      _buildStatCard('Total Reviews', stats['total_reviews']?.toString() ?? '0', Icons.star, const Color(0xFFFBBC05)),
                    ],
                  );
                },
              ),
              const SizedBox(height: 24),
              // Recent Activity Section
              Text(
                'Recent Activity',
                style: GoogleFonts.inter(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: FlutterFlowTheme.of(context).primaryText,
                ),
              ),
              const SizedBox(height: 16),
              _buildActivityCard('Content reported', 'User reported inappropriate product', Icons.report, Colors.red),
              _buildActivityCard('Review approved', 'Product review was approved', Icons.check_circle, Colors.green),
              _buildActivityCard('Content flagged', 'Suspicious listing detected', Icons.warning, Colors.orange),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: FlutterFlowTheme.of(context).secondaryBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: FlutterFlowTheme.of(context).alternate),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 24, color: color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  value,
                  style: GoogleFonts.inter(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: FlutterFlowTheme.of(context).primaryText,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  title,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: FlutterFlowTheme.of(context).secondaryText,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActivityCard(String title, String subtitle, IconData icon, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: FlutterFlowTheme.of(context).secondaryBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: FlutterFlowTheme.of(context).alternate),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: FlutterFlowTheme.of(context).primaryText,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: FlutterFlowTheme.of(context).secondaryText,
                  ),
                ),
              ],
            ),
          ),
          Icon(Icons.chevron_right, color: FlutterFlowTheme.of(context).secondaryText),
        ],
      ),
    );
  }

  Widget _buildModerationQueueTab() {
    return StreamBuilder<List<ModerationQueueRecord>>(
      stream: queryModerationQueueRecord(
        queryBuilder: (moderationQueueRecord) => moderationQueueRecord
            .where('status', isEqualTo: 'pending')
            .orderBy('created_at', descending: true),
        limit: 50,
      ),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        final moderations = snapshot.data!;
        final isDesktop = MediaQuery.of(context).size.width > 768;
        
        if (moderations.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.check_circle, size: 64, color: Colors.green[300]),
                const SizedBox(height: 16),
                Text(
                  'All Clear!',
                  style: GoogleFonts.inter(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: FlutterFlowTheme.of(context).primaryText,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'No pending moderations',
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    color: FlutterFlowTheme.of(context).secondaryText,
                  ),
                ),
              ],
            ),
          );
        }
        
        return ListView.builder(
          padding: EdgeInsets.all(isDesktop ? 24 : 16),
          itemCount: moderations.length,
          itemBuilder: (context, index) {
            final mod = moderations[index];
            return Container(
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: FlutterFlowTheme.of(context).secondaryBackground,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: mod.priority == 'high' ? Colors.red.withValues(alpha: 0.3) : FlutterFlowTheme.of(context).alternate,
                  width: mod.priority == 'high' ? 2 : 1,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: (mod.priority == 'high' ? Colors.red : Colors.orange).withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            Icons.flag,
                            color: mod.priority == 'high' ? Colors.red : Colors.orange,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                mod.contentType.toUpperCase(),
                                style: GoogleFonts.inter(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: FlutterFlowTheme.of(context).secondaryText,
                                ),
                              ),
                              Text(
                                mod.reason,
                                style: GoogleFonts.inter(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: FlutterFlowTheme.of(context).primaryText,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: mod.priority == 'high' ? Colors.red.withValues(alpha: 0.1) : Colors.orange.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            mod.priority.toUpperCase(),
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: mod.priority == 'high' ? Colors.red : Colors.orange,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      mod.description,
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: FlutterFlowTheme.of(context).secondaryText,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () async {
                              await AdminService.reviewModeration(
                                moderationId: mod.reference.id,
                                reviewedBy: currentUserReference!,
                                actionTaken: 'approved',
                              );
                              setState(() {});
                            },
                            icon: const Icon(Icons.check, size: 18),
                            label: const Text('Approve'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () async {
                              await AdminService.reviewModeration(
                                moderationId: mod.reference.id,
                                reviewedBy: currentUserReference!,
                                actionTaken: 'removed',
                              );
                              setState(() {});
                            },
                            icon: const Icon(Icons.close, size: 18),
                            label: const Text('Remove'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildReportedContentTab() {
    return FutureBuilder<Map<String, int>>(
      future: AdminService.getReportedContentSummary(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        final summary = snapshot.data!;
        final isDesktop = MediaQuery.of(context).size.width > 768;
        
        return SingleChildScrollView(
          padding: EdgeInsets.all(isDesktop ? 24 : 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Reported Content Summary',
                style: GoogleFonts.inter(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: FlutterFlowTheme.of(context).primaryText,
                ),
              ),
              const SizedBox(height: 16),
              if (summary.isEmpty)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Text(
                      'No reported content',
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        color: FlutterFlowTheme.of(context).secondaryText,
                      ),
                    ),
                  ),
                )
              else
                ...summary.entries.map((entry) => Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: FlutterFlowTheme.of(context).secondaryBackground,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: FlutterFlowTheme.of(context).alternate),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.red.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          _getContentIcon(entry.key),
                          color: Colors.red,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              entry.key.toUpperCase(),
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: FlutterFlowTheme.of(context).secondaryText,
                              ),
                            ),
                            Text(
                              '${entry.value} reports',
                              style: GoogleFonts.inter(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: FlutterFlowTheme.of(context).primaryText,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(Icons.chevron_right, color: FlutterFlowTheme.of(context).secondaryText),
                    ],
                  ),
                )),
            ],
          ),
        );
      },
    );
  }

  IconData _getContentIcon(String contentType) {
    switch (contentType.toLowerCase()) {
      case 'product':
        return Icons.inventory_2;
      case 'review':
        return Icons.star;
      case 'user':
        return Icons.person;
      case 'message':
        return Icons.message;
      default:
        return Icons.report;
    }
  }
}
