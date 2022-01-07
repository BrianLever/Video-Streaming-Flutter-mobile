
import 'package:americonictv_mobile/data/auth/user_data.dart';
import 'package:americonictv_mobile/ui/screens/categories/categories_screen.dart';
import 'package:americonictv_mobile/ui/screens/chat/chats_screen.dart';
import 'package:americonictv_mobile/ui/screens/home/home_screen.dart';
import 'package:americonictv_mobile/ui/screens/livestreams/livestreams_screen.dart';
import 'package:americonictv_mobile/ui/screens/saved_videos/saved_videos_screen.dart';
import 'package:americonictv_mobile/ui/screens/trending/trending_screen.dart';

import 'nav_bar_entry.dart';
import 'package:flutter/material.dart';

class CustomNavBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor,
        border: Border(top: BorderSide(width: 0.2, color: Colors.black26)),
      ),
      child: SizedBox(
        width: MediaQuery.of(context).size.width,
        height: kBottomNavigationBarHeight,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            NavBarEntry(
              label: 'CATEGORIES',
              icon: Icons.category,
              screen: CategoriesScreen(),
            ),
            NavBarEntry(
              label: 'LATEST',
              icon: Icons.home,
              screen: HomeScreen(),
            ),
            NavBarEntry(
              label: 'TRENDING',
              icon: Icons.grade,
              screen: TrendingScreen(),
            ),
            NavBarEntry(
              label: 'LIVE',
              icon: Icons.online_prediction,
              screen: LivestreamsScreen(),
            ),
            if (User.loggedIn)
              NavBarEntry(
                label: 'SAVED',
                icon: Icons.bookmark,
                screen: SavedVideoScreen(),
              ),
            // Uncomment 1 == 2 in order to display the chat icon
            if (User.loggedIn && 1 == 2)
              NavBarEntry(
                label: 'CHAT',
                icon: Icons.chat,
                screen: ChatsScreen(),
              ),
          ],
        ),
      ),
    );
  }
}
