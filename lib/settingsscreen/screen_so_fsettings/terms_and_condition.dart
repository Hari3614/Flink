import 'package:flutter/material.dart';

class TermsConditionsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Terms & Conditions', style: TextStyle(fontSize: 20)),
        centerTitle: true,
        backgroundColor: Colors.black,
      ),
      backgroundColor: Colors.black,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Terms and Conditions',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 16),
              Text(
                'Welcome to Flink. By using our app, you agree to the following terms and conditions.',
                style: TextStyle(fontSize: 16, color: Colors.white70),
              ),
              SizedBox(height: 16),
              Text(
                '1. User Conduct',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
              ),
              SizedBox(height: 8),
              Text(
                'You agree to use the app responsibly and not engage in harmful or illegal activities.',
                style: TextStyle(fontSize: 16, color: Colors.white70),
              ),
              SizedBox(height: 16),
              Text(
                '2. Account Security',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
              ),
              SizedBox(height: 8),
              Text(
                'You are responsible for maintaining the confidentiality of your account credentials.',
                style: TextStyle(fontSize: 16, color: Colors.white70),
              ),
              SizedBox(height: 16),
              Text(
                '3. Content Ownership',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
              ),
              SizedBox(height: 8),
              Text(
                'All content you upload must comply with copyright laws and our community guidelines.',
                style: TextStyle(fontSize: 16, color: Colors.white70),
              ),
              SizedBox(height: 24),
              Text(
                'For complete terms, visit our website at www.flinkapp.com/terms.',
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
