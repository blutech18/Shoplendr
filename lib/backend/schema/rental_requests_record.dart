import 'dart:async';

import 'package:collection/collection.dart';

import '/backend/schema/util/firestore_util.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

class RentalRequestsRecord extends FirestoreRecord {
  RentalRequestsRecord._(
    super.reference,
    super.data,
  ) {
    _initializeFields();
  }

  // "productRef" field.
  DocumentReference? _productRef;
  DocumentReference? get productRef => _productRef;
  bool hasProductRef() => _productRef != null;

  // "requesterRef" field.
  DocumentReference? _requesterRef;
  DocumentReference? get requesterRef => _requesterRef;
  bool hasRequesterRef() => _requesterRef != null;

  // "ownerRef" field.
  DocumentReference? _ownerRef;
  DocumentReference? get ownerRef => _ownerRef;
  bool hasOwnerRef() => _ownerRef != null;

  // "status" field.
  String? _status;
  String get status => _status ?? '';
  bool hasStatus() => _status != null;

  // "requestDate" field.
  DateTime? _requestDate;
  DateTime? get requestDate => _requestDate;
  bool hasRequestDate() => _requestDate != null;

  // "rentalStartDate" field.
  DateTime? _rentalStartDate;
  DateTime? get rentalStartDate => _rentalStartDate;
  bool hasRentalStartDate() => _rentalStartDate != null;

  // "rentalEndDate" field.
  DateTime? _rentalEndDate;
  DateTime? get rentalEndDate => _rentalEndDate;
  bool hasRentalEndDate() => _rentalEndDate != null;

  // "paymentProof" field.
  String? _paymentProof;
  String get paymentProof => _paymentProof ?? '';
  bool hasPaymentProof() => _paymentProof != null;

  // "insuranceAgreed" field.
  bool? _insuranceAgreed;
  bool get insuranceAgreed => _insuranceAgreed ?? false;
  bool hasInsuranceAgreed() => _insuranceAgreed != null;

  // "message" field.
  String? _message;
  String get message => _message ?? '';
  bool hasMessage() => _message != null;

  // "responseDate" field.
  DateTime? _responseDate;
  DateTime? get responseDate => _responseDate;
  bool hasResponseDate() => _responseDate != null;

  // "responseMessage" field.
  String? _responseMessage;
  String get responseMessage => _responseMessage ?? '';
  bool hasResponseMessage() => _responseMessage != null;

  // "totalAmount" field.
  double? _totalAmount;
  double get totalAmount => _totalAmount ?? 0.0;
  bool hasTotalAmount() => _totalAmount != null;

  void _initializeFields() {
    _productRef = snapshotData['productRef'] as DocumentReference?;
    _requesterRef = snapshotData['requesterRef'] as DocumentReference?;
    _ownerRef = snapshotData['ownerRef'] as DocumentReference?;
    _status = snapshotData['status'] as String?;
    _requestDate = snapshotData['requestDate'] as DateTime?;
    _rentalStartDate = snapshotData['rentalStartDate'] as DateTime?;
    _rentalEndDate = snapshotData['rentalEndDate'] as DateTime?;
    _paymentProof = snapshotData['paymentProof'] as String?;
    _insuranceAgreed = snapshotData['insuranceAgreed'] as bool?;
    _message = snapshotData['message'] as String?;
    _responseDate = snapshotData['responseDate'] as DateTime?;
    _responseMessage = snapshotData['responseMessage'] as String?;
    _totalAmount = castToType<double>(snapshotData['totalAmount']);
  }

  static CollectionReference get collection =>
      FirebaseFirestore.instance.collection('RentalRequests');

  static Stream<RentalRequestsRecord> getDocument(DocumentReference ref) =>
      ref.snapshots().map((s) => RentalRequestsRecord.fromSnapshot(s));

  static Future<RentalRequestsRecord> getDocumentOnce(DocumentReference ref) =>
      ref.get().then((s) => RentalRequestsRecord.fromSnapshot(s));

  static RentalRequestsRecord fromSnapshot(DocumentSnapshot snapshot) =>
      RentalRequestsRecord._(
        snapshot.reference,
        mapFromFirestore(snapshot.data() as Map<String, dynamic>),
      );

  static RentalRequestsRecord getDocumentFromData(
    Map<String, dynamic> data,
    DocumentReference reference,
  ) =>
      RentalRequestsRecord._(reference, mapFromFirestore(data));

  @override
  String toString() =>
      'RentalRequestsRecord(reference: ${reference.path}, data: $snapshotData)';

  @override
  int get hashCode => reference.path.hashCode;

  @override
  bool operator ==(other) =>
      other is RentalRequestsRecord &&
      reference.path.hashCode == other.reference.path.hashCode;
}

Map<String, dynamic> createRentalRequestsRecordData({
  DocumentReference? productRef,
  DocumentReference? requesterRef,
  DocumentReference? ownerRef,
  String? status,
  DateTime? requestDate,
  DateTime? rentalStartDate,
  DateTime? rentalEndDate,
  String? paymentProof,
  bool? insuranceAgreed,
  String? message,
  DateTime? responseDate,
  String? responseMessage,
  double? totalAmount,
}) {
  final firestoreData = mapToFirestore(
    <String, dynamic>{
      'productRef': productRef,
      'requesterRef': requesterRef,
      'ownerRef': ownerRef,
      'status': status,
      'requestDate': requestDate,
      'rentalStartDate': rentalStartDate,
      'rentalEndDate': rentalEndDate,
      'paymentProof': paymentProof,
      'insuranceAgreed': insuranceAgreed,
      'message': message,
      'responseDate': responseDate,
      'responseMessage': responseMessage,
      'totalAmount': totalAmount,
    }.withoutNulls,
  );

  return firestoreData;
}

class RentalRequestsRecordDocumentEquality
    implements Equality<RentalRequestsRecord> {
  const RentalRequestsRecordDocumentEquality();

  @override
  bool equals(RentalRequestsRecord? e1, RentalRequestsRecord? e2) {
    return e1?.productRef == e2?.productRef &&
        e1?.requesterRef == e2?.requesterRef &&
        e1?.ownerRef == e2?.ownerRef &&
        e1?.status == e2?.status &&
        e1?.requestDate == e2?.requestDate &&
        e1?.rentalStartDate == e2?.rentalStartDate &&
        e1?.rentalEndDate == e2?.rentalEndDate &&
        e1?.paymentProof == e2?.paymentProof &&
        e1?.insuranceAgreed == e2?.insuranceAgreed &&
        e1?.message == e2?.message &&
        e1?.responseDate == e2?.responseDate &&
        e1?.responseMessage == e2?.responseMessage &&
        e1?.totalAmount == e2?.totalAmount;
  }

  @override
  int hash(RentalRequestsRecord? e) => const ListEquality().hash([
        e?.productRef,
        e?.requesterRef,
        e?.ownerRef,
        e?.status,
        e?.requestDate,
        e?.rentalStartDate,
        e?.rentalEndDate,
        e?.paymentProof,
        e?.insuranceAgreed,
        e?.message,
        e?.responseDate,
        e?.responseMessage,
        e?.totalAmount
      ]);

  @override
  bool isValidKey(Object? o) => o is RentalRequestsRecord;
}
