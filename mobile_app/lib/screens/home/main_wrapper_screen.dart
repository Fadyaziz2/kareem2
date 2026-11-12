import 'package:flutter/material.dart';
import '../../core/theme.dart';
import 'home_tab.dart';
import '../contracts/contracts_tab.dart';
import '../escrow/escrow_tab.dart';
import '../lawyers/lawyers_tab.dart';
import '../wallet/wallet_tab.dart';

class MainWrapperScreen extends StatefulWidget {
  const MainWrapperScreen({super.key});

  @override
  State<MainWrapperScreen> createState() => _MainWrapperScreenState();
}

class _MainWrapperScreenState extends State<MainWrapperScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    HomeTab(),
    ContractsTab(),
    EscrowTab(),
    LawyersTab(),
    WalletTab(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        type: BottomNavigationBarType.fixed,
        backgroundColor: OqoodyTheme.primaryDark,
        selectedItemColor: OqoodyTheme.accentGold,
        unselectedItemColor: OqoodyTheme.textMuted,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_outlined), activeIcon: Icon(Icons.home), label: 'الرئيسية'),
          BottomNavigationBarItem(icon: Icon(Icons.description_outlined), activeIcon: Icon(Icons.description), label: 'العقود'),
          BottomNavigationBarItem(icon: Icon(Icons.security_outlined), activeIcon: Icon(Icons.security), label: 'الوساطة'),
          BottomNavigationBarItem(icon: Icon(Icons.person_search_outlined), activeIcon: Icon(Icons.person_search), label: 'المحامين'),
          BottomNavigationBarItem(icon: Icon(Icons.account_balance_wallet_outlined), activeIcon: Icon(Icons.account_balance_wallet), label: 'المحفظة'),
        ],
      ),
    );
  }
}
