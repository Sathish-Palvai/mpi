import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../features/auth/bloc/auth_bloc.dart';
import '../../../features/auth/bloc/auth_event.dart';
import '../../../features/auth/bloc/auth_state.dart';
import '../../../l10n/app_localizations.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is AuthAuthenticated) {
          return Drawer(
            child: Column(
              children: [
                _buildDrawerHeader(context, state, l10n),
                Expanded(
                  child: _buildNavigationMenu(context, l10n),
                ),
                _buildLogoutSection(context, l10n),
              ],
            ),
          );
        }
        return const Drawer(
          child: Center(
            child: CircularProgressIndicator(),
          ),
        );
      },
    );
  }

  Widget _buildDrawerHeader(BuildContext context, AuthAuthenticated state, AppLocalizations l10n) {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            state.userType.color,
            state.userType.color.withOpacity(0.8),
          ],
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 35,
                    backgroundColor: Colors.white.withOpacity(0.3),
                    child: CircleAvatar(
                      radius: 32,
                      backgroundColor: state.userType.color,
                      child: Text(
                        state.username.substring(0, 1).toUpperCase(),
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          state.username,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            state.userType.getLocalizedName(context),
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                '${state.username}@company.com',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white.withOpacity(0.9),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavigationMenu(BuildContext context, AppLocalizations l10n) {
    final menuItems = [
      _DrawerMenuItem(
        icon: Icons.home,
        title: l10n.home,
        route: '/',
      ),
      _DrawerMenuItem(
        icon: Icons.person_add,
        title: l10n.registration,
        route: '/dashboard',
      ),
      _DrawerMenuItem(
        icon: Icons.developer_board,
        title: l10n.interface,
        route: '/interface',
      ),
      _DrawerMenuItem(
        icon: Icons.swap_horiz,
        title: l10n.switching,
        route: '/switching',
      ),
      _DrawerMenuItem(
        icon: Icons.analytics,
        title: l10n.reports,
        route: '/reports',
      ),
      _DrawerMenuItem(
        icon: Icons.settings,
        title: l10n.settings,
        route: '/settings',
      ),
    ];

    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 8),
      children: menuItems.map((item) => _buildMenuItem(context, item)).toList(),
    );
  }

  Widget _buildMenuItem(BuildContext context, _DrawerMenuItem item) {
    final currentRoute = GoRouterState.of(context).fullPath;
    final isSelected = currentRoute == item.route;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: isSelected
            ? Theme.of(context).colorScheme.primaryContainer
            : Colors.transparent,
      ),
      child: ListTile(
        leading: Icon(
          item.icon,
          color: isSelected
              ? Theme.of(context).colorScheme.primary
              : Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
        ),
        title: Text(
          item.title,
          style: TextStyle(
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            color: isSelected
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).colorScheme.onSurface,
          ),
        ),
        onTap: () {
          Navigator.pop(context);
          if (!isSelected) {
            context.go(item.route);
          }
        },
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  Widget _buildLogoutSection(BuildContext context, AppLocalizations l10n) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
          ),
        ),
      ),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: () => _showLogoutDialog(context, l10n),
          icon: const Icon(Icons.logout),
          label: Text(l10n.logout),
          style: ElevatedButton.styleFrom(
            backgroundColor: isDark 
                ? theme.colorScheme.errorContainer 
                : Colors.red.shade50,
            foregroundColor: isDark 
                ? theme.colorScheme.onErrorContainer 
                : Colors.red.shade700,
            elevation: 0,
            padding: const EdgeInsets.symmetric(vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(
                color: isDark 
                    ? theme.colorScheme.error.withOpacity(0.5) 
                    : Colors.red.shade200,
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context, AppLocalizations l10n) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.confirmLogout),
        content: Text(l10n.areYouSureLogout),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(l10n.cancel),
          ),
          ElevatedButton(
            onPressed: () {
              // Store the navigator context before closing dialogs
              final navigator = Navigator.of(context);
              final router = GoRouter.of(context);
              
              // Close dialog
              Navigator.pop(dialogContext);
              
              // Close drawer and dispatch logout
              navigator.pop();
              context.read<AuthBloc>().add(const AuthLogoutRequested());
              
              // Navigate to login after a brief delay to ensure state update
              Future.delayed(const Duration(milliseconds: 100), () {
                router.go('/login');
              });
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
              foregroundColor: Theme.of(context).colorScheme.onError,
            ),
            child: Text(l10n.logout),
          ),
        ],
      ),
    );
  }
}

class _DrawerMenuItem {
  final IconData icon;
  final String title;
  final String route;

  _DrawerMenuItem({
    required this.icon,
    required this.title,
    required this.route,
  });
}
