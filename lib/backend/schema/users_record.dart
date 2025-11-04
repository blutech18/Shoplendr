import 'dart:async';

import 'package:collection/collection.dart';

import '/backend/schema/util/firestore_util.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

class UsersRecord extends FirestoreRecord {
  UsersRecord._(
    super.reference,
    super.data,
  ) {
    _initializeFields();
  }

  // "display_name" field.
  String? _displayName;
  String get displayName => _displayName ?? '';
  bool hasDisplayName() => _displayName != null;

  // "photo_url" field.
  String? _photoUrl;
  String get photoUrl => _photoUrl ?? '';
  bool hasPhotoUrl() => _photoUrl != null;

  // "created_time" field.
  DateTime? _createdTime;
  DateTime? get createdTime => _createdTime;
  bool hasCreatedTime() => _createdTime != null;

  // "phone_number" field.
  String? _phoneNumber;
  String get phoneNumber => _phoneNumber ?? '';
  bool hasPhoneNumber() => _phoneNumber != null;

  // "username" field.
  String? _username;
  String get username => _username ?? '';
  bool hasUsername() => _username != null;

  // "profile_picture" field.
  String? _profilePicture;
  String get profilePicture => _profilePicture ?? '';
  bool hasProfilePicture() => _profilePicture != null;

  // "IDverification" field.
  String? _iDverification;
  String get iDverification => _iDverification ?? '';
  bool hasIDverification() => _iDverification != null;

  // "Address" field.
  String? _address;
  String get address => _address ?? '';
  bool hasAddress() => _address != null;

  // "emailVerified" field.
  bool? _emailVerified;
  bool get emailVerified => _emailVerified ?? false;
  bool hasEmailVerified() => _emailVerified != null;

  // "studentIdVerified" field.
  bool? _studentIdVerified;
  bool get studentIdVerified => _studentIdVerified ?? false;
  bool hasStudentIdVerified() => _studentIdVerified != null;

  // "verificationStatus" field.
  String? _verificationStatus;
  String get verificationStatus => _verificationStatus ?? '';
  bool hasVerificationStatus() => _verificationStatus != null;

  // "is_suspended" field.
  bool? _isSuspended;
  bool get isSuspended => _isSuspended ?? false;
  bool hasIsSuspended() => _isSuspended != null;

  // "suspended_by" field.
  DocumentReference? _suspendedBy;
  DocumentReference? get suspendedBy => _suspendedBy;
  bool hasSuspendedBy() => _suspendedBy != null;

  // "suspended_at" field.
  DateTime? _suspendedAt;
  DateTime? get suspendedAt => _suspendedAt;
  bool hasSuspendedAt() => _suspendedAt != null;

  // "suspension_reason" field.
  String? _suspensionReason;
  String get suspensionReason => _suspensionReason ?? '';
  bool hasSuspensionReason() => _suspensionReason != null;

  // "suspension_until" field.
  DateTime? _suspensionUntil;
  DateTime? get suspensionUntil => _suspensionUntil;
  bool hasSuspensionUntil() => _suspensionUntil != null;

  // "warning_count" field.
  int? _warningCount;
  int get warningCount => _warningCount ?? 0;
  bool hasWarningCount() => _warningCount != null;

  // "email" field.
  String? _email;
  String get email => _email ?? '';
  bool hasEmail() => _email != null;

  void _initializeFields() {
    _displayName = snapshotData['display_name'] as String?;
    _photoUrl = snapshotData['photo_url'] as String?;
    _createdTime = snapshotData['created_time'] as DateTime?;
    _phoneNumber = snapshotData['phone_number'] as String?;
    _username = snapshotData['username'] as String?;
    _profilePicture = snapshotData['profile_picture'] as String?;
    _iDverification = snapshotData['IDverification'] as String?;
    _address = snapshotData['Address'] as String?;
    _emailVerified = snapshotData['emailVerified'] as bool?;
    _studentIdVerified = snapshotData['studentIdVerified'] as bool?;
    _verificationStatus = snapshotData['verificationStatus'] as String?;
    _isSuspended = snapshotData['is_suspended'] as bool?;
    _suspendedBy = snapshotData['suspended_by'] as DocumentReference?;
    _suspendedAt = snapshotData['suspended_at'] as DateTime?;
    _suspensionReason = snapshotData['suspension_reason'] as String?;
    _suspensionUntil = snapshotData['suspension_until'] as DateTime?;
    _warningCount = castToType<int>(snapshotData['warning_count']);
    _email = snapshotData['email'] as String?;
  }

