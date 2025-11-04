import '/auth/firebase_auth/auth_util.dart';
import '/backend/backend.dart';
import '/components/bottom_nav_bar.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'message_model.dart';
export 'message_model.dart';

class MessageWidget extends StatefulWidget {
  const MessageWidget({super.key});

  static String routeName = 'Message';
  static String routePath = '/message';

  @override
  State<MessageWidget> createState() => _MessageWidgetState();
}

class _MessageWidgetState extends State<MessageWidget> {
  late MessageModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => MessageModel());
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
        appBar: AppBar(
          backgroundColor: FlutterFlowTheme.of(context).secondaryBackground,
          automaticallyImplyLeading: false,
          title: Text(
            'Messages',
            style: FlutterFlowTheme.of(context).headlineMedium.override(
                  font: GoogleFonts.interTight(
                    fontWeight: FontWeight.bold,
                  ),
                  color: FlutterFlowTheme.of(context).primaryText,
                  fontSize: 24,
                  letterSpacing: -0.5,
                ),
          ),
          actions: const [],
          centerTitle: true,
          elevation: 0.5,
        ),
        body: SafeArea(
          top: true,
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: [
              Expanded(
                child: FutureBuilder<List<MessagesRecord>>(
                  future: _getAllUserThreads(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return Center(
                        child: SizedBox(
                          width: 50.0,
                          height: 50.0,
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(
                              FlutterFlowTheme.of(context).primary,
                            ),
                          ),
                        ),
                      );
                    }
                    
                    List<MessagesRecord> allThreads = snapshot.data!;
                    
                    // Filter out admin/customer support threads
                    const adminUid = 'e5JeP91nfRVyg8ZINWKSUypPOwD2';
                    final filteredThreads = allThreads.where((thread) {
                      return thread.participants?.id != adminUid;
                    }).toList();

                    return Column(
                      mainAxisSize: MainAxisSize.max,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Support chat pinned at top
                        Padding(
                          padding: const EdgeInsetsDirectional.fromSTEB(16.0, 0.0, 16.0, 0.0),
                          child: InkWell(
                            splashColor: Colors.transparent,
                            focusColor: Colors.transparent,
                            hoverColor: Colors.transparent,
                            highlightColor: Colors.transparent,
                            onTap: () async {
                              context.pushNamed(ChatPageWidget.routeName);
                            },
                            child: Container(
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: FlutterFlowTheme.of(context).accent1,
                                borderRadius: BorderRadius.circular(12.0),
                                border: Border.all(
                                  color: FlutterFlowTheme.of(context).primary,
                                  width: 1.0,
                                ),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(12.0),
                                child: Row(
                                  mainAxisSize: MainAxisSize.max,
                                  children: [
                                    Container(
                                      width: 48.0,
                                      height: 48.0,
                                      decoration: BoxDecoration(
                                        color: FlutterFlowTheme.of(context).primary,
                                        shape: BoxShape.circle,
                                      ),
                                      child: Align(
                                        alignment: const AlignmentDirectional(0.0, 0.0),
                                        child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Text(
                                            'SL',
                                            style: FlutterFlowTheme.of(context)
                                                .titleMedium
                                                .override(
                                                  font: GoogleFonts.interTight(
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                  color: FlutterFlowTheme.of(context)
                                                      .primaryBackground,
                                                  letterSpacing: 0.0,
                                                ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: Column(
                                        mainAxisSize: MainAxisSize.max,
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Chat with ShopLendr (Customer Support)',
                                            style: FlutterFlowTheme.of(context)
                                                .titleMedium
                                                .override(
                                                  font: GoogleFonts.interTight(
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                  letterSpacing: 0.0,
                                                ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsetsDirectional.fromSTEB(0.0, 4.0, 0.0, 0.0),
                                            child: Text(
                                              'We\'re here to help! Ask us anything.',
                                              style: FlutterFlowTheme.of(context)
                                                  .bodySmall
                                                  .override(
                                                    font: GoogleFonts.inter(),
                                                    color: FlutterFlowTheme.of(context)
                                                        .secondaryText,
                                                    letterSpacing: 0.0,
                                                  ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Row(
                                      mainAxisSize: MainAxisSize.max,
                                      children: [
                                        Text(
                                          'Online',
                                          style: FlutterFlowTheme.of(context)
                                              .labelSmall
                                              .override(
                                                font: GoogleFonts.inter(
                                                  fontWeight: FontWeight.w500,
                                                ),
                                                color: FlutterFlowTheme.of(context).success,
                                                letterSpacing: 0.0,
                                              ),
                                        ),
                                        Container(
                                          width: 8.0,
                                          height: 8.0,
                                          decoration: BoxDecoration(
                                            color: FlutterFlowTheme.of(context).success,
                                            shape: BoxShape.circle,
                                          ),
                                        ),
                                      ].divide(const SizedBox(width: 4.0)),
                                    ),
                                  ].divide(const SizedBox(width: 12.0)),
                                ),
                              ),
                            ),
                          ),
                        ),
                        // User conversations
                        ...List.generate(filteredThreads.length, (index) {
                          final thread = filteredThreads[index];

                          // Determine the other participant reference correctly:
                          // - If current user owns the thread (uid == currentUserUid), other is `participants`
                          // - Else current user is the participant, other is the document with id = thread.uid
                          final DocumentReference? otherUserRef =
                              thread.uid == currentUserUid
                                  ? thread.participants
                                  : (thread.uid.isNotEmpty
                                      ? UsersRecord.collection.doc(thread.uid)
                                      : null);

                          return FutureBuilder<UsersRecord?>(
                            future: otherUserRef != null
                                ? otherUserRef.get().then((doc) {
                                    if (doc.exists) {
                                      return UsersRecord.getDocumentFromData(
                                        doc.data() as Map<String, dynamic>,
                                        doc.reference,
                                      );
                                    }
                                    return null;
                                  })
                                : Future.value(null),
                            builder: (context, userSnapshot) {
                              final otherUser = userSnapshot.data;
                              final displayName = otherUser?.displayName ??
                                  (thread.displayName.isNotEmpty
                                      ? thread.displayName
                                      : 'Unknown User');

                              return Padding(
                                padding: const EdgeInsetsDirectional.fromSTEB(16.0, 12.0, 16.0, 0.0),
                                child: InkWell(
                                  splashColor: Colors.transparent,
                                  focusColor: Colors.transparent,
                                  hoverColor: Colors.transparent,
                                  highlightColor: Colors.transparent,
                                  onTap: () async {
                                    context.pushNamed(
                                      ChatPageWidget.routeName,
                                      queryParameters: {
                                        'threadId': [thread.reference.id],
                                      },
                                    );
                                  },
                                  child: Container(
                                    width: double.infinity,
                                    decoration: BoxDecoration(
                                      color: FlutterFlowTheme.of(context).secondaryBackground,
                                      borderRadius: BorderRadius.circular(12.0),
                                      border: Border.all(
                                        color: FlutterFlowTheme.of(context).alternate,
                                        width: 1.0,
                                      ),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(12.0),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.max,
                                        children: [
                                          Container(
                                            width: 48.0,
                                            height: 48.0,
                                            decoration: BoxDecoration(
                                              color: FlutterFlowTheme.of(context).primary,
                                              shape: BoxShape.circle,
                                            ),
                                            child: Icon(
                                              Icons.person,
                                              color: FlutterFlowTheme.of(context).primaryBackground,
                                              size: 24.0,
                                            ),
                                          ),
                                          Expanded(
                                            child: Column(
                                              mainAxisSize: MainAxisSize.max,
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  displayName,
                                                  style: FlutterFlowTheme.of(context)
                                                      .titleMedium
                                                      .override(
                                                        font: GoogleFonts.interTight(
                                                          fontWeight: FontWeight.w600,
                                                        ),
                                                        letterSpacing: 0.0,
                                                      ),
                                                ),
                                                if (thread.lastMessage.isNotEmpty)
                                                  Padding(
                                                    padding: const EdgeInsetsDirectional.fromSTEB(0.0, 4.0, 0.0, 0.0),
                                                    child: Text(
                                                      thread.lastMessage,
                                                      style: FlutterFlowTheme.of(context)
                                                          .bodySmall
                                                          .override(
                                                            font: GoogleFonts.inter(),
                                                            color: FlutterFlowTheme.of(context)
                                                                .secondaryText,
                                                            letterSpacing: 0.0,
                                                          ),
                                                    ),
                                                  ),
                                              ],
                                            ),
                                          ),
                                          if (thread.updatedAt != null)
                                            Text(
                                              dateTimeFormat('jm', thread.updatedAt!),
                                              style: FlutterFlowTheme.of(context)
                                                  .labelSmall
                                                  .override(
                                                    font: GoogleFonts.inter(
                                                      fontWeight: FontWeight.w500,
                                                    ),
                                                    color: FlutterFlowTheme.of(context)
                                                        .secondaryText,
                                                    letterSpacing: 0.0,
                                                  ),
                                            ),
                                        ].divide(const SizedBox(width: 12.0)),
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          );
                        }),
                      ].addToStart(const SizedBox(height: 16.0)),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
        bottomNavigationBar: BottomNavBar(currentRoute: MessageWidget.routeName),
      ),
    );
  }

  Future<List<MessagesRecord>> _getAllUserThreads() async {
    // Get threads where user is the owner (uid field)
    final ownerThreads = await queryMessagesRecordOnce(
      queryBuilder: (messagesRecord) =>
          messagesRecord
              .where('uid', isEqualTo: currentUserUid)
              .orderBy('updatedAt', descending: true),
    );

    // Get threads where user is a participant (participants field)
    // This ensures both users can see conversations they're part of
    final participantThreads = await queryMessagesRecordOnce(
      queryBuilder: (messagesRecord) =>
          messagesRecord
              .where('participants', isEqualTo: currentUserReference)
              .orderBy('updatedAt', descending: true),
    );

    // Combine and deduplicate threads
    // Use a map to ensure no duplicate threads appear
    Map<String, MessagesRecord> uniqueThreads = {};
    
    // Add owner threads
    for (final thread in ownerThreads) {
      uniqueThreads[thread.reference.id] = thread;
    }
    
    // Add participant threads (only if not already present)
    for (final thread in participantThreads) {
      if (!uniqueThreads.containsKey(thread.reference.id)) {
        uniqueThreads[thread.reference.id] = thread;
      }
    }

    // Convert to list and sort by updatedAt
    List<MessagesRecord> allThreads = uniqueThreads.values.toList();
    allThreads.sort((a, b) {
      final aTime = a.updatedAt ?? a.createdAt ?? DateTime(1970);
      final bTime = b.updatedAt ?? b.createdAt ?? DateTime(1970);
      return bTime.compareTo(aTime);
    });

    return allThreads;
  }
}