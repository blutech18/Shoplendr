import '/auth/firebase_auth/auth_util.dart';
import '/backend/admin_service.dart';
import '/backend/backend.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/profile/profile_widget.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:io';
import 'admin_messages_model.dart';
export 'admin_messages_model.dart';

class AdminMessagesWidget extends StatefulWidget {
  const AdminMessagesWidget({super.key});

  static String routeName = 'AdminMessages';
  static String routePath = '/admin/messages';

  @override
  State<AdminMessagesWidget> createState() => _AdminMessagesWidgetState();
}

class _AdminMessagesWidgetState extends State<AdminMessagesWidget> {
  late AdminMessagesModel _model;
  final scaffoldKey = GlobalKey<ScaffoldState>();
  
  DocumentReference? selectedThreadRef;
  UsersRecord? selectedUser;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => AdminMessagesModel());
    _model.messageController = TextEditingController();
    _model.messageFocusNode = FocusNode();
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  // Supported file types
  final List<String> _supportedImageTypes = ['png', 'jpg', 'jpeg'];
  final List<String> _supportedDocumentTypes = ['pdf', 'doc', 'docx'];

  IconData _getDocumentIcon(String url) {
    final uri = Uri.parse(url);
    final pathSegments = uri.pathSegments;
    if (pathSegments.isNotEmpty) {
      final fileName = pathSegments.last;
      final extension = fileName.split('.').last.toLowerCase();
      
      switch (extension) {
        case 'pdf':
          return Icons.picture_as_pdf;
        case 'doc':
        case 'docx':
          return Icons.description;
        default:
          return Icons.description;
      }
    }
    return Icons.description;
  }

  String _getDocumentName(String url) {
    final uri = Uri.parse(url);
    final pathSegments = uri.pathSegments;
    if (pathSegments.isNotEmpty) {
      final fileName = pathSegments.last;
      final extension = fileName.split('.').last.toLowerCase();
      
      switch (extension) {
        case 'pdf':
          return 'PDF Document';
        case 'doc':
        case 'docx':
          return 'Word Document';
        default:
          return 'Document';
      }
    }
    return 'Document';
  }

  bool _isFileTypeSupported(String extension) {
    return _supportedImageTypes.contains(extension) || 
           _supportedDocumentTypes.contains(extension);
  }

  Future<void> _showAttachmentOptions() async {
    await showModalBottomSheet(
      context: context,
      backgroundColor: FlutterFlowTheme.of(context).secondaryBackground,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Attach File',
              style: FlutterFlowTheme.of(context).headlineSmall.override(
                font: GoogleFonts.interTight(fontWeight: FontWeight.bold),
                letterSpacing: 0.0,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildAttachmentOption(
                  context,
                  icon: Icons.image,
                  label: 'Images',
                  onTap: () {
                    Navigator.pop(context);
                    _pickImage();
                  },
                ),
                _buildAttachmentOption(
                  context,
                  icon: Icons.description,
                  label: 'Documents',
                  onTap: () {
                    Navigator.pop(context);
                    _pickDocument();
                  },
                ),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildAttachmentOption(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: FlutterFlowTheme.of(context).primaryBackground,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: FlutterFlowTheme.of(context).alternate,
            width: 1,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 32,
              color: FlutterFlowTheme.of(context).primary,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: FlutterFlowTheme.of(context).bodyMedium.override(
                font: GoogleFonts.inter(fontWeight: FontWeight.w600),
                letterSpacing: 0.0,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImage() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: _supportedImageTypes,
        allowMultiple: false,
      );

      if (result != null && result.files.single.path != null) {
        final file = File(result.files.single.path!);
        final fileName = result.files.single.name;
        final bytes = result.files.single.bytes;
        
        setState(() {
          _model.selectedFile = file;
          _model.selectedFileName = fileName;
          _model.selectedFileType = 'image';
          _model.selectedFileBytes = bytes;
          _model.uploadedFileUrl = null;
        });
      }
    } catch (e) {
      _showErrorSnackBar('Failed to pick image: $e');
    }
  }

  Future<void> _pickDocument() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: _supportedDocumentTypes,
        allowMultiple: false,
      );

      if (result != null && result.files.single.path != null) {
        final file = File(result.files.single.path!);
        final fileName = result.files.single.name;
        final bytes = result.files.single.bytes;
        
        setState(() {
          _model.selectedFile = file;
          _model.selectedFileName = fileName;
          _model.selectedFileType = 'document';
          _model.selectedFileBytes = bytes;
          _model.uploadedFileUrl = null;
        });
      }
    } catch (e) {
      _showErrorSnackBar('Failed to pick document: $e');
    }
  }

  void _removeAttachment() {
    setState(() {
      _model.selectedFile = null;
      _model.selectedFileName = null;
      _model.selectedFileType = null;
      _model.selectedFileBytes = null;
      _model.uploadedFileUrl = null;
    });
  }

  Future<void> _uploadAndSendMessage(File? file, String messageText) async {
    if (selectedThreadRef == null) {
      _showErrorSnackBar('Unable to send attachment');
      return;
    }

    try {
      _showLoadingSnackBar('Uploading file...');

      final fileName = _model.selectedFileName ?? 'unknown';
      final fileExtension = fileName.split('.').last.toLowerCase();
      
      if (!_isFileTypeSupported(fileExtension)) {
        _showErrorSnackBar('Unsupported file type. Please select PNG, JPG, JPEG, PDF, DOC, or DOCX files.');
        return;
      }

      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final uniqueFileName = '${timestamp}_$fileName';

      final Reference storageRef = FirebaseStorage.instance
          .ref()
          .child('chat_attachments')
          .child(uniqueFileName);

      UploadTask uploadTask;
      
      if (_model.selectedFileBytes != null) {
        uploadTask = storageRef.putData(_model.selectedFileBytes!);
      } else if (file != null) {
        uploadTask = storageRef.putFile(file);
      } else {
        _showErrorSnackBar('No file data available');
        return;
      }

      final TaskSnapshot snapshot = await uploadTask;
      final String downloadUrl = await snapshot.ref.getDownloadURL();

      await ChatsRecord.createDoc(selectedThreadRef!).set(
        createChatsRecordData(
          senderRef: currentUserReference,
          text: messageText.isNotEmpty ? messageText : (_model.selectedFileType == 'image' ? '📷 Image' : '📄 Document'),
          sentAt: getCurrentTimestamp,
          imageUrl: downloadUrl,
        ),
      );

      _removeAttachment();
      
      if (mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'File sent successfully!',
              style: FlutterFlowTheme.of(context).bodyMedium.override(
                font: GoogleFonts.inter(),
                color: Colors.white,
                letterSpacing: 0.0,
              ),
            ),
            backgroundColor: FlutterFlowTheme.of(context).success,
            duration: const Duration(seconds: 2),
          ),
        );
      }

    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        _showErrorSnackBar('Failed to upload file: $e');
      }
    }
  }

  Future<void> _handleSendMessage() async {
    if (selectedThreadRef == null) {
      return;
    }

    final messageText = _model.messageController?.text.trim() ?? '';
    final hasAttachment = _model.selectedFile != null;

    if (messageText.isEmpty && !hasAttachment) {
      return;
    }

    _model.messageController?.clear();

    if (hasAttachment) {
      await _uploadAndSendMessage(_model.selectedFile, messageText);
    } else {
      await ChatsRecord.createDoc(selectedThreadRef!).set(
        createChatsRecordData(
          senderRef: currentUserReference,
          text: messageText,
          sentAt: getCurrentTimestamp,
        ),
      );
    }
  }

  void _showImageViewer(String imageUrl) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            backgroundColor: Colors.black,
            iconTheme: const IconThemeData(color: Colors.white),
            title: const Text(
              'Image',
              style: TextStyle(color: Colors.white),
            ),
          ),
          body: Center(
            child: InteractiveViewer(
              child: CachedNetworkImage(
                imageUrl: imageUrl,
                fit: BoxFit.contain,
                placeholder: (context, url) => const Center(
                  child: CircularProgressIndicator(color: Colors.white),
                ),
                errorWidget: (context, url, error) => const Center(
                  child: Icon(
                    Icons.broken_image,
                    color: Colors.white,
                    size: 64,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _downloadDocument(String url, String fileName) async {
    try {
      final Uri uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        _showErrorSnackBar('Unable to open document');
      }
    } catch (e) {
      _showErrorSnackBar('Failed to download document: $e');
    }
  }

  void _showErrorSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            message,
            style: FlutterFlowTheme.of(context).bodyMedium.override(
              font: GoogleFonts.inter(),
              color: Colors.white,
              letterSpacing: 0.0,
            ),
          ),
          backgroundColor: FlutterFlowTheme.of(context).error,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  void _showLoadingSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    FlutterFlowTheme.of(context).primaryBackground,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                message,
                style: FlutterFlowTheme.of(context).bodyMedium.override(
                  font: GoogleFonts.inter(),
                  color: Colors.white,
                  letterSpacing: 0.0,
                ),
              ),
            ],
          ),
          backgroundColor: FlutterFlowTheme.of(context).primary,
          duration: const Duration(seconds: 30),
        ),
      );
    }
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
          appBar: AppBar(
            backgroundColor: FlutterFlowTheme.of(context).secondaryBackground,
            automaticallyImplyLeading: true,
            title: Text(
              'Customer Service Messages',
              style: FlutterFlowTheme.of(context).headlineMedium.override(
                    font: GoogleFonts.interTight(fontWeight: FontWeight.bold),
                    fontSize: 22,
                    letterSpacing: 0.0,
                  ),
            ),
            actions: const [],
            centerTitle: false,
            elevation: 1.0,
          ),
          body: LayoutBuilder(
            builder: (context, constraints) {
              final isMobile = constraints.maxWidth < 768;
              final showThreadsList = isMobile ? selectedThreadRef == null : true;
              final showChatView = isMobile ? selectedThreadRef != null : true;
              
              return Row(
                children: [
                  // Left Panel - Message Threads List
                  if (showThreadsList)
                    Container(
                      width: isMobile ? constraints.maxWidth : 350,
                      decoration: BoxDecoration(
                        color: FlutterFlowTheme.of(context).secondaryBackground,
                        border: isMobile ? null : Border(
                          right: BorderSide(
                            color: FlutterFlowTheme.of(context).alternate,
                            width: 1,
                          ),
                        ),
                      ),
                child: StreamBuilder<List<MessagesRecord>>(
                  stream: queryMessagesRecord(
                    queryBuilder: (messagesRecord) =>
                        messagesRecord
                            .where('participants', isEqualTo: currentUserReference)
                            .orderBy('updatedAt', descending: true),
                  ),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    
                    final threads = snapshot.data!;
                    
                    if (threads.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.chat_bubble_outline,
                              size: 64,
                              color: FlutterFlowTheme.of(context).secondaryText,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No messages yet',
                              style: FlutterFlowTheme.of(context).bodyLarge,
                            ),
                          ],
                        ),
                      );
                    }
                    
                    return ListView.builder(
                      itemCount: threads.length,
                      itemBuilder: (context, index) {
                        final thread = threads[index];
                        final isSelected = selectedThreadRef?.id == thread.reference.id;
                        
                        return StreamBuilder<UsersRecord>(
                          stream: UsersRecord.getDocument(UsersRecord.collection.doc(thread.uid)),
                          builder: (context, userSnapshot) {
                            final studentUser = userSnapshot.data;
                            final displayName = studentUser?.displayName ?? 'User';
                            
                            return InkWell(
                              onTap: () async {
                                // Load user data
                                final userRef = UsersRecord.collection.doc(thread.uid);
                                final userDoc = await userRef.get();
                                if (userDoc.exists) {
                                  setState(() {
                                    selectedThreadRef = thread.reference;
                                    selectedUser = UsersRecord.getDocumentFromData(
                                      userDoc.data() as Map<String, dynamic>,
                                      userDoc.reference,
                                    );
                                  });
                                }
                              },
                              child: Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? FlutterFlowTheme.of(context).accent1
                                      : FlutterFlowTheme.of(context).secondaryBackground,
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
                                      width: 48,
                                      height: 48,
                                      decoration: BoxDecoration(
                                        color: FlutterFlowTheme.of(context).primary,
                                        shape: BoxShape.circle,
                                      ),
                                      child: Center(
                                        child: Text(
                                          displayName.isNotEmpty
                                              ? displayName[0].toUpperCase()
                                              : 'U',
                                          style: FlutterFlowTheme.of(context).titleMedium.override(
                                                font: GoogleFonts.interTight(fontWeight: FontWeight.bold),
                                                color: FlutterFlowTheme.of(context).primaryBackground,
                                                letterSpacing: 0.0,
                                              ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            displayName,
                                            style: FlutterFlowTheme.of(context).titleSmall.override(
                                                  font: GoogleFonts.inter(fontWeight: FontWeight.w600),
                                                  letterSpacing: 0.0,
                                                ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                      const SizedBox(height: 4),
                                      Text(
                                        thread.lastMessage.isNotEmpty
                                            ? thread.lastMessage
                                            : 'No messages yet',
                                        style: FlutterFlowTheme.of(context).bodySmall.override(
                                              font: GoogleFonts.inter(),
                                              color: FlutterFlowTheme.of(context).secondaryText,
                                              letterSpacing: 0.0,
                                            ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                                if (thread.updatedAt != null)
                                  Text(
                                    dateTimeFormat('relative', thread.updatedAt!),
                                    style: FlutterFlowTheme.of(context).bodySmall.override(
                                          font: GoogleFonts.inter(),
                                          color: FlutterFlowTheme.of(context).secondaryText,
                                          fontSize: 11,
                                          letterSpacing: 0.0,
                                        ),
                                  ),
                                  ],
                                ),
                              ),
                            );
                          },
                        );
                      },
                    );
                  },
                ),
              ),
              // Right Panel - Chat Messages
              if (showChatView)
                Expanded(
                  child: selectedThreadRef == null
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.chat,
                              size: 64,
                              color: FlutterFlowTheme.of(context).secondaryText,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Select a conversation to view messages',
                              style: FlutterFlowTheme.of(context).bodyLarge,
                            ),
                          ],
                        ),
                      )
                    : Column(
                        children: [
                          // Chat Header
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: FlutterFlowTheme.of(context).primaryBackground,
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
                                    icon: const Icon(Icons.arrow_back),
                                    onPressed: () {
                                      setState(() {
                                        selectedThreadRef = null;
                                        selectedUser = null;
                                      });
                                    },
                                  ),
                                if (isMobile) const SizedBox(width: 8),
                                Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: FlutterFlowTheme.of(context).primary,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Center(
                                    child: Text(
                                      selectedUser?.displayName.isNotEmpty == true
                                          ? selectedUser!.displayName[0].toUpperCase()
                                          : 'U',
                                      style: FlutterFlowTheme.of(context).titleMedium.override(
                                            font: GoogleFonts.interTight(fontWeight: FontWeight.bold),
                                            color: FlutterFlowTheme.of(context).primaryBackground,
                                            letterSpacing: 0.0,
                                          ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      InkWell(
                                        onTap: selectedUser?.reference != null && selectedUser!.reference.id != currentUserUid
                                            ? () {
                                                context.pushNamed(
                                                  ProfileWidget.routeName,
                                                  queryParameters: {
                                                    'userRef': serializeParam(
                                                      selectedUser!.reference,
                                                      ParamType.DocumentReference,
                                                    ),
                                                  }.withoutNulls,
                                                );
                                              }
                                            : null,
                                        child: Text(
                                          selectedUser?.displayName ?? 'User',
                                          style: FlutterFlowTheme.of(context).titleMedium.override(
                                                font: GoogleFonts.interTight(fontWeight: FontWeight.w600),
                                                color: selectedUser?.reference != null && selectedUser!.reference.id != currentUserUid
                                                    ? FlutterFlowTheme.of(context).primary
                                                    : FlutterFlowTheme.of(context).primaryText,
                                                letterSpacing: 0.0,
                                                decoration: selectedUser?.reference != null && selectedUser!.reference.id != currentUserUid
                                                    ? TextDecoration.underline
                                                    : null,
                                              ),
                                        ),
                                      ),
                                      Text(
                                        selectedUser?.email ?? '',
                                        style: FlutterFlowTheme.of(context).bodySmall.override(
                                              font: GoogleFonts.inter(),
                                              color: FlutterFlowTheme.of(context).secondaryText,
                                              letterSpacing: 0.0,
                                            ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // Messages List
                          Expanded(
                            child: StreamBuilder<List<ChatsRecord>>(
                              stream: queryChatsRecord(
                                parent: selectedThreadRef,
                                queryBuilder: (chatsRecord) =>
                                    chatsRecord.orderBy('sentAt', descending: false),
                              ),
                              builder: (context, snapshot) {
                                if (!snapshot.hasData) {
                                  return const Center(child: CircularProgressIndicator());
                                }
                                
                                final messages = snapshot.data!;
                                
                                return ListView.builder(
                                  padding: const EdgeInsets.all(16),
                                  itemCount: messages.length,
                                  itemBuilder: (context, index) {
                                    final message = messages[index];
                                    final isAdmin = message.senderRef?.id == currentUserUid;
                                    
                                    return Padding(
                                      padding: const EdgeInsets.only(bottom: 12),
                                      child: Row(
                                        mainAxisAlignment: isAdmin
                                            ? MainAxisAlignment.end
                                            : MainAxisAlignment.start,
                                        children: [
                                          if (!isAdmin) ...[
                                            Container(
                                              width: 32,
                                              height: 32,
                                              decoration: BoxDecoration(
                                                color: FlutterFlowTheme.of(context).primary,
                                                shape: BoxShape.circle,
                                              ),
                                              child: Center(
                                                child: Text(
                                                  selectedUser?.displayName.isNotEmpty == true
                                                      ? selectedUser!.displayName[0].toUpperCase()
                                                      : 'U',
                                                  style: FlutterFlowTheme.of(context).bodySmall.override(
                                                        font: GoogleFonts.interTight(fontWeight: FontWeight.bold),
                                                        color: FlutterFlowTheme.of(context).primaryBackground,
                                                        fontSize: 12,
                                                        letterSpacing: 0.0,
                                                      ),
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                          ],
                                          Flexible(
                                            child: Column(
                                              crossAxisAlignment: isAdmin
                                                  ? CrossAxisAlignment.end
                                                  : CrossAxisAlignment.start,
                                              children: [
                                                Container(
                                                  constraints: const BoxConstraints(maxWidth: 500),
                                                  padding: const EdgeInsets.all(12),
                                                  decoration: BoxDecoration(
                                                    color: isAdmin
                                                        ? FlutterFlowTheme.of(context).primary
                                                        : FlutterFlowTheme.of(context).secondaryBackground,
                                                    borderRadius: BorderRadius.circular(12),
                                                    border: isAdmin
                                                        ? null
                                                        : Border.all(
                                                            color: FlutterFlowTheme.of(context).alternate,
                                                          ),
                                                  ),
                                                  child: Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    mainAxisSize: MainAxisSize.min,
                                                    children: [
                                                      // Show attachment if present
                                                      if (message.imageUrl.isNotEmpty) ...[
                                                        // Check if it's a document or image
                                                        if (message.text.contains('📄 Document')) ...[
                                                          // Display document
                                                          GestureDetector(
                                                            onTap: () => _downloadDocument(
                                                              message.imageUrl, 
                                                              'document_${DateTime.now().millisecondsSinceEpoch}'
                                                            ),
                                                            child: Container(
                                                              constraints: const BoxConstraints(
                                                                maxWidth: 200.0,
                                                                minHeight: 80.0,
                                                              ),
                                                              padding: const EdgeInsets.all(12.0),
                                                              decoration: BoxDecoration(
                                                                color: isAdmin 
                                                                    ? Colors.white.withValues(alpha: 0.1)
                                                                    : FlutterFlowTheme.of(context).primary.withValues(alpha: 0.1),
                                                                borderRadius: BorderRadius.circular(8.0),
                                                                border: Border.all(
                                                                  color: isAdmin 
                                                                      ? Colors.white.withValues(alpha: 0.3)
                                                                      : FlutterFlowTheme.of(context).primary.withValues(alpha: 0.3),
                                                                ),
                                                              ),
                                                              child: Row(
                                                                children: [
                                                                  Container(
                                                                    padding: const EdgeInsets.all(8.0),
                                                                    decoration: BoxDecoration(
                                                                      color: isAdmin 
                                                                          ? Colors.white.withValues(alpha: 0.2)
                                                                          : FlutterFlowTheme.of(context).primary.withValues(alpha: 0.2),
                                                                      borderRadius: BorderRadius.circular(6.0),
                                                                    ),
                                                                    child: Icon(
                                                                      _getDocumentIcon(message.imageUrl),
                                                                      color: isAdmin 
                                                                          ? Colors.white
                                                                          : FlutterFlowTheme.of(context).primary,
                                                                      size: 24.0,
                                                                    ),
                                                                  ),
                                                                  const SizedBox(width: 12.0),
                                                                  Expanded(
                                                                    child: Column(
                                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                                      children: [
                                                                        Text(
                                                                          _getDocumentName(message.imageUrl),
                                                                          style: GoogleFonts.inter(
                                                                            fontSize: 14.0,
                                                                            fontWeight: FontWeight.w600,
                                                                            color: isAdmin
                                                                                ? Colors.white
                                                                                : FlutterFlowTheme.of(context).primaryText,
                                                                          ),
                                                                        ),
                                                                        const SizedBox(height: 4.0),
                                                                        Text(
                                                                          'Tap to download',
                                                                          style: GoogleFonts.inter(
                                                                            fontSize: 12.0,
                                                                            color: isAdmin
                                                                                ? Colors.white.withValues(alpha: 0.7)
                                                                                : FlutterFlowTheme.of(context).secondaryText,
                                                                          ),
                                                                        ),
                                                                      ],
                                                                    ),
                                                                  ),
                                                                  Icon(
                                                                    Icons.download,
                                                                    color: isAdmin 
                                                                        ? Colors.white.withValues(alpha: 0.7)
                                                                        : FlutterFlowTheme.of(context).secondaryText,
                                                                    size: 20.0,
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                          ),
                                                        ] else ...[
                                                          // Display image
                                                          GestureDetector(
                                                            onTap: () => _showImageViewer(message.imageUrl),
                                                            child: Container(
                                                              constraints: const BoxConstraints(
                                                                maxWidth: 200.0,
                                                                maxHeight: 200.0,
                                                              ),
                                                              child: ClipRRect(
                                                                borderRadius: BorderRadius.circular(8.0),
                                                                child: Stack(
                                                                  children: [
                                                                    CachedNetworkImage(
                                                                      imageUrl: message.imageUrl,
                                                                      fit: BoxFit.cover,
                                                                      placeholder: (context, url) => Container(
                                                                        height: 100,
                                                                        color: FlutterFlowTheme.of(context).alternate,
                                                                        child: Center(
                                                                          child: CircularProgressIndicator(
                                                                            valueColor: AlwaysStoppedAnimation<Color>(
                                                                              FlutterFlowTheme.of(context).primary,
                                                                            ),
                                                                          ),
                                                                        ),
                                                                      ),
                                                                      errorWidget: (context, url, error) => Container(
                                                                        height: 100,
                                                                        color: FlutterFlowTheme.of(context).alternate,
                                                                        child: Center(
                                                                          child: Icon(
                                                                            Icons.broken_image,
                                                                            color: FlutterFlowTheme.of(context).secondaryText,
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    ),
                                                                    // Overlay icon to indicate clickable
                                                                    Positioned(
                                                                      top: 8.0,
                                                                      right: 8.0,
                                                                      child: Container(
                                                                        padding: const EdgeInsets.all(4.0),
                                                                        decoration: BoxDecoration(
                                                                          color: Colors.black54,
                                                                          borderRadius: BorderRadius.circular(12.0),
                                                                        ),
                                                                        child: const Icon(
                                                                          Icons.zoom_in,
                                                                          color: Colors.white,
                                                                          size: 16.0,
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                        ],
                                                        const SizedBox(height: 8.0),
                                                      ],
                                                      // Show message text
                                                      if (message.text.isNotEmpty)
                                                        Text(
                                                          message.text,
                                                          style: FlutterFlowTheme.of(context).bodyMedium.override(
                                                                font: GoogleFonts.inter(),
                                                                color: isAdmin
                                                                    ? FlutterFlowTheme.of(context).primaryBackground
                                                                    : FlutterFlowTheme.of(context).primaryText,
                                                                letterSpacing: 0.0,
                                                              ),
                                                        ),
                                                    ],
                                                  ),
                                                ),
                                                if (message.sentAt != null)
                                                  Padding(
                                                    padding: const EdgeInsets.only(top: 4),
                                                    child: Text(
                                                      dateTimeFormat('jm', message.sentAt!),
                                                      style: FlutterFlowTheme.of(context).bodySmall.override(
                                                            font: GoogleFonts.inter(),
                                                            color: FlutterFlowTheme.of(context).secondaryText,
                                                            fontSize: 11,
                                                            letterSpacing: 0.0,
                                                          ),
                                                    ),
                                                  ),
                                              ],
                                            ),
                                          ),
                                          if (isAdmin) ...[
                                            const SizedBox(width: 8),
                                            Container(
                                              width: 32,
                                              height: 32,
                                              decoration: BoxDecoration(
                                                color: FlutterFlowTheme.of(context).accent1,
                                                shape: BoxShape.circle,
                                              ),
                                              child: const Icon(
                                                Icons.support_agent,
                                                size: 18,
                                              ),
                                            ),
                                          ],
                                        ],
                                      ),
                                    );
                                  },
                                );
                              },
                            ),
                          ),
                          // Message Input
                          Container(
                            decoration: BoxDecoration(
                              color: FlutterFlowTheme.of(context).secondaryBackground,
                              border: Border(
                                top: BorderSide(
                                  color: FlutterFlowTheme.of(context).alternate,
                                  width: 1,
                                ),
                              ),
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // Attachment preview
                                if (_model.selectedFile != null)
                                  Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.all(12.0),
                                    decoration: BoxDecoration(
                                      color: FlutterFlowTheme.of(context).primaryBackground,
                                      border: Border(
                                        bottom: BorderSide(
                                          color: FlutterFlowTheme.of(context).alternate,
                                          width: 1.0,
                                        ),
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        // File icon or image preview
                                        if (_model.selectedFileType == 'image')
                                          Container(
                                            width: 50.0,
                                            height: 50.0,
                                            decoration: BoxDecoration(
                                              borderRadius: BorderRadius.circular(8.0),
                                              border: Border.all(
                                                color: FlutterFlowTheme.of(context).alternate,
                                                width: 1.0,
                                              ),
                                            ),
                                            child: ClipRRect(
                                              borderRadius: BorderRadius.circular(8.0),
                                              child: _model.selectedFileBytes != null
                                                  ? Image.memory(
                                                      _model.selectedFileBytes!,
                                                      fit: BoxFit.cover,
                                                      errorBuilder: (context, error, stackTrace) => Icon(
                                                        Icons.broken_image,
                                                        color: FlutterFlowTheme.of(context).secondaryText,
                                                      ),
                                                    )
                                                  : Icon(
                                                      Icons.image,
                                                      color: FlutterFlowTheme.of(context).secondaryText,
                                                    ),
                                            ),
                                          )
                                        else
                                          Container(
                                            width: 50.0,
                                            height: 50.0,
                                            decoration: BoxDecoration(
                                              color: FlutterFlowTheme.of(context).alternate,
                                              borderRadius: BorderRadius.circular(8.0),
                                            ),
                                            child: Icon(
                                              Icons.description,
                                              color: FlutterFlowTheme.of(context).secondaryText,
                                            ),
                                          ),
                                        const SizedBox(width: 12.0),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                _model.selectedFileName ?? 'File',
                                                style: FlutterFlowTheme.of(context).bodyMedium.override(
                                                  font: GoogleFonts.inter(fontWeight: FontWeight.w600),
                                                  letterSpacing: 0.0,
                                                ),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                              Text(
                                                _model.selectedFileType == 'image' ? 'Image' : 'Document',
                                                style: FlutterFlowTheme.of(context).bodySmall.override(
                                                  font: GoogleFonts.inter(),
                                                  color: FlutterFlowTheme.of(context).secondaryText,
                                                  letterSpacing: 0.0,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        IconButton(
                                          icon: Icon(
                                            Icons.close,
                                            color: FlutterFlowTheme.of(context).error,
                                          ),
                                          onPressed: _removeAttachment,
                                        ),
                                      ],
                                    ),
                                  ),
                                // Input field and buttons
                                Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Row(
                                    children: [
                                      FlutterFlowIconButton(
                                        borderRadius: 12,
                                        buttonSize: 48,
                                        fillColor: FlutterFlowTheme.of(context).primaryBackground,
                                        icon: Icon(
                                          Icons.attach_file,
                                          color: FlutterFlowTheme.of(context).primaryText,
                                          size: 24,
                                        ),
                                        onPressed: _showAttachmentOptions,
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: TextFormField(
                                          controller: _model.messageController,
                                          focusNode: _model.messageFocusNode,
                                          autofocus: false,
                                          textInputAction: TextInputAction.send,
                                          obscureText: false,
                                          onFieldSubmitted: (_) async {
                                            await _handleSendMessage();
                                          },
                                          decoration: InputDecoration(
                                            hintText: 'Type your message...',
                                            hintStyle: FlutterFlowTheme.of(context).bodyMedium.override(
                                                  font: GoogleFonts.inter(),
                                                  color: FlutterFlowTheme.of(context).secondaryText,
                                                  letterSpacing: 0.0,
                                                ),
                                            enabledBorder: OutlineInputBorder(
                                              borderSide: BorderSide(
                                                color: FlutterFlowTheme.of(context).alternate,
                                                width: 1,
                                              ),
                                              borderRadius: BorderRadius.circular(12),
                                            ),
                                            focusedBorder: OutlineInputBorder(
                                              borderSide: BorderSide(
                                                color: FlutterFlowTheme.of(context).primary,
                                                width: 1,
                                              ),
                                              borderRadius: BorderRadius.circular(12),
                                            ),
                                            filled: true,
                                            fillColor: FlutterFlowTheme.of(context).primaryBackground,
                                            contentPadding: const EdgeInsets.all(16),
                                          ),
                                          style: FlutterFlowTheme.of(context).bodyMedium.override(
                                                font: GoogleFonts.inter(),
                                                letterSpacing: 0.0,
                                              ),
                                          maxLines: 3,
                                          minLines: 1,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      FlutterFlowIconButton(
                                        borderRadius: 12,
                                        buttonSize: 48,
                                        fillColor: FlutterFlowTheme.of(context).primary,
                                        icon: Icon(
                                          Icons.send,
                                          color: FlutterFlowTheme.of(context).primaryBackground,
                                          size: 24,
                                        ),
                                        onPressed: _handleSendMessage,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
              ),
                ],
              );
            },
          ),
        );
      },
    );
  }
}
