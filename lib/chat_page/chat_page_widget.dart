import '/auth/firebase_auth/auth_util.dart';
import '/backend/backend.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'dart:io';
import 'package:url_launcher/url_launcher.dart';
import 'chat_page_model.dart';
export 'chat_page_model.dart';

/// 📩 Message Page
///
/// Top Bar
///
/// Back Button ← (goes to Profile Page)
///
/// Chat Name (e.g., “Juan Dela Cruz”)
///
/// Settings ⚙️ (options: block, clear chat, report)
///
/// Conversation Area
///
/// Messages appear in bubble style (left = other user, right = you).
///
/// Scrollable area.
///
/// Bottom Chat Bar
///
/// 📎 Attachment button → send picture (choose from gallery or camera).
///
/// ✏️ Text field → type message.
///
/// ➤ Send button → send text or picture.
class ChatPageWidget extends StatefulWidget {
  const ChatPageWidget({super.key});

  static String routeName = 'ChatPage';
  static String routePath = '/chatPage';

  @override
  State<ChatPageWidget> createState() => _ChatPageWidgetState();
}

class _ChatPageWidgetState extends State<ChatPageWidget> {
  late ChatPageModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();
  DocumentReference? threadRef;
  UsersRecord? otherUser;
  bool isLoadingThread = true;
  
