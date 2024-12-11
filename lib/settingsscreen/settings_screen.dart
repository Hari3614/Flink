import 'package:flink/settingsscreen/screen_so_fsettings/about_screen.dart';
import 'package:flink/settingsscreen/screen_so_fsettings/edit_account.dart';
import 'package:flink/settingsscreen/screen_so_fsettings/privacy_policy.dart';
import 'package:flink/settingsscreen/screen_so_fsettings/terms_and_condition.dart';
import 'package:flutter/material.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          'Settings',
          style: TextStyle(
              fontWeight: FontWeight.bold, fontSize: 20.0, color: Colors.white),
        ),
        backgroundColor: Colors.grey[900],
      ),
      backgroundColor: Colors.black,
      body: ListView(
        padding: const EdgeInsets.all(8.0),
        children: [
          // Account Section
          ListTile(
            leading: const Icon(Icons.account_circle, color: Colors.white),
            title: const Text('Edit Account',
                style: TextStyle(color: Colors.white)),
            trailing: const Icon(Icons.arrow_forward_ios, color: Colors.white),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EditProfileScreen(),
                ),
              );
            },
          ),
          const Divider(color: Colors.grey),

          // Privacy and Policy Section
          ListTile(
            leading: const Icon(Icons.privacy_tip, color: Colors.white),
            title: const Text('Privacy Policy',
                style: TextStyle(color: Colors.white)),
            trailing: const Icon(Icons.arrow_forward_ios, color: Colors.white),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PrivacyPolicyScreen(),
                ),
              );
            },
          ),
          const Divider(color: Colors.grey),

          // Terms and Conditions Section
          ListTile(
            leading: const Icon(Icons.description, color: Colors.white),
            title: const Text('Terms and Conditions',
                style: TextStyle(color: Colors.white)),
            trailing: const Icon(Icons.arrow_forward_ios, color: Colors.white),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => TermsConditionsScreen(),
                ),
              );
            },
          ),
          const Divider(color: Colors.grey),

          // About Section
          ListTile(
            leading: const Icon(Icons.info, color: Colors.white),
            title: const Text('About', style: TextStyle(color: Colors.white)),
            trailing: const Icon(Icons.arrow_forward_ios, color: Colors.white),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AboutScreen(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
