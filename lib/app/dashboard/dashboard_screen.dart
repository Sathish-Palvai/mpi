import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'bloc/dashboard_bloc.dart';
import 'bloc/dashboard_event.dart';
import 'bloc/dashboard_state.dart';
import 'widgets/participant_tab.dart';
import 'widgets/resource_tab.dart';
import 'widgets/user_tab.dart';
import '../shared/widgets/app_drawer.dart';
import '../../widgets/notification_icon.dart';
import '../../features/auth/bloc/auth_bloc.dart';
import '../../features/auth/bloc/auth_state.dart';
import '../../core/user_type.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> with TickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    
    // Get userType from auth state and dispatch LoadDashboardData
    final authState = context.read<AuthBloc>().state;
    final userType = authState is AuthAuthenticated ? authState.userType : UserType.BSP;
    context.read<DashboardBloc>().add(LoadDashboardData(userType: userType));
    
    _searchController.addListener(() {
      context.read<DashboardBloc>().add(SearchChanged(query: _searchController.text));
    });
    // Listen to tab changes to update add button visibility
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        setState(() {}); // Trigger rebuild when tab changes
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _showAddDialog() {
    final currentTabIndex = _tabController.index;
    switch (currentTabIndex) {
      case 0: // Participants tab
        context.go('/dashboard/add-participant');
        break;
      case 1: // Users tab
        _showComingSoonDialog('Add New User');
        break;
      case 2: // Resources tab
        _showComingSoonDialog('Add New Resource');
        break;
    }
  }

  void _showComingSoonDialog(String feature) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(feature),
          content: Text('$feature functionality is coming soon!'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const AppDrawer(),
      appBar: AppBar(
        title: const Text('Dashboard'),
        elevation: 0,
        automaticallyImplyLeading: true,
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () => Scaffold.of(context).openDrawer(),
            tooltip: 'Menu',
          ),
        ),
        actions: [
          // IconButton(
          //   icon: const Icon(Icons.home),
          //   onPressed: () => context.go('/'),
          //   tooltip: 'Home',
          // ),
          // const SizedBox(width: 8),
          BlocBuilder<AuthBloc, AuthState>(
            builder: (context, authState) {
              final userType = authState is AuthAuthenticated 
                ? authState.userType 
                : UserType.BSP;
              
              // Refresh button logic:
              // - Participants tab: only for MO and TSO users
              // - Users and Resources tabs: for all users
              final isParticipantsTab = _tabController.index == 0;
              final isMOOrTSO = userType == UserType.MO || userType == UserType.TSO;
              final showRefreshButton = isParticipantsTab 
                ? isMOOrTSO  // Participants tab: MO/TSO only
                : true;       // Users/Resources tabs: all users
              
              if (!showRefreshButton) {
                return const SizedBox.shrink();
              }
              
              // Check if data is currently loading
              return BlocBuilder<DashboardBloc, DashboardState>(
                builder: (context, dashboardState) {
                  final isLoading = dashboardState is DashboardLoading;
                  
                  return IconButton(
                    icon: isLoading
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Icon(Icons.refresh),
                    onPressed: isLoading ? null : () {
                      context.read<DashboardBloc>().add(
                        RefreshDashboardData(userType: userType),
                      );
                    },
                    tooltip: isLoading ? 'Refreshing...' : 'Refresh Data',
                  );
                },
              );
            },
          ),
          const NotificationIcon(),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(125),
          child: SafeArea(
            child: BlocBuilder<AuthBloc, AuthState>(
              builder: (context, authState) {
                // Check if user is BSP and on participants tab
                final isBSP = authState is AuthAuthenticated && authState.userType == UserType.BSP;
                final isParticipantsTab = _tabController.index == 0;
                final shouldHideSearchBar = isBSP && isParticipantsTab;
                
                return Column(
                  children: [
                    const SizedBox(height: 5), // Added vertical space
                    // Search Bar with integrated Add button (hidden for BSP on participants tab)
                    if (!shouldHideSearchBar)
                      Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(25.0),
                  ),
                  child: Row(
                    children: [
                      // Search icon
                      Padding(
                        padding: const EdgeInsets.only(left: 16),
                        child: Icon(Icons.search, color: Colors.white.withOpacity(0.8), size: 22),
                      ),
                      // Search text field
                      Expanded(
                        child: TextField(
                          controller: _searchController,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                          decoration: InputDecoration(
                            hintText: 'Search across all data...',
                            hintStyle: TextStyle(
                              color: Colors.white.withOpacity(0.6),
                              fontSize: 16,
                            ),
                            border: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            focusedBorder: InputBorder.none,
                            filled: false,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          ),
                        ),
                      ),
                      // Clear button
                      if (_searchController.text.isNotEmpty)
                        IconButton(
                          icon: Icon(Icons.clear, color: Colors.white.withOpacity(0.8)),
                          onPressed: () {
                            _searchController.clear();
                          },
                        ),
                      // Divider and Add button - conditionally shown based on user type and tab
                      BlocBuilder<AuthBloc, AuthState>(
                        builder: (context, authState) {
                          // Check if user is BSP and on participants tab
                          final isBSP = authState is AuthAuthenticated && authState.userType == UserType.BSP;
                          final isParticipantsTab = _tabController.index == 0;
                          final shouldHideAddButton = isBSP && isParticipantsTab;
                          
                          if (shouldHideAddButton) {
                            return const SizedBox.shrink(); // Hide the button
                          }
                          
                          return Row(
                            children: [
                              // Divider
                              Container(
                                height: 30,
                                width: 1,
                                color: Colors.white.withOpacity(0.4),
                                margin: const EdgeInsets.symmetric(horizontal: 8),
                              ),
                              // Add button integrated into search bar
                              Padding(
                                padding: const EdgeInsets.only(right: 4),
                                child: IconButton(
                                  onPressed: () => _showAddDialog(),
                                  icon: const Icon(Icons.add_circle, size: 32),
                                  color: Colors.white,
                                  tooltip: 'Add New',
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ],
                  ),
                ),
                    // Tab Bar
                    TabBar(
                      controller: _tabController,
                      indicatorColor: Colors.white,
                      labelColor: Colors.white,
                      unselectedLabelColor: Colors.white.withOpacity(0.7),
                      tabs: const [
                        Tab(text: 'Participants', icon: Icon(Icons.business)),
                        Tab(text: 'Users', icon: Icon(Icons.people)),
                        Tab(text: 'Resources', icon: Icon(Icons.power)),
                      ],
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
      body: BlocListener<DashboardBloc, DashboardState>(
        listener: (context, state) {
          // Show snackbar when refresh completes successfully
          if (state is DashboardLoaded) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('Data refreshed successfully'),
                duration: const Duration(seconds: 2),
                behavior: SnackBarBehavior.floating,
                backgroundColor: Colors.green,
              ),
            );
          }
          // Show error snackbar if refresh fails
          if (state is DashboardError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Refresh failed: ${state.message}'),
                duration: const Duration(seconds: 3),
                behavior: SnackBarBehavior.floating,
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        child: BlocBuilder<DashboardBloc, DashboardState>(
          builder: (context, state) {
            if (state is DashboardLoading) {
              return const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text('Loading dashboard data...'),
                  ],
                ),
              );
            }
            if (state is DashboardLoaded) {
              // Get userType from auth state
              final authState = context.read<AuthBloc>().state;
              final userType = authState is AuthAuthenticated ? authState.userType : null;
              
              return TabBarView(
                controller: _tabController,
                children: [
                  ParticipantTab(
                    participants: state.filteredParticipants,
                    userType: userType,
                  ),
                  UserTab(users: state.filteredUsers),
                  ResourceTab(resources: state.filteredResources),
                ],
              );
            }
            if (state is DashboardError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 64,
                      color: Theme.of(context).colorScheme.error,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Error loading dashboard',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      state.message,
                      style: Theme.of(context).textTheme.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: () {
                        final authState = context.read<AuthBloc>().state;
                        final userType = authState is AuthAuthenticated ? authState.userType : UserType.BSP;
                        context.read<DashboardBloc>().add(LoadDashboardData(userType: userType));
                      },
                      icon: const Icon(Icons.refresh),
                      label: const Text('Retry'),
                    ),
                  ],
                ),
              );
            }
            return const Center(child: Text('Something went wrong.'));
          },
        ),
      ),
    );
  }
}
