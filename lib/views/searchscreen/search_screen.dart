import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flink/services/authentication.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SearchScreen extends StatelessWidget {
  const SearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final currentUserUid =
        Provider.of<Authentication>(context, listen: false).getUserUid;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Saved Posts'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(currentUserUid)
            .collection('saved_posts')
            .orderBy('savedAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No saved posts available.'));
          }

          final savedPosts = snapshot.data!.docs;

          return ListView.builder(
            itemCount: savedPosts.length,
            itemBuilder: (context, index) {
              final post = savedPosts[index];
              final postId = post['postId'];

              return FutureBuilder<DocumentSnapshot>(
                future: FirebaseFirestore.instance
                    .collection('posts')
                    .doc(postId)
                    .get(),
                builder: (context, postSnapshot) {
                  if (postSnapshot.connectionState == ConnectionState.waiting) {
                    return const ListTile(
                      title: Text('Loading post...'),
                    );
                  }
                  if (!postSnapshot.hasData || !postSnapshot.data!.exists) {
                    return const ListTile(
                      title: Text('Post not available'),
                    );
                  }

                  final postData =
                      postSnapshot.data!.data() as Map<String, dynamic>;
                  final postImage = postData['postimage'];
                  final postCaption = postData['caption'];

                  return ListTile(
                    leading: Image.network(
                      postImage,
                      width: 50,
                      height: 50,
                      fit: BoxFit.cover,
                    ),
                    title: Text(postCaption),
                    subtitle: Text('Post ID: $postId'),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
