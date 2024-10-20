import 'package:flink/constants/constant_colors.dart';
import 'package:flink/views/feedscreen/feed_helpers.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// ignore: must_be_immutable
class FeedScreen extends StatelessWidget {
  FeedScreen({super.key});

  ConstantColors constantColors = ConstantColors();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 167, 167, 167),
      drawer: Drawer(),
      appBar: Provider.of<FeedHelpers>(context, listen: false).appBar(context),
      body: Provider.of<FeedHelpers>(context, listen: false).FeedBody(context),
    );
  }
}
