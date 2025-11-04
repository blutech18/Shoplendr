import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class BottomNavBar extends StatelessWidget {
  final String currentRoute;
  final bool isProfileComplete;

  const BottomNavBar({
    super.key,
    required this.currentRoute,
    this.isProfileComplete = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: FlutterFlowTheme.of(context).secondaryBackground,
        boxShadow: const [
          BoxShadow(
            color: Color(0x1A000000),
            offset: Offset(0, -2),
            blurRadius: 8,
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(
                context,
                icon: Icons.home_rounded,
                label: 'Home',
                isActive: currentRoute == HomepageCopy2CopyWidget.routeName ||
                    currentRoute == HomepageCopy2Widget.routeName,
                onTap: () => context.pushNamed(HomepageCopy2CopyWidget.routeName),
              ),
              _buildNavItem(
                context,
                icon: Icons.chat_bubble_outline_rounded,
                label: 'Messages',
                isActive: currentRoute == MessageWidget.routeName,
                onTap: () => context.pushNamed(MessageWidget.routeName),
              ),
              _buildNavItem(
                context,
                icon: Icons.add_circle_outline_rounded,
                label: 'Sell',
                isActive: currentRoute == SellWidget.routeName,
                onTap: isProfileComplete ? () => context.pushNamed(SellWidget.routeName) : null,
                isDisabled: !isProfileComplete,
              ),
              _buildNavItem(
                context,
                icon: Icons.inventory_2_outlined,
                label: 'Listings',
                isActive: currentRoute == 'MyTransactions',
                onTap: () => context.pushNamed('MyTransactions'),
              ),
              _buildNavItem(
                context,
                icon: Icons.person_outline_rounded,
                label: 'Profile',
                isActive: currentRoute == ProfileWidget.routeName,
                onTap: () => context.pushNamed(ProfileWidget.routeName),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required bool isActive,
    required VoidCallback? onTap,
    bool isDisabled = false,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Opacity(
        opacity: isDisabled ? 0.5 : 1.0,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                color: isActive
                    ? FlutterFlowTheme.of(context).primary
                    : FlutterFlowTheme.of(context).secondaryText,
                size: 24.0,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: FlutterFlowTheme.of(context).bodySmall.override(
                      font: GoogleFonts.inter(
                        fontWeight: FontWeight.w600,
                      ),
                      color: isActive
                          ? FlutterFlowTheme.of(context).primary
                          : FlutterFlowTheme.of(context).secondaryText,
                      fontSize: 11,
                      letterSpacing: 0.0,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
