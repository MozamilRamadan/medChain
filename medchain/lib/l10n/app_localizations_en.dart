// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'MedChain';

  @override
  String get login => 'Login';

  @override
  String get register => 'Register';

  @override
  String get patient => 'Patient';

  @override
  String get doctor => 'Doctor';

  @override
  String get medicalRecords => 'Medical Records';

  @override
  String get addRecord => 'Add Medical Record';

  @override
  String get profile => 'Profile';

  @override
  String get logout => 'Logout';

  @override
  String get language => 'Language';

  @override
  String get selectLanguage => 'Select Language';

  @override
  String get arabic => 'Arabic';

  @override
  String get english => 'English';

  @override
  String get patientLogin => 'Sign in As A Patient';

  @override
  String get doctorLogin => 'Sign in As A Doctor';

  @override
  String get switchToEnglish => 'العربية';

  @override
  String get switchToArabic => 'English';

  @override
  String get loginAsDoctor => 'Login as Doctor';

  @override
  String get loginAsPatient => 'Login as Patient';

  @override
  String get enterInformation => 'Enter your information';

  @override
  String get idNumber => 'ID Number';

  @override
  String get password => 'Password';

  @override
  String get pleaseEnterId => 'Please enter your ID number';

  @override
  String get idTooShort => 'ID number is too short';

  @override
  String get pleaseEnterPassword => 'Please enter your password';

  @override
  String get passwordTooShort => 'Password must be at least 6 characters';

  @override
  String get loggingIn => 'Logging in...';

  @override
  String get createAccount => 'Create Account';

  @override
  String accountWrongRole(Object role) {
    return 'This account is not registered as a $role';
  }

  @override
  String get doctorRole => 'Doctor';

  @override
  String get patientRole => 'Patient';

  @override
  String welcomeUser(String name) {
    return 'Welcome, $name';
  }

  @override
  String get confirmLogout => 'Are you sure you want to log out of MedChain?';

  @override
  String get cancel => 'Cancel';

  @override
  String welcome(String name) {
    return 'Welcome, $name';
  }

  @override
  String get patientSection => 'Patient';

  @override
  String get doctorSection => 'Doctor';

  @override
  String get administrator => 'Administrator';

  @override
  String get myMedicalRecords => 'My Medical Records';

  @override
  String get permissionRequests => 'Permission Requests';

  @override
  String get myPatients => 'My Patients';

  @override
  String get requestPatientAccess => 'Request Patient Access';

  @override
  String get manageUsers => 'Manage Users';

  @override
  String get manageUsersDescription => 'View and manage registered users';

  @override
  String get loginAgainAdmin => 'Please log in again to access administration.';

  @override
  String get adminUsersTitle => 'Manage Users';

  @override
  String get refreshUsers => 'Refresh users';

  @override
  String get retry => 'Retry';

  @override
  String get noUsersFound => 'No users found.';

  @override
  String get searchUsersHint => 'Search name, national ID, or phone';

  @override
  String get clearSearch => 'Clear search';

  @override
  String get filterByRole => 'Filter by role';

  @override
  String get allUsers => 'All users';

  @override
  String get patients => 'Patients';

  @override
  String get doctors => 'Doctors';

  @override
  String get admins => 'Admins';

  @override
  String showingUsers(String filtered, String total) {
    return 'Showing $filtered of $total users';
  }

  @override
  String get noMatchingUsers => 'No matching users found.';

  @override
  String get unknownUser => 'Unknown';

  @override
  String userIdLabel(String id) {
    return 'User ID: $id';
  }

  @override
  String nationalIdLabel(String id) {
    return 'National ID: $id';
  }

  @override
  String phoneLabel(String phone) {
    return 'Phone: $phone';
  }

  @override
  String rolesLabel(String roles) {
    return 'Roles: $roles';
  }

  @override
  String get none => 'None';

  @override
  String get processing => 'Processing...';

  @override
  String get grantAdminAccess => 'Grant Admin Access';

  @override
  String get removeAdminAccess => 'Remove Admin Access';

  @override
  String get grantAdminConfirmTitle => 'Grant administrator access?';

  @override
  String get removeAdminConfirmTitle => 'Remove administrator access?';

  @override
  String grantAdminConfirmMessage(String name) {
    return 'Grant $name permission to manage users?';
  }

  @override
  String removeAdminConfirmMessage(String name) {
    return 'Remove administrator permissions from $name?';
  }

  @override
  String get grantAccess => 'Grant access';

  @override
  String get removeAccess => 'Remove access';

  @override
  String get adminGrantedSuccess => 'Administrator access granted successfully';

  @override
  String get adminRemovedSuccess => 'Administrator access removed successfully';

  @override
  String get invalidUserId => 'Invalid user ID';

  @override
  String get patientProfile => 'Patient';

  @override
  String get doctorProfile => 'Doctor';

  @override
  String removeProfileTitle(String role) {
    return 'Remove $role Profile?';
  }

  @override
  String removeProfileMessage(String role, String name) {
    return 'Remove the $role profile for $name? The user account will remain.';
  }

  @override
  String get removeProfile => 'Remove Profile';

  @override
  String profileRemovedSuccess(String role) {
    return '$role profile removed successfully';
  }

  @override
  String get deleteAccountTitle => 'Delete Account Permanently?';

  @override
  String deleteAccountMessage(String name) {
    return 'Delete the entire account belonging to $name, including associated SQL database records? This action cannot be undone. Copies already stored on the blockchain or IPFS will remain.';
  }

  @override
  String get deleteAccount => 'Delete Account';

  @override
  String get accountDeletedSuccess => 'Account deleted successfully';

  @override
  String get forgotPassword => 'Forgot Password?';

  @override
  String get phoneTooShort => 'Phone number is too short.';

  @override
  String get pleaseEnterPhone => 'Please enter your phone number.';

  @override
  String get enterPhoneForReset =>
      'Enter your phone number to reset your password.';

  @override
  String get phoneNumber => 'Phone number';

  @override
  String get continueButton => 'Continue';

  @override
  String get resetNotConnected =>
      'Password recovery is not connected to the server yet.';

  @override
  String get phoneNumberTooShortMessage =>
      'Phone number must contain at least 9 digits.';

  @override
  String get profileTitle => 'My Profile';

  @override
  String get refreshProfile => 'Refresh profile';

  @override
  String get editProfile => 'Edit Profile';

  @override
  String get loadProfileError => 'Could not load your profile.';

  @override
  String get tryAgain => 'Try Again';

  @override
  String get chooseProfilePicture => 'Choose profile picture';

  @override
  String get newPictureSelected => 'New picture selected';

  @override
  String get uploading => 'Uploading...';

  @override
  String get savePicture => 'Save Picture';

  @override
  String get profilePictureUpdated => 'Profile picture updated successfully.';

  @override
  String get selectValidImage => 'Please select a JPG, JPEG, or PNG image.';

  @override
  String get imageFileNotFound => 'The selected image file could not be found.';

  @override
  String get imageSizeLimit => 'Image size must not exceed 5 MB.';

  @override
  String get selectImageFirst => 'Please select an image first.';

  @override
  String get allowedImageTypes => 'Only JPG, JPEG, and PNG images are allowed.';

  @override
  String imageSelectionFailed(String error) {
    return 'Could not select image: $error';
  }

  @override
  String imageUploadFailed(String error) {
    return 'Image upload failed: $error';
  }

  @override
  String get personalInformation => 'Personal Information';

  @override
  String get fullNameLabel => 'Full Name';

  @override
  String get phoneNumberLabel => 'Phone Number';

  @override
  String get nationalIdLabelProfile => 'National ID';

  @override
  String get specializationLabel => 'Specialization';

  @override
  String get licenseNumberLabel => 'License Number';

  @override
  String get notAvailable => 'Not available';

  @override
  String get fullNameRequired => 'Full name is required';

  @override
  String get phoneNumberRequired => 'Phone number is required';

  @override
  String get accountRoles => 'Account Roles';

  @override
  String get noRolesAssigned => 'No roles assigned';

  @override
  String get profileUpdatedSuccess => 'Profile updated successfully.';

  @override
  String uploadImageFailedStatus(String statusCode) {
    return 'Image upload failed ($statusCode).';
  }

  @override
  String get profileUpdateFailed => 'Profile update failed.';

  @override
  String get profileSaveFailed => 'Profile save failed.';

  @override
  String get saving => 'Saving...';

  @override
  String get saveChanges => 'Save Changes';
}
