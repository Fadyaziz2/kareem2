import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants.dart';
import '../../core/theme.dart';
import '../../providers/auth_provider.dart';
import 'home_tab.dart';
import '../contracts/contracts_tab.dart';
import '../escrow/escrow_tab.dart';
import '../lawyers/lawyers_tab.dart';
import '../lawyers/lawyer_dashboard_tab.dart';
import '../wallet/wallet_tab.dart';

class MainWrapperScreen extends StatefulWidget {
  const MainWrapperScreen({super.key});

  @override
  State<MainWrapperScreen> createState() => _MainWrapperScreenState();
}

class _MainWrapperScreenState extends State<MainWrapperScreen> {
  int _currentIndex = 0;

  void _onTabSelected(int index) {
    setState(() => _currentIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final isLawyer = auth.isLawyer;

    final List<Widget> screens = [];
    final List<BottomNavigationBarItem> navItems = [];

    // 0: الرئيسية (Home)
    screens.add(HomeTab(onNavigateTab: _onTabSelected));
    navItems.add(const BottomNavigationBarItem(
      icon: Icon(Icons.home_outlined),
      activeIcon: Icon(Icons.home),
      label: 'الرئيسية',
    ));

    // لوحة المحامي (Lawyer Dashboard)
    if (isLawyer) {
      screens.add(const LawyerDashboardTab());
      navItems.add(const BottomNavigationBarItem(
        icon: Icon(Icons.dashboard_outlined),
        activeIcon: Icon(Icons.dashboard),
        label: 'لوحة المحامي',
      ));
    }

    // العقود (Contracts)
    screens.add(const ContractsTab());
    navItems.add(const BottomNavigationBarItem(
      icon: Icon(Icons.description_outlined),
      activeIcon: Icon(Icons.description),
      label: 'العقود',
    ));

    // الوساطة (Escrow - مخفية مؤقتاً)
    if (AppConstants.enableEscrow) {
      screens.add(const EscrowTab());
      navItems.add(const BottomNavigationBarItem(
        icon: Icon(Icons.security_outlined),
        activeIcon: Icon(Icons.security),
        label: 'الوساطة',
      ));
    }

    // المحامين (Lawyers - للعملاء فقط)
    if (!isLawyer) {
      screens.add(const LawyersTab());
      navItems.add(const BottomNavigationBarItem(
        icon: Icon(Icons.person_search_outlined),
        activeIcon: Icon(Icons.person_search),
        label: 'المحامين',
      ));
    }

    // المحفظة (Wallet - مخفية مؤقتاً)
    if (AppConstants.enableWallet) {
      screens.add(const WalletTab());
      navItems.add(const BottomNavigationBarItem(
        icon: Icon(Icons.account_balance_wallet_outlined),
        activeIcon: Icon(Icons.account_balance_wallet),
        label: 'المحفظة',
      ));
    }

    final safeIndex = _currentIndex < screens.length ? _currentIndex : 0;

    return Scaffold(
      body: IndexedStack(
        index: safeIndex,
        children: screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: safeIndex,
        onTap: _onTabSelected,
        type: BottomNavigationBarType.fixed,
        backgroundColor: OqoodyTheme.primaryDark,
        selectedItemColor: OqoodyTheme.accentGold,
        unselectedItemColor: OqoodyTheme.textMuted,
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11),
        unselectedLabelStyle: const TextStyle(fontSize: 10),
        items: navItems,
      ),
    );
  }
}
