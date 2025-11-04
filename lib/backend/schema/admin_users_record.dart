import 'dart:async';

import 'package:collection/collection.dart';

import '/backend/schema/util/firestore_util.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

class AdminUsersRecord extends FirestoreRecord {
  AdminUsersRecord._(
    super.reference,
    super.data,
  ) {
    _initializeFields();
  }

  // "user_ref" field.
  DocumentReference? _userRef;
  DocumentReference? get userRef => _userRef;
  bool hasUserRef() => _userRef != null;

  // "role" field.
  String? _role;
  String get role => _role ?? '';
  bool hasRole() => _role != null;

  // "permissions" field.
  List<String>? _permissions;
  List<String> get permissions => _permissions ?? const [];
  bool hasPermissions() => _permissions != null;

  // "is_active" field.
  bool? _isActive;
  bool get isActive => _isActive ?? true;
  bool hasIsActive() => _isActive != null;

  // "created_at" field.
  DateTime? _createdAt;
  DateTime? get createdAt => _createdAt;
  bool hasCreatedAt() => _createdAt != null;

  // "created_by" field.
  DocumentReference? _createdBy;
  DocumentReference? get createdBy => _createdBy;
  bool hasCreatedBy() => _createdBy != null;

  void _initializeFields() {
    _userRef = snapshotData['user_ref'] as DocumentReference?;
    _role = snapshotData['role'] as String?;
    _permissions = getDataList(snapshotData['permissions']);
    _isActive = snapshotData['is_active'] as bool?;
    _createdAt = snapshotData['created_at'] as DateTime?;
    _createdBy = snapshotData['created_by'] as DocumentReference?;
  }

  static CollectionReference get collection =>
      FirebaseFirestore.instance.collection('AdminUsers');

  static Stream<AdminUsersRecord> getDocument(DocumentReference ref) =>
      ref.snapshots().map((s) => AdminUsersRecord.fromSnapshot(s));

  static Future<AdminUsersRecord> getDocumentOnce(DocumentReference ref) =>
      ref.get().then((s) => AdminUsersRecord.fromSnapshot(s));

  static AdminUsersRecord fromSnapshot(DocumentSnapshot snapshot) =>
      AdminUsersRecord._(
        snapshot.reference,
        mapFromFirestore(snapshot.data() as Map<String, dynamic>),
      );

  static AdminUsersRecord getDocumentFromData(
    Map<String, dynamic> data,
    DocumentReference reference,
  ) =>
      AdminUsersRecord._(reference, mapFromFirestore(data));

  @override
  String toString() =>
      'AdminUsersRecord(reference: ${reference.path}, data: $snapshotData)';

  @override
  int get hashCode => reference.path.hashCode;

  @override
  bool operator ==(other) =>
      other is AdminUsersRecord &&
      reference.path.hashCode == other.reference.path.hashCode;
}

Map<String, dynamic> createAdminUsersRecordData({
  DocumentReference? userRef,
  String? role,
  bool? isActive,
  DateTime? createdAt,
  DocumentReference? createdBy,
}) {
  final firestoreData = mapToFirestore(
    <String, dynamic>{
      'user_ref': userRef,
      'role': role,
      'is_active': isActive,
      'created_at': createdAt,
      'created_by': createdBy,
    }.withoutNulls,
  );

  return firestoreData;
}

class AdminUsersRecordDocumentEquality implements Equality<AdminUsersRecord> {
  const AdminUsersRecordDocumentEquality();

  @override
  bool equals(AdminUsersRecord? e1, AdminUsersRecord? e2) {
    const listEquality = ListEquality();
    return e1?.userRef == e2?.userRef &&
        e1?.role == e2?.role &&
        listEquality.equals(e1?.permissions, e2?.permissions) &&
        e1?.isActive == e2?.isActive &&
        e1?.createdAt == e2?.createdAt &&
        e1?.createdBy == e2?.createdBy;
  }

  @override
  int hash(AdminUsersRecord? e) => const ListEquality().hash([
        e?.userRef,
        e?.role,
        e?.permissions,
        e?.isActive,
        e?.createdAt,
        e?.createdBy
      ]);

  @override
  bool isValidKey(Object? o) => o is AdminUsersRecord;
}
