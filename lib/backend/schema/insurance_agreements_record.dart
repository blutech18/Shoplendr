import 'dart:async';

import 'package:collection/collection.dart';

import '/backend/schema/util/firestore_util.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

class InsuranceAgreementsRecord extends FirestoreRecord {
  InsuranceAgreementsRecord._(
    super.reference,
    super.data,
  ) {
    _initializeFields();
  }

  // "userRef" field.
  DocumentReference? _userRef;
  DocumentReference? get userRef => _userRef;
  bool hasUserRef() => _userRef != null;

  // "rentalRequestRef" field.
  DocumentReference? _rentalRequestRef;
  DocumentReference? get rentalRequestRef => _rentalRequestRef;
  bool hasRentalRequestRef() => _rentalRequestRef != null;

  // "agreedAt" field.
  DateTime? _agreedAt;
  DateTime? get agreedAt => _agreedAt;
  bool hasAgreedAt() => _agreedAt != null;

  // "termsVersion" field.
  String? _termsVersion;
  String get termsVersion => _termsVersion ?? '';
  bool hasTermsVersion() => _termsVersion != null;

  // "ipAddress" field.
  String? _ipAddress;
  String get ipAddress => _ipAddress ?? '';
  bool hasIpAddress() => _ipAddress != null;

  void _initializeFields() {
    _userRef = snapshotData['userRef'] as DocumentReference?;
    _rentalRequestRef = snapshotData['rentalRequestRef'] as DocumentReference?;
    _agreedAt = snapshotData['agreedAt'] as DateTime?;
    _termsVersion = snapshotData['termsVersion'] as String?;
    _ipAddress = snapshotData['ipAddress'] as String?;
  }

  static CollectionReference get collection =>
      FirebaseFirestore.instance.collection('InsuranceAgreements');

  static Stream<InsuranceAgreementsRecord> getDocument(DocumentReference ref) =>
      ref.snapshots().map((s) => InsuranceAgreementsRecord.fromSnapshot(s));

  static Future<InsuranceAgreementsRecord> getDocumentOnce(
          DocumentReference ref) =>
      ref.get().then((s) => InsuranceAgreementsRecord.fromSnapshot(s));

  static InsuranceAgreementsRecord fromSnapshot(DocumentSnapshot snapshot) =>
      InsuranceAgreementsRecord._(
        snapshot.reference,
        mapFromFirestore(snapshot.data() as Map<String, dynamic>),
      );

  static InsuranceAgreementsRecord getDocumentFromData(
    Map<String, dynamic> data,
    DocumentReference reference,
  ) =>
      InsuranceAgreementsRecord._(reference, mapFromFirestore(data));

  @override
  String toString() =>
      'InsuranceAgreementsRecord(reference: ${reference.path}, data: $snapshotData)';

  @override
  int get hashCode => reference.path.hashCode;

  @override
  bool operator ==(other) =>
      other is InsuranceAgreementsRecord &&
      reference.path.hashCode == other.reference.path.hashCode;
}

Map<String, dynamic> createInsuranceAgreementsRecordData({
  DocumentReference? userRef,
  DocumentReference? rentalRequestRef,
  DateTime? agreedAt,
  String? termsVersion,
  String? ipAddress,
}) {
  final firestoreData = mapToFirestore(
    <String, dynamic>{
      'userRef': userRef,
      'rentalRequestRef': rentalRequestRef,
      'agreedAt': agreedAt,
      'termsVersion': termsVersion,
      'ipAddress': ipAddress,
    }.withoutNulls,
  );

  return firestoreData;
}

class InsuranceAgreementsRecordDocumentEquality
    implements Equality<InsuranceAgreementsRecord> {
  const InsuranceAgreementsRecordDocumentEquality();

  @override
  bool equals(InsuranceAgreementsRecord? e1, InsuranceAgreementsRecord? e2) {
    return e1?.userRef == e2?.userRef &&
        e1?.rentalRequestRef == e2?.rentalRequestRef &&
        e1?.agreedAt == e2?.agreedAt &&
        e1?.termsVersion == e2?.termsVersion &&
        e1?.ipAddress == e2?.ipAddress;
  }

  @override
  int hash(InsuranceAgreementsRecord? e) => const ListEquality().hash([
        e?.userRef,
        e?.rentalRequestRef,
        e?.agreedAt,
        e?.termsVersion,
        e?.ipAddress
      ]);

  @override
  bool isValidKey(Object? o) => o is InsuranceAgreementsRecord;
}
