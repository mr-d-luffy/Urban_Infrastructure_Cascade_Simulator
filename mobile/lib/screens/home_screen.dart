import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/app_theme.dart';
import '../providers/simulation_controller.dart';
import '../widgets/cinematic/cinematic_nav_bar.dart';
import '../widgets/common/cinematic_bottom_nav.dart';
import '../widgets/common/floating_simulation_bar.dart';
import 'pages/analytics_page.dart';
import 'pages/intro_page.dart';
import 'pages/network_graph_page.dart';
import 'pages/simulate_page.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _currentIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<SimulationController>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppTheme.darkBackground : AppTheme.lightBackground,
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            // Top Navigation Bar
            CinematicNavBar(
              onEnterSimulator: () => _onTabTapped(1),
            ),

            // PageView for swipeable and tabbed page experience
            Expanded(
              child: RefreshIndicator(
                onRefresh: () async {
                  await controller.checkBackendHealth();
                  await controller.fetchBackendGraphData();
                  await controller.fetchScenarios();
                },
                child: PageView(
                  controller: _pageController,
                  onPageChanged: (index) {
                    setState(() {
                      _currentIndex = index;
                    });
                  },
                  children: [
                    // Tab 0: Intro / Story / Cinematic Hero
                    IntroPage(
                      onEnterNetwork: () => _onTabTapped(1),
                      onLaunchDemo: () => _onTabTapped(1),
                    ),

                    // Tab 1: Immersive Topology Network Graph Canvas
                    NetworkGraphPage(
                      onNavigateToSimulate: () => _onTabTapped(2),
                    ),

                    // Tab 2: Simulation Controls, Disruptions & Recovery
                    const SimulatePage(),

                    // Tab 3: Analytics Metrics & Event Stream Timeline
                    const AnalyticsPage(),
                  ],
                ),
              ),
            ),

            // Global Floating Simulation Bar (shown when simulation is active)
            FloatingSimulationBar(
              onNavigateToSimulation: () => _onTabTapped(2),
            ),

            // Bottom Navigation Tabs
            CinematicBottomNav(
              currentIndex: _currentIndex,
              onTap: _onTabTapped,
            ),
          ],
        ),
      ),
    );
  }
}
