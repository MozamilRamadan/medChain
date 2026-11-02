import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';

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

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
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
    Locale('ar'),
    Locale('en'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'MedChain'**
  String get appTitle;

  /// No description provided for @login.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get login;

  /// No description provided for @register.
  ///
  /// In en, this message translates to:
  /// **'Register'**
  String get register;

  /// No description provided for @patient.
  ///
  /// In en, this message translates to:
  /// **'Patient'**
  String get patient;

  /// No description provided for @doctor.
  ///
  /// In en, this message translates to:
  /// **'Doctor'**
  String get doctor;

  /// No description provided for @medicalRecords.
  ///
  /// In en, this message translates to:
  /// **'Medical Records'**
  String get medicalRecords;

  /// No description provided for @addRecord.
  ///
  /// In en, this message translates to:
  /// **'Add Medical Record'**
  String get addRecord;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @selectLanguage.
  ///
  /// In en, this message translates to:
  /// **'Select Language'**
  String get selectLanguage;

  /// No description provided for @arabic.
  ///
  /// In en, this message translates to:
  /// **'Arabic'**
  String get arabic;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @patientLogin.
  ///
  /// In en, this message translates to:
  /// **'Sign in As A Patient'**
  String get patientLogin;

  /// No description provided for @doctorLogin.
  ///
  /// In en, this message translates to:
  /// **'Sign in As A Doctor'**
  String get doctorLogin;

  /// No description provided for @switchToEnglish.
  ///
  /// In en, this message translates to:
  /// **'العربية'**
  String get switchToEnglish;

  /// No description provided for @switchToArabic.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get switchToArabic;

  /// No description provided for @loginAsDoctor.
  ///
  /// In en, this message translates to:
  /// **'Login as Doctor'**
  String get loginAsDoctor;

  /// No description provided for @loginAsPatient.
  ///
  /// In en, this message translates to:
  /// **'Login as Patient'**
  String get loginAsPatient;

  /// No description provided for @enterInformation.
  ///
  /// In en, this message translates to:
  /// **'Enter your information'**
  String get enterInformation;

  /// No description provided for @idNumber.
  ///
  /// In en, this message translates to:
  /// **'ID Number'**
  String get idNumber;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @pleaseEnterId.
  ///
  /// In en, this message translates to:
  /// **'Please enter your ID number'**
  String get pleaseEnterId;

  /// No description provided for @idTooShort.
  ///
  /// In en, this message translates to:
  /// **'ID number is too short'**
  String get idTooShort;

  /// No description provided for @pleaseEnterPassword.
  ///
  /// In en, this message translates to:
  /// **'Please enter your password'**
  String get pleaseEnterPassword;

  /// No description provided for @passwordTooShort.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 6 characters'**
  String get passwordTooShort;

  /// No description provided for @loggingIn.
  ///
  /// In en, this message translates to:
  /// **'Logging in...'**
  String get loggingIn;

  /// No description provided for @createAccount.
  ///
  /// In en, this message translates to:
  /// **'Create Account'**
  String get createAccount;

  /// No description provided for @accountWrongRole.
  ///
  /// In en, this message translates to:
  /// **'This account is not registered as a {role}'**
  String accountWrongRole(Object role);

  /// No description provided for @doctorRole.
  ///
  /// In en, this message translates to:
  /// **'Doctor'**
  String get doctorRole;

  /// No description provided for @patientRole.
  ///
  /// In en, this message translates to:
  /// **'Patient'**
  String get patientRole;

  /// No description provided for @welcomeUser.
  ///
  /// In en, this message translates to:
  /// **'Welcome, {name}'**
  String welcomeUser(String name);

  /// No description provided for @confirmLogout.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to log out of MedChain?'**
  String get confirmLogout;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @welcome.
  ///
  /// In en, this message translates to:
  /// **'Welcome, {name}'**
  String welcome(String name);

  /// No description provided for @patientSection.
  ///
  /// In en, this message translates to:
  /// **'Patient'**
  String get patientSection;

  /// No description provided for @doctorSection.
  ///
  /// In en, this message translates to:
  /// **'Doctor'**
  String get doctorSection;

  /// No description provided for @administrator.
  ///
  /// In en, this message translates to:
  /// **'Administrator'**
  String get administrator;

  /// No description provided for @myMedicalRecords.
  ///
  /// In en, this message translates to:
  /// **'My Medical Records'**
  String get myMedicalRecords;

  /// No description provided for @permissionRequests.
  ///
  /// In en, this message translates to:
  /// **'Permission Requests'**
  String get permissionRequests;

  /// No description provided for @myPatients.
  ///
  /// In en, this message translates to:
  /// **'My Patients'**
  String get myPatients;

  /// No description provided for @requestPatientAccess.
  ///
  /// In en, this message translates to:
  /// **'Request Patient Access'**
  String get requestPatientAccess;

  /// No description provided for @manageUsers.
  ///
  /// In en, this message translates to:
  /// **'Manage Users'**
  String get manageUsers;

  /// No description provided for @manageUsersDescription.
  ///
  /// In en, this message translates to:
  /// **'View and manage registered users'**
  String get manageUsersDescription;

  /// No description provided for @loginAgainAdmin.
  ///
  /// In en, this message translates to:
  /// **'Please log in again to access administration.'**
  String get loginAgainAdmin;

  /// No description provided for @adminUsersTitle.
  ///
  /// In en, this message translates to:
  /// **'Manage Users'**
  String get adminUsersTitle;

  /// No description provided for @refreshUsers.
  ///
  /// In en, this message translates to:
  /// **'Refresh users'**
  String get refreshUsers;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @noUsersFound.
  ///
  /// In en, this message translates to:
  /// **'No users found.'**
  String get noUsersFound;

  /// No description provided for @searchUsersHint.
  ///
  /// In en, this message translates to:
  /// **'Search name, national ID, or phone'**
  String get searchUsersHint;

  /// No description provided for @clearSearch.
  ///
  /// In en, this message translates to:
  /// **'Clear search'**
  String get clearSearch;

  /// No description provided for @filterByRole.
  ///
  /// In en, this message translates to:
  /// **'Filter by role'**
  String get filterByRole;

  /// No description provided for @allUsers.
  ///
  /// In en, this message translates to:
  /// **'All users'**
  String get allUsers;

  /// No description provided for @patients.
  ///
  /// In en, this message translates to:
  /// **'Patients'**
  String get patients;

  /// No description provided for @doctors.
  ///
  /// In en, this message translates to:
  /// **'Doctors'**
  String get doctors;

  /// No description provided for @admins.
  ///
  /// In en, this message translates to:
  /// **'Admins'**
  String get admins;

  /// No description provided for @showingUsers.
  ///
  /// In en, this message translates to:
  /// **'Showing {filtered} of {total} users'**
  String showingUsers(String filtered, String total);

  /// No description provided for @noMatchingUsers.
  ///
  /// In en, this message translates to:
  /// **'No matching users found.'**
  String get noMatchingUsers;

  /// No description provided for @unknownUser.
  ///
  /// In en, this message translates to:
  /// **'Unknown'**
  String get unknownUser;

  /// No description provided for @userIdLabel.
  ///
  /// In en, this message translates to:
  /// **'User ID: {id}'**
  String userIdLabel(String id);

  /// No description provided for @nationalIdLabel.
  ///
  /// In en, this message translates to:
  /// **'National ID: {id}'**
  String nationalIdLabel(String id);

  /// No description provided for @phoneLabel.
  ///
  /// In en, this message translates to:
  /// **'Phone: {phone}'**
  String phoneLabel(String phone);

  /// No description provided for @rolesLabel.
  ///
  /// In en, this message translates to:
  /// **'Roles: {roles}'**
  String rolesLabel(String roles);

  /// No description provided for @none.
  ///
  /// In en, this message translates to:
  /// **'None'**
  String get none;

  /// No description provided for @processing.
  ///
  /// In en, this message translates to:
  /// **'Processing...'**
  String get processing;

  /// No description provided for @grantAdminAccess.
  ///
  /// In en, this message translates to:
  /// **'Grant Admin Access'**
  String get grantAdminAccess;

  /// No description provided for @removeAdminAccess.
  ///
  /// In en, this message translates to:
  /// **'Remove Admin Access'**
  String get removeAdminAccess;

  /// No description provided for @grantAdminConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Grant administrator access?'**
  String get grantAdminConfirmTitle;

  /// No description provided for @removeAdminConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Remove administrator access?'**
  String get removeAdminConfirmTitle;

  /// No description provided for @grantAdminConfirmMessage.
  ///
  /// In en, this message translates to:
  /// **'Grant {name} permission to manage users?'**
  String grantAdminConfirmMessage(String name);

  /// No description provided for @removeAdminConfirmMessage.
  ///
  /// In en, this message translates to:
  /// **'Remove administrator permissions from {name}?'**
  String removeAdminConfirmMessage(String name);

  /// No description provided for @grantAccess.
  ///
  /// In en, this message translates to:
  /// **'Grant access'**
  String get grantAccess;

  /// No description provided for @removeAccess.
  ///
  /// In en, this message translates to:
  /// **'Remove access'**
  String get removeAccess;

  /// No description provided for @adminGrantedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Administrator access granted successfully'**
  String get adminGrantedSuccess;

  /// No description provided for @adminRemovedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Administrator access removed successfully'**
  String get adminRemovedSuccess;

  /// No description provided for @invalidUserId.
  ///
  /// In en, this message translates to:
  /// **'Invalid user ID'**
  String get invalidUserId;

  /// No description provided for @patientProfile.
  ///
  /// In en, this message translates to:
  /// **'Patient'**
  String get patientProfile;

  /// No description provided for @doctorProfile.
  ///
  /// In en, this message translates to:
  /// **'Doctor'**
  String get doctorProfile;

  /// No description provided for @removeProfileTitle.
  ///
  /// In en, this message translates to:
  /// **'Remove {role} Profile?'**
  String removeProfileTitle(String role);

  /// No description provided for @removeProfileMessage.
  ///
  /// In en, this message translates to:
  /// **'Remove the {role} profile for {name}? The user account will remain.'**
  String removeProfileMessage(String role, String name);

  /// No description provided for @removeProfile.
  ///
  /// In en, this message translates to:
  /// **'Remove Profile'**
  String get removeProfile;

  /// No description provided for @profileRemovedSuccess.
  ///
  /// In en, this message translates to:
  /// **'{role} profile removed successfully'**
  String profileRemovedSuccess(String role);

  /// No description provided for @deleteAccountTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete Account Permanently?'**
  String get deleteAccountTitle;

  /// No description provided for @deleteAccountMessage.
  ///
  /// In en, this message translates to:
  /// **'Delete the entire account belonging to {name}, including associated SQL database records? This action cannot be undone. Copies already stored on the blockchain or IPFS will remain.'**
  String deleteAccountMessage(String name);

  /// No description provided for @deleteAccount.
  ///
  /// In en, this message translates to:
  /// **'Delete Account'**
  String get deleteAccount;

  /// No description provided for @accountDeletedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Account deleted successfully'**
  String get accountDeletedSuccess;

  /// No description provided for @forgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot Password?'**
  String get forgotPassword;

  /// No description provided for @phoneTooShort.
  ///
  /// In en, this message translates to:
  /// **'Phone number is too short.'**
  String get phoneTooShort;

  /// No description provided for @pleaseEnterPhone.
  ///
  /// In en, this message translates to:
  /// **'Please enter your phone number.'**
  String get pleaseEnterPhone;

  /// No description provided for @enterPhoneForReset.
  ///
  /// In en, this message translates to:
  /// **'Enter your phone number to reset your password.'**
  String get enterPhoneForReset;

  /// No description provided for @phoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Phone number'**
  String get phoneNumber;

  /// No description provided for @continueButton.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueButton;

  /// No description provided for @resetNotConnected.
  ///
  /// In en, this message translates to:
  /// **'Password recovery is not connected to the server yet.'**
  String get resetNotConnected;

  /// No description provided for @phoneNumberTooShortMessage.
  ///
  /// In en, this message translates to:
  /// **'Phone number must contain at least 9 digits.'**
  String get phoneNumberTooShortMessage;

  /// No description provided for @profileTitle.
  ///
  /// In en, this message translates to:
  /// **'My Profile'**
  String get profileTitle;

  /// No description provided for @refreshProfile.
  ///
  /// In en, this message translates to:
  /// **'Refresh profile'**
  String get refreshProfile;

  /// No description provided for @editProfile.
  ///
  /// In en, this message translates to:
  /// **'Edit Profile'**
  String get editProfile;

  /// No description provided for @loadProfileError.
  ///
  /// In en, this message translates to:
  /// **'Could not load your profile.'**
  String get loadProfileError;

  /// No description provided for @tryAgain.
  ///
  /// In en, this message translates to:
  /// **'Try Again'**
  String get tryAgain;

  /// No description provided for @chooseProfilePicture.
  ///
  /// In en, this message translates to:
  /// **'Choose profile picture'**
  String get chooseProfilePicture;

  /// No description provided for @newPictureSelected.
  ///
  /// In en, this message translates to:
  /// **'New picture selected'**
  String get newPictureSelected;

  /// No description provided for @uploading.
  ///
  /// In en, this message translates to:
  /// **'Uploading...'**
  String get uploading;

  /// No description provided for @savePicture.
  ///
  /// In en, this message translates to:
  /// **'Save Picture'**
  String get savePicture;

  /// No description provided for @profilePictureUpdated.
  ///
  /// In en, this message translates to:
  /// **'Profile picture updated successfully.'**
  String get profilePictureUpdated;

  /// No description provided for @selectValidImage.
  ///
  /// In en, this message translates to:
  /// **'Please select a JPG, JPEG, or PNG image.'**
  String get selectValidImage;

  /// No description provided for @imageFileNotFound.
  ///
  /// In en, this message translates to:
  /// **'The selected image file could not be found.'**
  String get imageFileNotFound;

  /// No description provided for @imageSizeLimit.
  ///
  /// In en, this message translates to:
  /// **'Image size must not exceed 5 MB.'**
  String get imageSizeLimit;

  /// No description provided for @selectImageFirst.
  ///
  /// In en, this message translates to:
  /// **'Please select an image first.'**
  String get selectImageFirst;

  /// No description provided for @allowedImageTypes.
  ///
  /// In en, this message translates to:
  /// **'Only JPG, JPEG, and PNG images are allowed.'**
  String get allowedImageTypes;

  /// No description provided for @imageSelectionFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not select image: {error}'**
  String imageSelectionFailed(String error);

  /// No description provided for @imageUploadFailed.
  ///
  /// In en, this message translates to:
  /// **'Image upload failed: {error}'**
  String imageUploadFailed(String error);

  /// No description provided for @personalInformation.
  ///
  /// In en, this message translates to:
  /// **'Personal Information'**
  String get personalInformation;

  /// No description provided for @fullNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Full Name'**
  String get fullNameLabel;

  /// No description provided for @phoneNumberLabel.
  ///
  /// In en, this message translates to:
  /// **'Phone Number'**
  String get phoneNumberLabel;

  /// No description provided for @nationalIdLabelProfile.
  ///
  /// In en, this message translates to:
  /// **'National ID'**
  String get nationalIdLabelProfile;

  /// No description provided for @specializationLabel.
  ///
  /// In en, this message translates to:
  /// **'Specialization'**
  String get specializationLabel;

  /// No description provided for @licenseNumberLabel.
  ///
  /// In en, this message translates to:
  /// **'License Number'**
  String get licenseNumberLabel;

  /// No description provided for @notAvailable.
  ///
  /// In en, this message translates to:
  /// **'Not available'**
  String get notAvailable;

  /// No description provided for @fullNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Full name is required'**
  String get fullNameRequired;

  /// No description provided for @phoneNumberRequired.
  ///
  /// In en, this message translates to:
  /// **'Phone number is required'**
  String get phoneNumberRequired;

  /// No description provided for @accountRoles.
  ///
  /// In en, this message translates to:
  /// **'Account Roles'**
  String get accountRoles;

  /// No description provided for @noRolesAssigned.
  ///
  /// In en, this message translates to:
  /// **'No roles assigned'**
  String get noRolesAssigned;

  /// No description provided for @profileUpdatedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Profile updated successfully.'**
  String get profileUpdatedSuccess;

  /// No description provided for @uploadImageFailedStatus.
  ///
  /// In en, this message translates to:
  /// **'Image upload failed ({statusCode}).'**
  String uploadImageFailedStatus(String statusCode);

  /// No description provided for @profileUpdateFailed.
  ///
  /// In en, this message translates to:
  /// **'Profile update failed.'**
  String get profileUpdateFailed;

  /// No description provided for @profileSaveFailed.
  ///
  /// In en, this message translates to:
  /// **'Profile save failed.'**
  String get profileSaveFailed;

  /// No description provided for @saving.
  ///
  /// In en, this message translates to:
  /// **'Saving...'**
  String get saving;

  /// No description provided for @saveChanges.
  ///
  /// In en, this message translates to:
  /// **'Save Changes'**
  String get saveChanges;
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
      <String>['ar', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
