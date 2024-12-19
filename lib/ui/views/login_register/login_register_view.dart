import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:smart_transist_guardian/ui/views/login_register/login_register_viewmodel.dart';

import 'package:smart_transist_guardian/widget/login_register.dart';

import 'package:stacked/stacked.dart';

class LoginRegisterView extends StackedView<LoginRegisterViewModel> {
  const LoginRegisterView({Key? key}) : super(key: key);

  @override
  Widget builder(
    BuildContext context,
    LoginRegisterViewModel viewModel,
    Widget? child,
  ) {
    return Scaffold(
        backgroundColor: Theme.of(context).colorScheme.background,
        body: SingleChildScrollView(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 10, right: 15),
                  child: Image.asset(
                    'assets/logo.png',
                    height: 500,
                  ),
                ),
                LoginRegisterWidget(
                  onLogin: viewModel.openLoginView,
                  onRegister: viewModel.openRegisterView,
                  loginText: "",
                  registerText: "",
                ),
              ],
            ),
          ),
        ));
  }

  @override
  LoginRegisterViewModel viewModelBuilder(
    BuildContext context,
  ) =>
      LoginRegisterViewModel();
}
