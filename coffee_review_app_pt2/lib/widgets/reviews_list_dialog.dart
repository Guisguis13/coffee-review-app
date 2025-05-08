import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../widgets/rating_dialog.dart';

class ReviewsListDialog extends StatelessWidget {
  final String placeId;
  final String placeName;

  const ReviewsListDialog({
    super.key,
    required this.placeId,
    required this.placeName,
  });

  @override
  Widget build(BuildContext context) {
    // the query to db for the given placeId
    final reviewQuery = FirebaseFirestore.instance
        .collection('reviews')
        .where('place_id', isEqualTo: placeId);

    return AlertDialog(
      title: Text('Reviews for $placeName'),
      content: SizedBox(
        // This lets our list expand to fill the dialog’s width.
        width: double.maxFinite,
        //stream builder listens to the query and updates the UI when data changes
        child: StreamBuilder<QuerySnapshot>(
          //the snapshot is a stream of data from the query
          stream: reviewQuery.snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return const Text("Error loading reviews.");
            }
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            // Extract the list of reviews from the snapshot
            // this ternary operator checks if the snapshot has data and assigns it to docs
            // if not, it assigns an empty list to docs
            final docs = snapshot.data?.docs ?? [];
            if (docs.isEmpty) {
              return const Text("No reviews yet.");
            }

            // Build a ListView of all reviews
            return ListView.builder(
              shrinkWrap: true,
              itemCount: docs.length,
              itemBuilder: (context, index) {
                // Extract the data from each document
                // and assign it to a Map<String, dynamic> variable
                final data = docs[index].data() as Map<String, dynamic>;
                final rating = data['rating'] ?? 0;
                final comment = data['comment'] ?? '';
                final userId = data['user_id'] ?? 'unknown';
                // Build a card for each review and create rows to display the info more clearly
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 6.0),
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const Icon(Icons.star, color: Colors.amber),
                            const SizedBox(width: 4),
                            Text(
                              rating.toString(),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                comment,
                                style: const TextStyle(fontSize: 14),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'by $userId',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
      actions: [
        // Button to open your existing RatingDialog
        TextButton(
          onPressed: () {
            // Close this dialog first
            Navigator.pop(context);
            // Then show your RatingDialog
            showDialog(
              context: context,
              builder: (_) => RatingDialog(
                placeId: placeId,
                placeName: placeName,
              ),
            );
          },
          child: const Text("Leave a Review"),
        ),
        // Close button
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Close"),
        ),
      ],
    );
  }
}
