import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class ReportedItem {
  final String id;
  final String name;
  final String description;
  final dynamic location;
  final String category;
  final String phoneNumber;
  static final String collectionPath = "reportedItems";
  final String firestoreID;
  static final FirebaseFirestore db = FirebaseFirestore.instance;
  static final String displayName =
      FirebaseAuth.instance.currentUser?.displayName ?? 'John Doe';
  String get reporterName => displayName;
  final String? personName;
  final String? imagePath; // Img URL
  final String? deleteUrl;
  final Timestamp createdAt;
  final bool isFound;

  const ReportedItem({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.location,
    required this.phoneNumber,
    required this.firestoreID,
    required this.createdAt,
    this.imagePath, // Now stores the Firebase Storage URL
    this.personName,
    this.deleteUrl,
    this.isFound = false,
  });

  factory ReportedItem.fromJson(Map<String, dynamic> json, String id) {
    return ReportedItem(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      category: json['category'],
      location: json['location'],
      phoneNumber: json['phoneNumber'],
      firestoreID: id,
      imagePath: json['imagePath'],
      personName: json['reporterName'],
      createdAt: json['createdAt'],
      isFound: json['isFound'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'category': category,
      'location': location,
      'reporterName': reporterName,
      'phoneNumber': phoneNumber,
      'imagePath': imagePath,
      "deleteUrl": deleteUrl,
      "createdAt": Timestamp.fromDate(DateTime.now()),
      "isFound": isFound,
    };
  }

  Future<bool> deleteImgBBImage(String? deleteUrl) async {
    if (deleteUrl == null || deleteUrl.isEmpty) {
      print('Error: deleteUrl is null or empty');
      return false;
    }

    try {
      // Parse delete_url
      final uri = Uri.parse(deleteUrl);
      final segments = uri.pathSegments;
      if (segments.length < 2) {
        print('Error: Invalid delete_url format: $deleteUrl');
        return false;
      }
      final imageId = segments[0];
      final imageHash = segments[1];

      // Create multipart request
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('https://ibb.co/json'),
      );
      request.headers['User-Agent'] =
          'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36';
      request.headers['Accept'] = 'application/json';
      request.fields['action'] = 'delete';
      request.fields['delete'] = 'image';
      request.fields['from'] = 'resource';
      request.fields['deleting[id]'] = imageId;
      request.fields['deleting[hash]'] = imageHash;

      // Send request
      final response = await request.send();
      final responseBody = await response.stream.bytesToString();
      print(
        'Delete response: Status ${response.statusCode}, Body: $responseBody',
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        print(
          'Failed to delete image: Status ${response.statusCode}, Body: $responseBody',
        );
        return false;
      }
    } catch (e) {
      print('Error deleting ImgBB image: $e');
      return false;
    }
  }

  // Get all ReportedItems objects
  static Stream<List<ReportedItem>> getReportedItems() {
    return db
        .collection(collectionPath)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs
                  .map((items) => ReportedItem.fromJson(items.data(), items.id))
                  .toList(),
        );
  }

  // Add a found item
  Future<String> uploadReportedItem() async {
    try {
      final docRef = await db.collection(collectionPath).add(toJson());
      return docRef.id;
    } catch (error) {
      debugPrint("Error uploading reported item: $error");
      rethrow;
    }
  }

  // Update a found item
  Future<void> updateReportedItem() async {
    try {
      await db.collection(collectionPath).doc(firestoreID).update(toJson());
    } catch (error) {
      debugPrint("Error updating reported item: $error");
      rethrow;
    }
  }

  // Delete a found item
  Future<void> deleteReportedItem() async {
    try {
      deleteImgBBImage(deleteUrl);
      await db.collection(collectionPath).doc(firestoreID).delete();
    } catch (error) {
      debugPrint("Error deleting reported item: $error");
      rethrow;
    }
  }
}