  static CollectionReference get collection =>
      FirebaseFirestore.instance.collection('Users');

  static Stream<UsersRecord> getDocument(DocumentReference ref) =>
      ref.snapshots().map((s) => UsersRecord.fromSnapshot(s));

  static Future<UsersRecord> getDocumentOnce(DocumentReference ref) =>
      ref.get().then((s) => UsersRecord.fromSnapshot(s));

  static UsersRecord fromSnapshot(DocumentSnapshot snapshot) => UsersRecord._(
        snapshot.reference,
        mapFromFirestore(snapshot.data() as Map<String, dynamic>),
      );

  static UsersRecord getDocumentFromData(
    Map<String, dynamic> data,
    DocumentReference reference,
  ) =>
      UsersRecord._(reference, mapFromFirestore(data));

  @override
  String toString() =>
      'UsersRecord(reference: ${reference.path}, data: $snapshotData)';

  @override
  int get hashCode => reference.path.hashCode;

  @override
  bool operator ==(other) =>
      other is UsersRecord &&
      reference.path.hashCode == other.reference.path.hashCode;
}

Map<String, dynamic> createUsersRecordData({
  String? displayName,
  String? photoUrl,
  DateTime? createdTime,
  String? phoneNumber,
  String? username,
  String? profilePicture,
  String? iDverification,
  String? address,
  bool? emailVerified,
  bool? studentIdVerified,
  String? verificationStatus,
  bool? isSuspended,
  DocumentReference? suspendedBy,
  DateTime? suspendedAt,
  String? suspensionReason,
  DateTime? suspensionUntil,
  int? warningCount,
  String? email,
}) {
  final firestoreData = mapToFirestore(
    <String, dynamic>{
      'display_name': displayName,
      'photo_url': photoUrl,
      'created_time': createdTime,
      'phone_number': phoneNumber,
      'username': username,
      'profile_picture': profilePicture,
      'IDverification': iDverification,
      'Address': address,
      'emailVerified': emailVerified,
      'studentIdVerified': studentIdVerified,
      'verificationStatus': verificationStatus,
      'is_suspended': isSuspended,
      'suspended_by': suspendedBy,
      'suspended_at': suspendedAt,
      'suspension_reason': suspensionReason,
      'suspension_until': suspensionUntil,
      'warning_count': warningCount,
      'email': email,
    }.withoutNulls,
  );

  return firestoreData;
}

class UsersRecordDocumentEquality implements Equality<UsersRecord> {
  const UsersRecordDocumentEquality();

  @override
  bool equals(UsersRecord? e1, UsersRecord? e2) {
    return e1?.displayName == e2?.displayName &&
        e1?.photoUrl == e2?.photoUrl &&
        e1?.createdTime == e2?.createdTime &&
        e1?.phoneNumber == e2?.phoneNumber &&
        e1?.username == e2?.username &&
        e1?.profilePicture == e2?.profilePicture &&
        e1?.iDverification == e2?.iDverification &&
        e1?.address == e2?.address &&
        e1?.emailVerified == e2?.emailVerified &&
        e1?.studentIdVerified == e2?.studentIdVerified &&
        e1?.verificationStatus == e2?.verificationStatus &&
        e1?.isSuspended == e2?.isSuspended &&
        e1?.suspendedBy == e2?.suspendedBy &&
        e1?.suspendedAt == e2?.suspendedAt &&
        e1?.suspensionReason == e2?.suspensionReason &&
        e1?.suspensionUntil == e2?.suspensionUntil &&
        e1?.warningCount == e2?.warningCount &&
        e1?.email == e2?.email;
  }

  @override
  int hash(UsersRecord? e) => const ListEquality().hash([
        e?.displayName,
        e?.photoUrl,
        e?.createdTime,
        e?.phoneNumber,
        e?.username,
        e?.profilePicture,
        e?.iDverification,
        e?.address,
        e?.emailVerified,
        e?.studentIdVerified,
        e?.verificationStatus,
        e?.isSuspended,
        e?.suspendedBy,
        e?.suspendedAt,
        e?.suspensionReason,
        e?.suspensionUntil,
        e?.warningCount,
        e?.email
      ]);

  @override
  bool isValidKey(Object? o) => o is UsersRecord;
}
