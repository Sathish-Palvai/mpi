import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('es')
  ];

  /// Application title
  ///
  /// In en, this message translates to:
  /// **'Power Management Interface'**
  String get appTitle;

  /// Login button text
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get login;

  /// Username field label
  ///
  /// In en, this message translates to:
  /// **'Username'**
  String get username;

  /// Password field label
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// User type field label
  ///
  /// In en, this message translates to:
  /// **'User Type'**
  String get userType;

  /// BSP user type description
  ///
  /// In en, this message translates to:
  /// **'BSP - Balancing Service Provider'**
  String get userTypeBsp;

  /// TSO user type description
  ///
  /// In en, this message translates to:
  /// **'TSO - Transmission System Operator'**
  String get userTypeTso;

  /// MO user type description
  ///
  /// In en, this message translates to:
  /// **'MO - Market Operator'**
  String get userTypeMo;

  /// Home navigation item
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// Dashboard title
  ///
  /// In en, this message translates to:
  /// **'Dashboard'**
  String get dashboard;

  /// Registration navigation item
  ///
  /// In en, this message translates to:
  /// **'Registration'**
  String get registration;

  /// Interface navigation item
  ///
  /// In en, this message translates to:
  /// **'Interface'**
  String get interface;

  /// Switching navigation item
  ///
  /// In en, this message translates to:
  /// **'Switching'**
  String get switching;

  /// Reports navigation item
  ///
  /// In en, this message translates to:
  /// **'Reports'**
  String get reports;

  /// Settings navigation item
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// Logout button text
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// Cancel button text
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// Confirm button text
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// Welcome message with username
  ///
  /// In en, this message translates to:
  /// **'Welcome back, {username}!'**
  String welcomeMessage(String username);

  /// Welcome subtitle
  ///
  /// In en, this message translates to:
  /// **'Manage your power system operations efficiently'**
  String get welcomeSubtitle;

  /// Quick access section title
  ///
  /// In en, this message translates to:
  /// **'Quick Access'**
  String get quickAccess;

  /// Recent activity section title
  ///
  /// In en, this message translates to:
  /// **'Recent Activity'**
  String get recentActivity;

  /// Welcome back title
  ///
  /// In en, this message translates to:
  /// **'Welcome Back'**
  String get welcomeBack;

  /// Sign in subtitle
  ///
  /// In en, this message translates to:
  /// **'Sign in to your account'**
  String get signInToAccount;

  /// Username field hint
  ///
  /// In en, this message translates to:
  /// **'Enter your username'**
  String get enterUsername;

  /// Password field hint
  ///
  /// In en, this message translates to:
  /// **'Enter your password'**
  String get enterPassword;

  /// Sign in button text
  ///
  /// In en, this message translates to:
  /// **'Sign In'**
  String get signIn;

  /// Signing in loading text
  ///
  /// In en, this message translates to:
  /// **'Signing In...'**
  String get signingIn;

  /// Demo credentials section title
  ///
  /// In en, this message translates to:
  /// **'Demo Credentials'**
  String get demoCredentials;

  /// Username validation error
  ///
  /// In en, this message translates to:
  /// **'Please enter your username'**
  String get usernameRequired;

  /// Username minimum length validation
  ///
  /// In en, this message translates to:
  /// **'Username must be at least 3 characters'**
  String get usernameMinLength;

  /// Password validation error
  ///
  /// In en, this message translates to:
  /// **'Please enter your password'**
  String get passwordRequired;

  /// Password minimum length validation
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 6 characters'**
  String get passwordMinLength;

  /// Logout confirmation dialog title
  ///
  /// In en, this message translates to:
  /// **'Confirm Logout'**
  String get confirmLogout;

  /// Logout confirmation message
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to logout?'**
  String get logoutConfirmation;

  /// Registration screen title
  ///
  /// In en, this message translates to:
  /// **'Registration Management'**
  String get registrationManagement;

  /// Registration screen subtitle
  ///
  /// In en, this message translates to:
  /// **'Manage user registrations and participant information'**
  String get registrationSubtitle;

  /// Interface screen title
  ///
  /// In en, this message translates to:
  /// **'System Interface'**
  String get systemInterface;

  /// Interface screen subtitle
  ///
  /// In en, this message translates to:
  /// **'Monitor and manage system interfaces and connections'**
  String get interfaceSubtitle;

  /// Subtitle for switching card
  ///
  /// In en, this message translates to:
  /// **'Power switching'**
  String get powerSwitching;

  /// Switching screen subtitle
  ///
  /// In en, this message translates to:
  /// **'Manage power switching operations and configurations'**
  String get switchingSubtitle;

  /// Reports screen title
  ///
  /// In en, this message translates to:
  /// **'Analytics & Reports'**
  String get analyticsReports;

  /// Reports screen subtitle
  ///
  /// In en, this message translates to:
  /// **'View detailed analytics and generate comprehensive reports'**
  String get reportsSubtitle;

  /// Settings screen subtitle
  ///
  /// In en, this message translates to:
  /// **'Configure application settings and preferences'**
  String get settingsSubtitle;

  /// Coming soon text
  ///
  /// In en, this message translates to:
  /// **'Coming Soon'**
  String get comingSoon;

  /// Feature in development message
  ///
  /// In en, this message translates to:
  /// **'This feature is under development and will be available soon.'**
  String get featureInDevelopment;

  /// User information section title
  ///
  /// In en, this message translates to:
  /// **'User Information'**
  String get userInformation;

  /// Login time label
  ///
  /// In en, this message translates to:
  /// **'Login Time'**
  String get loginTime;

  /// Notifications button tooltip
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// Registration card subtitle
  ///
  /// In en, this message translates to:
  /// **'Manage registrations'**
  String get registrationCardSubtitle;

  /// Interface card subtitle
  ///
  /// In en, this message translates to:
  /// **'System interfaces'**
  String get interfaceCardSubtitle;

  /// Switching card subtitle
  ///
  /// In en, this message translates to:
  /// **'Power switching'**
  String get switchingCardSubtitle;

  /// Reports card subtitle
  ///
  /// In en, this message translates to:
  /// **'Analytics & insights'**
  String get reportsCardSubtitle;

  /// Activity: new registration
  ///
  /// In en, this message translates to:
  /// **'New registration submitted'**
  String get newRegistrationSubmitted;

  /// Activity: switching operation
  ///
  /// In en, this message translates to:
  /// **'Switching operation completed'**
  String get switchingOperationCompleted;

  /// Activity: report generated
  ///
  /// In en, this message translates to:
  /// **'Monthly report generated'**
  String get monthlyReportGenerated;

  /// Language setting label
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// Welcome message for power system operations
  ///
  /// In en, this message translates to:
  /// **'Manage your power system operations efficiently'**
  String get managePowerSystemOperations;

  /// Subtitle for registration card
  ///
  /// In en, this message translates to:
  /// **'Manage registrations'**
  String get manageRegistrations;

  /// Subtitle for interface card
  ///
  /// In en, this message translates to:
  /// **'System interfaces'**
  String get systemInterfaces;

  /// Subtitle for reports card
  ///
  /// In en, this message translates to:
  /// **'Analytics & insights'**
  String get analyticsInsights;

  /// Time unit for activities
  ///
  /// In en, this message translates to:
  /// **'hours ago'**
  String get hoursAgo;

  /// Time unit for activities
  ///
  /// In en, this message translates to:
  /// **'day ago'**
  String get dayAgo;

  /// Logout confirmation message
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to logout?'**
  String get areYouSureLogout;

  /// Settings page description
  ///
  /// In en, this message translates to:
  /// **'Configure application settings and preferences'**
  String get configureAppSettings;

  /// Theme section title
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get theme;

  /// Theme section description
  ///
  /// In en, this message translates to:
  /// **'Choose your preferred appearance'**
  String get chooseAppearance;

  /// Light theme option
  ///
  /// In en, this message translates to:
  /// **'Light Theme'**
  String get lightTheme;

  /// Light theme description
  ///
  /// In en, this message translates to:
  /// **'Clean and bright interface'**
  String get lightThemeDescription;

  /// Dark theme option
  ///
  /// In en, this message translates to:
  /// **'Dark Theme'**
  String get darkTheme;

  /// Dark theme description
  ///
  /// In en, this message translates to:
  /// **'Easy on the eyes in low light'**
  String get darkThemeDescription;

  /// System theme option
  ///
  /// In en, this message translates to:
  /// **'System Theme'**
  String get systemTheme;

  /// System theme description
  ///
  /// In en, this message translates to:
  /// **'Follows device settings'**
  String get systemThemeDescription;

  /// Language section description
  ///
  /// In en, this message translates to:
  /// **'Choose your preferred language'**
  String get chooseLanguage;

  /// About section title
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get about;

  /// Application name label
  ///
  /// In en, this message translates to:
  /// **'App Name'**
  String get appName;

  /// Version label
  ///
  /// In en, this message translates to:
  /// **'Version'**
  String get version;

  /// Developer label
  ///
  /// In en, this message translates to:
  /// **'Developer'**
  String get developer;

  /// Registration page title
  ///
  /// In en, this message translates to:
  /// **'Create Account'**
  String get createAccount;

  /// Registration page subtitle
  ///
  /// In en, this message translates to:
  /// **'Join our platform to access market participant services'**
  String get joinOurPlatform;

  /// Personal information section title
  ///
  /// In en, this message translates to:
  /// **'Personal Information'**
  String get personalInformation;

  /// Full name field label
  ///
  /// In en, this message translates to:
  /// **'Full Name'**
  String get fullName;

  /// Full name field hint
  ///
  /// In en, this message translates to:
  /// **'Enter your full name'**
  String get enterFullName;

  /// Email field label
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// Email field hint
  ///
  /// In en, this message translates to:
  /// **'Enter your email address'**
  String get enterEmail;

  /// Phone number field label
  ///
  /// In en, this message translates to:
  /// **'Phone Number'**
  String get phoneNumber;

  /// Phone number field hint
  ///
  /// In en, this message translates to:
  /// **'Enter your phone number (optional)'**
  String get enterPhoneNumber;

  /// Account details section title
  ///
  /// In en, this message translates to:
  /// **'Account Details'**
  String get accountDetails;

  /// Username field hint
  ///
  /// In en, this message translates to:
  /// **'Enter a unique username'**
  String get enterUniqueUsername;

  /// Password field hint
  ///
  /// In en, this message translates to:
  /// **'Enter a secure password'**
  String get enterSecurePassword;

  /// Confirm password field label
  ///
  /// In en, this message translates to:
  /// **'Confirm Password'**
  String get confirmPassword;

  /// Confirm password field hint
  ///
  /// In en, this message translates to:
  /// **'Re-enter your password'**
  String get reenterPassword;

  /// Organization details section title
  ///
  /// In en, this message translates to:
  /// **'Organization Details'**
  String get organizationDetails;

  /// User type field hint
  ///
  /// In en, this message translates to:
  /// **'Select your user type'**
  String get selectUserType;

  /// Company field label
  ///
  /// In en, this message translates to:
  /// **'Company/Organization'**
  String get companyOrganization;

  /// Company field hint
  ///
  /// In en, this message translates to:
  /// **'Enter your company or organization name'**
  String get enterCompanyName;

  /// Register button text
  ///
  /// In en, this message translates to:
  /// **'Register'**
  String get register;

  /// Registering loading text
  ///
  /// In en, this message translates to:
  /// **'Registering...'**
  String get registering;

  /// Login link prefix text
  ///
  /// In en, this message translates to:
  /// **'Already have an account?'**
  String get alreadyHaveAccount;

  /// Full name validation error
  ///
  /// In en, this message translates to:
  /// **'Please enter your full name'**
  String get fullNameRequired;

  /// Email validation error
  ///
  /// In en, this message translates to:
  /// **'Please enter your email address'**
  String get emailRequired;

  /// Email format validation error
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid email address'**
  String get emailInvalid;

  /// Username format validation error
  ///
  /// In en, this message translates to:
  /// **'Username must be 3-20 characters, alphanumeric only'**
  String get usernameInvalid;

  /// Password complexity validation error
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 8 characters with uppercase, lowercase, and number'**
  String get passwordComplexity;

  /// Password confirmation validation error
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get passwordMismatch;

  /// Phone number validation error
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid phone number'**
  String get phoneInvalid;

  /// Company validation error
  ///
  /// In en, this message translates to:
  /// **'Please enter your company or organization name'**
  String get companyRequired;

  /// Registration success message
  ///
  /// In en, this message translates to:
  /// **'Registration successful! Please sign in.'**
  String get registrationSuccess;

  /// Registration failure message
  ///
  /// In en, this message translates to:
  /// **'Registration failed. Please try again.'**
  String get registrationFailed;

  /// Create account link prefix text
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account?'**
  String get dontHaveAccount;

  /// User management screen title
  ///
  /// In en, this message translates to:
  /// **'User Management'**
  String get userManagement;

  /// Add user tab title
  ///
  /// In en, this message translates to:
  /// **'Add User'**
  String get addUser;

  /// Users list tab title
  ///
  /// In en, this message translates to:
  /// **'Users List'**
  String get usersList;

  /// Add new user header title
  ///
  /// In en, this message translates to:
  /// **'Add New User'**
  String get addNewUser;

  /// Add user description
  ///
  /// In en, this message translates to:
  /// **'Add a new user to the system'**
  String get addUserToSystem;

  /// System users list title
  ///
  /// In en, this message translates to:
  /// **'System Users'**
  String get systemUsers;

  /// Refresh list tooltip
  ///
  /// In en, this message translates to:
  /// **'Refresh List'**
  String get refreshList;

  /// Empty users list message
  ///
  /// In en, this message translates to:
  /// **'No users found'**
  String get noUsersFound;

  /// User password field hint
  ///
  /// In en, this message translates to:
  /// **'Enter user password'**
  String get enterUserPassword;

  /// Adding user loading text
  ///
  /// In en, this message translates to:
  /// **'Adding User...'**
  String get addingUser;

  /// Participant details screen title
  ///
  /// In en, this message translates to:
  /// **'Participant Details'**
  String get participantDetailsTitle;

  /// Add new participant screen title
  ///
  /// In en, this message translates to:
  /// **'Add New Participant'**
  String get addNewParticipant;

  /// Participant general details tab
  ///
  /// In en, this message translates to:
  /// **'General Details'**
  String get participantGeneralTab;

  /// Participant validity tab
  ///
  /// In en, this message translates to:
  /// **'Participant Validity'**
  String get participantValidityTab;

  /// Participant bank account tab
  ///
  /// In en, this message translates to:
  /// **'Bank Account'**
  String get participantBankAccountTab;

  /// Participant name field label
  ///
  /// In en, this message translates to:
  /// **'Participant Name'**
  String get participantNameLabel;

  /// Participant name placeholder text
  ///
  /// In en, this message translates to:
  /// **'System generated value'**
  String get participantNamePlaceholder;

  /// Participant name validation pattern message
  ///
  /// In en, this message translates to:
  /// **'Must be of pattern : (^[A-W]([0-9][0-9][1-9]|[0-9][1-9][0-9]|[1-9][0-9][0-9])\$)'**
  String get participantNamePattern;

  /// Participant type field label
  ///
  /// In en, this message translates to:
  /// **'Participant Type'**
  String get participantTypeLabel;

  /// Start date field label
  ///
  /// In en, this message translates to:
  /// **'Start Date'**
  String get startDateLabel;

  /// End date field label
  ///
  /// In en, this message translates to:
  /// **'End Date'**
  String get endDateLabel;

  /// Area field label
  ///
  /// In en, this message translates to:
  /// **'Area'**
  String get areaLabel;

  /// Company short name field label
  ///
  /// In en, this message translates to:
  /// **'Company Short Name'**
  String get companyShortNameLabel;

  /// Company short name placeholder
  ///
  /// In en, this message translates to:
  /// **'Must be of pattern: Japanese characters'**
  String get companyShortNamePlaceholder;

  /// Company short name validation pattern
  ///
  /// In en, this message translates to:
  /// **'Must be of pattern: Japanese characters'**
  String get companyShortNamePattern;

  /// Company long name field label
  ///
  /// In en, this message translates to:
  /// **'Company Long Name'**
  String get companyLongNameLabel;

  /// Company long name placeholder
  ///
  /// In en, this message translates to:
  /// **'Must be of pattern: Japanese characters'**
  String get companyLongNamePlaceholder;

  /// Company long name validation pattern
  ///
  /// In en, this message translates to:
  /// **'Must be of pattern: Japanese characters'**
  String get companyLongNamePattern;

  /// Phone number field label
  ///
  /// In en, this message translates to:
  /// **'Phone Number'**
  String get phoneNumberLabel;

  /// Phone part 1 field label
  ///
  /// In en, this message translates to:
  /// **'Phone Part1'**
  String get phonePart1Label;

  /// Phone part 1 placeholder
  ///
  /// In en, this message translates to:
  /// **'XXXXX'**
  String get phonePart1Placeholder;

  /// Phone part 2 field label
  ///
  /// In en, this message translates to:
  /// **'Phone Part2'**
  String get phonePart2Label;

  /// Phone part 2 placeholder
  ///
  /// In en, this message translates to:
  /// **'XXXX'**
  String get phonePart2Placeholder;

  /// Phone part 3 field label
  ///
  /// In en, this message translates to:
  /// **'Phone Part3'**
  String get phonePart3Label;

  /// Phone part 3 placeholder
  ///
  /// In en, this message translates to:
  /// **'XXXX'**
  String get phonePart3Placeholder;

  /// Transaction ID field label
  ///
  /// In en, this message translates to:
  /// **'Transaction Id'**
  String get transactionIdLabel;

  /// Transaction ID placeholder
  ///
  /// In en, this message translates to:
  /// **''**
  String get transactionIdPlaceholder;

  /// Trade date field label for query
  ///
  /// In en, this message translates to:
  /// **'Trade Date'**
  String get tradeDateLabel;

  /// Query participant dialog title
  ///
  /// In en, this message translates to:
  /// **'Query Participant'**
  String get queryParticipantTitle;

  /// Query button text
  ///
  /// In en, this message translates to:
  /// **'Query'**
  String get queryParticipantButton;

  /// Reset button text
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get resetButton;

  /// Create participant button text
  ///
  /// In en, this message translates to:
  /// **'Create Participant'**
  String get createParticipantButton;

  /// Creating participant loading text
  ///
  /// In en, this message translates to:
  /// **'Creating...'**
  String get creatingParticipant;

  /// Save button text
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get saveButton;

  /// Saving changes loading text
  ///
  /// In en, this message translates to:
  /// **'Saving...'**
  String get savingChanges;

  /// Response messages card title
  ///
  /// In en, this message translates to:
  /// **'Messages'**
  String get messagesTitle;

  /// Add new participant tooltip
  ///
  /// In en, this message translates to:
  /// **'Add New User'**
  String get addNewParticipantTooltip;

  /// Add participant tooltip
  ///
  /// In en, this message translates to:
  /// **'Add User'**
  String get addParticipantTooltip;

  /// Participant created success message
  ///
  /// In en, this message translates to:
  /// **'Participant created successfully with name: {name}'**
  String participantCreatedSuccess(String name);

  /// Participant updated success message
  ///
  /// In en, this message translates to:
  /// **'Participant updated successfully'**
  String get participantUpdatedSuccess;

  /// Participant query success message
  ///
  /// In en, this message translates to:
  /// **'Participant data loaded successfully'**
  String get participantQuerySuccess;

  /// Form validation error message
  ///
  /// In en, this message translates to:
  /// **'Please fix the errors in the form'**
  String get fixFormErrors;

  /// Participant name trimmed warning
  ///
  /// In en, this message translates to:
  /// **'Participant name trimmed to first 4 chars (max length = 4).'**
  String get participantNameTrimmed;

  /// Failed to create participant error message
  ///
  /// In en, this message translates to:
  /// **'Failed to add participant: {error}'**
  String failedToCreateParticipant(String error);

  /// Failed to update participant error message
  ///
  /// In en, this message translates to:
  /// **'Failed to update participant: {error}'**
  String failedToUpdateParticipant(String error);

  /// Failed to query participant error message
  ///
  /// In en, this message translates to:
  /// **'Failed to query participant: {error}'**
  String failedToQueryParticipant(String error);
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'es'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
