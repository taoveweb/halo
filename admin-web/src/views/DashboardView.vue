<template>
  <section>
    <el-row :gutter="16" class="summary-row">
      <el-col :span="6">
        <el-card>
          <div class="summary-title">用户总数</div>
          <div class="summary-value">{{ stats.users }}</div>
        </el-card>
      </el-col>
      <el-col :span="6">
        <el-card>
          <div class="summary-title">推文总数</div>
          <div class="summary-value">{{ stats.tweets }}</div>
        </el-card>
      </el-col>
      <el-col :span="6">
        <el-card>
          <div class="summary-title">评论总数</div>
          <div class="summary-value">{{ stats.comments }}</div>
        </el-card>
      </el-col>
      <el-col :span="6">
        <el-card>
          <div class="summary-title">话题总数</div>
          <div class="summary-value">{{ stats.topics }}</div>
        </el-card>
      </el-col>
    </el-row>

    <el-tabs v-model="activeTab">
      <el-tab-pane label="推文管理" name="tweets">
        <el-card>
          <template #header>
            <div class="table-header">
              <span>推文管理</span>
              <div class="table-actions">
                <el-input
                  v-model="tweetKeyword"
                  placeholder="搜索内容 / 用户"
                  clearable
                  style="width: 220px"
                  @keyup.enter="refreshTweets"
                />
                <el-button type="primary" @click="refreshTweets">查询</el-button>
              </div>
            </div>
          </template>

          <el-table :data="tweetList" v-loading="tweetLoading" border>
            <el-table-column prop="authorName" label="作者" width="160" />
            <el-table-column prop="authorHandle" label="账号" width="160" />
            <el-table-column prop="content" label="内容" min-width="420" show-overflow-tooltip />
            <el-table-column prop="createdAt" label="发布时间" width="180" />
            <el-table-column label="操作" width="180" fixed="right">
              <template #default="{ row }">
                <el-button type="primary" text @click="openComments(row)">评论列表</el-button>
                <el-popconfirm title="确认删除这条推文吗？" @confirm="handleDeleteTweet(row.id)">
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
            :current-page="tweetPagination.page"
            :page-size="tweetPagination.pageSize"
            :total="tweetPagination.total"
            @current-change="handleTweetPageChange"
          />
        </el-card>
      </el-tab-pane>

      <el-tab-pane label="话题管理" name="topics">
        <el-card>
          <template #header>
            <div class="table-header">
              <span>话题管理</span>
              <div class="table-actions">
                <el-input
                  v-model="topicKeyword"
                  placeholder="搜索话题标题"
                  clearable
                  style="width: 220px"
                  @keyup.enter="refreshTopics"
                />
                <el-button type="primary" @click="refreshTopics">查询</el-button>
              </div>
            </div>
          </template>

          <el-table :data="topicList" v-loading="topicLoading" border>
            <el-table-column prop="title" label="话题" min-width="360" />
            <el-table-column prop="posts" label="帖子数" width="120" />
            <el-table-column prop="createdAt" label="创建时间" width="180" />
            <el-table-column label="操作" width="120" fixed="right">
              <template #default="{ row }">
                <el-popconfirm title="确认删除这个话题吗？" @confirm="handleDeleteTopic(row.id)">
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
            :current-page="topicPagination.page"
            :page-size="topicPagination.pageSize"
            :total="topicPagination.total"
            @current-change="handleTopicPageChange"
          />
        </el-card>
      </el-tab-pane>
    </el-tabs>

    <el-dialog v-model="commentDialogVisible" width="760px" :title="commentDialogTitle">
      <el-table :data="commentList" v-loading="commentLoading" border max-height="420">
        <el-table-column prop="author" label="评论用户" width="160" />
        <el-table-column prop="handle" label="账号" width="150" />
        <el-table-column prop="content" label="评论内容" min-width="260" />
        <el-table-column prop="createdAt" label="评论时间" width="180" />
      </el-table>
      <el-empty v-if="!commentLoading && commentList.length === 0" description="暂无评论" />
    </el-dialog>
  </section>
</template>

<script setup>
import { onMounted, reactive, ref } from 'vue';
import { ElMessage } from 'element-plus';

import http from '../api/http';

const activeTab = ref('tweets');
const tweetLoading = ref(false);
const topicLoading = ref(false);
const commentLoading = ref(false);
const tweetKeyword = ref('');
const topicKeyword = ref('');
const tweetList = ref([]);
const topicList = ref([]);
const commentList = ref([]);
const commentDialogVisible = ref(false);
const commentDialogTitle = ref('评论列表');

const stats = reactive({
  users: 0,
  tweets: 0,
  comments: 0,
  topics: 0
});

const tweetPagination = reactive({
  page: 1,
  pageSize: 10,
  total: 0
});

const topicPagination = reactive({
  page: 1,
  pageSize: 10,
  total: 0
});

async function fetchDashboard() {
  const { data } = await http.get('/admin/dashboard');
  stats.users = data.counts.users;
  stats.tweets = data.counts.tweets;
  stats.comments = data.counts.comments;
  stats.topics = data.counts.topics ?? 0;
}

async function fetchTweets() {
  const { data } = await http.get('/admin/tweets', {
    params: {
      keyword: tweetKeyword.value,
      page: tweetPagination.page,
      pageSize: tweetPagination.pageSize
    }
  });
  tweetList.value = data.list;
  tweetPagination.total = data.pagination.total;
}

async function fetchTopics() {
  const { data } = await http.get('/admin/topics', {
    params: {
      keyword: topicKeyword.value,
      page: topicPagination.page,
      pageSize: topicPagination.pageSize
    }
  });
  topicList.value = data.list;
  topicPagination.total = data.pagination.total;
}

async function refreshTweets() {
  tweetLoading.value = true;
  try {
    await Promise.all([fetchDashboard(), fetchTweets()]);
  } catch (error) {
    ElMessage.error(error.response?.data?.message || '加载推文失败');
  } finally {
    tweetLoading.value = false;
  }
}

async function refreshTopics() {
  topicLoading.value = true;
  try {
    await Promise.all([fetchDashboard(), fetchTopics()]);
  } catch (error) {
    ElMessage.error(error.response?.data?.message || '加载话题失败');
  } finally {
    topicLoading.value = false;
  }
}

async function handleDeleteTweet(id) {
  try {
    await http.delete(`/admin/tweets/${id}`);
    ElMessage.success('删除成功');
    await refreshTweets();
  } catch (error) {
    ElMessage.error(error.response?.data?.message || '删除失败');
  }
}

async function handleDeleteTopic(id) {
  try {
    await http.delete(`/admin/topics/${id}`);
    ElMessage.success('删除成功');
    await refreshTopics();
  } catch (error) {
    ElMessage.error(error.response?.data?.message || '删除失败');
  }
}

async function openComments(tweet) {
  commentDialogVisible.value = true;
  commentDialogTitle.value = `推文评论：${tweet.content.slice(0, 30)}${tweet.content.length > 30 ? '...' : ''}`;
  commentLoading.value = true;
  commentList.value = [];

  try {
    const { data } = await http.get(`/admin/tweets/${tweet.id}/comments`);
    commentList.value = data.list;
  } catch (error) {
    ElMessage.error(error.response?.data?.message || '加载评论失败');
  } finally {
    commentLoading.value = false;
  }
}

function handleTweetPageChange(page) {
  tweetPagination.page = page;
  refreshTweets();
}

function handleTopicPageChange(page) {
  topicPagination.page = page;
  refreshTopics();
}

onMounted(async () => {
  await Promise.all([refreshTweets(), refreshTopics()]);
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
