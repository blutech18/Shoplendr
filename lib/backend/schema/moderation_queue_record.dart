import 'dart:async';

import 'package:collection/collection.dart';

import '/backend/schema/util/firestore_util.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

class ModerationQueueRecord extends FirestoreRecord {
  ModerationQueueRecord._(
    super.reference,
    super.data,
  ) {
    _initializeFields();
  }

  // "content_type" field.
  String? _contentType;
  String get contentType => _contentType ?? '';
  bool hasContentType() => _contentType != null;

  // "content_ref" field.
  DocumentReference? _contentRef;
  DocumentReference? get contentRef => _contentRef;
  bool hasContentRef() => _contentRef != null;

  // "reporter_ref" field.
  DocumentReference? _reporterRef;
  DocumentReference? get reporterRef => _reporterRef;
  bool hasReporterRef() => _reporterRef != null;

  // "reason" field.
  String? _reason;
  String get reason => _reason ?? '';
  bool hasReason() => _reason != null;

  // "description" field.
  String? _description;
  String get description => _description ?? '';
  bool hasDescription() => _description != null;

  // "status" field.
  String? _status;
  String get status => _status ?? '';
  bool hasStatus() => _status != null;

  // "priority" field.
  String? _priority;
  String get priority => _priority ?? '';
  bool hasPriority() => _priority != null;

  // "reviewed_by" field.
  DocumentReference? _reviewedBy;
  DocumentReference? get reviewedBy => _reviewedBy;
  bool hasReviewedBy() => _reviewedBy != null;

  // "reviewed_at" field.
  DateTime? _reviewedAt;
  DateTime? get reviewedAt => _reviewedAt;
  bool hasReviewedAt() => _reviewedAt != null;

  // "action_taken" field.
  String? _actionTaken;
  String get actionTaken => _actionTaken ?? '';
  bool hasActionTaken() => _actionTaken != null;

  // "notes" field.
  String? _notes;
  String get notes => _notes ?? '';
  bool hasNotes() => _notes != null;

  // "created_at" field.
  DateTime? _createdAt;
  DateTime? get createdAt => _createdAt;
  bool hasCreatedAt() => _createdAt != null;

  void _initializeFields() {
    _contentType = snapshotData['content_type'] as String?;
    _contentRef = snapshotData['content_ref'] as DocumentReference?;
    _reporterRef = snapshotData['reporter_ref'] as DocumentReference?;
    _reason = snapshotData['reason'] as String?;
    _description = snapshotData['description'] as String?;
    _status = snapshotData['status'] as String?;
    _priority = snapshotData['priority'] as String?;
    _reviewedBy = snapshotData['reviewed_by'] as DocumentReference?;
    _reviewedAt = snapshotData['reviewed_at'] as DateTime?;
    _actionTaken = snapshotData['action_taken'] as String?;
    _notes = snapshotData['notes'] as String?;
    _createdAt = snapshotData['created_at'] as DateTime?;
  }

  static CollectionReference get collection =>
      FirebaseFirestore.instance.collection('ModerationQueue');

  static Stream<ModerationQueueRecord> getDocument(DocumentReference ref) =>
      ref.snapshots().map((s) => ModerationQueueRecord.fromSnapshot(s));

  static Future<ModerationQueueRecord> getDocumentOnce(DocumentReference ref) =>
      ref.get().then((s) => ModerationQueueRecord.fromSnapshot(s));

  static ModerationQueueRecord fromSnapshot(DocumentSnapshot snapshot) =>
      ModerationQueueRecord._(
        snapshot.reference,
        mapFromFirestore(snapshot.data() as Map<String, dynamic>),
      );

  static ModerationQueueRecord getDocumentFromData(
    Map<String, dynamic> data,
    DocumentReference reference,
  ) =>
      ModerationQueueRecord._(reference, mapFromFirestore(data));

  @override
  String toString() =>
      'ModerationQueueRecord(reference: ${reference.path}, data: $snapshotData)';

  @override
  int get hashCode => reference.path.hashCode;

  @override
  bool operator ==(other) =>
      other is ModerationQueueRecord &&
      reference.path.hashCode == other.reference.path.hashCode;
}

Map<String, dynamic> createModerationQueueRecordData({
  String? contentType,
  DocumentReference? contentRef,
  DocumentReference? reporterRef,
  String? reason,
  String? description,
  String? status,
  String? priority,
  DocumentReference? reviewedBy,
  DateTime? reviewedAt,
  String? actionTaken,
  String? notes,
  DateTime? createdAt,
}) {
  final firestoreData = mapToFirestore(
    <String, dynamic>{
      'content_type': contentType,
      'content_ref': contentRef,
      'reporter_ref': reporterRef,
      'reason': reason,
      'description': description,
      'status': status,
      'priority': priority,
      'reviewed_by': reviewedBy,
      'reviewed_at': reviewedAt,
      'action_taken': actionTaken,
      'notes': notes,
      'created_at': createdAt,
    }.withoutNulls,
  );

  return firestoreData;
}

class ModerationQueueRecordDocumentEquality
    implements Equality<ModerationQueueRecord> {
  const ModerationQueueRecordDocumentEquality();

  @override
  bool equals(ModerationQueueRecord? e1, ModerationQueueRecord? e2) {
    return e1?.contentType == e2?.contentType &&
        e1?.contentRef == e2?.contentRef &&
        e1?.reporterRef == e2?.reporterRef &&
        e1?.reason == e2?.reason &&
        e1?.description == e2?.description &&
        e1?.status == e2?.status &&
        e1?.priority == e2?.priority &&
        e1?.reviewedBy == e2?.reviewedBy &&
        e1?.reviewedAt == e2?.reviewedAt &&
        e1?.actionTaken == e2?.actionTaken &&
        e1?.notes == e2?.notes &&
        e1?.createdAt == e2?.createdAt;
  }

  @override
  int hash(ModerationQueueRecord? e) => const ListEquality().hash([
        e?.contentType,
        e?.contentRef,
        e?.reporterRef,
        e?.reason,
        e?.description,
        e?.status,
        e?.priority,
        e?.reviewedBy,
        e?.reviewedAt,
        e?.actionTaken,
        e?.notes,
        e?.createdAt
      ]);

  @override
  bool isValidKey(Object? o) => o is ModerationQueueRecord;
}
