import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flink/constants/constant_colors.dart';

import 'package:flutter/material.dart';

// ignore: must_be_immutable
class TimeAgoWidget extends StatelessWidget {
  final Timestamp postTime;
  final Color textColor;
  ConstantColors constantColors = ConstantColors();

  TimeAgoWidget({required this.postTime, required this.textColor});

  String _calculateTimeDifference() {
    final DateTime postDateTime = postTime.toDate();
    final Duration difference = DateTime.now().difference(postDateTime);

    if (difference.inDays > 0) {
      return '${difference.inDays} days ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hours ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minutes ago';
    } else {
      return 'just now';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      _calculateTimeDifference(),
      style: TextStyle(
        color: textColor.withOpacity(0.8),
        fontSize: 12.0,
      ),
    );
  }

  Widget _interactionIcon(
      {required IconData icon, required Color color, required String count}) {
    return Container(
      width: 80.0,
      child: Row(
        children: [
          GestureDetector(
            child: Icon(icon, color: color, size: 22.0),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 8.0),
            child: Text(
              count,
              style: TextStyle(
                color: constantColors.whiteColor,
                fontWeight: FontWeight.bold,
                fontSize: 18.0,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
