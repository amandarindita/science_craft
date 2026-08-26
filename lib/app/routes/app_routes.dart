part of 'app_pages.dart';

abstract class Routes {
  Routes._();
  static const LOGIN = _Paths.LOGIN;
  static const REGISTER = _Paths.REGISTER;
  static const FORGOT_PASSWORD = _Paths.FORGOT_PASSWORD;
  static const OTP_VERIFICATION = _Paths.OTP_VERIFICATION;
  static const RESET_PASSWORD = _Paths.RESET_PASSWORD;
  static const DASHBOARD = _Paths.DASHBOARD;
  static const MATERIAL_LIST = _Paths.MATERIAL_LIST; 
  static const ROOT = _Paths.ROOT;
  static const PROFILE = _Paths.PROFILE;
  static const MATERIAL_DETAIL = _Paths.MATERIAL_DETAIL;
  static const NOTIFICATION = _Paths.NOTIFICATION;
  static const ABOUT = _Paths.ABOUT;
  static const FAQ = _Paths.FAQ;
  static const EDITPROFILE = _Paths.EDITPROFILE;
  static const QUIZ = _Paths.QUIZ;
  static const CHATBOT = _Paths.CHATBOT; 
  static const ROADMAP = _Paths.ROADMAP;
  static const ONBOARDING = _Paths.ONBOARDING;
  static const ADMIN = _Paths.ADMIN;
  static const LAB = _Paths.LAB;
  static const SIMULATION = _Paths.SIMULATION;
  static const LEARNING = _Paths.LEARNING;
  static const ADMIN_LEARNING =_Paths.ADMIN_LEARNING;
  
}

abstract class _Paths {
  _Paths._();
  static const LOGIN = '/login';
  static const REGISTER = '/register';
  static const FORGOT_PASSWORD = '/forgot-password';
  static const OTP_VERIFICATION = '/otp-verification';
  static const RESET_PASSWORD = '/reset-password';
  static const DASHBOARD = '/dashboard'; 
  static const MATERIAL_LIST = '/material-list';
  static const ROOT = '/root';
  static const PROFILE = '/profile';
  static const MATERIAL_DETAIL = '/material-detail/-:id';
  static const NOTIFICATION = '/notification';
  static const ABOUT = '/about';
  static const FAQ = '/faq';
  static const EDITPROFILE = '/edit-profile';
  static const QUIZ = '/quiz/:id';
  static const CHATBOT = '/chatbot';
  static const ROADMAP = '/roadmap';
  static const ONBOARDING = '/onboarding'; 
  static const ADMIN = '/admin'; 
  static const LAB = '/lab';
  static const SIMULATION = '/simulation';
  static const LEARNING = '/learning';
  static const ADMIN_LEARNING ='/admin-learning';
  }
// Tambahkan path untuk dashboard
