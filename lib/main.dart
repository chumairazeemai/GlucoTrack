import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app_state.dart';
import 'models.dart';
import 'screens/dashboard_screen.dart';
import 'screens/history_screen.dart';
import 'screens/profile_screen.dart';
import 'widgets/add_reading_sheet.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
  ));
  runApp(const GlucoTrackApp());
}

class GlucoTrackApp extends StatefulWidget {
  const GlucoTrackApp({super.key});

  @override
  State<GlucoTrackApp> createState() => _GlucoTrackAppState();
}

class _GlucoTrackAppState extends State<GlucoTrackApp> {
  final AppState _state = AppState();

  @override
  void initState() {
    super.initState();
    _state.load();
  }

  @override
  void dispose() {
    _state.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GlucoTrack',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: AppColors.sky600),
        scaffoldBackgroundColor: AppColors.slate50,
      ),
      home: ListenableBuilder(
        listenable: _state,
        builder: (context, _) {
          if (!_state.loaded) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }
          return HomeShell(state: _state);
        },
      ),
    );
  }
}

class HomeShell extends StatefulWidget {
  final AppState state;
  const HomeShell({super.key, required this.state});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _tab = 0; // 0 overview, 1 history, 2 profile

  @override
  Widget build(BuildContext context) {
    final state = widget.state;
    final pages = <Widget>[
      DashboardScreen(state: state, onSeeAll: () => setState(() => _tab = 1)),
      HistoryScreen(state: state),
      ProfileScreen(state: state),
    ];

    return PopScope(
      canPop: _tab == 0,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) setState(() => _tab = 0);
      },
      child: Scaffold(
        body: Column(
          children: [
            _Header(state: state, onProfileTap: () => setState(() => _tab = 2)),
            Expanded(child: IndexedStack(index: _tab, children: pages)),
          ],
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        floatingActionButton: FloatingActionButton(
          onPressed: () => showAddReadingSheet(context, state),
          backgroundColor: AppColors.sky600,
          foregroundColor: Colors.white,
          shape: const CircleBorder(),
          tooltip: 'Add Sugar Reading',
          child: const Icon(Icons.add, size: 30),
        ),
        bottomNavigationBar: BottomAppBar(
          color: Colors.white,
          surfaceTintColor: Colors.transparent,
          shape: const CircularNotchedRectangle(),
          notchMargin: 8,
          padding: EdgeInsets.zero,
          child: Row(
            children: [
              Expanded(
                  child: _NavItem(
                      icon: Icons.home_filled,
                      label: 'Overview',
                      selected: _tab == 0,
                      onTap: () => setState(() => _tab = 0))),
              Expanded(
                  child: _NavItem(
                      icon: Icons.history,
                      label: 'History',
                      selected: _tab == 1,
                      onTap: () => setState(() => _tab = 1))),
              const SizedBox(width: 72), // space for the docked FAB
              Expanded(
                  child: _NavItem(
                      icon: Icons.manage_accounts,
                      label: 'Profile',
                      selected: _tab == 2,
                      onTap: () => setState(() => _tab = 2))),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _NavItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = selected ? AppColors.sky600 : AppColors.slate400;
    return InkWell(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 2),
          Text(label,
              style: TextStyle(
                  color: color, fontSize: 11.5, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final AppState state;
  final VoidCallback onProfileTap;
  const _Header({required this.state, required this.onProfileTap});

  @override
  Widget build(BuildContext context) {
    final p = state.profile;
    return Container(
      padding: EdgeInsets.fromLTRB(
          20, MediaQuery.of(context).padding.top + 12, 20, 18),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.sky600, AppColors.blue700],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha(51),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(Icons.water_drop, color: Colors.white),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('GlucoTrack',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w800)),
                    Text('Welcome back, ${p.name}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            color: Color(0xFFE0F2FE),
                            fontSize: 11,
                            fontWeight: FontWeight.w500)),
                  ],
                ),
              ),
              _UnitToggle(state: state),
            ],
          ),
          const SizedBox(height: 12),
          InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: onProfileTap,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
              decoration: BoxDecoration(
                color: Colors.white.withAlpha(26),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white.withAlpha(38)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Wrap(
                      spacing: 10,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        _pill('${p.age} yrs'),
                        const Text('•',
                            style: TextStyle(color: Color(0xFFE0F2FE))),
                        _pill('${formatWeight(p.weight)} kg'),
                        const Text('•',
                            style: TextStyle(color: Color(0xFFE0F2FE))),
                        Text.rich(TextSpan(
                          style: const TextStyle(
                              color: Color(0xFFF0F9FF), fontSize: 12),
                          children: [
                            const TextSpan(text: 'BMI: '),
                            TextSpan(
                              text: '${p.bmi}',
                              style: const TextStyle(
                                  color: Color(0xFFFCD34D),
                                  fontWeight: FontWeight.w800),
                            ),
                          ],
                        )),
                      ],
                    ),
                  ),
                  const Text('Edit ',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 11.5,
                          fontWeight: FontWeight.w700)),
                  const Icon(Icons.chevron_right,
                      size: 16, color: Colors.white),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _pill(String t) => Text(t,
      style: const TextStyle(
          color: Color(0xFFF0F9FF), fontSize: 12, fontWeight: FontWeight.w700));
}

class _UnitToggle extends StatelessWidget {
  final AppState state;
  const _UnitToggle({required this.state});

  Widget _btn(String unit, String label) {
    final active = state.displayUnit == unit;
    return GestureDetector(
      onTap: () => state.setUnit(unit),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
        decoration: BoxDecoration(
          color: active ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(9),
        ),
        child: Text(label,
            style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: active ? const Color(0xFF0369A1) : const Color(0xFFE0F2FE))),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: const Color(0xFF0C4A6E).withAlpha(128),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withAlpha(38)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [_btn('mg', 'mg/dL'), _btn('mmol', 'mmol/L')],
      ),
    );
  }
}
