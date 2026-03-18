import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'auth_controller.dart';

class AuthView extends GetView<AuthController> {
  const AuthView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Halo Social')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Obx(() {
              final isLogin = controller.isLoginMode.value;
              return ListView(
                shrinkWrap: true,
                children: [
                  Text(
                    isLogin ? '欢迎回来' : '创建账号',
                    style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    isLogin ? '登录后继续浏览你的时间线。' : '注册后即可发布动态、评论与互动。',
                    style: const TextStyle(color: Color(0xFF71767B)),
                  ),
                  const SizedBox(height: 18),
                  if (!isLogin) ...[
                    TextField(
                      controller: controller.nameController,
                      decoration: const InputDecoration(labelText: '昵称'),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: controller.handleController,
                      decoration: const InputDecoration(labelText: '账号（如 @halo）'),
                    ),
                    const SizedBox(height: 12),
                  ],
                  TextField(
                    controller: controller.emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(labelText: '邮箱'),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: controller.passwordController,
                    obscureText: true,
                    decoration: const InputDecoration(labelText: '密码'),
                  ),
                  const SizedBox(height: 20),
                  FilledButton(
                    onPressed: controller.isSubmitting.value ? null : controller.submit,
                    child: controller.isSubmitting.value
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text(isLogin ? '登录' : '注册'),
                  ),
                  const SizedBox(height: 10),
                  TextButton(
                    onPressed: controller.toggleMode,
                    child: Text(isLogin ? '没有账号？去注册' : '已有账号？去登录'),
                  ),
                  if (isLogin) ...[
                    const SizedBox(height: 8),
                    const Text(
                      '演示账号：halo@example.com / 123456',
                      style: TextStyle(color: Color(0xFF71767B), fontSize: 12),
                    ),
                  ],
                ],
              );
            }),
          ),
        ),
      ),
    );
  }
}
