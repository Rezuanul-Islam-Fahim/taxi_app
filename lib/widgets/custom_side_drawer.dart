import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../screens/login_signup_screen.dart';

class CustomSideDrawer extends StatelessWidget {
  const CustomSideDrawer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // final UserProvider userProvider = Provider.of<UserProvider>(
    //   context,
    //   listen: false,
    // );
    // final user.User? loggedUser = userProvider.loggedUser;

    return Drawer(
      child: Column(
        children: [
          // loggedUser != null
          //     ?
          UserAccountsDrawerHeader(
            currentAccountPicture: Container(
              decoration: BoxDecoration(
                color: Colors.grey[50],
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.person,
                size: 50,
                color: Colors.black45,
              ),
            ),
            accountName: Text('Fahim'),
            accountEmail: Text('rifahim98@gmail.com'),
          ),
          // : Container(
          //     height: 200,
          //     color: Theme.of(context).primaryColor,
          //     child: const Center(
          //       child: CircularProgressIndicator(
          //         color: Colors.white,
          //       ),
          //     ),
          //   ),
          const SizedBox(height: 10),
          _buildButtonTile(
            context: context,
            title: 'Trips',
            icon: Icons.navigation_rounded,
            onTap: () {},
          ),
          _buildButtonTile(
            context: context,
            title: 'Logout',
            icon: Icons.exit_to_app,
            onTap: () {
              // userProvider.clearUser();
              // Navigator.of(context).pushReplacementNamed(
              //   LoginSignupScreen.route,
              // );
              // FirebaseAuth.instance.signOut();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildButtonTile({
    BuildContext? context,
    String? title,
    IconData? icon,
    Function()? onTap,
  }) {
    return ListTile(
      title: Text(title!),
      leading: Icon(icon),
      onTap: () {
        Navigator.pop(context!);
        onTap!();
      },
    );
  }
}
