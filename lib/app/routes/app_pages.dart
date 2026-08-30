import 'package:get/get.dart';
import 'package:science_craft/app/modules/FAQ/bindings/faq_binding.dart';
import 'package:science_craft/app/modules/FAQ/views/faq_view.dart';
import 'package:science_craft/app/modules/notification/views/notification_view.dart';
import 'package:science_craft/app/modules/on_boarding/views/on_boarding_view.dart';
import 'package:science_craft/app/modules/learning/bindings/learning_binding.dart';
import '../modules/login/bindings/login_binding.dart';
import '../modules/login/views/login_view.dart';
import '../modules/register/bindings/register_binding.dart';
import '../modules/register/views/register_view.dart';
import '../modules/password_recovery/bindings/password_recovery_binding.dart';
import '../modules/password_recovery/views/forgot_password_view.dart';
import '../modules/password_recovery/views/otp_verification_view.dart';
import '../modules/password_recovery/views/reset_password_view.dart';
import '../modules/dashboard/bindings/dashboard_binding.dart';
import '../modules/dashboard/views/dashboard_view.dart';
import '../modules/profile/bindings/profile_binding.dart';
import '../modules/profile/views/profile_view.dart';
import '../modules/root/bindings/root_binding.dart';
import '../modules/root/views/root_view.dart';
import '../modules/materi/bindings/materi_binding.dart';
import '../modules/materi/views/materi_view.dart';
import '../modules/materi/bindings/material_list_binding.dart';
import '../modules/materi/views/material_list_view.dart';
import '../modules/notification/bindings/notification_binding.dart';
import '../modules/about/bindings/about_binding.dart';
import '../modules/about/views/about_view.dart';
import '../modules/edit_profile_learning/bindings/edit_profile_learning_binding.dart';
import '../modules/edit_profile_learning/views/edit_profile_learning_view.dart';
import '../modules/chatbot/views/chatbot_view.dart';
import '../modules/chatbot/bindings/chatbot_binding.dart';
import '../modules/roadmap/bindings/roadmap_binding.dart';
import '../modules/roadmap/views/roadmap_view.dart';
import '../modules/admin/bindings/admin_binding.dart';
import '../modules/admin/views/admin_view.dart';
import '../modules/lab/bindings/lab_binding.dart';
import '../modules/lab/views/lab_view.dart';
import '../modules/lab/views/simulation_view.dart';
import '../modules/learning/views/learning_view.dart';
import '../modules/admin_learning/bindings/admin_learning_binding.dart';
import '../modules/admin_learning/views/admin_learning_view.dart';

part 'app_routes.dart';

class AppPages {
  AppPages._();

  // Atur halaman awal ke ROOT untuk development, atau LOGIN untuk produksi
  static const INITIAL = Routes.LOGIN; 

  static final routes = [
    GetPage(
      name: _Paths.LOGIN,
      page: () => const LoginView(),
      binding: LoginBinding(),
    ),
    GetPage(
      name: _Paths.REGISTER,
      page: () => const RegisterView(),
      binding: RegisterBinding(),
    ),

    GetPage(
      name: _Paths.FORGOT_PASSWORD,
      page: () => const ForgotPasswordView(),
      binding: PasswordRecoveryBinding(), 
    ),

    GetPage(
      name: _Paths.OTP_VERIFICATION,
      page: () => const OtpVerificationView(),
      binding: PasswordRecoveryBinding(),
    ),

    GetPage(
      name: _Paths.RESET_PASSWORD,
      page: () => const ResetPasswordView(),
      binding: PasswordRecoveryBinding(),
    ),
    
    // Ini adalah "rumah" utama aplikasi setelah login
    GetPage(
      name: _Paths.ROOT,
      page: () => const RootView(),
      binding: RootBinding(),
    ),

    // Halaman detail materi
     GetPage(
      name: _Paths.MATERIAL_DETAIL,
      page: () => const MaterialDetailView(),
      binding: MaterialDetailBinding(),
    ),

    // GetPage(
    //   name: _Paths.QUIZ,
    //   page: () => LearningQuizView(
    //     materialId: Get.arguments['materialId'],
    //     moduleTitle: Get.arguments['moduleTitle'],
    //   ),
    //   binding: LearningBinding(),
    // ),
    // GetPage untuk halaman lain yang mungkin masih dibutuhkan
    GetPage(
      name: _Paths.DASHBOARD,
      page: () => const DashboardView(),
      binding: DashboardBinding(),
    ),
    GetPage(
      name: _Paths.MATERIAL_LIST,
      page: () => const MaterialListView(),
      binding: MaterialListBinding(),
    ),
     GetPage(
      name: _Paths.PROFILE,
      page: () => const ProfileView(),
      binding: ProfileBinding(),
    ),
    GetPage(
      name: _Paths.NOTIFICATION,
      page: () => const NotificationView(),
      binding: NotificationBinding(),
    ),
    GetPage(
      name: _Paths.ABOUT,
      page: () => const AboutAppView(),
      binding: AboutAppBinding(),
    ),
    GetPage(
      name: _Paths.FAQ,
      page: () => const FaqView(),
      binding: FaqBinding(),
    ),
    GetPage(
      name: _Paths.EDITPROFILE,
      page: () => const EditProfileLearningView(),
      binding: EditProfileLearningBinding(),
    ),
    GetPage(
      name: _Paths.ROADMAP,
      page: () => const LevelRoadmapView(),
      binding: LevelRoadmapBinding(),
    ),
    GetPage(
      name: _Paths.CHATBOT,
      page: () => const ChatbotView(),
      binding: ChatbotBinding(),
    ),
    GetPage(
      name: _Paths.ONBOARDING,
      page: () => OnboardingView(),
      // Kita tidak perlu binding khusus karena sudah pakai Get.put di View
    ),
    GetPage(
      name: _Paths.ADMIN,
      page: () => AdminView(),
      binding: AdminBinding(),
    ),

    GetPage(
      name: _Paths.ADMIN_LEARNING,
      page: () => const AdminLearningView(),
      binding: AdminLearningBinding(),
    ),
    GetPage(
      name: _Paths.LAB, // atau rute Simulation kamu
      page: () => LabView(),
      binding: LabBinding(), // <--- JANGAN LUPA INI
    ),
// Kalau SimulationView punya rute sendiri:
    GetPage(
      name: _Paths.SIMULATION,
      page: () => SimulationView(),
      binding: LabBinding(),
    ),
    GetPage(
      name: _Paths.LEARNING,
      page: () => const LearningView(),
      binding: LearningBinding(),
    ),
  ];
}

