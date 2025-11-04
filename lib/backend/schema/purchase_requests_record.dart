import 'dart:async';

import 'package:collection/collection.dart';

import '/backend/schema/util/firestore_util.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

class PurchaseRequestsRecord extends FirestoreRecord {
  PurchaseRequestsRecord._(
    super.reference,
    super.data,
  ) {
    _initializeFields();
  }

  // "productRef" field.
  DocumentReference? _productRef;
  DocumentReference? get productRef => _productRef;
  bool hasProductRef() => _productRef != null;

  // "buyerRef" field.
  DocumentReference? _buyerRef;
  DocumentReference? get buyerRef => _buyerRef;
  bool hasBuyerRef() => _buyerRef != null;

  // "sellerRef" field.
  DocumentReference? _sellerRef;
  DocumentReference? get sellerRef => _sellerRef;
  bool hasSellerRef() => _sellerRef != null;

  // "status" field.
  String? _status;
  String get status => _status ?? '';
  bool hasStatus() => _status != null;

  // "requestDate" field.
  DateTime? _requestDate;
  DateTime? get requestDate => _requestDate;
  bool hasRequestDate() => _requestDate != null;

  // "paymentProof" field.
  String? _paymentProof;
  String get paymentProof => _paymentProof ?? '';
  bool hasPaymentProof() => _paymentProof != null;

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

  // "confirmedDate" field.
  DateTime? _confirmedDate;
  DateTime? get confirmedDate => _confirmedDate;
  bool hasConfirmedDate() => _confirmedDate != null;

  void _initializeFields() {
    _productRef = snapshotData['productRef'] as DocumentReference?;
    _buyerRef = snapshotData['buyerRef'] as DocumentReference?;
    _sellerRef = snapshotData['sellerRef'] as DocumentReference?;
    _status = snapshotData['status'] as String?;
    _requestDate = snapshotData['requestDate'] as DateTime?;
    _paymentProof = snapshotData['paymentProof'] as String?;
    _message = snapshotData['message'] as String?;
    _responseDate = snapshotData['responseDate'] as DateTime?;
    _responseMessage = snapshotData['responseMessage'] as String?;
    _totalAmount = castToType<double>(snapshotData['totalAmount']);
    _confirmedDate = snapshotData['confirmedDate'] as DateTime?;
  }

  static CollectionReference get collection =>
      FirebaseFirestore.instance.collection('PurchaseRequests');

  static Stream<PurchaseRequestsRecord> getDocument(DocumentReference ref) =>
      ref.snapshots().map((s) => PurchaseRequestsRecord.fromSnapshot(s));

  static Future<PurchaseRequestsRecord> getDocumentOnce(DocumentReference ref) =>
      ref.get().then((s) => PurchaseRequestsRecord.fromSnapshot(s));

  static PurchaseRequestsRecord fromSnapshot(DocumentSnapshot snapshot) =>
      PurchaseRequestsRecord._(
        snapshot.reference,
        mapFromFirestore(snapshot.data() as Map<String, dynamic>),
      );

  static PurchaseRequestsRecord getDocumentFromData(
    Map<String, dynamic> data,
    DocumentReference reference,
  ) =>
      PurchaseRequestsRecord._(reference, mapFromFirestore(data));

  @override
  String toString() =>
      'PurchaseRequestsRecord(reference: ${reference.path}, data: $snapshotData)';

  @override
  int get hashCode => reference.path.hashCode;

  @override
  bool operator ==(other) =>
      other is PurchaseRequestsRecord &&
      reference.path.hashCode == other.reference.path.hashCode;
}

Map<String, dynamic> createPurchaseRequestsRecordData({
  DocumentReference? productRef,
  DocumentReference? buyerRef,
  DocumentReference? sellerRef,
  String? status,
  DateTime? requestDate,
  String? paymentProof,
  String? message,
  DateTime? responseDate,
  String? responseMessage,
  double? totalAmount,
  DateTime? confirmedDate,
}) {
  final firestoreData = mapToFirestore(
    <String, dynamic>{
      'productRef': productRef,
      'buyerRef': buyerRef,
      'sellerRef': sellerRef,
      'status': status,
      'requestDate': requestDate,
      'paymentProof': paymentProof,
      'message': message,
      'responseDate': responseDate,
      'responseMessage': responseMessage,
      'totalAmount': totalAmount,
      'confirmedDate': confirmedDate,
    }.withoutNulls,
  );

  return firestoreData;
}

class PurchaseRequestsRecordDocumentEquality
    implements Equality<PurchaseRequestsRecord> {
  const PurchaseRequestsRecordDocumentEquality();

  @override
  bool equals(PurchaseRequestsRecord? e1, PurchaseRequestsRecord? e2) {
    return e1?.productRef == e2?.productRef &&
        e1?.buyerRef == e2?.buyerRef &&
        e1?.sellerRef == e2?.sellerRef &&
        e1?.status == e2?.status &&
        e1?.requestDate == e2?.requestDate &&
        e1?.paymentProof == e2?.paymentProof &&
        e1?.message == e2?.message &&
        e1?.responseDate == e2?.responseDate &&
        e1?.responseMessage == e2?.responseMessage &&
        e1?.totalAmount == e2?.totalAmount &&
        e1?.confirmedDate == e2?.confirmedDate;
  }

  @override
  int hash(PurchaseRequestsRecord? e) => const ListEquality().hash([
        e?.productRef,
        e?.buyerRef,
        e?.sellerRef,
        e?.status,
        e?.requestDate,
        e?.paymentProof,
        e?.message,
        e?.responseDate,
        e?.responseMessage,
        e?.totalAmount,
        e?.confirmedDate
      ]);

  @override
  bool isValidKey(Object? o) => o is PurchaseRequestsRecord;
}
