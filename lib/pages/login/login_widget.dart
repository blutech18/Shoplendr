import '/auth/firebase_auth/auth_util.dart';
import '/auth/auth_redirect_helper.dart';
import '/backend/admin_service.dart';
import '/flutter_flow/flutter_flow_animations.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/flutter_flow/security_utils.dart';
import '/pages/moderator/moderator_dashboard_widget.dart';
import '/index.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:async';
import 'login_model.dart';
export 'login_model.dart';

class LoginWidget extends StatefulWidget {
  const LoginWidget({super.key});

  static String routeName = 'Login';
  static String routePath = '/login';

  @override
  State<LoginWidget> createState() => _LoginWidgetState();
}

class _LoginWidgetState extends State<LoginWidget>
    with TickerProviderStateMixin {
  late LoginModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  final animationsMap = <String, AnimationInfo>{};
  
  // Brute force protection state
  bool _isLoginDisabled = false;
  bool _isSignupDisabled = false;
  Timer? _lockoutTimer;
  
  // Failed attempt counters
  int _loginFailedAttempts = 0;
  int _signupFailedAttempts = 0;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => LoginModel());

    _model.tabBarController = TabController(
      vsync: this,
      length: 2,
      initialIndex: 0,
    )..addListener(() => safeSetState(() {}));
    
    // Start lockout timer
    _startLockoutTimer();
    
    // Listen to text changes for button enabling/disabling
    _model.emailAddressTextController?.addListener(_updateLoginButtonState);
    _model.passwordTextController?.addListener(_updateLoginButtonState);
    _model.emailAddressCreateTextController?.addListener(_updateSignupButtonState);
    _model.passwordCreateTextController?.addListener(_updateSignupButtonState);

    _model.emailAddressCreateTextController ??= TextEditingController();
    _model.emailAddressCreateFocusNode ??= FocusNode();

    _model.passwordCreateTextController ??= TextEditingController();
    _model.passwordCreateFocusNode ??= FocusNode();

    _model.emailAddressTextController ??= TextEditingController();
    _model.emailAddressFocusNode ??= FocusNode();

    _model.passwordTextController ??= TextEditingController();
    _model.passwordFocusNode ??= FocusNode();

    animationsMap.addAll({
      'containerOnPageLoadAnimation': AnimationInfo(
        trigger: AnimationTrigger.onPageLoad,
        effectsBuilder: () => [
          VisibilityEffect(duration: 1.ms),
          FadeEffect(
            curve: Curves.easeInOut,
            delay: 0.0.ms,
            duration: 600.0.ms,
            begin: 0.0,
            end: 1.0,
          ),
          MoveEffect(
            curve: Curves.easeInOut,
            delay: 0.0.ms,
            duration: 600.0.ms,
            begin: const Offset(0.0, 80.0),
            end: const Offset(0.0, 0.0),
          ),
          ScaleEffect(
            curve: Curves.easeInOut,
            delay: 200.0.ms,
            duration: 600.0.ms,
            begin: const Offset(0.8, 0.8),
            end: const Offset(1.0, 1.0),
          ),
        ],
      ),
      'columnOnPageLoadAnimation1': AnimationInfo(
        trigger: AnimationTrigger.onPageLoad,
        effectsBuilder: () => [
          VisibilityEffect(duration: 300.ms),
          FadeEffect(
            curve: Curves.easeInOut,
            delay: 400.0.ms,
            duration: 600.0.ms,
            begin: 0.0,
            end: 1.0,
          ),
          MoveEffect(
            curve: Curves.easeInOut,
            delay: 400.0.ms,
            duration: 600.0.ms,
            begin: const Offset(0.0, 20.0),
            end: const Offset(0.0, 0.0),
          ),
        ],
      ),
      'columnOnPageLoadAnimation2': AnimationInfo(
        trigger: AnimationTrigger.onPageLoad,
        effectsBuilder: () => [
          VisibilityEffect(duration: 300.ms),
          FadeEffect(
            curve: Curves.easeInOut,
            delay: 600.0.ms,
            duration: 600.0.ms,
            begin: 0.0,
            end: 1.0,
          ),
          MoveEffect(
            curve: Curves.easeInOut,
            delay: 600.0.ms,
            duration: 600.0.ms,
            begin: const Offset(0.0, 20.0),
            end: const Offset(0.0, 0.0),
          ),
        ],
      ),
    });
  }

  @override
  void dispose() {
    _lockoutTimer?.cancel();
    _model.emailAddressTextController?.removeListener(_updateLoginButtonState);
    _model.passwordTextController?.removeListener(_updateLoginButtonState);
    _model.emailAddressCreateTextController?.removeListener(_updateSignupButtonState);
    _model.passwordCreateTextController?.removeListener(_updateSignupButtonState);
    _model.dispose();
    super.dispose();
  }
  
  // Update login button state based on form validity
  void _updateLoginButtonState() {
    final email = _model.emailAddressTextController?.text.trim() ?? '';
    final password = _model.passwordTextController?.text.trim() ?? '';
    final identifier = SecurityUtils.sanitizeEmail(email);
    
    // Check if locked due to brute force
    final isLocked = BruteForceProtection.isLocked(identifier);
    
    setState(() {
      _isLoginDisabled = email.isEmpty || password.isEmpty || isLocked;
    });
  }
  
  // Update signup button state based on form validity
  void _updateSignupButtonState() {
    final email = _model.emailAddressCreateTextController?.text.trim() ?? '';
    final password = _model.passwordCreateTextController?.text.trim() ?? '';
    final identifier = SecurityUtils.sanitizeEmail(email);
    
    // Check if locked due to brute force
    final isLocked = BruteForceProtection.isLocked(identifier);
    
    setState(() {
      _isSignupDisabled = email.isEmpty || password.isEmpty || isLocked;
    });
  }
  
  // Start lockout timer to update UI
  void _startLockoutTimer() {
    _lockoutTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _updateLoginButtonState();
          _updateSignupButtonState();
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
        body: SafeArea(
          top: true,
                child: Container(
                  width: double.infinity,
            height: double.infinity,
                  decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  FlutterFlowTheme.of(context).primary,
                  FlutterFlowTheme.of(context).secondary,
                ],
                stops: const [0.0, 1.0],
                begin: const AlignmentDirectional(-1.0, -1.0),
                end: const AlignmentDirectional(1.0, 1.0),
              ),
            ),
            child: MediaQuery.of(context).size.width > 768 
              ? _buildDesktopLayout()
              : _buildMobileLayout(),
                          ),
                    ),
                  ),
    );
  }

  Widget _buildMobileLayout() {
    return Column(
      mainAxisSize: MainAxisSize.max,
      children: [
        _buildHeaderSection(),
        Expanded(child: _buildAuthCard()),
      ],
    );
  }

  Widget _buildDesktopLayout() {
    return Row(
      children: [
        // Left side - Branding
        Expanded(
          flex: 1,
          child: Container(
            padding: const EdgeInsetsDirectional.fromSTEB(60.0, 40.0, 60.0, 40.0),
            child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                  width: 100.0,
                  height: 100.0,
                          decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(24.0),
                            border: Border.all(
                      color: Colors.white.withValues(alpha: 0.3),
                      width: 1.0,
                    ),
                  ),
                  child: const Icon(
                    Icons.shopping_bag_rounded,
                    color: Colors.white,
                    size: 50.0,
                  ),
                ).animateOnPageLoad(
                  animationsMap['containerOnPageLoadAnimation']!,
                ),
                const SizedBox(height: 32.0),
                Text(
                  'Welcome to ShopLendr',
                  style: FlutterFlowTheme.of(context).displayMedium.override(
                                              font: GoogleFonts.interTight(
                      fontWeight: FontWeight.bold,
                    ),
                    color: Colors.white,
                    fontSize: 42.0,
                                              letterSpacing: 0.0,
                  ),
                ).animateOnPageLoad(
                  animationsMap['containerOnPageLoadAnimation']!,
                ),
                const SizedBox(height: 16.0),
                Text(
                  'Your trusted marketplace for buying and selling items. Connect with your community and discover amazing deals.',
                  style: FlutterFlowTheme.of(context).bodyLarge.override(
                    font: GoogleFonts.inter(),
                    color: Colors.white.withValues(alpha: 0.9),
                    fontSize: 18.0,
                    letterSpacing: 0.0,
                  ).copyWith(height: 1.5),
                ).animateOnPageLoad(
                  animationsMap['containerOnPageLoadAnimation']!,
                ),
                const SizedBox(height: 32.0),
                Row(
                                    children: [
                    Icon(
                      Icons.security,
                      color: Colors.white.withValues(alpha: 0.8),
                      size: 20.0,
                    ),
                    const SizedBox(width: 8.0),
                                                      Text(
                      'Secure & Trusted Platform',
                      style: FlutterFlowTheme.of(context).bodyMedium.override(
                        font: GoogleFonts.inter(),
                        color: Colors.white.withValues(alpha: 0.8),
                        letterSpacing: 0.0,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12.0),
                Row(
                  children: [
                    Icon(
                      Icons.people,
                      color: Colors.white.withValues(alpha: 0.8),
                      size: 20.0,
                    ),
                    const SizedBox(width: 8.0),
                    Text(
                      'Join thousands of users',
                      style: FlutterFlowTheme.of(context).bodyMedium.override(
                        font: GoogleFonts.inter(),
                        color: Colors.white.withValues(alpha: 0.8),
                        letterSpacing: 0.0,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        // Right side - Auth Form
        Expanded(
          flex: 1,
          child: Container(
            padding: const EdgeInsetsDirectional.fromSTEB(40.0, 40.0, 40.0, 40.0),
            child: Center(
              child: SizedBox(
                width: 450.0,
                child: _buildAuthCard(),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeaderSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsetsDirectional.fromSTEB(24.0, 20.0, 24.0, 20.0),
      child: Column(
        children: [
          // Logo/Icon
          Container(
            width: 60.0,
            height: 60.0,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(20.0),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.3),
                width: 1.0,
              ),
            ),
            child: const Icon(
              Icons.shopping_bag_rounded,
              color: Colors.white,
              size: 30.0,
            ),
          ).animateOnPageLoad(
            animationsMap['containerOnPageLoadAnimation']!,
          ),
          const SizedBox(height: 12.0),
          // App Title
          Text(
            'ShopLendr',
            style: FlutterFlowTheme.of(context).displaySmall.override(
              font: GoogleFonts.interTight(
                fontWeight: FontWeight.bold,
              ),
              color: Colors.white,
              fontSize: 28.0,
              letterSpacing: 0.0,
            ),
          ).animateOnPageLoad(
            animationsMap['containerOnPageLoadAnimation']!,
          ),
          const SizedBox(height: 4.0),
          Text(
            'Your trusted marketplace',
            style: FlutterFlowTheme.of(context).bodyLarge.override(
              font: GoogleFonts.inter(),
              color: Colors.white.withValues(alpha: 0.8),
              fontSize: 14.0,
              letterSpacing: 0.0,
            ),
          ).animateOnPageLoad(
            animationsMap['containerOnPageLoadAnimation']!,
          ),
        ],
      ),
    );
  }

  Widget _buildAuthCard() {
    return Container(
      width: double.infinity,
      constraints: BoxConstraints(
        maxWidth: MediaQuery.of(context).size.width > 768 ? 450.0 : MediaQuery.of(context).size.width - 48.0,
      ),
      margin: EdgeInsetsDirectional.fromSTEB(
        MediaQuery.of(context).size.width > 768 ? 0.0 : 24.0, 
        0.0, 
        MediaQuery.of(context).size.width > 768 ? 0.0 : 24.0, 
        MediaQuery.of(context).size.width > 768 ? 40.0 : 24.0
      ),
      decoration: BoxDecoration(
        color: FlutterFlowTheme.of(context).secondaryBackground,
        borderRadius: BorderRadius.circular(24.0),
        boxShadow: [
          BoxShadow(
            blurRadius: 20.0,
            color: Colors.black.withValues(alpha: 0.1),
            offset: const Offset(0.0, 10.0),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Tab Bar
          Container(
            margin: const EdgeInsetsDirectional.fromSTEB(0.0, 16.0, 0.0, 0.0),
            child: TabBar(
              controller: _model.tabBarController,
              isScrollable: false,
              labelColor: FlutterFlowTheme.of(context).primary,
              unselectedLabelColor: FlutterFlowTheme.of(context).secondaryText,
              labelStyle: FlutterFlowTheme.of(context).titleMedium.override(
                font: GoogleFonts.inter(
                  fontWeight: FontWeight.w600,
                ),
                letterSpacing: 0.0,
              ),
              unselectedLabelStyle: FlutterFlowTheme.of(context).titleMedium.override(
                font: GoogleFonts.inter(),
                letterSpacing: 0.0,
              ),
              indicatorColor: FlutterFlowTheme.of(context).primary,
              indicatorWeight: 3.0,
              indicatorPadding: const EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 0.0),
              tabs: const [
                Tab(
                  text: 'Sign In',
                ),
                Tab(
                  text: 'Sign Up',
                ),
              ],
              dividerColor: Colors.transparent,
            ),
          ),

          // Tab Content
          Expanded(
            child: TabBarView(
              controller: _model.tabBarController,
              children: [
                // Sign In Tab
                _buildSignInForm(),
                // Sign Up Tab
                _buildSignUpForm(),
              ],
            ),
          ),
        ],
      ),
    ).animateOnPageLoad(
      animationsMap['columnOnPageLoadAnimation1']!,
    );
  }

  Widget _buildSignInForm() {
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(24.0, 12.0, 24.0, 24.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Welcome Text
          Text(
            'Welcome Back!',
            style: FlutterFlowTheme.of(context).headlineMedium.override(
              font: GoogleFonts.inter(
                fontWeight: FontWeight.bold,
              ),
              letterSpacing: 0.0,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4.0),
          Text(
            'Sign in to continue to your account',
            style: FlutterFlowTheme.of(context).bodyMedium.override(
              font: GoogleFonts.inter(),
              color: FlutterFlowTheme.of(context).secondaryText,
              letterSpacing: 0.0,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16.0),

          // Email Field
          _buildTextField(
            controller: _model.emailAddressTextController!,
            focusNode: _model.emailAddressFocusNode!,
            labelText: 'Email',
            hintText: 'Enter your email',
            icon: Icons.email_outlined,
            keyboardType: TextInputType.emailAddress,
            autofillHints: const [AutofillHints.email],
            validator: _model.emailAddressTextControllerValidator,
          ),
          const SizedBox(height: 12.0),

          // Password Field
          _buildTextField(
            controller: _model.passwordTextController!,
            focusNode: _model.passwordFocusNode!,
            labelText: 'Password',
            hintText: 'Enter your password',
            icon: Icons.lock_outline,
            obscureText: !_model.passwordVisibility,
            suffixIcon: IconButton(
              onPressed: () => safeSetState(() {
                _model.passwordVisibility = !_model.passwordVisibility;
              }),
              icon: Icon(
                _model.passwordVisibility
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined,
                color: FlutterFlowTheme.of(context).secondaryText,
                size: 20.0,
              ),
            ),
            autofillHints: const [AutofillHints.password],
          ),
          const SizedBox(height: 12.0),

          // Forgot Password
          Align(
            alignment: const AlignmentDirectional(1.0, 0.0),
            child: TextButton(
              onPressed: () async {
                if (!mounted) return;
                final email = _model.emailAddressTextController.text.trim();
                if (email.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Enter your email to reset password.')),
                  );
                  return;
                }
                try {
                  await authManager.resetPassword(email: email, context: context);
                } catch (_) {}
              },
              child: Text(
                'Forgot Password?',
                style: FlutterFlowTheme.of(context).bodyMedium.override(
                  font: GoogleFonts.inter(),
                  color: FlutterFlowTheme.of(context).primary,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.0,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16.0),

          // Sign In Button
          Builder(
            builder: (context) {
              final email = _model.emailAddressTextController?.text.trim() ?? '';
              final identifier = SecurityUtils.sanitizeEmail(email);
              final isLocked = BruteForceProtection.isLocked(identifier);
              final lockoutRemaining = BruteForceProtection.getRemainingLockoutTime(identifier);
              final failedAttempts = BruteForceProtection.getFailedAttemptCount(identifier);
              
              String buttonText = 'Sign In';
              String? lockoutMessage;
              
              if (isLocked && lockoutRemaining != null) {
                final minutes = lockoutRemaining.inMinutes;
                final seconds = lockoutRemaining.inSeconds % 60;
                buttonText = 'Locked';
                lockoutMessage = minutes > 0
                    ? 'Too many failed attempts. Please try again in $minutes:${seconds.toString().padLeft(2, '0')}'
                    : 'Too many failed attempts. Please try again in ${seconds}s';
              } else if (failedAttempts > 0) {
                lockoutMessage = '$failedAttempts failed attempt${failedAttempts > 1 ? 's' : ''}. After 5 attempts, you will be locked out for 5 minutes.';
              }
              
              return Column(
                children: [
                  if (lockoutMessage != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12.0),
                      child: Container(
                        padding: const EdgeInsets.all(12.0),
                        decoration: BoxDecoration(
                          color: isLocked
                              ? FlutterFlowTheme.of(context).error.withValues(alpha: 0.1)
                              : FlutterFlowTheme.of(context).warning.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8.0),
                          border: Border.all(
                            color: isLocked
                                ? FlutterFlowTheme.of(context).error
                                : FlutterFlowTheme.of(context).warning,
                            width: 1.0,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              isLocked ? Icons.lock_outlined : Icons.warning_amber_rounded,
                              color: isLocked
                                  ? FlutterFlowTheme.of(context).error
                                  : FlutterFlowTheme.of(context).warning,
                              size: 18.0,
                            ),
                            const SizedBox(width: 8.0),
                            Expanded(
                              child: Text(
                                lockoutMessage,
                                style: FlutterFlowTheme.of(context).bodySmall.override(
                                      font: GoogleFonts.inter(),
                                      color: isLocked
                                          ? FlutterFlowTheme.of(context).error
                                          : FlutterFlowTheme.of(context).warning,
                                      fontSize: 12.0,
                                      letterSpacing: 0.0,
                                    ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  _buildPrimaryButton(
                    text: buttonText,
                    onPressed: _isLoginDisabled ? null : () async {
                      if (_model.formKey.currentState?.validate() ?? true) {
                        GoRouter.of(context).prepareAuthEvent();

                        // Store context-dependent values BEFORE async operations
                        final theme = FlutterFlowTheme.of(context);
                        final messenger = ScaffoldMessenger.of(context);
                        final router = GoRouter.of(context);
                        
                        // Sanitize inputs
                        final emailText = _model.emailAddressTextController?.text ?? '';
                        final passwordText = _model.passwordTextController?.text ?? '';
                        final sanitizedEmail = SecurityUtils.sanitizeEmail(emailText);
                        final sanitizedPassword = SecurityUtils.sanitizePassword(passwordText);

                        final user = await authManager.signInWithEmail(
                          context,
                          sanitizedEmail,
                          sanitizedPassword,
                        );

                        if (!mounted) return;
                        
                        if (user == null) {
                          // Record failed attempt
                          BruteForceProtection.recordFailedAttempt(sanitizedEmail);
                          _loginFailedAttempts = BruteForceProtection.getFailedAttemptCount(sanitizedEmail);
                          
                          if (!mounted) return;
                          setState(() {
                            _updateLoginButtonState();
                          });
                          
                          if (!mounted) return;
                          messenger.showSnackBar(
                            SnackBar(
                              content: Text(
                                _loginFailedAttempts >= 3
                                    ? 'Invalid credentials. ${5 - _loginFailedAttempts} attempts remaining before lockout.'
                                    : 'Invalid email or password. Please try again.',
                              ),
                              backgroundColor: theme.error,
                              duration: const Duration(seconds: 3),
                            ),
                          );
                          return;
                        }

                        // Record successful login
                        BruteForceProtection.recordSuccess(sanitizedEmail);
                        _loginFailedAttempts = 0;

                        // Show success message
                        if (!mounted) return;
                        messenger.showSnackBar(
                          const SnackBar(
                            content: Text('Sign in successful!'),
                            backgroundColor: Colors.green,
                            duration: Duration(seconds: 2),
                          ),
                        );

                        // Redirect based on user role (admin or student)
                        if (!mounted) return;
                        
                        // Handle redirect inline to avoid BuildContext usage across async gap
                        if (currentUserReference == null) {
                          router.goNamed(HomepageCopy2CopyWidget.routeName);
                          return;
                        }

                        // Get admin user record to check role
                        final adminUser = await AdminService.getAdminUser(currentUserReference!);
                        
                        if (!mounted) return;

                        if (adminUser != null && adminUser.isActive) {
                          // User has admin panel access
                          final role = adminUser.role;
                          if (role == AdminService.roleAdmin || role == AdminService.roleSuperAdmin) {
                            // Redirect to admin dashboard
                            router.goNamed(AdminDashboardWidget.routeName);
                          } else if (role == AdminService.roleModerator) {
                            // Redirect to moderator dashboard
                            router.goNamed(ModeratorDashboardWidget.routeName);
                          } else {
                            // Unknown role, redirect to student homepage
                            router.goNamed(HomepageCopy2CopyWidget.routeName);
                          }
                        } else {
                          // Regular student user
                          router.goNamed(HomepageCopy2CopyWidget.routeName);
                        }
                      }
                    },
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 16.0),

          // Divider
          _buildDivider(),
          const SizedBox(height: 12.0),

          // Social Sign In
          _buildSocialSignInButtons(),
        ],
      ),
    );
  }

  Widget _buildSignUpForm() {
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(24.0, 12.0, 24.0, 24.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Welcome Text
          Text(
            'Create Account',
            style: FlutterFlowTheme.of(context).headlineMedium.override(
              font: GoogleFonts.inter(
                fontWeight: FontWeight.bold,
              ),
              letterSpacing: 0.0,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4.0),
          Text(
            'Join ShopLendr and start your journey',
            style: FlutterFlowTheme.of(context).bodyMedium.override(
              font: GoogleFonts.inter(),
              color: FlutterFlowTheme.of(context).secondaryText,
              letterSpacing: 0.0,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16.0),

          // Email Field
          _buildTextField(
            controller: _model.emailAddressCreateTextController!,
            focusNode: _model.emailAddressCreateFocusNode!,
            labelText: 'Email',
            hintText: 'Enter your email',
            icon: Icons.email_outlined,
            keyboardType: TextInputType.emailAddress,
            autofillHints: const [AutofillHints.email],
            validator: _model.emailAddressCreateTextControllerValidator,
          ),
          const SizedBox(height: 12.0),

          // Password Field
          _buildTextField(
            controller: _model.passwordCreateTextController!,
            focusNode: _model.passwordCreateFocusNode!,
            labelText: 'Password',
            hintText: 'Create a password',
            icon: Icons.lock_outline,
            obscureText: !_model.passwordCreateVisibility,
            suffixIcon: IconButton(
              onPressed: () => safeSetState(() {
                _model.passwordCreateVisibility = !_model.passwordCreateVisibility;
              }),
              icon: Icon(
                _model.passwordCreateVisibility
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined,
                color: FlutterFlowTheme.of(context).secondaryText,
                size: 20.0,
              ),
            ),
            autofillHints: const [AutofillHints.newPassword],
          ),
          const SizedBox(height: 12.0),

          // Terms and Conditions
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: 'By signing up, you agree to our ',
                  style: FlutterFlowTheme.of(context).bodySmall.override(
                    font: GoogleFonts.inter(),
                    letterSpacing: 0.0,
                  ),
                ),
                TextSpan(
                  text: 'Terms of Service',
                  style: FlutterFlowTheme.of(context).bodySmall.override(
                    font: GoogleFonts.inter(),
                    color: FlutterFlowTheme.of(context).primary,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.0,
                  ),
                  recognizer: TapGestureRecognizer()
                    ..onTap = () {
                      if (!mounted) return;
                      context.pushNamed('terms');
                    },
                ),
                TextSpan(
                  text: ' and ',
                  style: FlutterFlowTheme.of(context).bodySmall.override(
                    font: GoogleFonts.inter(),
                    letterSpacing: 0.0,
                  ),
                ),
                TextSpan(
                  text: 'Privacy Policy',
                  style: FlutterFlowTheme.of(context).bodySmall.override(
                    font: GoogleFonts.inter(),
                    color: FlutterFlowTheme.of(context).primary,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.0,
                  ),
                  recognizer: TapGestureRecognizer()
                    ..onTap = () {
                      if (!mounted) return;
                      context.pushNamed('privacy');
                    },
                ),
              ],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16.0),

          // Sign Up Button
          Builder(
            builder: (context) {
              final email = _model.emailAddressCreateTextController?.text.trim() ?? '';
              final identifier = SecurityUtils.sanitizeEmail(email);
              final isLocked = BruteForceProtection.isLocked(identifier);
              final lockoutRemaining = BruteForceProtection.getRemainingLockoutTime(identifier);
              final failedAttempts = BruteForceProtection.getFailedAttemptCount(identifier);
              
              String buttonText = 'Create Account';
              String? lockoutMessage;
              
              if (isLocked && lockoutRemaining != null) {
                final minutes = lockoutRemaining.inMinutes;
                final seconds = lockoutRemaining.inSeconds % 60;
                buttonText = 'Locked';
                lockoutMessage = minutes > 0
                    ? 'Too many failed attempts. Please try again in $minutes:${seconds.toString().padLeft(2, '0')}'
                    : 'Too many failed attempts. Please try again in ${seconds}s';
              } else if (failedAttempts > 0) {
                lockoutMessage = '$failedAttempts failed attempt${failedAttempts > 1 ? 's' : ''}. After 5 attempts, you will be locked out for 5 minutes.';
              }
              
              return Column(
                children: [
                  if (lockoutMessage != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12.0),
                      child: Container(
                        padding: const EdgeInsets.all(12.0),
                        decoration: BoxDecoration(
                          color: isLocked
                              ? FlutterFlowTheme.of(context).error.withValues(alpha: 0.1)
                              : FlutterFlowTheme.of(context).warning.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8.0),
                          border: Border.all(
                            color: isLocked
                                ? FlutterFlowTheme.of(context).error
                                : FlutterFlowTheme.of(context).warning,
                            width: 1.0,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              isLocked ? Icons.lock_outlined : Icons.warning_amber_rounded,
                              color: isLocked
                                  ? FlutterFlowTheme.of(context).error
                                  : FlutterFlowTheme.of(context).warning,
                              size: 18.0,
                            ),
                            const SizedBox(width: 8.0),
                            Expanded(
                              child: Text(
                                lockoutMessage,
                                style: FlutterFlowTheme.of(context).bodySmall.override(
                                      font: GoogleFonts.inter(),
                                      color: isLocked
                                          ? FlutterFlowTheme.of(context).error
                                          : FlutterFlowTheme.of(context).warning,
                                      fontSize: 12.0,
                                      letterSpacing: 0.0,
                                    ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  _buildPrimaryButton(
                    text: buttonText,
                    onPressed: _isSignupDisabled ? null : () async {
                      if (_model.formKey.currentState?.validate() ?? true) {
                        GoRouter.of(context).prepareAuthEvent();

                        // Store context-dependent values BEFORE async operations
                        final theme = FlutterFlowTheme.of(context);
                        final messenger = ScaffoldMessenger.of(context);
                        final router = GoRouter.of(context);
                        
                        // Sanitize inputs
                        final createEmailText = _model.emailAddressCreateTextController?.text ?? '';
                        final createPasswordText = _model.passwordCreateTextController?.text ?? '';
                        final sanitizedEmail = SecurityUtils.sanitizeEmail(createEmailText);
                        final sanitizedPassword = SecurityUtils.sanitizePassword(createPasswordText);

                        final user = await authManager.createAccountWithEmail(
                          context,
                          sanitizedEmail,
                          sanitizedPassword,
                        );

                        if (!mounted) return;
                        
                        if (user == null) {
                          // Record failed attempt
                          BruteForceProtection.recordFailedAttempt(sanitizedEmail);
                          _signupFailedAttempts = BruteForceProtection.getFailedAttemptCount(sanitizedEmail);
                          
                          if (!mounted) return;
                          setState(() {
                            _updateSignupButtonState();
                          });
                          
                          if (!mounted) return;
                          messenger.showSnackBar(
                            SnackBar(
                              content: Text(
                                _signupFailedAttempts >= 3
                                    ? 'Account creation failed. ${5 - _signupFailedAttempts} attempts remaining before lockout.'
                                    : 'Account creation failed. Please try again.',
                              ),
                              backgroundColor: theme.error,
                              duration: const Duration(seconds: 3),
                            ),
                          );
                          return;
                        }

                        // Record successful signup
                        BruteForceProtection.recordSuccess(sanitizedEmail);
                        _signupFailedAttempts = 0;

                        // Show success message
                        if (!mounted) return;
                        messenger.showSnackBar(
                          const SnackBar(
                            content: Text('Account created successfully!'),
                            backgroundColor: Colors.green,
                            duration: Duration(seconds: 2),
                          ),
                        );

                        if (!mounted) return;
                        router.goNamed(
                          HomepageCopy2CopyWidget.routeName,
                        );
                      }
                    },
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 16.0),

          // Divider
          _buildDivider(),
          const SizedBox(height: 12.0),

          // Social Sign Up
          _buildSocialSignInButtons(),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required FocusNode focusNode,
    required String labelText,
    required String hintText,
    required IconData icon,
    TextInputType? keyboardType,
    bool obscureText = false,
    Widget? suffixIcon,
    List<String>? autofillHints,
    String? Function(BuildContext, String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      focusNode: focusNode,
      keyboardType: keyboardType,
      obscureText: obscureText,
      autofillHints: autofillHints,
      decoration: InputDecoration(
        labelText: labelText,
        hintText: hintText,
        prefixIcon: Icon(
          icon,
          color: FlutterFlowTheme.of(context).secondaryText,
          size: 20.0,
        ),
        suffixIcon: suffixIcon,
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: FlutterFlowTheme.of(context).alternate,
            width: 1.0,
          ),
          borderRadius: BorderRadius.circular(12.0),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: FlutterFlowTheme.of(context).primary,
                                                            width: 2.0,
                                                          ),
          borderRadius: BorderRadius.circular(12.0),
        ),
        errorBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: FlutterFlowTheme.of(context).error,
            width: 1.0,
          ),
          borderRadius: BorderRadius.circular(12.0),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: FlutterFlowTheme.of(context).error,
                                                            width: 2.0,
                                                          ),
          borderRadius: BorderRadius.circular(12.0),
                                                        ),
                                                        filled: true,
        fillColor: FlutterFlowTheme.of(context).primaryBackground,
        contentPadding: const EdgeInsetsDirectional.fromSTEB(16.0, 20.0, 16.0, 20.0),
      ),
      style: FlutterFlowTheme.of(context).bodyLarge.override(
        font: GoogleFonts.inter(),
        letterSpacing: 0.0,
      ),
      validator: validator != null 
          ? (value) => validator(context, value)
          : (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your $labelText';
              }
              if (labelText == 'Password' && value.length < 6) {
                return 'Password must be at least 6 characters';
              }
              return null;
            },
    );
  }

  Widget _buildPrimaryButton({
    required String text,
    required VoidCallback? onPressed,
  }) {
    final isDisabled = onPressed == null;
    
    return FFButtonWidget(
      onPressed: onPressed,
      text: text,
      options: FFButtonOptions(
        width: double.infinity,
        height: 48.0,
        padding: const EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 0.0),
        iconPadding: const EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 0.0),
        color: isDisabled
            ? FlutterFlowTheme.of(context).alternate
            : FlutterFlowTheme.of(context).primary,
        textStyle: FlutterFlowTheme.of(context).titleMedium.override(
          font: GoogleFonts.inter(
            fontWeight: FontWeight.w600,
          ),
          color: Colors.white,
          letterSpacing: 0.0,
          fontSize: 16.0,
        ),
        elevation: 0.0,
        borderSide: const BorderSide(
          color: Colors.transparent,
          width: 1.0,
        ),
        borderRadius: BorderRadius.circular(12.0),
        hoverColor: FlutterFlowTheme.of(context).primary.withValues(alpha: 0.8),
      ),
    );
  }

  Widget _buildDivider() {
    return Row(
      children: [
        Expanded(
          child: Divider(
            thickness: 1.0,
            color: FlutterFlowTheme.of(context).alternate,
          ),
        ),
        Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(16.0, 0.0, 16.0, 0.0),
                                                    child: Text(
            'or',
            style: FlutterFlowTheme.of(context).bodySmall.override(
              font: GoogleFonts.inter(),
              color: FlutterFlowTheme.of(context).secondaryText,
              letterSpacing: 0.0,
            ),
          ),
        ),
        Expanded(
          child: Divider(
            thickness: 1.0,
            color: FlutterFlowTheme.of(context).alternate,
          ),
        ),
      ],
    );
  }

  Widget _buildSocialSignInButtons() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Google Sign In
        FFButtonWidget(
                                                          onPressed: () async {
            GoRouter.of(context).prepareAuthEvent();
            final user = await authManager.signInWithGoogle(context);
                                                            if (user == null) {
                                                              return;
                                                            }

            if (_model.tabBarController?.index == 0) {
              // Sign in - redirect based on role
              if (!mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Sign in successful!'),
                  backgroundColor: Colors.green,
                  duration: Duration(seconds: 2),
                ),
              );
              await AuthRedirectHelper.redirectAfterLogin(context);
            } else {
              // Sign up
              if (!mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Account created successfully!'),
                  backgroundColor: Colors.green,
                  duration: Duration(seconds: 2),
                ),
              );
              context.goNamedAuth(
                HomepageCopy2CopyWidget.routeName,
                context.mounted,
              );
            }
          },
          text: 'Continue with Google',
          icon: const FaIcon(
            FontAwesomeIcons.google,
            size: 20.0,
            color: Colors.white,
          ),
          options: FFButtonOptions(
            width: double.infinity,
            height: 48.0,
            padding: const EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 0.0),
            iconPadding: const EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 12.0, 0.0),
            color: const Color(0xFF4285F4),
            textStyle: FlutterFlowTheme.of(context).titleMedium.override(
              font: GoogleFonts.inter(
                fontWeight: FontWeight.w600,
              ),
              color: Colors.white,
              letterSpacing: 0.0,
              fontSize: 16.0,
            ),
            elevation: 0.0,
            borderSide: const BorderSide(
              color: Colors.transparent,
              width: 1.0,
            ),
            borderRadius: BorderRadius.circular(12.0),
            hoverColor: const Color(0xFF3367D6),
          ),
        ),
        if (Theme.of(context).platform == TargetPlatform.iOS)
          const SizedBox(height: 12.0),

        // Apple Sign In (iOS only)
        if (Theme.of(context).platform == TargetPlatform.iOS)
          FFButtonWidget(
            onPressed: () async {
              GoRouter.of(context).prepareAuthEvent();
              final user = await authManager.signInWithApple(context);
              if (user == null) {
                return;
              }

              if (_model.tabBarController?.index == 0) {
                // Sign in
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Sign in successful!'),
                    backgroundColor: Colors.green,
                    duration: Duration(seconds: 2),
                  ),
                );
                await AuthRedirectHelper.redirectAfterLogin(context);
              } else {
                // Sign up
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Account created successfully!'),
                    backgroundColor: Colors.green,
                    duration: Duration(seconds: 2),
                  ),
                );
                context.goNamedAuth(
                  HomepageCopy2CopyWidget.routeName,
                  context.mounted,
                );
              }
            },
            text: 'Continue with Apple',
            icon: const FaIcon(
              FontAwesomeIcons.apple,
              size: 20.0,
              color: Colors.white,
            ),
            options: FFButtonOptions(
              width: double.infinity,
              height: 48.0,
              padding: const EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 0.0),
              iconPadding: const EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 12.0, 0.0),
              color: Colors.black,
              textStyle: FlutterFlowTheme.of(context).titleMedium.override(
                font: GoogleFonts.inter(
                  fontWeight: FontWeight.w600,
                ),
                color: Colors.white,
                letterSpacing: 0.0,
                fontSize: 16.0,
              ),
              elevation: 0.0,
              borderSide: const BorderSide(
                color: Colors.transparent,
                width: 1.0,
              ),
              borderRadius: BorderRadius.circular(12.0),
              hoverColor: Colors.black.withValues(alpha: 0.8),
            ),
                                      ),
                                    ],
    );
  }
}