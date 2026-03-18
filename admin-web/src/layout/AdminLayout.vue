<template>
  <el-container class="admin-layout">
    <el-header class="admin-header">
      <div class="brand">Halo 后台管理系统</div>
      <div class="right-actions">
        <span class="username">管理员：{{ authStore.username }}</span>
        <el-button type="danger" plain size="small" @click="handleLogout">退出登录</el-button>
      </div>
    </el-header>
    <el-main class="admin-main">
      <router-view />
    </el-main>
  </el-container>
</template>

<script setup>
import { ElMessage } from 'element-plus';
import { useRouter } from 'vue-router';

import { useAdminAuthStore } from '../stores/adminAuth';

const router = useRouter();
const authStore = useAdminAuthStore();

async function handleLogout() {
  await authStore.logout();
  ElMessage.success('已退出登录');
  router.push('/login');
}
</script>

<style scoped lang="less">
.admin-layout {
  min-height: 100%;
}

.admin-header {
  display: flex;
  align-items: center;
  justify-content: space-between;
  border-bottom: 1px solid #ebeef5;
  background-color: #fff;

  .brand {
    font-weight: 700;
    color: #303133;
  }

  .right-actions {
    display: flex;
    align-items: center;
    gap: 12px;

    .username {
      font-size: 14px;
      color: #606266;
    }
  }
}

.admin-main {
  padding: 20px;
}
</style>
