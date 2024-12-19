import 'package:smart_transist_guardian/services/database_service.dart';
import 'package:smart_transist_guardian/services/firestore_service.dart';
import 'package:smart_transist_guardian/services/user_service.dart';
import 'package:smart_transist_guardian/ui/bottom_sheets/notice/notice_sheet.dart';
import 'package:smart_transist_guardian/ui/dialogs/info_alert/info_alert_dialog.dart';
import 'package:smart_transist_guardian/ui/views/controlroom/controlroom_view.dart';
import 'package:smart_transist_guardian/ui/views/emergencyvehicle/emergencyvehicle_view.dart';

import 'package:smart_transist_guardian/ui/views/home/home_view.dart';
import 'package:smart_transist_guardian/ui/views/startup/startup_view.dart';
import 'package:smart_transist_guardian/ui/views/user/user_view.dart';

import 'package:stacked/stacked_annotations.dart';
import 'package:stacked_firebase_auth/stacked_firebase_auth.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:smart_transist_guardian/ui/views/login_register/login_register_view.dart';
import 'package:smart_transist_guardian/ui/views/login/login_view.dart';
import 'package:smart_transist_guardian/ui/views/register/register_view.dart';

@StackedApp(
  routes: [
    MaterialRoute(page: HomeView),
    MaterialRoute(page: StartupView),
    MaterialRoute(page: LoginRegisterView),
    MaterialRoute(page: LoginView),
    MaterialRoute(page: RegisterView),

    MaterialRoute(page: UserView),
    MaterialRoute(page: EmergencyVehicleView),
    MaterialRoute(page: ControlRoomView),
// @stacked-route
  ],
  dependencies: [
    LazySingleton(classType: BottomSheetService),
    LazySingleton(classType: DialogService),
    LazySingleton(classType: NavigationService),
    LazySingleton(classType: FirebaseAuthenticationService),
    LazySingleton(classType: FirestoreService),
    LazySingleton(classType: SnackbarService),
    LazySingleton(classType: UserService),
    LazySingleton(classType: DatabaseService),

// @stacked-service
  ],
  bottomsheets: [
    StackedBottomsheet(classType: NoticeSheet),
    // @stacked-bottom-sheet
  ],
  dialogs: [
    StackedDialog(classType: InfoAlertDialog),
    // @stacked-dialog
  ],
  logger: StackedLogger(),
)
class App {}
