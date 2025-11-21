part of 'app_pages.dart';

abstract class Routes {
  Routes._();
  static const LOGIN = _Paths.LOGIN;
  static const REGISTER = _Paths.REGISTER;
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
}

abstract class _Paths {
  _Paths._();
  static const LOGIN = '/login';
  static const REGISTER = '/register';
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
  }
// Tambahkan path untuk dashboard
