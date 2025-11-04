import 'dart:async';

import 'package:collection/collection.dart';

import '/backend/schema/util/firestore_util.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

class ReviewsRecord extends FirestoreRecord {
  ReviewsRecord._(
    super.reference,
    super.data,
  ) {
    _initializeFields();
  }

  // "product_ref" field.
  DocumentReference? _productRef;
  DocumentReference? get productRef => _productRef;
  bool hasProductRef() => _productRef != null;

  // "reviewer_ref" field.
  DocumentReference? _reviewerRef;
  DocumentReference? get reviewerRef => _reviewerRef;
  bool hasReviewerRef() => _reviewerRef != null;

  // "seller_ref" field.
  DocumentReference? _sellerRef;
  DocumentReference? get sellerRef => _sellerRef;
  bool hasSellerRef() => _sellerRef != null;

  // "rating" field.
  double? _rating;
  double get rating => _rating ?? 0.0;
  bool hasRating() => _rating != null;

  // "comment" field.
  String? _comment;
  String get comment => _comment ?? '';
  bool hasComment() => _comment != null;

  // "review_type" field.
  String? _reviewType;
  String get reviewType => _reviewType ?? '';
  bool hasReviewType() => _reviewType != null;

  // "is_verified_purchase" field.
  bool? _isVerifiedPurchase;
  bool get isVerifiedPurchase => _isVerifiedPurchase ?? false;
  bool hasIsVerifiedPurchase() => _isVerifiedPurchase != null;

  // "helpful_count" field.
  int? _helpfulCount;
  int get helpfulCount => _helpfulCount ?? 0;
  bool hasHelpfulCount() => _helpfulCount != null;

  // "images" field.
  List<String>? _images;
  List<String> get images => _images ?? const [];
  bool hasImages() => _images != null;

  // "created_at" field.
  DateTime? _createdAt;
  DateTime? get createdAt => _createdAt;
  bool hasCreatedAt() => _createdAt != null;

  // "updated_at" field.
  DateTime? _updatedAt;
  DateTime? get updatedAt => _updatedAt;
  bool hasUpdatedAt() => _updatedAt != null;

  void _initializeFields() {
    _productRef = snapshotData['product_ref'] as DocumentReference?;
    _reviewerRef = snapshotData['reviewer_ref'] as DocumentReference?;
    _sellerRef = snapshotData['seller_ref'] as DocumentReference?;
    _rating = castToType<double>(snapshotData['rating']);
    _comment = snapshotData['comment'] as String?;
    _reviewType = snapshotData['review_type'] as String?;
    _isVerifiedPurchase = snapshotData['is_verified_purchase'] as bool?;
    _helpfulCount = castToType<int>(snapshotData['helpful_count']);
    _images = getDataList(snapshotData['images']);
    _createdAt = snapshotData['created_at'] as DateTime?;
    _updatedAt = snapshotData['updated_at'] as DateTime?;
  }

  static CollectionReference get collection =>
      FirebaseFirestore.instance.collection('Reviews');

  static Stream<ReviewsRecord> getDocument(DocumentReference ref) =>
      ref.snapshots().map((s) => ReviewsRecord.fromSnapshot(s));

  static Future<ReviewsRecord> getDocumentOnce(DocumentReference ref) =>
      ref.get().then((s) => ReviewsRecord.fromSnapshot(s));

  static ReviewsRecord fromSnapshot(DocumentSnapshot snapshot) =>
      ReviewsRecord._(
        snapshot.reference,
        mapFromFirestore(snapshot.data() as Map<String, dynamic>),
      );

  static ReviewsRecord getDocumentFromData(
    Map<String, dynamic> data,
    DocumentReference reference,
  ) =>
      ReviewsRecord._(reference, mapFromFirestore(data));

  @override
  String toString() =>
      'ReviewsRecord(reference: ${reference.path}, data: $snapshotData)';

  @override
  int get hashCode => reference.path.hashCode;

  @override
  bool operator ==(other) =>
      other is ReviewsRecord &&
      reference.path.hashCode == other.reference.path.hashCode;
}

Map<String, dynamic> createReviewsRecordData({
  DocumentReference? productRef,
  DocumentReference? reviewerRef,
  DocumentReference? sellerRef,
  double? rating,
  String? comment,
  String? reviewType,
  bool? isVerifiedPurchase,
  int? helpfulCount,
  DateTime? createdAt,
  DateTime? updatedAt,
}) {
  final firestoreData = mapToFirestore(
    <String, dynamic>{
      'product_ref': productRef,
      'reviewer_ref': reviewerRef,
      'seller_ref': sellerRef,
      'rating': rating,
      'comment': comment,
      'review_type': reviewType,
      'is_verified_purchase': isVerifiedPurchase,
      'helpful_count': helpfulCount,
      'created_at': createdAt,
      'updated_at': updatedAt,
    }.withoutNulls,
  );

  return firestoreData;
}

class ReviewsRecordDocumentEquality implements Equality<ReviewsRecord> {
  const ReviewsRecordDocumentEquality();

  @override
  bool equals(ReviewsRecord? e1, ReviewsRecord? e2) {
    const listEquality = ListEquality();
    return e1?.productRef == e2?.productRef &&
        e1?.reviewerRef == e2?.reviewerRef &&
        e1?.sellerRef == e2?.sellerRef &&
        e1?.rating == e2?.rating &&
        e1?.comment == e2?.comment &&
        e1?.reviewType == e2?.reviewType &&
        e1?.isVerifiedPurchase == e2?.isVerifiedPurchase &&
        e1?.helpfulCount == e2?.helpfulCount &&
        listEquality.equals(e1?.images, e2?.images) &&
        e1?.createdAt == e2?.createdAt &&
        e1?.updatedAt == e2?.updatedAt;
  }

  @override
  int hash(ReviewsRecord? e) => const ListEquality().hash([
        e?.productRef,
        e?.reviewerRef,
        e?.sellerRef,
        e?.rating,
        e?.comment,
        e?.reviewType,
        e?.isVerifiedPurchase,
        e?.helpfulCount,
        e?.images,
        e?.createdAt,
        e?.updatedAt
      ]);

  @override
  bool isValidKey(Object? o) => o is ReviewsRecord;
}
