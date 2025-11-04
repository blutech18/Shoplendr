import 'dart:async';

import 'package:collection/collection.dart';

import '/backend/schema/util/firestore_util.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

class ShopListviewRecord extends FirestoreRecord {
  ShopListviewRecord._(
    super.reference,
    super.data,
  ) {
    _initializeFields();
  }

  // "name" field.
  String? _name;
  String get name => _name ?? '';
  bool hasName() => _name != null;

  // "Image" field.
  String? _image;
  String get image => _image ?? '';
  bool hasImage() => _image != null;

  // "Rating" field.
  String? _rating;
  String get rating => _rating ?? '';
  bool hasRating() => _rating != null;

  void _initializeFields() {
    _name = snapshotData['name'] as String?;
    _image = snapshotData['Image'] as String?;
    _rating = snapshotData['Rating'] as String?;
  }

  static CollectionReference get collection =>
      FirebaseFirestore.instance.collection('shop_listview');

  static Stream<ShopListviewRecord> getDocument(DocumentReference ref) =>
      ref.snapshots().map((s) => ShopListviewRecord.fromSnapshot(s));

  static Future<ShopListviewRecord> getDocumentOnce(DocumentReference ref) =>
      ref.get().then((s) => ShopListviewRecord.fromSnapshot(s));

  static ShopListviewRecord fromSnapshot(DocumentSnapshot snapshot) =>
      ShopListviewRecord._(
        snapshot.reference,
        mapFromFirestore(snapshot.data() as Map<String, dynamic>),
      );

  static ShopListviewRecord getDocumentFromData(
    Map<String, dynamic> data,
    DocumentReference reference,
  ) =>
      ShopListviewRecord._(reference, mapFromFirestore(data));

  @override
  String toString() =>
      'ShopListviewRecord(reference: ${reference.path}, data: $snapshotData)';

  @override
  int get hashCode => reference.path.hashCode;

  @override
  bool operator ==(other) =>
      other is ShopListviewRecord &&
      reference.path.hashCode == other.reference.path.hashCode;
}

Map<String, dynamic> createShopListviewRecordData({
  String? name,
  String? image,
  String? rating,
}) {
  final firestoreData = mapToFirestore(
    <String, dynamic>{
      'name': name,
      'Image': image,
      'Rating': rating,
    }.withoutNulls,
  );

  return firestoreData;
}

class ShopListviewRecordDocumentEquality
    implements Equality<ShopListviewRecord> {
  const ShopListviewRecordDocumentEquality();

  @override
  bool equals(ShopListviewRecord? e1, ShopListviewRecord? e2) {
    return e1?.name == e2?.name &&
        e1?.image == e2?.image &&
        e1?.rating == e2?.rating;
  }

  @override
  int hash(ShopListviewRecord? e) =>
      const ListEquality().hash([e?.name, e?.image, e?.rating]);

  @override
  bool isValidKey(Object? o) => o is ShopListviewRecord;
}
