<template>
  <div class="login-page">
    <el-card class="login-card" shadow="hover">
      <template #header>
        <span>后台登录</span>
      </template>

      <el-form ref="formRef" :model="form" :rules="rules" label-position="top">
        <el-form-item label="用户名" prop="username">
          <el-input v-model="form.username" placeholder="请输入管理员用户名" />
        </el-form-item>
        <el-form-item label="密码" prop="password">
          <el-input v-model="form.password" type="password" show-password placeholder="请输入管理员密码" />
        </el-form-item>
        <el-button type="primary" :loading="loading" class="login-btn" @click="handleLogin">登录</el-button>
      </el-form>

      <p class="hint">默认账号：admin / admin123456</p>
    </el-card>
  </div>
</template>

<script setup>
import { reactive, ref } from 'vue';
import { ElMessage } from 'element-plus';
import { useRouter } from 'vue-router';

import { useAdminAuthStore } from '../stores/adminAuth';

const router = useRouter();
const authStore = useAdminAuthStore();
const formRef = ref();
const loading = ref(false);

const form = reactive({
  username: 'admin',
  password: 'admin123456'
});

const rules = {
  username: [{ required: true, message: '请输入用户名', trigger: 'blur' }],
  password: [{ required: true, message: '请输入密码', trigger: 'blur' }]
};

async function handleLogin() {
  const valid = await formRef.value.validate().catch(() => false);
  if (!valid) {
    return;
  }

  loading.value = true;
  try {
    await authStore.login(form);
    ElMessage.success('登录成功');
    router.push('/');
  } catch (error) {
    ElMessage.error(error.response?.data?.message || '登录失败');
  } finally {
    loading.value = false;
  }
}
</script>

<style scoped lang="less">
.login-page {
  min-height: 100%;
  display: flex;
  align-items: center;
  justify-content: center;
  background: linear-gradient(120deg, #e0ecff, #f8fbff);

  .login-card {
    width: 420px;
  }

  .login-btn {
    width: 100%;
    margin-top: 12px;
  }

  .hint {
    margin-top: 12px;
    color: #909399;
    font-size: 12px;
    text-align: center;
  }
}
</style>
