<template>
  <section>
    <el-row :gutter="16" class="summary-row">
      <el-col :span="8">
        <el-card>
          <div class="summary-title">用户总数</div>
          <div class="summary-value">{{ stats.users }}</div>
        </el-card>
      </el-col>
      <el-col :span="8">
        <el-card>
          <div class="summary-title">推文总数</div>
          <div class="summary-value">{{ stats.tweets }}</div>
        </el-card>
      </el-col>
      <el-col :span="8">
        <el-card>
          <div class="summary-title">评论总数</div>
          <div class="summary-value">{{ stats.comments }}</div>
        </el-card>
      </el-col>
    </el-row>

    <el-card>
      <template #header>
        <div class="table-header">
          <span>推文管理</span>
          <div class="table-actions">
            <el-input v-model="keyword" placeholder="搜索内容 / 用户" clearable style="width: 220px" @keyup.enter="refresh" />
            <el-button type="primary" @click="refresh">查询</el-button>
          </div>
        </div>
      </template>

      <el-table :data="tweetList" v-loading="loading" border>
        <el-table-column prop="authorName" label="作者" width="160" />
        <el-table-column prop="authorHandle" label="账号" width="160" />
        <el-table-column prop="content" label="内容" min-width="420" />
        <el-table-column prop="createdAt" label="发布时间" width="180" />
        <el-table-column label="操作" width="120" fixed="right">
          <template #default="{ row }">
            <el-popconfirm title="确认删除这条推文吗？" @confirm="handleDelete(row.id)">
              <template #reference>
                <el-button type="danger" text>删除</el-button>
              </template>
            </el-popconfirm>
          </template>
        </el-table-column>
      </el-table>

      <el-pagination
        class="pagination"
        background
        layout="total, prev, pager, next"
        :current-page="pagination.page"
        :page-size="pagination.pageSize"
        :total="pagination.total"
        @current-change="handlePageChange"
      />
    </el-card>
  </section>
</template>

<script setup>
import { onMounted, reactive, ref } from 'vue';
import { ElMessage } from 'element-plus';

import http from '../api/http';

const loading = ref(false);
const keyword = ref('');
const tweetList = ref([]);
const stats = reactive({
  users: 0,
  tweets: 0,
  comments: 0
});
const pagination = reactive({
  page: 1,
  pageSize: 10,
  total: 0
});

async function fetchDashboard() {
  const { data } = await http.get('/admin/dashboard');
  stats.users = data.counts.users;
  stats.tweets = data.counts.tweets;
  stats.comments = data.counts.comments;
}

async function fetchTweets() {
  const { data } = await http.get('/admin/tweets', {
    params: {
      keyword: keyword.value,
      page: pagination.page,
      pageSize: pagination.pageSize
    }
  });
  tweetList.value = data.list;
  pagination.total = data.pagination.total;
}

async function refresh() {
  loading.value = true;
  try {
    await Promise.all([fetchDashboard(), fetchTweets()]);
  } catch (error) {
    ElMessage.error(error.response?.data?.message || '加载失败');
  } finally {
    loading.value = false;
  }
}

async function handleDelete(id) {
  try {
    await http.delete(`/admin/tweets/${id}`);
    ElMessage.success('删除成功');
    await refresh();
  } catch (error) {
    ElMessage.error(error.response?.data?.message || '删除失败');
  }
}

function handlePageChange(page) {
  pagination.page = page;
  refresh();
}

onMounted(() => {
  refresh();
});
</script>

<style scoped lang="less">
.summary-row {
  margin-bottom: 16px;

  .summary-title {
    color: #909399;
    font-size: 13px;
  }

  .summary-value {
    margin-top: 6px;
    font-size: 30px;
    font-weight: 700;
    color: #303133;
  }
}

.table-header {
  display: flex;
  align-items: center;
  justify-content: space-between;

  .table-actions {
    display: flex;
    gap: 8px;
  }
}

.pagination {
  margin-top: 16px;
  justify-content: flex-end;
}
</style>