  // Admin UID for customer support
  static const String adminUid = 'e5JeP91nfRVyg8ZINWKSUypPOwD2';

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => ChatPageModel());

    _model.textController ??= TextEditingController();
    _model.textFieldFocusNode ??= FocusNode();
    
    // Get or create thread with admin
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final threadId = GoRouterState.of(context).uri.queryParameters['threadId'];
      
      if (threadId != null && threadId.isNotEmpty) {
        // Existing thread
        threadRef = MessagesRecord.collection.doc(threadId);
        final threadDoc = await threadRef!.get();
        if (threadDoc.exists) {
          final threadData = MessagesRecord.getDocumentFromData(
            threadDoc.data() as Map<String, dynamic>,
            threadDoc.reference,
          );
          // Resolve other participant correctly
          DocumentReference? otherRef;
          if (threadData.uid == currentUserUid) {
            otherRef = threadData.participants;
          } else if (threadData.uid.isNotEmpty) {
            otherRef = UsersRecord.collection.doc(threadData.uid);
          }
          if (otherRef != null) {
            final otherUserDoc = await otherRef.get();
            if (otherUserDoc.exists) {
              otherUser = UsersRecord.getDocumentFromData(
                otherUserDoc.data() as Map<String, dynamic>,
                otherUserDoc.reference,
              );
            }
          }
        }
      } else {
        // Create or get support thread with admin
        await _getOrCreateSupportThread();
      }
      
      setState(() {
        isLoadingThread = false;
      });
    });
  }
  
  Future<void> _getOrCreateSupportThread() async {
    try {
      final adminRef = UsersRecord.collection.doc(adminUid);
      
      // Check if a thread already exists between current user and admin
      final existingThreads = await MessagesRecord.collection
          .where('uid', isEqualTo: currentUserUid)
          .where('participants', isEqualTo: adminRef)
          .limit(1)
          .get();
      
      if (existingThreads.docs.isNotEmpty) {
        // Use existing thread
        threadRef = existingThreads.docs.first.reference;
      } else {
        // Create new support thread
        final adminDoc = await adminRef.get();
        
        if (adminDoc.exists) {
          final adminData = UsersRecord.getDocumentFromData(
            adminDoc.data() as Map<String, dynamic>,
            adminDoc.reference,
          );
          
          otherUser = adminData;
          
          // Create new thread
          final newThread = await MessagesRecord.collection.add(
            createMessagesRecordData(
              participants: adminRef,
              createdAt: getCurrentTimestamp,
              updatedAt: getCurrentTimestamp,
              lastMessage: '',
              email: 'admin@antiquespride.edu.ph',
              displayName: adminData.displayName,
              photoUrl: adminData.photoUrl,
              uid: currentUserUid,
              createdTime: getCurrentTimestamp,
            ),
          );
          
          threadRef = newThread;
        }
      }
      
      // Load admin user data
      if (otherUser == null) {
        final adminRef2 = UsersRecord.collection.doc(adminUid);
        final adminDoc2 = await adminRef2.get();
        if (adminDoc2.exists) {
          otherUser = UsersRecord.getDocumentFromData(
            adminDoc2.data() as Map<String, dynamic>,
            adminDoc2.reference,
          );
        }
      }
    } catch (e) {
      debugPrint('Error creating support thread: $e');
    }
  }

  @override
  void dispose() {
    _model.dispose();

    super.dispose();
  }
  
  String _getPriorityFromCategory(String category) {
    switch (category) {
      case 'Violence or Threats':
      case 'Hate Speech':
        return 'high';
      case 'Harassment':
      case 'Scam or Fraud':
        return 'medium';
      default:
        return 'low';
    }
  }

  IconData _getDocumentIcon(String url) {
    // Extract file extension from URL
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
    // Extract file name from URL
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

  // Supported file types
  final List<String> _supportedImageTypes = ['png', 'jpg', 'jpeg'];
  final List<String> _supportedDocumentTypes = ['pdf', 'doc', 'docx'];
  
  Future<void> _showAttachmentOptions(BuildContext context) async {
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
        
        // Store file info in model for preview
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
        
        // Store file info in model for preview
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
    if (threadRef == null) {
      _showErrorSnackBar('Unable to send attachment');
      return;
    }

    try {
      // Show loading indicator
      _showLoadingSnackBar('Uploading file...');

      // Get file extension and validate
      final fileName = _model.selectedFileName ?? 'unknown';
      final fileExtension = fileName.split('.').last.toLowerCase();
      
      if (!_isFileTypeSupported(fileExtension)) {
        _showErrorSnackBar('Unsupported file type. Please select PNG, JPG, JPEG, PDF, DOC, or DOCX files.');
        return;
      }

      // Create unique filename
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final uniqueFileName = '${timestamp}_$fileName';

      // Upload to Firebase Storage
      final Reference storageRef = FirebaseStorage.instance
          .ref()
          .child('chat_attachments')
          .child(uniqueFileName);

      UploadTask uploadTask;
      
      // Use bytes for web compatibility, file for mobile
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

      // Create message with attachment
      await ChatsRecord.createDoc(threadRef!).set(
        createChatsRecordData(
          senderRef: currentUserReference,
          text: messageText.isNotEmpty ? messageText : (_model.selectedFileType == 'image' ? '📷 Image' : '📄 Document'),
          sentAt: getCurrentTimestamp,
          imageUrl: downloadUrl,
        ),
      );

      // Hide loading indicator
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
      // Hide loading indicator and show error
      if (mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        _showErrorSnackBar('Failed to upload file: $e');
      }
    }
  }

  bool _isFileTypeSupported(String extension) {
    return _supportedImageTypes.contains(extension) || 
           _supportedDocumentTypes.contains(extension);
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
          duration: const Duration(seconds: 30), // Long duration for loading
        ),
      );
    }
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
          backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
          automaticallyImplyLeading: false,
          leading: FlutterFlowIconButton(
            borderRadius: 20.0,
            buttonSize: 40.0,
            icon: Icon(
              Icons.arrow_back,
              color: FlutterFlowTheme.of(context).primaryText,
              size: 24.0,
            ),
            onPressed: () async {
              context.pushNamed(MessageWidget.routeName);
            },
          ),
          title: otherUser != null
              ? Row(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Container(
                      width: 36.0,
                      height: 36.0,
                      decoration: BoxDecoration(
                        color: FlutterFlowTheme.of(context).primary,
                        shape: BoxShape.circle,
                      ),
                      child: otherUser!.photoUrl.isNotEmpty
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(18.0),
                              child: Image.network(
                                otherUser!.photoUrl,
                                width: 36.0,
                                height: 36.0,
                                fit: BoxFit.cover,
                              ),
                            )
                          : Center(
                              child: Text(
                                otherUser!.displayName.isNotEmpty
                                    ? otherUser!.displayName[0].toUpperCase()
                                    : 'A',
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
                    Expanded(
                      child: Column(
                        mainAxisSize: MainAxisSize.max,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          InkWell(
                            onTap: otherUser?.reference != null && otherUser!.reference.id != currentUserUid
                                ? () {
                                    context.pushNamed(
                                      ProfileWidget.routeName,
                                      queryParameters: {
                                        'userRef': serializeParam(
                                          otherUser!.reference,
                                          ParamType.DocumentReference,
                                        ),
                                      }.withoutNulls,
                                    );
                                  }
                                : null,
                            child: Text(
                              otherUser?.displayName ?? 'User',
                              style: FlutterFlowTheme.of(context).titleMedium.override(
                                    font: GoogleFonts.interTight(
                                      fontWeight: FontWeight.w600,
                                      fontStyle: FlutterFlowTheme.of(context)
                                          .titleMedium
                                          .fontStyle,
                                    ),
                                    color: otherUser?.reference != null && otherUser!.reference.id != currentUserUid
                                        ? FlutterFlowTheme.of(context).primary
                                        : FlutterFlowTheme.of(context).primaryText,
                                    fontSize: 16.0,
                                    letterSpacing: 0.0,
                                    fontWeight: FontWeight.w600,
                                    fontStyle: FlutterFlowTheme.of(context)
                                        .titleMedium
                                        .fontStyle,
                                    decoration: otherUser?.reference != null && otherUser!.reference.id != currentUserUid
                                        ? TextDecoration.underline
                                        : null,
                                  ),
                            ),
                          ),
                          Text(
                            'Online',
                            style: FlutterFlowTheme.of(context).bodySmall.override(
                                  font: GoogleFonts.inter(
                                    fontWeight: FlutterFlowTheme.of(context)
                                        .bodySmall
                                        .fontWeight,
                                    fontStyle: FlutterFlowTheme.of(context)
                                        .bodySmall
                                        .fontStyle,
                                ),
                                color: FlutterFlowTheme.of(context).success,
                                fontSize: 12.0,
                                letterSpacing: 0.0,
                                fontWeight:
                                    FlutterFlowTheme.of(context).bodySmall.fontWeight,
                                fontStyle:
                                    FlutterFlowTheme.of(context).bodySmall.fontStyle,
                              ),
                        ),
                      ],
                    ),
                  ),
                  ].divide(const SizedBox(width: 12.0)),
                )
              : Row(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Container(
                      width: 36.0,
                      height: 36.0,
                      decoration: BoxDecoration(
                        color: FlutterFlowTheme.of(context).primary,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
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
                    Text(
                      'Customer Service',
                      style: FlutterFlowTheme.of(context).titleMedium.override(
                            font: GoogleFonts.interTight(
                              fontWeight: FontWeight.w600,
                            ),
                            fontSize: 16.0,
                            letterSpacing: 0.0,
                          ),
                    ),
                  ].divide(const SizedBox(width: 12.0)),
                ),
          actions: [
            // Report button
            FlutterFlowIconButton(
              borderRadius: 20.0,
              buttonSize: 40.0,
              icon: Icon(
                Icons.flag_outlined,
                color: FlutterFlowTheme.of(context).error,
                size: 24.0,
              ),
              onPressed: () async {
                // Initialize report controllers
                _model.reportCategory = null;
                _model.reportDescriptionController = TextEditingController();
                _model.reportDescriptionFocusNode = FocusNode();
                
                // Show report modal
                await showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  enableDrag: false,
                  builder: (context) {
                    return StatefulBuilder(
                      builder: (context, setModalState) {
                        return GestureDetector(
                          onTap: () => FocusScope.of(context).unfocus(),
                          child: Padding(
                            padding: MediaQuery.viewInsetsOf(context),
                            child: Container(
                              height: MediaQuery.sizeOf(context).height * 0.7,
                              decoration: BoxDecoration(
                                color: FlutterFlowTheme.of(context).secondaryBackground,
                                borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(20.0),
                                  topRight: Radius.circular(20.0),
                                ),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(24.0),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          'Report User',
                                          style: FlutterFlowTheme.of(context).headlineSmall.override(
                                                font: GoogleFonts.interTight(fontWeight: FontWeight.bold),
                                                letterSpacing: 0.0,
                                              ),
                                        ),
                                        IconButton(
                                          icon: Icon(
                                            Icons.close,
                                            color: FlutterFlowTheme.of(context).secondaryText,
                                          ),
                                          onPressed: () => Navigator.pop(context),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8.0),
                                    Text(
                                      'Please select a category and provide details about why you\'re reporting this ${otherUser?.reference.id == adminUid ? 'support agent' : 'user'}.',
                                      style: FlutterFlowTheme.of(context).bodyMedium.override(
                                            font: GoogleFonts.inter(),
                                            color: FlutterFlowTheme.of(context).secondaryText,
                                            letterSpacing: 0.0,
                                          ),
                                    ),
                                    const SizedBox(height: 24.0),
                                    Text(
                                      'Report Category *',
                                      style: FlutterFlowTheme.of(context).bodyMedium.override(
                                            font: GoogleFonts.inter(fontWeight: FontWeight.w600),
                                            letterSpacing: 0.0,
                                          ),
                                    ),
                                    const SizedBox(height: 8.0),
                                    Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(8.0),
                                        border: Border.all(
                                          color: FlutterFlowTheme.of(context).alternate,
                                          width: 1.0,
                                        ),
                                      ),
                                      child: DropdownButtonFormField<String>(
                                        initialValue: _model.reportCategory,
                                        decoration: InputDecoration(
                                          contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                                          border: InputBorder.none,
                                          hintText: 'Select a category',
                                          hintStyle: FlutterFlowTheme.of(context).bodyMedium.override(
                                                font: GoogleFonts.inter(),
                                                color: FlutterFlowTheme.of(context).secondaryText,
                                                letterSpacing: 0.0,
                                              ),
                                        ),
                                        items: const [
                                          DropdownMenuItem(value: 'Spam', child: Text('Spam')),
                                          DropdownMenuItem(value: 'Harassment', child: Text('Harassment')),
                                          DropdownMenuItem(value: 'Inappropriate Content', child: Text('Inappropriate Content')),
                                          DropdownMenuItem(value: 'Scam or Fraud', child: Text('Scam or Fraud')),
                                          DropdownMenuItem(value: 'Hate Speech', child: Text('Hate Speech')),
                                          DropdownMenuItem(value: 'Violence or Threats', child: Text('Violence or Threats')),
                                          DropdownMenuItem(value: 'Other', child: Text('Other')),
                                        ],
                                        onChanged: (value) {
                                          setModalState(() {
                                            _model.reportCategory = value;
                                          });
                                        },
                                        style: FlutterFlowTheme.of(context).bodyMedium.override(
                                              font: GoogleFonts.inter(),
                                              letterSpacing: 0.0,
                                            ),
                                        dropdownColor: FlutterFlowTheme.of(context).secondaryBackground,
                                        icon: Icon(
                                          Icons.keyboard_arrow_down,
                                          color: FlutterFlowTheme.of(context).secondaryText,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 24.0),
                                    Text(
                                      'Additional Details (Optional)',
                                      style: FlutterFlowTheme.of(context).bodyMedium.override(
                                            font: GoogleFonts.inter(fontWeight: FontWeight.w600),
                                            letterSpacing: 0.0,
                                          ),
                                    ),
                                    const SizedBox(height: 8.0),
                                    TextFormField(
                                      controller: _model.reportDescriptionController,
                                      focusNode: _model.reportDescriptionFocusNode,
                                      autofocus: false,
                                      textCapitalization: TextCapitalization.sentences,
                                      obscureText: false,
                                      decoration: InputDecoration(
                                        hintText: 'Provide more context about this report...',
                                        hintStyle: FlutterFlowTheme.of(context).bodyMedium.override(
                                              font: GoogleFonts.inter(),
                                              color: FlutterFlowTheme.of(context).secondaryText,
                                              letterSpacing: 0.0,
                                            ),
                                        enabledBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                            color: FlutterFlowTheme.of(context).alternate,
                                            width: 1.0,
                                          ),
                                          borderRadius: BorderRadius.circular(8.0),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                            color: FlutterFlowTheme.of(context).primary,
                                            width: 2.0,
                                          ),
                                          borderRadius: BorderRadius.circular(8.0),
                                        ),
                                        errorBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                            color: FlutterFlowTheme.of(context).error,
                                            width: 1.0,
                                          ),
                                          borderRadius: BorderRadius.circular(8.0),
                                        ),
                                        focusedErrorBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                            color: FlutterFlowTheme.of(context).error,
                                            width: 2.0,
                                          ),
                                          borderRadius: BorderRadius.circular(8.0),
                                        ),
                                        contentPadding: const EdgeInsets.all(16.0),
                                      ),
                                      style: FlutterFlowTheme.of(context).bodyMedium.override(
                                            font: GoogleFonts.inter(),
                                            letterSpacing: 0.0,
                                          ),
                                      maxLines: 5,
                                      minLines: 3,
                                    ),
                                    const Spacer(),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: OutlinedButton(
                                            onPressed: () => Navigator.pop(context),
                                            style: OutlinedButton.styleFrom(
                                              padding: const EdgeInsets.symmetric(vertical: 16.0),
                                              side: BorderSide(
                                                color: FlutterFlowTheme.of(context).alternate,
                                              ),
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(8.0),
                                              ),
                                            ),
                                            child: Text(
                                              'Cancel',
                                              style: FlutterFlowTheme.of(context).bodyMedium.override(
                                                    font: GoogleFonts.inter(fontWeight: FontWeight.w600),
                                                    color: FlutterFlowTheme.of(context).secondaryText,
                                                    letterSpacing: 0.0,
                                                  ),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 12.0),
                                        Expanded(
                                          child: ElevatedButton(
                                            onPressed: _model.reportCategory == null
                                                ? null
                                                : () async {
                                                    // Create report in ModerationQueue
                                                    try {
                                                      debugPrint('Starting report submission...');
                                                      debugPrint('Report category: ${_model.reportCategory}');
                                                      debugPrint('Other user ref: ${otherUser?.reference}');
                                                      debugPrint('Current user ref: $currentUserReference');
                                                      
                                                      await ModerationQueueRecord.collection.add(
                                                        createModerationQueueRecordData(
                                                          contentType: 'user_report',
                                                          contentRef: otherUser?.reference,
                                                          reporterRef: currentUserReference,
                                                          reason: _model.reportCategory!,
                                                          description: _model.reportDescriptionController?.text.trim() ?? '',
                                                          status: 'pending',
                                                          priority: _getPriorityFromCategory(_model.reportCategory!),
                                                          createdAt: getCurrentTimestamp,
                                                        ),
                                                      );
                                                      
                                                      debugPrint('Report submitted successfully to Firestore');
                                                      
                                                      // Show success message before closing modal
                                                      if (context.mounted) {
                                                        debugPrint('Showing success message...');
                                                        
                                                        // Clear any existing snackbars first
                                                        ScaffoldMessenger.of(context).clearSnackBars();
                                                        
                                                        ScaffoldMessenger.of(context).showSnackBar(
                                                          SnackBar(
                                                            content: Row(
                                                              children: [
                                                                const Icon(
                                                                  Icons.check_circle,
                                                                  color: Colors.white,
                                                                  size: 20,
                                                                ),
                                                                const SizedBox(width: 8),
                                                                Expanded(
                                                                  child: Text(
                                                                    'Report submitted successfully. Our team will review it.',
                                                                    style: FlutterFlowTheme.of(context).bodyMedium.override(
                                                                          font: GoogleFonts.inter(),
                                                                          color: Colors.white,
                                                                          letterSpacing: 0.0,
                                                                        ),
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                            backgroundColor: Colors.green,
                                                            duration: const Duration(seconds: 4),
                                                            behavior: SnackBarBehavior.floating,
                                                            margin: const EdgeInsets.all(16),
                                                            shape: RoundedRectangleBorder(
                                                              borderRadius: BorderRadius.circular(8),
                                                            ),
                                                          ),
                                                        );
                                                        
                                                        // Close modal after showing success message
                                                        Navigator.pop(context);
                                                      } else {
                                                        debugPrint('Context not mounted, cannot show success message');
                                                        if (context.mounted) Navigator.pop(context);
                                                      }
                                                    } catch (e) {
                                                      debugPrint('Error submitting report: $e');
                                                      if (context.mounted) {
                                                        ScaffoldMessenger.of(context).clearSnackBars();
                                                        ScaffoldMessenger.of(context).showSnackBar(
                                                          SnackBar(
                                                            content: Row(
                                                              children: [
                                                                const Icon(
                                                                  Icons.error,
                                                                  color: Colors.white,
                                                                  size: 20,
                                                                ),
                                                                const SizedBox(width: 8),
                                                                Expanded(
                                                                  child: Text(
                                                                    'Failed to submit report. Please try again.',
                                                                    style: FlutterFlowTheme.of(context).bodyMedium.override(
                                                                          font: GoogleFonts.inter(),
                                                                          color: Colors.white,
                                                                          letterSpacing: 0.0,
                                                                        ),
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                            backgroundColor: Colors.red,
                                                            duration: const Duration(seconds: 4),
                                                            behavior: SnackBarBehavior.floating,
                                                            margin: const EdgeInsets.all(16),
                                                            shape: RoundedRectangleBorder(
                                                              borderRadius: BorderRadius.circular(8),
                                                            ),
                                                          ),
                                                        );
                                                      }
                                                      if (context.mounted) Navigator.pop(context);
                                                    }
                                                  },
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: _model.reportCategory == null
                                                  ? FlutterFlowTheme.of(context).alternate
                                                  : FlutterFlowTheme.of(context).error,
                                              padding: const EdgeInsets.symmetric(vertical: 16.0),
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(8.0),
                                              ),
                                            ),
                                            child: Text(
                                              'Submit Report',
                                              style: FlutterFlowTheme.of(context).bodyMedium.override(
                                                    font: GoogleFonts.inter(fontWeight: FontWeight.w600),
                                                    color: Colors.white,
                                                    letterSpacing: 0.0,
                                                  ),
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
                        );
                      },
                    );
                  },
                );
              },
            ),
          ],
          centerTitle: false,
          elevation: 1.0,
        ),
        body: SafeArea(
          top: true,
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: [
              Expanded(
                child: isLoadingThread
                    ? Center(
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                            FlutterFlowTheme.of(context).primary,
                          ),
                        ),
                      )
                    : threadRef != null
                        ? StreamBuilder<List<ChatsRecord>>(
                        stream: queryChatsRecord(
                          parent: threadRef,
                          queryBuilder: (chatsRecord) =>
                              chatsRecord.orderBy('sentAt', descending: false),
                        ),
                        builder: (context, snapshot) {
                          if (!snapshot.hasData) {
                            return Center(
                              child: CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  FlutterFlowTheme.of(context).primary,
                                ),
                              ),
                            );
                          }
                          List<ChatsRecord> messages = snapshot.data!;

                          return ListView.builder(
                  padding: const EdgeInsetsDirectional.fromSTEB(16.0, 0.0, 16.0, 0.0),
                            itemCount: messages.length,
                            itemBuilder: (context, index) {
                              final message = messages[index];
                              final isCurrentUser = message.senderRef?.id == currentUserUid;
                              
                              return Padding(
                                padding: const EdgeInsetsDirectional.fromSTEB(0.0, 8.0, 0.0, 8.0),
                                child: Row(
                      mainAxisSize: MainAxisSize.max,
                                  mainAxisAlignment: isCurrentUser
                                      ? MainAxisAlignment.end
                                      : MainAxisAlignment.start,
                      children: [
                                    if (!isCurrentUser) ...[
                            Container(
                              width: 40.0,
                              height: 40.0,
                              decoration: BoxDecoration(
                                color: FlutterFlowTheme.of(context)
                                    .secondaryBackground,
                                shape: BoxShape.circle,
                              ),
                                        child: Icon(
                                          Icons.person,
                                          color: FlutterFlowTheme.of(context).primaryText,
                                          size: 20.0,
                                        ),
                                      ),
                                      const SizedBox(width: 8.0),
                                    ],
                                    Flexible(
                              child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        crossAxisAlignment: isCurrentUser
                                            ? CrossAxisAlignment.end
                                            : CrossAxisAlignment.start,
                                children: [
                                          Container(
                                            constraints: const BoxConstraints(
                                              maxWidth: 250.0,
                                            ),
                                      decoration: BoxDecoration(
                                              color: isCurrentUser
                                                  ? FlutterFlowTheme.of(context).primary
                                                  : FlutterFlowTheme.of(context)
                                                      .secondaryBackground,
                                              borderRadius: BorderRadius.circular(16.0),
                                      ),
                                      child: Padding(
                                              padding: const EdgeInsets.all(12.0),
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
                                                      color: isCurrentUser 
                                                          ? Colors.white.withValues(alpha: 0.1)
                                                          : FlutterFlowTheme.of(context).primary.withValues(alpha: 0.1),
                                                      borderRadius: BorderRadius.circular(8.0),
                                                      border: Border.all(
                                                        color: isCurrentUser 
                                                            ? Colors.white.withValues(alpha: 0.3)
                                                            : FlutterFlowTheme.of(context).primary.withValues(alpha: 0.3),
                                                      ),
                                                    ),
                                                    child: Row(
                                                      children: [
                                                        Container(
                                                          padding: const EdgeInsets.all(8.0),
                                                          decoration: BoxDecoration(
                                                            color: isCurrentUser 
                                                                ? Colors.white.withValues(alpha: 0.2)
                                                                : FlutterFlowTheme.of(context).primary.withValues(alpha: 0.2),
                                                            borderRadius: BorderRadius.circular(6.0),
                                                          ),
                                                          child: Icon(
                                                            _getDocumentIcon(message.imageUrl),
                                                            color: isCurrentUser 
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
                                                                  color: isCurrentUser
                                                                      ? Colors.white
                                                                      : FlutterFlowTheme.of(context).primaryText,
                                                                ),
                                                              ),
                                                              const SizedBox(height: 4.0),
                                                              Text(
                                                                'Tap to download',
                                                                style: GoogleFonts.inter(
                                                                  fontSize: 12.0,
                                                                  color: isCurrentUser
                                                                      ? Colors.white.withValues(alpha: 0.7)
                                                                      : FlutterFlowTheme.of(context).secondaryText,
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                        Icon(
                                                          Icons.download,
                                                          color: isCurrentUser 
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
                                            Text(
                                                message.text,
                                          style: FlutterFlowTheme.of(context)
                                              .bodyMedium
                                              .override(
                                                font: GoogleFonts.inter(
                                                        fontWeight: FlutterFlowTheme.of(context)
                                                          .bodyMedium
                                                          .fontWeight,
                                                        fontStyle: FlutterFlowTheme.of(context)
                                                          .bodyMedium
                                                          .fontStyle,
                                                ),
                                                      color: isCurrentUser
                                                          ? Colors.white
                                                          : FlutterFlowTheme.of(context)
                                                              .primaryText,
                                                fontSize: 14.0,
                                                letterSpacing: 0.0,
                                                      fontWeight: FlutterFlowTheme.of(context)
                                                          .bodyMedium
                                                          .fontWeight,
                                                      fontStyle: FlutterFlowTheme.of(context)
                                                          .bodyMedium
                                                          .fontStyle,
                                              ),
                                            ),
                                            // Show document download button if it's a document
                                            if (message.imageUrl.isNotEmpty && 
                                                message.text.contains('📄 Document')) ...[
                                              const SizedBox(height: 8.0),
                                              GestureDetector(
                                                onTap: () => _downloadDocument(
                                                  message.imageUrl, 
                                                  'document_${DateTime.now().millisecondsSinceEpoch}'
                                                ),
                                                child: Container(
                                                  padding: const EdgeInsets.symmetric(
                                                    horizontal: 12.0, 
                                                    vertical: 8.0
                                                  ),
                                                  decoration: BoxDecoration(
                                                    color: isCurrentUser 
                                                        ? Colors.white.withValues(alpha: 0.2)
                                                        : FlutterFlowTheme.of(context).primary.withValues(alpha: 0.1),
                                                    borderRadius: BorderRadius.circular(8.0),
                                                    border: Border.all(
                                                      color: isCurrentUser 
                                                          ? Colors.white.withValues(alpha: 0.3)
                                                          : FlutterFlowTheme.of(context).primary.withValues(alpha: 0.3),
                                                    ),
                                                  ),
                                                  child: Row(
                                                    mainAxisSize: MainAxisSize.min,
                                                    children: [
                                                      Icon(
                                                        Icons.download,
                                                        color: isCurrentUser 
                                                            ? Colors.white
                                                            : FlutterFlowTheme.of(context).primary,
                                                        size: 16.0,
                                                      ),
                                                      const SizedBox(width: 8.0),
                                                      Text(
                                                        'Download Document',
                                                        style: TextStyle(
                                                          color: isCurrentUser 
                                                              ? Colors.white
                                                              : FlutterFlowTheme.of(context).primary,
                                                          fontSize: 12.0,
                                                          fontWeight: FontWeight.w500,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ],
                                            // Show timestamp
                                            if (message.sentAt != null)
                                              Padding(
                                                padding: const EdgeInsetsDirectional.fromSTEB(0.0, 4.0, 0.0, 0.0),
                                                child: Text(
                                                  dateTimeFormat('jm', message.sentAt!),
                                    style: FlutterFlowTheme.of(context)
                                        .bodySmall
                                        .override(
                                          font: GoogleFonts.inter(
                                                        fontWeight: FlutterFlowTheme.of(context)
                                                    .bodySmall
                                                    .fontWeight,
                                                        fontStyle: FlutterFlowTheme.of(context)
                                                    .bodySmall
                                                    .fontStyle,
                                          ),
                                          color: FlutterFlowTheme.of(context)
                                              .secondaryText,
                                          fontSize: 12.0,
                                          letterSpacing: 0.0,
                                          fontWeight: FlutterFlowTheme.of(context)
                                              .bodySmall
                                              .fontWeight,
                                          fontStyle: FlutterFlowTheme.of(context)
                                              .bodySmall
                                              .fontStyle,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (isCurrentUser) ...[
                        const SizedBox(width: 8.0),
                        Container(
                          width: 40.0,
                          height: 40.0,
                          decoration: BoxDecoration(
                            color: FlutterFlowTheme.of(context).accent1,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.person,
                            color: FlutterFlowTheme.of(context).primaryText,
                            size: 20.0,
                          ),
                        ),
                      ],
                    ],
                  ),
                );
                            },
                          );
                        },
                      )
                        : Center(
                            child: Text(
                              'Unable to load conversation',
                              style: FlutterFlowTheme.of(context).bodyLarge,
                            ),
                          ),
              ),
              Align(
                alignment: const AlignmentDirectional(0.0, 1.0),
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: FlutterFlowTheme.of(context).primaryBackground,
                    border: Border.all(
                      color: FlutterFlowTheme.of(context).alternate,
                      width: 1.0,
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
                            color: FlutterFlowTheme.of(context).secondaryBackground,
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
                                              Icons.image,
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
                                    color: FlutterFlowTheme.of(context).primary.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(8.0),
                                    border: Border.all(
                                      color: FlutterFlowTheme.of(context).alternate,
                                      width: 1.0,
                                    ),
                                  ),
                                  child: Icon(
                                    Icons.description,
                                    color: FlutterFlowTheme.of(context).primary,
                                    size: 24.0,
                                  ),
                                ),
                              const SizedBox(width: 12.0),
                              // File info
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      _model.selectedFileName ?? 'Unknown file',
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
                              // Remove button
                              FlutterFlowIconButton(
                                borderRadius: 20.0,
                                buttonSize: 32.0,
                                fillColor: FlutterFlowTheme.of(context).error.withValues(alpha: 0.1),
                                icon: Icon(
                                  Icons.close,
                                  color: FlutterFlowTheme.of(context).error,
                                  size: 16.0,
                                ),
                                onPressed: _removeAttachment,
                              ),
                            ],
                          ),
                        ),
                      // Message input row
                      Padding(
                        padding: const EdgeInsetsDirectional.fromSTEB(16.0, 8.0, 16.0, 8.0),
                        child: Row(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            FlutterFlowIconButton(
                          borderRadius: 20.0,
                          buttonSize: 40.0,
                          fillColor:
                              FlutterFlowTheme.of(context).secondaryBackground,
                          icon: Icon(
                            Icons.attach_file,
                            color: FlutterFlowTheme.of(context).primaryText,
                            size: 20.0,
                          ),
                          onPressed: () async {
                            await _showAttachmentOptions(context);
                          },
                            ),
                            Expanded(
                          child: TextFormField(
                            controller: _model.textController,
                            focusNode: _model.textFieldFocusNode,
                            autofocus: false,
                            textCapitalization: TextCapitalization.sentences,
                            textInputAction: TextInputAction.send,
                            obscureText: false,
                            decoration: InputDecoration(
                              hintText: 'Type a message...',
                              hintStyle: FlutterFlowTheme.of(context)
                                  .bodyMedium
                                  .override(
                                    font: GoogleFonts.inter(
                                      fontWeight: FlutterFlowTheme.of(context)
                                          .bodyMedium
                                          .fontWeight,
                                      fontStyle: FlutterFlowTheme.of(context)
                                          .bodyMedium
                                          .fontStyle,
                                    ),
                                    color: FlutterFlowTheme.of(context)
                                        .secondaryText,
                                    fontSize: 14.0,
                                    letterSpacing: 0.0,
                                    fontWeight: FlutterFlowTheme.of(context)
                                        .bodyMedium
                                        .fontWeight,
                                    fontStyle: FlutterFlowTheme.of(context)
                                        .bodyMedium
                                        .fontStyle,
                                  ),
                              enabledBorder: OutlineInputBorder(
                                borderSide: const BorderSide(
                                  color: Color(0x00000000),
                                  width: 0.0,
                                ),
                                borderRadius: BorderRadius.circular(20.0),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: const BorderSide(
                                  color: Color(0x00000000),
                                  width: 0.0,
                                ),
                                borderRadius: BorderRadius.circular(20.0),
                              ),
                              errorBorder: OutlineInputBorder(
                                borderSide: const BorderSide(
                                  color: Color(0x00000000),
                                  width: 0.0,
                                ),
                                borderRadius: BorderRadius.circular(20.0),
                              ),
                              focusedErrorBorder: OutlineInputBorder(
                                borderSide: const BorderSide(
                                  color: Color(0x00000000),
                                  width: 0.0,
                                ),
                                borderRadius: BorderRadius.circular(20.0),
                              ),
                              filled: true,
                              fillColor: FlutterFlowTheme.of(context)
                                  .secondaryBackground,
                              contentPadding: const EdgeInsetsDirectional.fromSTEB(
                                  16.0, 12.0, 16.0, 12.0),
                            ),
                            style: FlutterFlowTheme.of(context)
                                .bodyMedium
                                .override(
                                  font: GoogleFonts.inter(
                                    fontWeight: FlutterFlowTheme.of(context)
                                        .bodyMedium
                                        .fontWeight,
                                    fontStyle: FlutterFlowTheme.of(context)
                                        .bodyMedium
                                        .fontStyle,
                                  ),
                                  fontSize: 14.0,
                                  letterSpacing: 0.0,
                                  fontWeight: FlutterFlowTheme.of(context)
                                      .bodyMedium
                                      .fontWeight,
                                  fontStyle: FlutterFlowTheme.of(context)
                                      .bodyMedium
                                      .fontStyle,
                                ),
                            maxLines: 3,
                            minLines: 1,
                            validator: _model.textControllerValidator
                                .asValidator(context),
                            inputFormatters: [
                              if (!isAndroid && !isiOS)
                                TextInputFormatter.withFunction(
                                    (oldValue, newValue) {
                                  return TextEditingValue(
                                    selection: newValue.selection,
                                    text: newValue.text.toCapitalization(
                                        TextCapitalization.sentences),
                                  );
                                }),
                            ],
                          ),
                        ),
                        FlutterFlowIconButton(
                          borderRadius: 20.0,
                          buttonSize: 40.0,
                          fillColor: FlutterFlowTheme.of(context).primary,
                          icon: Icon(
                            Icons.send,
                            color:
                                FlutterFlowTheme.of(context).primaryBackground,
                            size: 20.0,
                          ),
                          onPressed: () async {
                            if ((_model.textController.text.trim().isEmpty && _model.selectedFile == null) || threadRef == null) {
                              return;
                            }
                            
                            final messageText = _model.textController.text.trim();
                            _model.textController?.clear();
                            
                            // If there's an attachment, upload it first
                            if (_model.selectedFile != null) {
                              await _uploadAndSendMessage(_model.selectedFile, messageText);
                            } else {
                              // Send text message only
                              await ChatsRecord.createDoc(threadRef!).set(
                                createChatsRecordData(
                                  senderRef: currentUserReference,
                                  text: messageText,
                                  sentAt: getCurrentTimestamp,
                                ),
                              );
                            }
                            
                            // Clear attachment after sending
                            _removeAttachment();
                          },
                            ),
                          ].divide(const SizedBox(width: 12.0)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
