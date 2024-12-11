import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class PersonalChatScreen extends StatefulWidget {
  final String receiverUid;
  final String receiverName;
  final String receiverProfileImage;

  PersonalChatScreen({
    required this.receiverUid,
    required this.receiverName,
    required this.receiverProfileImage,
  });

  @override
  _PersonalChatScreenState createState() => _PersonalChatScreenState();
}

class _PersonalChatScreenState extends State<PersonalChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final User? _currentUser = FirebaseAuth.instance.currentUser;

  void _sendMessage() async {
    if (_messageController.text.trim().isEmpty || _currentUser == null) return;

    final String message = _messageController.text.trim();
    final Timestamp timestamp = Timestamp.now();
    final String chatId = _getChatId();

    try {
      // Fetch sender's profile image and username from Firestore
      final senderSnapshot =
          await _firestore.collection('users').doc(_currentUser!.uid).get();

      final senderProfileImage =
          senderSnapshot.data()?['profileImageUrl'] ?? 'default_image_url';
      final senderUsername = senderSnapshot.data()?['username'] ?? 'Anonymous';

      // Save message to messages subcollection
      await _firestore
          .collection('chats')
          .doc(chatId)
          .collection('messages')
          .add({
        'senderId': _currentUser!.uid,
        'senderUsername': senderUsername,
        'senderProfileImage': senderProfileImage,
        'receiverId': widget.receiverUid,
        'receiverName': widget.receiverName,
        'receiverProfileImage': widget.receiverProfileImage,
        'message': message,
        'timestamp': timestamp,
      });

      // Update chat metadata in the main chat document
      await _firestore.collection('chats').doc(chatId).set({
        'participants': [_currentUser!.uid, widget.receiverUid],
        'lastMessage': message,
        'lastMessageTimestamp': timestamp,
        'receiverName': widget.receiverName,
        'receiverProfileImage': widget.receiverProfileImage,
      }, SetOptions(merge: true));

      _messageController.clear();
    } catch (e) {
      print('Failed to send message: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to send message: $e')),
      );
    }
  }

  String _getChatId() {
    return _currentUser!.uid.compareTo(widget.receiverUid) < 0
        ? '${_currentUser!.uid}_${widget.receiverUid}'
        : '${widget.receiverUid}_${_currentUser!.uid}';
  }

  void _confirmDeleteMessage(String messageId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Delete Message"),
        content: Text("Are you sure you want to delete this message?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteMessage(messageId);
            },
            child: Text("Delete"),
          ),
        ],
      ),
    );
  }

  void _deleteMessage(String messageId) async {
    try {
      final chatId = _getChatId();
      await _firestore
          .collection('chats')
          .doc(chatId)
          .collection('messages')
          .doc(messageId)
          .delete();
    } catch (e) {
      print('Failed to delete message: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete message: $e')),
      );
    }
  }

  void _clearChat() async {
    try {
      final chatId = _getChatId();

      // Fetch all messages in the chat
      final messages = await _firestore
          .collection('chats')
          .doc(chatId)
          .collection('messages')
          .get();

      for (var doc in messages.docs) {
        // Mark messages as deleted for the current user
        await doc.reference.update({
          '${_currentUser!.uid}_deleted': true,
        });
      }

      // Check if all messages are marked as deleted
      final updatedMessages = await _firestore
          .collection('chats')
          .doc(chatId)
          .collection('messages')
          .where('${_currentUser!.uid}_deleted', isEqualTo: false)
          .get();

      if (updatedMessages.docs.isEmpty) {
        // No visible messages, reset the last message field
        await _firestore.collection('chats').doc(chatId).update({
          'lastMessage': '',
          'lastMessageTimestamp': null,
        });
      }
    } catch (e) {
      print('Failed to clear chat: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to clear chat: $e')),
      );
    }
  }

  bool isSameDate(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  String formatDate(DateTime date) {
    final DateTime now = DateTime.now();
    if (isSameDate(date, now)) {
      return "Today";
    } else if (isSameDate(date, now.subtract(Duration(days: 1)))) {
      return "Yesterday";
    } else {
      return DateFormat('MMM d, yyyy').format(date);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 126, 126, 126),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 27, 27, 27),
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back,
              color: Color.fromARGB(255, 255, 255, 255)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            CircleAvatar(
              backgroundImage: NetworkImage(widget.receiverProfileImage),
              radius: 16,
            ),
            SizedBox(width: 10),
            Text(
              widget.receiverName,
              style: const TextStyle(
                  color: Color.fromARGB(255, 255, 255, 255),
                  fontWeight: FontWeight.bold),
            ),
          ],
        ),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == "Clear Chat") {
                _clearChat();
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: "Clear Chat",
                child: Text("Clear Chat"),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestore
                  .collection('chats')
                  .doc(_getChatId())
                  .collection('messages')
                  .orderBy('timestamp', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Center(child: CircularProgressIndicator());
                }

                final messages = snapshot.data!.docs.where((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  return !(data['${_currentUser!.uid}_deleted'] ?? false);
                }).toList();

                return ListView.builder(
                  reverse: true,
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final messageData = messages[index];
                    final bool isMe =
                        messageData['senderId'] == _currentUser?.uid;

                    final Timestamp timestamp = messageData['timestamp'];
                    final DateTime dateTime = timestamp.toDate();
                    final bool showDate = (index == 0) ||
                        !isSameDate(messages[index - 1]['timestamp'].toDate(),
                            dateTime);

                    return GestureDetector(
                      onLongPress: isMe
                          ? () => _confirmDeleteMessage(messageData.id)
                          : null,
                      child: Column(
                        crossAxisAlignment: isMe
                            ? CrossAxisAlignment.end
                            : CrossAxisAlignment.start,
                        children: [
                          if (showDate)
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 8.0),
                              child: Center(
                                child: Text(
                                  formatDate(dateTime),
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Color.fromARGB(255, 198, 198, 198),
                                  ),
                                ),
                              ),
                            ),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: isMe
                                ? MainAxisAlignment.end
                                : MainAxisAlignment.start,
                            children: [
                              if (!isMe)
                                CircleAvatar(
                                  backgroundImage:
                                      NetworkImage(widget.receiverProfileImage),
                                  radius: 16,
                                ),
                              if (!isMe) const SizedBox(width: 10),
                              Flexible(
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 14, vertical: 10),
                                  margin:
                                      const EdgeInsets.symmetric(vertical: 5),
                                  decoration: BoxDecoration(
                                    color: isMe
                                        ? Colors.blue[100]
                                        : Colors.grey[200],
                                    borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(15),
                                      topRight: Radius.circular(15),
                                      bottomLeft: isMe
                                          ? Radius.circular(15)
                                          : Radius.zero,
                                      bottomRight: isMe
                                          ? Radius.zero
                                          : Radius.circular(15),
                                    ),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        messageData['message'],
                                        style: const TextStyle(fontSize: 14),
                                      ),
                                      const SizedBox(height: 5),
                                      Text(
                                        DateFormat('h:mm a').format(dateTime),
                                        style: const TextStyle(
                                          fontSize: 10,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: "Type your message",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    ),
                  ),
                ),
                SizedBox(width: 10),
                CircleAvatar(
                  radius: 24,
                  child: IconButton(
                    icon: Icon(Icons.send),
                    onPressed: _sendMessage,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
