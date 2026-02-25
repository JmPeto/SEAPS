import 'package:flutter/material.dart';
import 'theme.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  String selectedRole = "Employee";
  bool isLoading = false;
  bool obscurePassword = true;

  final List<String> roles = ["Employee", "Admin"];

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  void login() {
    if (emailController.text.isEmpty || passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill in all fields")),
      );
      return;
    }

    setState(() => isLoading = true);

    // Simulate login delay
    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted) return;
      setState(() => isLoading = false);

      // Route based on role
      if (selectedRole == "Admin") {
        Navigator.of(context).pushReplacementNamed('/admin');
      } else {
        Navigator.of(context).pushReplacementNamed('/employee');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppTheme.primaryColor,
              AppTheme.primaryColor.withOpacity(0.8),
            ],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppTheme.paddingXLarge),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                /// Logo / Title
                const SizedBox(height: 40),
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Icon(
                    Icons.business,
                    size: 50,
                    color: AppTheme.primaryColor,
                  ),
                ),
                const SizedBox(height: AppTheme.spacingXLarge),
                const Text(
                  "SEAPS",
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: AppTheme.spacingSmall),
                const Text(
                  "Employee Attendance & Payroll System",
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white70,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: AppTheme.spacingXLarge * 2),

                /// Login Card
                Container(
                  padding: const EdgeInsets.all(AppTheme.paddingXLarge),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(AppTheme.borderRadiusLarge),
                    boxShadow: AppTheme.cardShadow,
                  ),
                  child: Column(
                    children: [
                      /// Role Selection
                      Container(
                        padding: const EdgeInsets.all(AppTheme.paddingMedium),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: GestureDetector(
                                onTap: () => setState(() => selectedRole = "Employee"),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: AppTheme.paddingMedium,
                                  ),
                                  decoration: BoxDecoration(
                                    color: selectedRole == "Employee"
                                        ? AppTheme.primaryColor
                                        : Colors.transparent,
                                    borderRadius: BorderRadius.circular(
                                      AppTheme.borderRadiusMedium,
                                    ),
                                  ),
                                  child: Text(
                                    "Employee",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: selectedRole == "Employee"
                                          ? Colors.white
                                          : Colors.black,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: AppTheme.spacingMedium),
                            Expanded(
                              child: GestureDetector(
                                onTap: () => setState(() => selectedRole = "Admin"),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: AppTheme.paddingMedium,
                                  ),
                                  decoration: BoxDecoration(
                                    color: selectedRole == "Admin"
                                        ? AppTheme.primaryColor
                                        : Colors.transparent,
                                    borderRadius: BorderRadius.circular(
                                      AppTheme.borderRadiusMedium,
                                    ),
                                  ),
                                  child: Text(
                                    "Admin",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: selectedRole == "Admin"
                                          ? Colors.white
                                          : Colors.black,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: AppTheme.spacingXLarge),

                      /// Email Field
                      TextField(
                        controller: emailController,
                        decoration: AppTheme.getInputDecoration("Email").copyWith(
                          prefixIcon: const Icon(Icons.email),
                        ),
                        keyboardType: TextInputType.emailAddress,
                      ),

                      const SizedBox(height: AppTheme.spacingLarge),

                      /// Password Field
                      TextField(
                        controller: passwordController,
                        decoration: AppTheme.getInputDecoration("Password").copyWith(
                          prefixIcon: const Icon(Icons.lock),
                          suffixIcon: IconButton(
                            icon: Icon(
                              obscurePassword
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                            ),
                            onPressed: () {
                              setState(
                                () => obscurePassword = !obscurePassword,
                              );
                            },
                          ),
                        ),
                        obscureText: obscurePassword,
                      ),

                      const SizedBox(height: AppTheme.spacingXLarge),

                      /// Login Button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: isLoading ? null : login,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primaryColor,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              vertical: AppTheme.paddingLarge,
                            ),
                          ),
                          child: isLoading
                              ? const SizedBox(
                                  height: 24,
                                  width: 24,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 3,
                                    valueColor: AlwaysStoppedAnimation(
                                      Colors.white,
                                    ),
                                  ),
                                )
                              : const Text(
                                  "Login",
                                  style: TextStyle(fontSize: 16),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: AppTheme.spacingXLarge),

                /// Footer
                const Text(
                  "Demo Credentials:\nEmployee: emp@example.com | admin: admin@example.com | Password: demo123",
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
