import 'package:flutter/material.dart';
import 'package:smart_transist_guardian/constants/validators.dart';
import 'package:smart_transist_guardian/ui/views/login/login_view.form.dart';

import 'package:smart_transist_guardian/widget/custom_button.dart';

import 'package:stacked/stacked.dart';
import 'package:stacked/stacked_annotations.dart';
import 'login_viewmodel.dart';

@FormView(fields: [
  FormTextField(
    name: 'email',
    validator: FormValidators.validateEmail, // Email validator
  ),
  FormTextField(
    name: 'password',
    validator: FormValidators.validatePassword, // Password validator
  ),
])
class LoginView extends StackedView<LoginViewModel> with $LoginView {
  LoginView({Key? key}) : super(key: key);

  @override
  Widget builder(
    BuildContext context,
    LoginViewModel viewModel,
    Widget? child,
  ) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: const Text('Login'),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Image.asset(
                  'assets/logo.png', // Ensure the image is available
                  height: 350,
                ),
              ),
              Form(
                autovalidateMode: AutovalidateMode
                    .always, // Trigger validation immediately when page loads
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      const SizedBox(height: 30),
                      ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 350),
                        child: TextField(
                          autofocus: true,
                          decoration: InputDecoration(
                            labelText: 'Email',
                            errorText: viewModel
                                .emailValidationMessage, // Display validation message
                            errorMaxLines: 2,
                          ),
                          controller: emailController,
                          keyboardType: TextInputType.emailAddress,
                          focusNode: emailFocusNode,
                        ),
                      ),
                      const SizedBox(height: 20),
                      ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 350),
                        child: TextField(
                          decoration: InputDecoration(
                            labelText: 'Password',
                            errorText: viewModel
                                .passwordValidationMessage, // Display validation message
                            errorMaxLines: 2,
                          ),
                          controller: passwordController,
                          obscureText: true,
                          focusNode: passwordFocusNode,
                        ),
                      ),
                      const SizedBox(height: 20),
                      CustomButton(
                        onTap: viewModel.authenticateUser,
                        text: 'Login',
                        isLoading: viewModel.isBusy,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  LoginViewModel viewModelBuilder(BuildContext context) => LoginViewModel();

  @override
  void onViewModelReady(LoginViewModel viewModel) {
    syncFormWithViewModel(viewModel); // Sync form with view model
  }

  @override
  void onDispose(LoginViewModel viewModel) {
    super.onDispose(viewModel);
    disposeForm(); // Dispose of form controllers properly
  }
}
