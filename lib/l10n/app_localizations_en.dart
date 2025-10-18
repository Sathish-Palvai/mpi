// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Power Management Interface';

  @override
  String get login => 'Login';

  @override
  String get username => 'Username';

  @override
  String get password => 'Password';

  @override
  String get userType => 'User Type';

  @override
  String get userTypeBsp => 'BSP - Balancing Service Provider';

  @override
  String get userTypeTso => 'TSO - Transmission System Operator';

  @override
  String get userTypeMo => 'MO - Market Operator';

  @override
  String get home => 'Home';

  @override
  String get dashboard => 'Dashboard';

  @override
  String get registration => 'Registration';

  @override
  String get interface => 'Interface';

  @override
  String get switching => 'Switching';

  @override
  String get reports => 'Reports';

  @override
  String get settings => 'Settings';

  @override
  String get logout => 'Logout';

  @override
  String get cancel => 'Cancel';

  @override
  String get confirm => 'Confirm';

  @override
  String welcomeMessage(String username) {
    return 'Welcome back, $username!';
  }

  @override
  String get welcomeSubtitle =>
      'Manage your power system operations efficiently';

  @override
  String get quickAccess => 'Quick Access';

  @override
  String get recentActivity => 'Recent Activity';

  @override
  String get welcomeBack => 'Welcome Back';

  @override
  String get signInToAccount => 'Sign in to your account';

  @override
  String get enterUsername => 'Enter your username';

  @override
  String get enterPassword => 'Enter your password';

  @override
  String get signIn => 'Sign In';

  @override
  String get signingIn => 'Signing In...';

  @override
  String get demoCredentials => 'Demo Credentials';

  @override
  String get usernameRequired => 'Please enter your username';

  @override
  String get usernameMinLength => 'Username must be at least 3 characters';

  @override
  String get passwordRequired => 'Please enter your password';

  @override
  String get passwordMinLength => 'Password must be at least 6 characters';

  @override
  String get confirmLogout => 'Confirm Logout';

  @override
  String get logoutConfirmation => 'Are you sure you want to logout?';

  @override
  String get registrationManagement => 'Registration Management';

  @override
  String get registrationSubtitle =>
      'Manage user registrations and participant information';

  @override
  String get systemInterface => 'System Interface';

  @override
  String get interfaceSubtitle =>
      'Monitor and manage system interfaces and connections';

  @override
  String get powerSwitching => 'Power switching';

  @override
  String get switchingSubtitle =>
      'Manage power switching operations and configurations';

  @override
  String get analyticsReports => 'Analytics & Reports';

  @override
  String get reportsSubtitle =>
      'View detailed analytics and generate comprehensive reports';

  @override
  String get settingsSubtitle =>
      'Configure application settings and preferences';

  @override
  String get comingSoon => 'Coming Soon';

  @override
  String get featureInDevelopment =>
      'This feature is under development and will be available soon.';

  @override
  String get userInformation => 'User Information';

  @override
  String get loginTime => 'Login Time';

  @override
  String get notifications => 'Notifications';

  @override
  String get registrationCardSubtitle => 'Manage registrations';

  @override
  String get interfaceCardSubtitle => 'System interfaces';

  @override
  String get switchingCardSubtitle => 'Power switching';

  @override
  String get reportsCardSubtitle => 'Analytics & insights';

  @override
  String get newRegistrationSubmitted => 'New registration submitted';

  @override
  String get switchingOperationCompleted => 'Switching operation completed';

  @override
  String get monthlyReportGenerated => 'Monthly report generated';

  @override
  String get language => 'Language';

  @override
  String get managePowerSystemOperations =>
      'Manage your power system operations efficiently';

  @override
  String get manageRegistrations => 'Manage registrations';

  @override
  String get systemInterfaces => 'System interfaces';

  @override
  String get analyticsInsights => 'Analytics & insights';

  @override
  String get hoursAgo => 'hours ago';

  @override
  String get dayAgo => 'day ago';

  @override
  String get areYouSureLogout => 'Are you sure you want to logout?';

  @override
  String get configureAppSettings =>
      'Configure application settings and preferences';

  @override
  String get theme => 'Theme';

  @override
  String get chooseAppearance => 'Choose your preferred appearance';

  @override
  String get lightTheme => 'Light Theme';

  @override
  String get lightThemeDescription => 'Clean and bright interface';

  @override
  String get darkTheme => 'Dark Theme';

  @override
  String get darkThemeDescription => 'Easy on the eyes in low light';

  @override
  String get systemTheme => 'System Theme';

  @override
  String get systemThemeDescription => 'Follows device settings';

  @override
  String get chooseLanguage => 'Choose your preferred language';

  @override
  String get about => 'About';

  @override
  String get appName => 'App Name';

  @override
  String get version => 'Version';

  @override
  String get developer => 'Developer';

  @override
  String get createAccount => 'Create Account';

  @override
  String get joinOurPlatform =>
      'Join our platform to access market participant services';

  @override
  String get personalInformation => 'Personal Information';

  @override
  String get fullName => 'Full Name';

  @override
  String get enterFullName => 'Enter your full name';

  @override
  String get email => 'Email';

  @override
  String get enterEmail => 'Enter your email address';

  @override
  String get phoneNumber => 'Phone Number';

  @override
  String get enterPhoneNumber => 'Enter your phone number (optional)';

  @override
  String get accountDetails => 'Account Details';

  @override
  String get enterUniqueUsername => 'Enter a unique username';

  @override
  String get enterSecurePassword => 'Enter a secure password';

  @override
  String get confirmPassword => 'Confirm Password';

  @override
  String get reenterPassword => 'Re-enter your password';

  @override
  String get organizationDetails => 'Organization Details';

  @override
  String get selectUserType => 'Select your user type';

  @override
  String get companyOrganization => 'Company/Organization';

  @override
  String get enterCompanyName => 'Enter your company or organization name';

  @override
  String get register => 'Register';

  @override
  String get registering => 'Registering...';

  @override
  String get alreadyHaveAccount => 'Already have an account?';

  @override
  String get fullNameRequired => 'Please enter your full name';

  @override
  String get emailRequired => 'Please enter your email address';

  @override
  String get emailInvalid => 'Please enter a valid email address';

  @override
  String get usernameInvalid =>
      'Username must be 3-20 characters, alphanumeric only';

  @override
  String get passwordComplexity =>
      'Password must be at least 8 characters with uppercase, lowercase, and number';

  @override
  String get passwordMismatch => 'Passwords do not match';

  @override
  String get phoneInvalid => 'Please enter a valid phone number';

  @override
  String get companyRequired =>
      'Please enter your company or organization name';

  @override
  String get registrationSuccess => 'Registration successful! Please sign in.';

  @override
  String get registrationFailed => 'Registration failed. Please try again.';

  @override
  String get dontHaveAccount => 'Don\'t have an account?';

  @override
  String get userManagement => 'User Management';

  @override
  String get addUser => 'Add User';

  @override
  String get usersList => 'Users List';

  @override
  String get addNewUser => 'Add New User';

  @override
  String get addUserToSystem => 'Add a new user to the system';

  @override
  String get systemUsers => 'System Users';

  @override
  String get refreshList => 'Refresh List';

  @override
  String get noUsersFound => 'No users found';

  @override
  String get enterUserPassword => 'Enter user password';

  @override
  String get addingUser => 'Adding User...';

  @override
  String get participantDetailsTitle => 'Participant Details';

  @override
  String get addNewParticipant => 'Add New Participant';

  @override
  String get participantGeneralTab => 'General Details';

  @override
  String get participantValidityTab => 'Participant Validity';

  @override
  String get participantBankAccountTab => 'Bank Account';

  @override
  String get participantNameLabel => 'Participant Name';

  @override
  String get participantNamePlaceholder => 'System generated value';

  @override
  String get participantNamePattern =>
      'Must be of pattern : (^[A-W]([0-9][0-9][1-9]|[0-9][1-9][0-9]|[1-9][0-9][0-9])\$)';

  @override
  String get participantTypeLabel => 'Participant Type';

  @override
  String get startDateLabel => 'Start Date';

  @override
  String get endDateLabel => 'End Date';

  @override
  String get areaLabel => 'Area';

  @override
  String get companyShortNameLabel => 'Company Short Name';

  @override
  String get companyShortNamePlaceholder =>
      'Must be of pattern: Japanese characters';

  @override
  String get companyShortNamePattern =>
      'Must be of pattern: Japanese characters';

  @override
  String get companyLongNameLabel => 'Company Long Name';

  @override
  String get companyLongNamePlaceholder =>
      'Must be of pattern: Japanese characters';

  @override
  String get companyLongNamePattern =>
      'Must be of pattern: Japanese characters';

  @override
  String get phoneNumberLabel => 'Phone Number';

  @override
  String get phonePart1Label => 'Phone Part1';

  @override
  String get phonePart1Placeholder => 'XXXXX';

  @override
  String get phonePart2Label => 'Phone Part2';

  @override
  String get phonePart2Placeholder => 'XXXX';

  @override
  String get phonePart3Label => 'Phone Part3';

  @override
  String get phonePart3Placeholder => 'XXXX';

  @override
  String get transactionIdLabel => 'Transaction Id';

  @override
  String get transactionIdPlaceholder => '';

  @override
  String get tradeDateLabel => 'Trade Date';

  @override
  String get queryParticipantTitle => 'Query Participant';

  @override
  String get queryParticipantButton => 'Query';

  @override
  String get resetButton => 'Reset';

  @override
  String get createParticipantButton => 'Create Participant';

  @override
  String get creatingParticipant => 'Creating...';

  @override
  String get saveButton => 'Save';

  @override
  String get savingChanges => 'Saving...';

  @override
  String get messagesTitle => 'Messages';

  @override
  String get addNewParticipantTooltip => 'Add New User';

  @override
  String get addParticipantTooltip => 'Add User';

  @override
  String participantCreatedSuccess(String name) {
    return 'Participant created successfully with name: $name';
  }

  @override
  String get participantUpdatedSuccess => 'Participant updated successfully';

  @override
  String get participantQuerySuccess => 'Participant data loaded successfully';

  @override
  String get fixFormErrors => 'Please fix the errors in the form';

  @override
  String get participantNameTrimmed =>
      'Participant name trimmed to first 4 chars (max length = 4).';

  @override
  String failedToCreateParticipant(String error) {
    return 'Failed to add participant: $error';
  }

  @override
  String failedToUpdateParticipant(String error) {
    return 'Failed to update participant: $error';
  }

  @override
  String failedToQueryParticipant(String error) {
    return 'Failed to query participant: $error';
  }
}
