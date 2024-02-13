

import 'package:afib/src/dart/utils/af_document_id_generator.dart';

/// A document retrieved from cloud firestore.
/// 
/// This utility class makes it easier to treat results from 
/// firestore documents and snapshots the same.  It also makes it easier
/// to create test data without having a firestore connection.
class AFFirestoreDocument {

  String documentId;
  Map<String, dynamic> data;
  bool exists;

  AFFirestoreDocument({
    required this.documentId,
    required this.data,
    required this.exists,
  });

  factory AFFirestoreDocument.fromDoc(dynamic doc) {
    return AFFirestoreDocument(documentId: doc.documentId, data: doc.data, exists: true);    
  }

  /// Returns true if this object has not yet been saved to firestore.  
  /// 
  /// Assumes new objects' ids will start with newId.
  bool get isNew { 
    return AFDocumentIDGenerator.isNewId(documentId);
  }
}