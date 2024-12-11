import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flink/services/authentication.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class PostDetailsScreen extends StatelessWidget {
  final String postId;
  final String postImage;

  PostDetailsScreen({required this.postId, required this.postImage});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          'Post Details',
          style: TextStyle(
              color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20.0),
        ),
        backgroundColor: Colors.black,
        actions: [
          IconButton(
            color: Colors.red,
            icon: Icon(Icons.delete),
            onPressed: () {
              _showDeleteConfirmationDialog(context);
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.network(postImage),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // Delete Confirmation Dialog
  void _showDeleteConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Color.fromARGB(255, 40, 40, 40),
          title: const Text(
            'Delete Post',
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
          ),
          content: const Text(
            'Are you sure you want to delete this post from profile ?',
            style: TextStyle(color: Colors.white),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel', style: TextStyle(color: Colors.green)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () async {
                await FirebaseFirestore.instance
                    .collection('users')
                    .doc(Provider.of<Authentication>(context, listen: false)
                        .getUserUid)
                    .collection('posts')
                    .doc(postId) // The post to be deleted
                    .delete();
                Navigator.of(context).pop(); // Close the dialog
                Navigator.of(context).pop(); // Go back to profile page
              },
              child: Text('Delete', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }
}
