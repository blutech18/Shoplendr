import '/auth/firebase_auth/auth_util.dart';
import '/backend/admin_service.dart';
import '/backend/backend.dart';
import '/components/cors_safe_image.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/price_format.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'admin_dashboard_model.dart';
export 'admin_dashboard_model.dart';

class AdminDashboardWidget extends StatefulWidget {
  const AdminDashboardWidget({super.key});

  static String routeName = 'AdminDashboard';
  static String routePath = '/admin/dashboard';

  @override
  State<AdminDashboardWidget> createState() => _AdminDashboardWidgetState();
}

class _AdminDashboardWidgetState extends State<AdminDashboardWidget>
    with TickerProviderStateMixin {
  late AdminDashboardModel _model;
  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => AdminDashboardModel());
    _model.tabBarController = TabController(vsync: this, length: 5, initialIndex: 0);
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: AdminService.isAdmin(currentUserReference!),
      builder: (context, adminSnapshot) {
        if (!adminSnapshot.hasData) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        if (!adminSnapshot.data!) {
          return Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.block, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text('Access Denied', style: FlutterFlowTheme.of(context).headlineMedium),
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
                    color: FlutterFlowTheme.of(context).primary,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.admin_panel_settings, color: Colors.white, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Admin Panel',
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
                _buildNavItem(Icons.people_outline, 'Users', 1),
                _buildNavItem(Icons.inventory_2_outlined, 'Listings', 2),
                _buildNavItem(Icons.flag_outlined, 'Moderation', 3),
                _buildNavItem(Icons.analytics_outlined, 'Reports', 4),
                _buildNavItem(Icons.chat_outlined, 'Messages', 5),
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
        color: isSelected ? FlutterFlowTheme.of(context).primary.withValues(alpha: 0.1) : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
      ),
      child: InkWell(
        onTap: () {
          if (index == 5) {
            // Navigate to Messages page
            context.pushNamed('AdminMessages');
          } else {
            setState(() {
              _model.tabBarController?.animateTo(index);
            });
          }
        },
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            children: [
              Icon(
                icon,
                size: 20,
                color: isSelected ? FlutterFlowTheme.of(context).primary : FlutterFlowTheme.of(context).secondaryText,
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: isSelected ? FlutterFlowTheme.of(context).primary : FlutterFlowTheme.of(context).secondaryText,
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
      height: 64, // Fixed height to match sidebar
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
                          user?.displayName ?? 'Admin',
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(width: 12),
                      ],
                      CircleAvatar(
                        radius: isMobile ? 16 : 18,
                        backgroundColor: FlutterFlowTheme.of(context).primary,
                        backgroundImage: user?.photoUrl != null && user!.photoUrl.isNotEmpty
                            ? NetworkImage(user.photoUrl)
                            : null,
                        child: user?.photoUrl == null || user!.photoUrl.isEmpty
                            ? Text(
                                (user?.displayName ?? 'A')[0].toUpperCase(),
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
        return isMobile ? 'Overview' : 'Dashboard Overview';
      case 1:
        return isMobile ? 'Users' : 'User Management';
      case 2:
        return isMobile ? 'Listings' : 'Listings Management';
      case 3:
        return isMobile ? 'Moderation' : 'Content Moderation';
      default:
        return isMobile ? 'Dashboard' : 'Admin Dashboard';
    }
  }

  Widget _buildContent() {
    return TabBarView(
      controller: _model.tabBarController,
      children: [
        _buildOverviewTab(),
        _buildUsersTab(),
        _buildListingsTab(),
        _buildModerationTab(),
        _buildReportsTab(),
      ],
    );
  }

  Widget _buildMobileBottomNav() {
    return BottomNavigationBar(
      currentIndex: _model.tabBarController?.index ?? 0,
      onTap: (index) {
        if (index == 5) {
          // Navigate to Messages page
          context.pushNamed('AdminMessages');
        } else {
          setState(() {
            _model.tabBarController?.animateTo(index);
          });
        }
      },
      type: BottomNavigationBarType.fixed,
      selectedItemColor: FlutterFlowTheme.of(context).primary,
      unselectedItemColor: FlutterFlowTheme.of(context).secondaryText,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: 'Overview'),
        BottomNavigationBarItem(icon: Icon(Icons.people), label: 'Users'),
        BottomNavigationBarItem(icon: Icon(Icons.inventory), label: 'Listings'),
        BottomNavigationBarItem(icon: Icon(Icons.flag), label: 'Moderation'),
        BottomNavigationBarItem(icon: Icon(Icons.analytics), label: 'Reports'),
        BottomNavigationBarItem(icon: Icon(Icons.chat), label: 'Messages'),
      ],
    );
  }

  Widget _buildMobileDrawer() {
    return Drawer(
      child: Column(
        children: [
          DrawerHeader(
            decoration: BoxDecoration(color: FlutterFlowTheme.of(context).primary),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(Icons.admin_panel_settings, color: FlutterFlowTheme.of(context).primary, size: 24),
                ),
                const SizedBox(width: 12),
                Text(
                  'Admin Panel',
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
                _buildNavItem(Icons.people_outline, 'Users', 1),
                _buildNavItem(Icons.inventory_2_outlined, 'Listings', 2),
                _buildNavItem(Icons.flag_outlined, 'Moderation', 3),
                _buildNavItem(Icons.analytics_outlined, 'Reports', 4),
                _buildNavItem(Icons.chat_outlined, 'Messages', 5),
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
                  final crossAxisCount = constraints.maxWidth > 1200 ? 5 : constraints.maxWidth > 768 ? 3 : 2;
                  return GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: crossAxisCount,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: crossAxisCount == 1 ? 3 : crossAxisCount == 2 ? 2.5 : 2.2,
                    children: [
                      _buildStatCard('Total Users', stats['total_users']?.toString() ?? '0', Icons.people, const Color(0xFF4285F4)),
                      _buildStatCard('Total Products', stats['total_products']?.toString() ?? '0', Icons.inventory_2, const Color(0xFF34A853)),
                      _buildStatCard('Total Reviews', stats['total_reviews']?.toString() ?? '0', Icons.star, const Color(0xFFFBBC05)),
                      _buildStatCard('Pending ID Verifications', stats['pending_id_verifications']?.toString() ?? '0', Icons.verified_user, const Color(0xFFFF9800)),
                      _buildStatCard('Pending Moderations', stats['pending_moderations']?.toString() ?? '0', Icons.flag, const Color(0xFFEA4335)),
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
              // Real-time activity from Firestore
              StreamBuilder<List<UsersRecord>>(
                stream: queryUsersRecord(
                  queryBuilder: (usersRecord) => usersRecord.orderBy('created_time', descending: true).limit(3),
                ),
                builder: (context, userSnapshot) {
                  if (!userSnapshot.hasData) {
                    return const SizedBox.shrink();
                  }
                  return Column(
                    children: userSnapshot.data!.map((user) {
                      return _buildActivityCard(
                        'New user registered',
                        '${user.displayName.isNotEmpty ? user.displayName : user.username} joined the platform',
                        Icons.person_add,
                        Colors.blue,
                      );
                    }).toList(),
                  );
                },
              ),
              StreamBuilder<List<ProductsRecord>>(
                stream: queryProductsRecord(
                  queryBuilder: (productsRecord) => productsRecord.orderBy('created_at', descending: true).limit(3),
                ),
                builder: (context, productSnapshot) {
                  if (!productSnapshot.hasData) {
                    return const SizedBox.shrink();
                  }
                  return Column(
                    children: productSnapshot.data!.map((product) {
                      return _buildActivityCard(
                        'Product listed',
                        '${product.name} listed for ${product.sellRent}',
                        Icons.add_shopping_cart,
                        Colors.green,
                      );
                    }).toList(),
                  );
                },
              ),
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

  Widget _buildUsersTab() {
    return StreamBuilder<List<UsersRecord>>(
      stream: queryUsersRecord(limit: 50),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        final users = snapshot.data!;
        final isDesktop = MediaQuery.of(context).size.width > 768;
        
        return Column(
          children: [
            // Search and Filter Bar
            Container(
              padding: EdgeInsets.all(isDesktop ? 24 : 16),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Search users...',
                        prefixIcon: const Icon(Icons.search),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        filled: true,
                        fillColor: FlutterFlowTheme.of(context).secondaryBackground,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  IconButton(
                    icon: const Icon(Icons.filter_list),
                    onPressed: () {},
                    style: IconButton.styleFrom(
                      backgroundColor: FlutterFlowTheme.of(context).primary,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            // Users List
            Expanded(
              child: ListView.builder(
                padding: EdgeInsets.symmetric(horizontal: isDesktop ? 24 : 16),
                itemCount: users.length,
                itemBuilder: (context, index) {
                  final user = users[index];
                  // Use email from Firestore, show enhanced UI
                  final displayEmail = user.email.isNotEmpty ? user.email : null;
                  
                  return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: FlutterFlowTheme.of(context).secondaryBackground,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: FlutterFlowTheme.of(context).alternate),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.05),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(16),
                          leading: Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(
                                colors: [
                                  FlutterFlowTheme.of(context).primary,
                                  FlutterFlowTheme.of(context).secondary,
                                ],
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: FlutterFlowTheme.of(context).primary.withValues(alpha: 0.3),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Center(
                              child: Text(
                                user.displayName.isNotEmpty ? user.displayName[0].toUpperCase() : 'U',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              ),
                            ),
                          ),
                          title: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  user.displayName.isNotEmpty ? user.displayName : 'Unknown User',
                                  style: GoogleFonts.inter(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                              if (user.emailVerified)
                                Icon(
                                  Icons.verified,
                                  size: 18,
                                  color: FlutterFlowTheme.of(context).success,
                                ),
                              if (user.studentIdVerified)
                                const SizedBox(width: 4),
                              if (user.studentIdVerified)
                                Icon(
                                  Icons.badge,
                                  size: 18,
                                  color: FlutterFlowTheme.of(context).primary,
                                ),
                            ],
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 6),
                              if (displayEmail != null && displayEmail.isNotEmpty) ...[
                                const SizedBox(height: 6),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.email_outlined,
                                      size: 14,
                                      color: FlutterFlowTheme.of(context).primary,
                                    ),
                                    const SizedBox(width: 4),
                                    Expanded(
                                      child: Text(
                                        displayEmail,
                                        style: GoogleFonts.inter(
                                          fontSize: 13,
                                          color: FlutterFlowTheme.of(context).primaryText,
                                          fontWeight: FontWeight.w500,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ] else ...[
                                const SizedBox(height: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: FlutterFlowTheme.of(context).warning.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(
                                      color: FlutterFlowTheme.of(context).warning,
                                      width: 1,
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.warning_amber_rounded,
                                        size: 14,
                                        color: FlutterFlowTheme.of(context).warning,
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        'Email not synced',
                                        style: GoogleFonts.inter(
                                          fontSize: 11,
                                          color: FlutterFlowTheme.of(context).warning,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                              if (user.isSuspended) ...[
                                const SizedBox(height: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: Colors.red.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: Colors.red,
                                      width: 1,
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(
                                        Icons.block,
                                        size: 14,
                                        color: Colors.red,
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        'Suspended',
                                        style: GoogleFonts.inter(
                                          color: Colors.red,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ],
                          ),
                      trailing: PopupMenuButton<String>(
                        icon: const Icon(Icons.more_vert),
                        onSelected: (value) async {
                          switch (value) {
                            case 'view':
                              await _viewUserDetails(user);
                              break;
                            case 'suspend':
                              if (user.isSuspended) {
                                await _activateUser(user);
                              } else {
                                await _suspendUser(user);
                              }
                              break;
                            case 'delete':
                              await _deleteUser(user);
                              break;
                          }
                        },
                        itemBuilder: (context) => [
                          const PopupMenuItem(value: 'view', child: Row(
                            children: [
                              Icon(Icons.info_outline, size: 20),
                              SizedBox(width: 8),
                              Text('View Details'),
                            ],
                          )),
                          PopupMenuItem(
                            value: 'suspend',
                            child: Row(
                              children: [
                                Icon(
                                  user.isSuspended ? Icons.check_circle_outline : Icons.block,
                                  size: 20,
                                  color: user.isSuspended ? Colors.green : Colors.orange,
                                ),
                                const SizedBox(width: 8),
                                Text(user.isSuspended ? 'Activate User' : 'Suspend User'),
                              ],
                            ),
                          ),
                          const PopupMenuItem(
                            value: 'delete',
                            child: Row(
                              children: [
                                Icon(Icons.delete_outline, size: 20, color: Colors.red),
                                SizedBox(width: 8),
                                Text('Delete User', style: TextStyle(color: Colors.red)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildListingsTab() {
    return StreamBuilder<List<ProductsRecord>>(
      stream: queryProductsRecord(queryBuilder: (q) => q.orderBy('created_at', descending: true), limit: 50),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        final products = snapshot.data!;
        final isDesktop = MediaQuery.of(context).size.width > 768;
        
        return Column(
          children: [
            // Search Bar
            Container(
              padding: EdgeInsets.all(isDesktop ? 24 : 16),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Search listings...',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: FlutterFlowTheme.of(context).secondaryBackground,
                ),
              ),
            ),
            // Products Grid/List
            Expanded(
              child: isDesktop
                  ? GridView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                        childAspectRatio: 0.8,
                      ),
                      itemCount: products.length,
                      itemBuilder: (context, index) => _buildProductCard(products[index]),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: products.length,
                      itemBuilder: (context, index) => _buildProductCard(products[index]),
                    ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildProductCard(ProductsRecord product) {
    return StreamBuilder<List<PurchaseRequestsRecord>>(
      stream: queryPurchaseRequestsRecord(
        queryBuilder: (query) => query
            .where('productRef', isEqualTo: product.reference)
            .where('status', isEqualTo: 'confirmed'),
      ),
      builder: (context, purchaseSnapshot) {
        return StreamBuilder<List<RentalRequestsRecord>>(
          stream: queryRentalRequestsRecord(
            queryBuilder: (query) => query
                .where('productRef', isEqualTo: product.reference)
                .where('status', whereIn: ['approved', 'active']),
          ),
          builder: (context, rentalSnapshot) {
            final isSold = (purchaseSnapshot.data?.isNotEmpty ?? false);
            final isRented = (rentalSnapshot.data?.isNotEmpty ?? false);
            final isUnavailable = isSold || isRented;

            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: FlutterFlowTheme.of(context).secondaryBackground,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isUnavailable 
                      ? Colors.red.withValues(alpha: 0.5)
                      : FlutterFlowTheme.of(context).alternate,
                  width: isUnavailable ? 2 : 1,
                ),
              ),
              child: Stack(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Product Image
                      if (product.photo.isNotEmpty)
                        Stack(
                          children: [
                            CorsSafeImage(
                              imageUrl: product.photo,
                              height: 150,
                              width: double.infinity,
                              fit: BoxFit.cover,
                              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                            ),
                            if (isUnavailable)
                              Positioned.fill(
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.black.withValues(alpha: 0.5),
                                    borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                                  ),
                                  child: Center(
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                      decoration: BoxDecoration(
                                        color: Colors.red,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        isSold ? 'SOLD' : 'RENTED',
                                        style: GoogleFonts.inter(
                                          color: Colors.white,
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          letterSpacing: 2,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    product.name,
                                    style: GoogleFonts.inter(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 16,
                                      decoration: isUnavailable ? TextDecoration.lineThrough : null,
                                      color: isUnavailable 
                                          ? FlutterFlowTheme.of(context).secondaryText
                                          : FlutterFlowTheme.of(context).primaryText,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                if (product.isFeatured)
                                  const Icon(Icons.star, color: Colors.amber, size: 20),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: product.sellRent == 'Sell' ? Colors.green.withValues(alpha: 0.1) : Colors.blue.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    product.sellRent,
                                    style: GoogleFonts.inter(
                                      color: product.sellRent == 'Sell' ? Colors.green : Colors.blue,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                if (isUnavailable)
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: Colors.red.withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(Icons.check_circle, color: Colors.red, size: 14),
                                        const SizedBox(width: 4),
                                        Text(
                                          isSold ? 'Confirmed' : 'Active',
                                          style: GoogleFonts.inter(
                                            color: Colors.red,
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                const Spacer(),
                                Text(
                                  formatPrice(product.price),
                                  style: GoogleFonts.inter(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: isUnavailable
                                        ? FlutterFlowTheme.of(context).secondaryText
                                        : FlutterFlowTheme.of(context).primary,
                                    decoration: isUnavailable ? TextDecoration.lineThrough : null,
                                  ),
                                ),
                              ],
                            ),
                const SizedBox(height: 12),
                // Action Buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          context.pushNamed(
                            'ItemPage',
                            queryParameters: {
                              'para': serializeParam(product.reference, ParamType.DocumentReference),
                            }.withoutNulls,
                          );
                        },
                        icon: const Icon(Icons.visibility, size: 16),
                        label: const Text('View'),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          side: BorderSide(color: FlutterFlowTheme.of(context).primary),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _deleteProduct(product),
                        icon: const Icon(Icons.delete_outline, size: 16, color: Colors.red),
                        label: const Text('Delete', style: TextStyle(color: Colors.red)),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          side: const BorderSide(color: Colors.red),
                        ),
                      ),
                    ),
                  ],
                ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildModerationTab() {
    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          TabBar(
            labelColor: FlutterFlowTheme.of(context).primary,
            unselectedLabelColor: FlutterFlowTheme.of(context).secondaryText,
            indicatorColor: FlutterFlowTheme.of(context).primary,
            tabs: const [
              Tab(text: 'ID Verifications'),
              Tab(text: 'Content Moderation'),
            ],
          ),
          Expanded(
            child: TabBarView(
              children: [
                _buildIDVerificationTab(),
                _buildContentModerationTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIDVerificationTab() {
    return StreamBuilder<List<UsersRecord>>(
      stream: queryUsersRecord(
        queryBuilder: (usersRecord) => usersRecord
            .where('verificationStatus', isEqualTo: 'pending')
            .orderBy('created_time', descending: true),
        limit: 50,
      ),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        final pendingUsers = snapshot.data!;
        final isDesktop = MediaQuery.of(context).size.width > 768;

        if (pendingUsers.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.verified_user, size: 64, color: Colors.green[300]),
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
                  'No pending ID verifications',
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
          itemCount: pendingUsers.length,
          itemBuilder: (context, index) {
            final user = pendingUsers[index];
            return _buildIDVerificationCard(user);
          },
        );
      },
    );
  }

  Widget _buildIDVerificationCard(UsersRecord user) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: FlutterFlowTheme.of(context).secondaryBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: FlutterFlowTheme.of(context).alternate,
        ),
      ),
      child: ExpansionTile(
        title: Row(
          children: [
            CircleAvatar(
              radius: 20,
              backgroundColor: FlutterFlowTheme.of(context).primary,
              child: Text(
                user.displayName.isNotEmpty ? user.displayName[0].toUpperCase() : 'U',
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user.displayName.isNotEmpty ? user.displayName : 'Unknown User',
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
                color: Colors.orange.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                'PENDING',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.orange,
                ),
              ),
            ),
          ],
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // User Details
                _buildDetailRow(
                  'Email', 
                  user.email.isNotEmpty ? user.email : 'N/A',
                  isError: user.email.isEmpty,
                ),
                _buildDetailRow('Phone', user.phoneNumber.isNotEmpty ? user.phoneNumber : 'N/A'),
                _buildDetailRow('Address', user.address.isNotEmpty ? user.address : 'N/A'),
                
                // Uploaded ID
                if (user.iDverification.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Text(
                    'Uploaded ID',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: FlutterFlowTheme.of(context).primaryText,
                    ),
                  ),
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: () {
                      // Show full-screen image
                      showDialog(
                        context: context,
                        builder: (context) => Dialog(
                          child: Stack(
                            children: [
                              InteractiveViewer(
                                child: CorsSafeImage(
                                  imageUrl: user.iDverification,
                                  fit: BoxFit.contain,
                                ),
                              ),
                              Positioned(
                                top: 8,
                                right: 8,
                                child: IconButton(
                                  icon: const Icon(Icons.close),
                                  onPressed: () => Navigator.of(context).pop(),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                    child: Container(
                      height: 200,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: FlutterFlowTheme.of(context).alternate),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: CorsSafeImage(
                          imageUrl: user.iDverification,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Tap to view full size',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: FlutterFlowTheme.of(context).secondaryText,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],

                const SizedBox(height: 16),
                // Action Buttons
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _approveIDVerification(user),
                        icon: const Icon(Icons.check_circle, color: Colors.white),
                        label: Text(
                          'Approve',
                          style: GoogleFonts.inter(fontWeight: FontWeight.w600, color: Colors.white),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _rejectIDVerification(user),
                        icon: const Icon(Icons.cancel, color: Colors.white),
                        label: Text(
                          'Reject',
                          style: GoogleFonts.inter(fontWeight: FontWeight.w600, color: Colors.white),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _approveIDVerification(UsersRecord user) async {
    try {
      await user.reference.update({
        'studentIdVerified': true,
        'verificationStatus': 'verified',
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('ID verification approved for ${user.displayName}'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error approving verification'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _rejectIDVerification(UsersRecord user) async {
    try {
      await user.reference.update({
        'studentIdVerified': false,
        'verificationStatus': 'rejected',
        'iDverification': '', // Clear the ID image
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('ID verification rejected for ${user.displayName}'),
            backgroundColor: Colors.orange,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error rejecting verification'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Widget _buildContentModerationTab() {
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
                    // Display reported user information
                    if (mod.contentRef != null) ...[
                      FutureBuilder<UsersRecord?>(
                        future: UsersRecord.getDocumentOnce(mod.contentRef!),
                        builder: (context, snapshot) {
                          if (snapshot.hasData && snapshot.data != null) {
                            final reportedUser = snapshot.data!;
                            return Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: FlutterFlowTheme.of(context).primaryBackground,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: FlutterFlowTheme.of(context).alternate,
                                ),
                              ),
                              child: Row(
                                children: [
                                  CircleAvatar(
                                    radius: 16,
                                    backgroundColor: FlutterFlowTheme.of(context).primary,
                                    child: Text(
                                      reportedUser.displayName.isNotEmpty 
                                          ? reportedUser.displayName[0].toUpperCase() 
                                          : 'U',
                                      style: const TextStyle(
                                        color: Colors.white, 
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Reported User',
                                          style: GoogleFonts.inter(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                            color: FlutterFlowTheme.of(context).secondaryText,
                                          ),
                                        ),
                                        Text(
                                          reportedUser.displayName.isNotEmpty 
                                              ? reportedUser.displayName 
                                              : 'Unknown User',
                                          style: GoogleFonts.inter(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                            color: FlutterFlowTheme.of(context).primaryText,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }
                          return const SizedBox.shrink();
                        },
                      ),
                      const SizedBox(height: 12),
                    ],
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
                            onPressed: () => _warnUserFromDashboard(mod),
                            icon: const Icon(Icons.warning, size: 18),
                            label: const Text('Warn'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.orange,
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
                            onPressed: () => _dismissReportFromDashboard(mod),
                            icon: const Icon(Icons.close, size: 18),
                            label: const Text('Dismiss'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.grey,
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

  Future<void> _warnUserFromDashboard(ModerationQueueRecord moderation) async {
    // Check if contentRef exists before showing dialog
    if (moderation.contentRef == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error: No user reference found for this report'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 4),
        ),
      );
      return;
    }

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Warn User'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('This will:'),
            const SizedBox(height: 8),
            const Text('• Send an automated warning message to the user'),
            const Text('• Increment their warning count'),
            const Text('• Automatically suspend them after 5 warnings'),
            const SizedBox(height: 16),
            Text(
              'Report Reason: ${moderation.reason}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            if (moderation.description.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text('Details: ${moderation.description}'),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Warn', style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );

    if (result == true) {
      // Check if widget is still mounted before using context
      if (!mounted) return;
      
      // Show loading indicator
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Processing warning...'),
          duration: Duration(seconds: 2),
        ),
      );
      
      try {
        debugPrint('🔔 Starting warning process for user: ${moderation.contentRef!.path}');
        
        // Warn user and track warning count (auto-sends message)
        final success = await AdminService.warnUserAndTrack(
          userRef: moderation.contentRef!,
          warnedBy: currentUserReference!,
          reason: moderation.reason,
        );
        
        debugPrint('🔔 Warning process completed: $success');
        
        // Mark moderation as reviewed
        await AdminService.reviewModeration(
          moderationId: moderation.reference.id,
          reviewedBy: currentUserReference!,
          actionTaken: 'warned',
          notes: 'User warned for: ${moderation.reason}. Automated warning message sent.',
        );
        
        debugPrint('🔔 Moderation marked as reviewed');
        
        // Show success message
        if (mounted) {
          ScaffoldMessenger.of(context).clearSnackBars();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('✅ Warning successfully issued! Automated message sent to the reported user.'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 4),
            ),
          );
        }
      } catch (e) {
        debugPrint('❌ Error issuing warning: $e');
        debugPrint('❌ Stack trace: ${StackTrace.current}');
        
        if (mounted) {
          ScaffoldMessenger.of(context).clearSnackBars();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('❌ Error issuing warning: ${e.toString()}'),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 5),
            ),
          );
        }
      }
    }
  }

  Future<void> _dismissReportFromDashboard(ModerationQueueRecord moderation) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Dismiss Report'),
        content: const Text('Are you sure you want to dismiss this report? No action will be taken.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Dismiss'),
          ),
        ],
      ),
    );

    if (result == true) {
      // Check if widget is still mounted before using context
      if (!mounted) return;
      
      try {
        await AdminService.reviewModeration(
          moderationId: moderation.reference.id,
          reviewedBy: currentUserReference!,
          actionTaken: 'dismissed',
          notes: 'Report dismissed - no violation found',
        );
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Report dismissed'),
            backgroundColor: Colors.grey,
          ),
        );
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error dismissing report: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Widget _buildReportsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Reports & Analytics',
            style: GoogleFonts.inter(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: FlutterFlowTheme.of(context).primaryText,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'View system statistics and user activity',
            style: GoogleFonts.inter(
              fontSize: 14,
              color: FlutterFlowTheme.of(context).secondaryText,
            ),
          ),
          const SizedBox(height: 24),
          
          // Summary Cards
          StreamBuilder<List<UsersRecord>>(
            stream: queryUsersRecord(),
            builder: (context, usersSnapshot) {
              return StreamBuilder<List<ProductsRecord>>(
                stream: queryProductsRecord(),
                builder: (context, productsSnapshot) {
                  return StreamBuilder<List<PurchaseRequestsRecord>>(
                    stream: queryPurchaseRequestsRecord(),
                    builder: (context, purchasesSnapshot) {
                      return StreamBuilder<List<RentalRequestsRecord>>(
                        stream: queryRentalRequestsRecord(),
                        builder: (context, rentalsSnapshot) {
                          final totalUsers = usersSnapshot.data?.length ?? 0;
                          final totalListings = productsSnapshot.data?.length ?? 0;
                          final confirmedPurchases = purchasesSnapshot.data
                              ?.where((p) => p.status == 'confirmed')
                              .length ?? 0;
                          final approvedRentals = rentalsSnapshot.data
                              ?.where((r) => r.status == 'approved')
                              .length ?? 0;

                          return GridView.count(
                            crossAxisCount: MediaQuery.of(context).size.width > 768 ? 4 : 2,
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                            childAspectRatio: 1.3,
                            children: [
                              _buildStatCard('Total Users', totalUsers.toString(), Icons.people, Colors.blue),
                              _buildStatCard('Total Listings', totalListings.toString(), Icons.inventory_2, Colors.green),
                              _buildStatCard('Completed Sales', confirmedPurchases.toString(), Icons.shopping_cart, Colors.orange),
                              _buildStatCard('Active Rentals', approvedRentals.toString(), Icons.event_available, Colors.purple),
                            ],
                          );
                        },
                      );
                    },
                  );
                },
              );
            },
          ),
          
          const SizedBox(height: 32),
          
          // Transaction Statistics
          Text(
            'Transaction Statistics',
            style: GoogleFonts.inter(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: FlutterFlowTheme.of(context).primaryText,
            ),
          ),
          const SizedBox(height: 16),
          StreamBuilder<List<PurchaseRequestsRecord>>(
            stream: queryPurchaseRequestsRecord(
              queryBuilder: (query) => query.orderBy('requestDate', descending: true),
              limit: 100,
            ),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              final purchases = snapshot.data!;
              final pending = purchases.where((p) => p.status == 'pending').length;
              final confirmed = purchases.where((p) => p.status == 'confirmed').length;
              final declined = purchases.where((p) => p.status == 'declined').length;

              return Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: FlutterFlowTheme.of(context).secondaryBackground,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    _buildStatRow('Pending Purchases', pending, Colors.orange),
                    const Divider(height: 24),
                    _buildStatRow('Confirmed Sales', confirmed, Colors.green),
                    const Divider(height: 24),
                    _buildStatRow('Declined Requests', declined, Colors.red),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildStatRow(String label, int count, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 15,
              color: FlutterFlowTheme.of(context).primaryText,
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              count.toString(),
              style: GoogleFonts.inter(
                fontSize: 16,
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // User Management Actions
  Future<void> _viewUserDetails(UsersRecord user) async {
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('User Details: ${user.displayName}'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDetailRow('Username', user.username.isNotEmpty ? user.username.trim() : 'N/A'),
              _buildDetailRow(
                'Email', 
                user.email.isNotEmpty ? user.email : 'N/A',
                isError: user.email.isEmpty,
              ),
              _buildDetailRow('Email Verified', user.emailVerified ? 'Yes' : 'No'),
              _buildDetailRow('Student ID Verified', user.studentIdVerified ? 'Yes' : 'No'),
              _buildDetailRow('Phone', user.phoneNumber.isNotEmpty ? user.phoneNumber : 'N/A'),
              _buildDetailRow('Address', user.address.isNotEmpty ? user.address : 'N/A'),
              _buildDetailRow('Joined', user.createdTime != null ? dateTimeFormat('yMMMd', user.createdTime!) : 'N/A'),
              if (user.isSuspended) ...[
                const Divider(height: 24),
                _buildDetailRow('Status', 'SUSPENDED', isError: true),
                _buildDetailRow('Suspension Reason', user.suspensionReason.isNotEmpty ? user.suspensionReason : 'N/A'),
                if (user.suspensionUntil != null)
                  _buildDetailRow('Suspended Until', dateTimeFormat('yMMMd', user.suspensionUntil!)),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {bool isError = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              '$label:',
              style: GoogleFonts.inter(
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.inter(
                fontSize: 14,
                color: isError ? Colors.red : null,
                fontWeight: isError ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _suspendUser(UsersRecord user) async {
    final reasonController = TextEditingController();
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Suspend User'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Suspend ${user.displayName}?'),
            const SizedBox(height: 16),
            TextField(
              controller: reasonController,
              decoration: const InputDecoration(
                labelText: 'Reason for suspension',
                border: OutlineInputBorder(),
                hintText: 'Enter reason...',
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.orange),
            child: const Text('Suspend'),
          ),
        ],
      ),
    );

    if (result == true && reasonController.text.isNotEmpty) {
      try {
        await user.reference.update({
          'is_suspended': true,
          'suspended_by': currentUserReference,
          'suspended_at': DateTime.now(),
          'suspension_reason': reasonController.text,
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${user.displayName} has been suspended'),
              backgroundColor: Colors.orange,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error suspending user: ${e.toString()}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  Future<void> _activateUser(UsersRecord user) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Activate User'),
        content: Text('Activate ${user.displayName}? This will remove the suspension.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.green),
            child: const Text('Activate'),
          ),
        ],
      ),
    );

    if (result == true) {
      try {
        await user.reference.update({
          'is_suspended': false,
          'suspended_by': null,
          'suspended_at': null,
          'suspension_reason': '',
          'suspension_until': null,
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${user.displayName} has been activated'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error activating user: ${e.toString()}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  Future<void> _deleteUser(UsersRecord user) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete User'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Are you sure you want to delete ${user.displayName}?'),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Row(
                children: [
                  Icon(Icons.warning, color: Colors.red, size: 20),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'This action cannot be undone!',
                      style: TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (result == true) {
      try {
        // Delete user's products first
        final products = await queryProductsRecordOnce(
          queryBuilder: (query) => query.where('OwnerRef', isEqualTo: user.reference),
        );
        for (final product in products) {
          await product.reference.delete();
        }

        // Delete user record
        await user.reference.delete();

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${user.displayName} has been deleted'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error deleting user: ${e.toString()}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  Future<void> _deleteProduct(ProductsRecord product) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Listing'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Are you sure you want to delete "${product.name}"?'),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.warning, color: Colors.red, size: 20),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'This action cannot be undone!',
                          style: TextStyle(
                            color: Colors.red,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Type: ${product.sellRent}',
                    style: const TextStyle(fontSize: 12),
                  ),
                  Text(
                    'Price: ${formatPrice(product.price)}',
                    style: const TextStyle(fontSize: 12),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (result == true) {
      try {
        // Delete related purchase requests
        final purchaseRequests = await queryPurchaseRequestsRecordOnce(
          queryBuilder: (query) => query.where('productRef', isEqualTo: product.reference),
        );
        for (final request in purchaseRequests) {
          await request.reference.delete();
        }

        // Delete related rental requests
        final rentalRequests = await queryRentalRequestsRecordOnce(
          queryBuilder: (query) => query.where('productRef', isEqualTo: product.reference),
        );
        for (final request in rentalRequests) {
          await request.reference.delete();
        }

        // Delete related reviews
        final reviews = await queryReviewsRecordOnce(
          queryBuilder: (query) => query.where('product_ref', isEqualTo: product.reference),
        );
        for (final review in reviews) {
          await review.reference.delete();
        }

        // Delete the product
        await product.reference.delete();

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${product.name} has been deleted'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error deleting product: ${e.toString()}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }
}
