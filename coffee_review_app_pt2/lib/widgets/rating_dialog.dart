import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import '../services/review_service.dart';

class RatingDialog extends StatefulWidget {
  final String placeId;
  final String placeName;

  const RatingDialog({
    super.key,
    required this.placeId,
    required this.placeName,
  });

  @override
  State<RatingDialog> createState() => _RatingDialogState();
}
// This widget is used to show a dialog for rating a place
class _RatingDialogState extends State<RatingDialog> {
  double _rating = 3.0;
  final _commentController = TextEditingController();

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }
  // Submit the rating and comment to the server
  void _submitRating() async {
    await ReviewService().submitReview(
      widget.placeId,
      widget.placeName,
      _rating.toInt(),
      _commentController.text.trim(),
    );
    //close the dialog after submitting the rating
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    // Show a dialog with a rating bar and a text field for comments
    //the rating bar allows the user to select a rating from 1 to 5 stars
    // hte text field allows the user to enter a comment about the place
    return AlertDialog(
      title: Text("Rate ${widget.placeName}"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          RatingBar.builder(
            initialRating: 3.0,
            minRating: 1,
            maxRating: 5,
            itemCount: 5,
            allowHalfRating: false,
            itemBuilder: (_, __) => const Icon(
              Icons.star,
              color: Colors.amber,
            ),
            onRatingUpdate: (value) => _rating = value,
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _commentController,
            decoration: const InputDecoration(
              labelText: "Comment",
              hintText: "What did you like or dislike?",
            ),
          ),
        ],
      ),
      // the dialog has two buttons: Cancel and Submit
      // cancel button closes the dialog without submitting the rating
      // submit button submits the rating and comment to the server
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Cancel"),
        ),
        ElevatedButton(
          onPressed: _submitRating,
          child: const Text("Submit"),
        ),
      ],
    );
  }
}
