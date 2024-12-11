import 'package:flutter/material.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Privacy Policy', style: TextStyle(fontSize: 20)),
        centerTitle: true,
        backgroundColor: Colors.black,
      ),
      backgroundColor: Colors.black,
      body: const Padding(
        padding: EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Privacy Policy',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 16),
              Text(
                'At Flink, your privacy is of utmost importance to us. This policy explains how we collect, use, and protect your personal information.',
                style: TextStyle(fontSize: 16, color: Colors.white70),
              ),
              SizedBox(height: 16),
              Text(
                '1. Information Collection',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
              ),
              SizedBox(height: 8),
              Text(
                'We may collect personal information like your name, email address, and interactions within the app.',
                style: TextStyle(fontSize: 16, color: Colors.white70),
              ),
              SizedBox(height: 16),
              Text(
                '2. Use of Information',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
              ),
              SizedBox(height: 8),
              Text(
                'Your data is used to improve your experience, personalize content, and provide customer support.',
                style: TextStyle(fontSize: 16, color: Colors.white70),
              ),
              SizedBox(height: 16),
              Text(
                '3. Data Security',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
              ),
              SizedBox(height: 8),
              Text(
                'We use advanced security measures to protect your data and ensure it remains confidential.',
                style: TextStyle(fontSize: 16, color: Colors.white70),
              ),
              SizedBox(height: 24),
              Text(
                'For more details, contact us at support@flinkapp.com.',
                style: TextStyle(
                    fontSize: 16,
                    fontStyle: FontStyle.italic,
                    color: Colors.white70),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
