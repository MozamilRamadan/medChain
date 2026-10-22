// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appTitle => 'ميد تشين';

  @override
  String get login => 'تسجيل الدخول';

  @override
  String get register => 'إنشاء حساب';

  @override
  String get patient => 'المريض';

  @override
  String get doctor => 'الطبيب';

  @override
  String get medicalRecords => 'السجلات الطبية';

  @override
  String get addRecord => 'إضافة سجل طبي';

  @override
  String get profile => 'الملف الشخصي';

  @override
  String get logout => 'تسجيل الخروج';

  @override
  String get language => 'اللغة';

  @override
  String get selectLanguage => 'اختر اللغة';

  @override
  String get arabic => 'العربية';

  @override
  String get english => 'الإنجليزية';

  @override
  String get patientLogin => 'تسجيل الدخول كمريض';

  @override
  String get doctorLogin => 'تسجيل الدخول كطبيب';

  @override
  String get switchToEnglish => 'التبديل إلى الإنجليزية';

  @override
  String get switchToArabic => 'التبديل إلى العربية';

  @override
  String get loginAsDoctor => 'تسجيل الدخول كطبيب';

  @override
  String get loginAsPatient => 'تسجيل الدخول كمريض';

  @override
  String get enterInformation => 'أدخل بياناتك';

  @override
  String get idNumber => 'الرقم الوطني';

  @override
  String get password => 'كلمة المرور';

  @override
  String get pleaseEnterId => 'يرجى إدخال الرقم الوطني';

  @override
  String get idTooShort => 'الرقم الوطني قصير جداً';

  @override
  String get pleaseEnterPassword => 'يرجى إدخال كلمة المرور';

  @override
  String get passwordTooShort => 'يجب ألا تقل كلمة المرور عن 6 أحرف';

  @override
  String get loggingIn => 'جارٍ تسجيل الدخول...';

  @override
  String get createAccount => 'إنشاء حساب';

  @override
  String accountWrongRole(Object role) {
    return 'هذا الحساب غير مسجل بصفة $role';
  }

  @override
  String get doctorRole => 'طبيب';

  @override
  String get patientRole => 'مريض';

  @override
  String welcomeUser(String name) {
    return 'مرحباً، $name';
  }

  @override
  String get confirmLogout => 'هل أنت متأكد أنك تريد تسجيل الخروج من MedChain؟';

  @override
  String get cancel => 'إلغاء';

  @override
  String welcome(String name) {
    return 'مرحباً، $name';
  }

  @override
  String get patientSection => 'المريض';

  @override
  String get doctorSection => 'الطبيب';

  @override
  String get administrator => 'المدير';

  @override
  String get myMedicalRecords => 'سجلاتي الطبية';

  @override
  String get permissionRequests => 'طلبات الصلاحيات';

  @override
  String get myPatients => 'مرضاي';

  @override
  String get requestPatientAccess => 'طلب الوصول إلى بيانات المريض';

  @override
  String get manageUsers => 'إدارة المستخدمين';

  @override
  String get manageUsersDescription => 'عرض المستخدمين المسجلين وإدارتهم';

  @override
  String get loginAgainAdmin => 'يرجى تسجيل الدخول مجدداً للوصول إلى الإدارة.';

  @override
  String get adminUsersTitle => 'إدارة المستخدمين';

  @override
  String get refreshUsers => 'تحديث المستخدمين';

  @override
  String get retry => 'إعادة المحاولة';

  @override
  String get noUsersFound => 'لم يتم العثور على مستخدمين.';

  @override
  String get searchUsersHint => 'ابحث بالاسم أو الرقم الوطني أو الهاتف';

  @override
  String get clearSearch => 'مسح البحث';

  @override
  String get filterByRole => 'تصفية حسب الدور';

  @override
  String get allUsers => 'جميع المستخدمين';

  @override
  String get patients => 'المرضى';

  @override
  String get doctors => 'الأطباء';

  @override
  String get admins => 'المديرون';

  @override
  String showingUsers(String filtered, String total) {
    return 'عرض $filtered من أصل $total مستخدم';
  }

  @override
  String get noMatchingUsers => 'لا توجد مستخدمون مطابقون للبحث.';

  @override
  String get unknownUser => 'غير معروف';

  @override
  String userIdLabel(String id) {
    return 'رقم المستخدم: $id';
  }

  @override
  String nationalIdLabel(String id) {
    return 'الرقم الوطني: $id';
  }

  @override
  String phoneLabel(String phone) {
    return 'الهاتف: $phone';
  }

  @override
  String rolesLabel(String roles) {
    return 'الأدوار: $roles';
  }

  @override
  String get none => 'لا يوجد';

  @override
  String get processing => 'جارٍ التنفيذ...';

  @override
  String get grantAdminAccess => 'منح صلاحيات المدير';

  @override
  String get removeAdminAccess => 'إزالة صلاحيات المدير';

  @override
  String get grantAdminConfirmTitle => 'هل تريد منح صلاحيات المدير؟';

  @override
  String get removeAdminConfirmTitle => 'هل تريد إزالة صلاحيات المدير؟';

  @override
  String grantAdminConfirmMessage(String name) {
    return 'هل تريد منح $name صلاحية إدارة المستخدمين؟';
  }

  @override
  String removeAdminConfirmMessage(String name) {
    return 'هل تريد إزالة صلاحيات الإدارة من $name؟';
  }

  @override
  String get grantAccess => 'منح الصلاحية';

  @override
  String get removeAccess => 'إزالة الصلاحية';

  @override
  String get adminGrantedSuccess => 'تم منح صلاحيات المدير بنجاح';

  @override
  String get adminRemovedSuccess => 'تمت إزالة صلاحيات المدير بنجاح';

  @override
  String get invalidUserId => 'رقم المستخدم غير صالح';

  @override
  String get patientProfile => 'المريض';

  @override
  String get doctorProfile => 'الطبيب';

  @override
  String removeProfileTitle(String role) {
    return 'إزالة ملف $role؟';
  }

  @override
  String removeProfileMessage(String role, String name) {
    return 'هل تريد إزالة ملف $role الخاص بالمستخدم $name؟ سيظل حساب المستخدم موجوداً.';
  }

  @override
  String get removeProfile => 'إزالة الملف';

  @override
  String profileRemovedSuccess(String role) {
    return 'تمت إزالة ملف $role بنجاح';
  }

  @override
  String get deleteAccountTitle => 'حذف الحساب نهائياً؟';

  @override
  String deleteAccountMessage(String name) {
    return 'هل تريد حذف حساب $name بالكامل، بما في ذلك سجلات قاعدة بيانات SQL المرتبطة به؟ لا يمكن التراجع عن هذا الإجراء. ستظل النسخ المخزنة مسبقاً على البلوك تشين أو IPFS موجودة.';
  }

  @override
  String get deleteAccount => 'حذف الحساب';

  @override
  String get accountDeletedSuccess => 'تم حذف الحساب بنجاح';

  @override
  String get forgotPassword => 'نسيت كلمة المرور؟';

  @override
  String get phoneTooShort => 'رقم الهاتف قصير جدًا.';

  @override
  String get pleaseEnterPhone => 'يرجى إدخال رقم الهاتف.';

  @override
  String get enterPhoneForReset => 'أدخل رقم هاتفك لاستعادة كلمة المرور.';

  @override
  String get phoneNumber => 'رقم الهاتف';

  @override
  String get continueButton => 'متابعة';

  @override
  String get resetNotConnected =>
      'استعادة كلمة المرور غير متصلة بالخادم حتى الآن.';

  @override
  String get phoneNumberTooShortMessage =>
      'يجب أن يحتوي رقم الهاتف على 9 أرقام على الأقل.';

  @override
  String get profileTitle => 'ملفي الشخصي';

  @override
  String get refreshProfile => 'تحديث الملف الشخصي';

  @override
  String get editProfile => 'تعديل الملف الشخصي';

  @override
  String get loadProfileError => 'تعذر تحميل ملفك الشخصي.';

  @override
  String get tryAgain => 'حاول مرة أخرى';

  @override
  String get chooseProfilePicture => 'اختيار الصورة الشخصية';

  @override
  String get newPictureSelected => 'تم اختيار صورة جديدة';

  @override
  String get uploading => 'جارٍ رفع الصورة...';

  @override
  String get savePicture => 'حفظ الصورة';

  @override
  String get profilePictureUpdated => 'تم تحديث الصورة الشخصية بنجاح.';

  @override
  String get selectValidImage => 'يرجى اختيار صورة بصيغة JPG أو JPEG أو PNG.';

  @override
  String get imageFileNotFound => 'تعذر العثور على ملف الصورة المحدد.';

  @override
  String get imageSizeLimit => 'يجب ألا يتجاوز حجم الصورة 5 ميجابايت.';

  @override
  String get selectImageFirst => 'يرجى اختيار صورة أولاً.';

  @override
  String get allowedImageTypes => 'يُسمح فقط بالصور بصيغة JPG أو JPEG أو PNG.';

  @override
  String imageSelectionFailed(String error) {
    return 'تعذر اختيار الصورة: $error';
  }

  @override
  String imageUploadFailed(String error) {
    return 'فشل رفع الصورة: $error';
  }

  @override
  String get personalInformation => 'المعلومات الشخصية';

  @override
  String get fullNameLabel => 'الاسم الكامل';

  @override
  String get phoneNumberLabel => 'رقم الهاتف';

  @override
  String get nationalIdLabelProfile => 'الرقم الوطني';

  @override
  String get specializationLabel => 'التخصص';

  @override
  String get licenseNumberLabel => 'رقم الترخيص';

  @override
  String get notAvailable => 'غير متوفر';

  @override
  String get fullNameRequired => 'الاسم الكامل مطلوب';

  @override
  String get phoneNumberRequired => 'رقم الهاتف مطلوب';

  @override
  String get accountRoles => 'أدوار الحساب';

  @override
  String get noRolesAssigned => 'لم يتم تعيين أدوار';

  @override
  String get profileUpdatedSuccess => 'تم تحديث الملف الشخصي بنجاح.';

  @override
  String uploadImageFailedStatus(String statusCode) {
    return 'فشل رفع الصورة (رمز الحالة: $statusCode).';
  }

  @override
  String get profileUpdateFailed => 'فشل تحديث الملف الشخصي.';

  @override
  String get profileSaveFailed => 'فشل حفظ الملف الشخصي.';

  @override
  String get saving => 'جارٍ الحفظ...';

  @override
  String get saveChanges => 'حفظ التغييرات';
}
