import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flink/services/authentication.dart';
import 'package:flink/views/homescreen/home_screen.dart';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SavedPostsScreen extends StatelessWidget {
  const SavedPostsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final currentUserUid =
        Provider.of<Authentication>(context, listen: false).getUserUid;

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 63, 63, 63),
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: const Color.fromARGB(255, 28, 28, 28),
        title: const Text(
          'Saved Posts',
          style: TextStyle(
              color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20.0),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => HomeScreen()),
          ),
        ),
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

          return GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
            ),
            itemCount: savedPosts.length,
            itemBuilder: (context, index) {
              final post = savedPosts[index];
              final postId = post['postId'];

              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SavedPostsListScreen(),
                    ),
                  );
                },
                child: FutureBuilder<DocumentSnapshot>(
                  future: FirebaseFirestore.instance
                      .collection('posts')
                      .doc(postId)
                      .get(),
                  builder: (context, postSnapshot) {
                    if (postSnapshot.connectionState ==
                        ConnectionState.waiting) {
                      return Container(
                        color: Colors.grey[300],
                        child: const Center(child: CircularProgressIndicator()),
                      );
                    }
                    if (!postSnapshot.hasData || !postSnapshot.data!.exists) {
                      return Container(
                        color: Colors.grey[300],
                        child: const Center(child: Text('Post not available')),
                      );
                    }

                    final postData =
                        postSnapshot.data!.data() as Map<String, dynamic>;
                    final postImage = postData['postimage'];
                    final postCaption = postData['caption'];

                    return _buildPostTile(postImage, postCaption);
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildPostTile(String postImage, String postCaption) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: Colors.grey[800],
        image: DecorationImage(
          image: NetworkImage(postImage),
          fit: BoxFit.cover,
        ),
      ),
      child: Align(
        alignment: Alignment.bottomLeft,
        child: Container(
          color: Colors.black54,
          padding: const EdgeInsets.all(8.0),
          child: Text(
            postCaption,
            style: const TextStyle(color: Colors.white),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ),
    );
  }
}

class SavedPostsListScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final currentUserUid =
        Provider.of<Authentication>(context, listen: false).getUserUid;

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 63, 63, 63),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 28, 28, 28),
        centerTitle: true,
        title: const Text(
          'All Saved Posts',
          style: TextStyle(
              color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20.0),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
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
                    return const Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Text('Loading post...'),
                    );
                  }
                  if (!postSnapshot.hasData || !postSnapshot.data!.exists) {
                    return const Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Text('Post not available'),
                    );
                  }

                  final postData =
                      postSnapshot.data!.data() as Map<String, dynamic>;
                  final postImage = postData['postimage'] ??
                      'https://via.placeholder.com/150';
                  final postCaption =
                      postData['caption'] ?? 'No caption available';
                  final username = postData['username'] ?? 'Unknown user';
                  final userImage =
                      postData['userimage'] ?? 'https://via.placeholder.com/50';

                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Image with username, avatar, and save icon overlay
                          Stack(
                            children: [
                              // Post image with increased height
                              ClipRRect(
                                borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(16),
                                  topRight: Radius.circular(16),
                                ),
                                child: Image.network(
                                  postImage,
                                  width: MediaQuery.of(context).size.width,
                                  height: MediaQuery.of(context).size.height *
                                      0.6, // Increased height
                                  fit: BoxFit.cover,
                                ),
                              ),
                              // Username, avatar, and save icon overlay
                              Positioned(
                                top: 8,
                                left: 8,
                                child: Row(
                                  children: [
                                    CircleAvatar(
                                      backgroundImage: NetworkImage(userImage),
                                      radius: 20,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      username,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Positioned(
                                top: 8,
                                right: 8,
                                child: IconButton(
                                  icon: const Icon(Icons.bookmark,
                                      color: Colors.blue),
                                  onPressed: () async {
                                    // Remove the post from the saved_posts collection
                                    await FirebaseFirestore.instance
                                        .collection('users')
                                        .doc(currentUserUid)
                                        .collection('saved_posts')
                                        .doc(postId)
                                        .delete();

                                    // Show a snackbar to confirm the post was removed
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                            'Post removed from saved posts.'),
                                        duration: Duration(seconds: 2),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                          // Caption below image
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              postCaption,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
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
