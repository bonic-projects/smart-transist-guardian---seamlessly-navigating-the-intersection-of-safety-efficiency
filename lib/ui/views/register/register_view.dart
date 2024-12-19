import 'package:flutter/material.dart';
import 'package:smart_transist_guardian/constants/validators.dart';
import 'package:smart_transist_guardian/ui/views/register/register_view.form.dart';
import 'package:smart_transist_guardian/widget/custom_button.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked/stacked_annotations.dart';
import 'register_viewmodel.dart';

@FormView(fields: [
  FormTextField(
    name: 'name',
    validator: FormValidators.validateText, // Name validator
  ),
  FormDropdownField(
    name: 'userRole',
    items: [
      StaticDropdownItem(
        title: 'User',
        value: 'User',
      ),
      StaticDropdownItem(
        title: 'Emergency Vehicle',
        value: 'Emergency Vehicle',
      ),
      StaticDropdownItem(
        title: 'Control Room',
        value: 'Control Room',
      ),
    ],
  ),
  FormTextField(
    name: 'email',
    validator: FormValidators.validateEmail, // Email validator
  ),
  FormTextField(
    name: 'password',
    validator: FormValidators.validatePassword, // Password validator
  ),
])
class RegisterView extends StackedView<RegisterViewModel> with $RegisterView {
  RegisterView({Key? key}) : super(key: key);

  @override
  Widget builder(
    BuildContext context,
    RegisterViewModel viewModel,
    Widget? child,
  ) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: const Text('Register'),
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
                            labelText: 'Full name',
                            errorText: viewModel
                                .nameValidationMessage, // Display validation message
                            errorMaxLines: 2,
                          ),
                          controller: nameController,
                          keyboardType: TextInputType.name,
                          focusNode: nameFocusNode,
                        ),
                      ),
                      const SizedBox(height: 20),
                      ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 350),
                        child: TextField(
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

                      // Dropdown to select user role (User, Emergency Vehicle, Control Room)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text('Select user role:'),
                          const SizedBox(width: 15),
                          DropdownButton<String>(
                            key: const ValueKey('dropdownField'),
                            value: viewModel.userRoleValue,
                            onChanged: (value) {
                              viewModel.setUserRole(value!);
                            },
                            items: const [
                              DropdownMenuItem(
                                value: 'User',
                                child: Text('User'),
                              ),
                              DropdownMenuItem(
                                value: 'Emergency Vehicle',
                                child: Text('Emergency Vehicle'),
                              ),
                              DropdownMenuItem(
                                value: 'Control Room',
                                child: Text('Control Room'),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Show additional fields based on selected role if needed

                      const SizedBox(height: 30),
                      CustomButton(
                        onTap: viewModel.registerUser,
                        text: 'Register',
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
  RegisterViewModel viewModelBuilder(BuildContext context) =>
      RegisterViewModel();

  @override
  void onViewModelReady(RegisterViewModel viewModel) {
    syncFormWithViewModel(viewModel); // Sync form with view model
  }

  @override
  void onDispose(RegisterViewModel viewModel) {
    super.onDispose(viewModel);
    disposeForm(); // Dispose of form controllers properly
  }
}
