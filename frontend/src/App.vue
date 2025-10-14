<template>
  <el-container class="app-shell">
    <el-aside width="240px" class="app-shell__sidebar">
      <div class="logo">Memo Flow</div>
      <el-menu :default-active="activePath" class="navigation" router>
        <el-menu-item index="/">
          <span>ダッシュボード</span>
        </el-menu-item>
        <el-menu-item index="/editor">
          <span>メモエディタ</span>
        </el-menu-item>
        <el-menu-item index="/tags">
          <span>タグブラウザ</span>
        </el-menu-item>
      </el-menu>
      <div class="status-card">
        <div class="status-card__title">サマリー進捗</div>
        <div class="status-card__value">{{ pendingCount }} 件待機中</div>
      </div>
    </el-aside>
    <el-container>
      <el-header class="app-shell__header">
        <div class="header-title">{{ headerTitle }}</div>
        <div class="header-actions">
          <el-button type="primary" @click="refresh">再読み込み</el-button>
        </div>
      </el-header>
      <el-main>
        <router-view />
      </el-main>
    </el-container>
  </el-container>
</template>

<script setup lang="ts">
import { computed } from 'vue';
import { useRoute, useRouter } from 'vue-router';
import { useNotesStore } from './stores/notes';

const route = useRoute();
const router = useRouter();
const notesStore = useNotesStore();

const headerTitle = computed(() => {
  switch (route.name) {
    case 'dashboard':
      return '日次ダッシュボード';
    case 'editor':
      return 'メモエディタ';
    case 'tags':
      return 'タグブラウザ';
    default:
      return 'Memo Flow';
  }
});

const pendingCount = computed(() => notesStore.pendingSummaries);
const activePath = computed(() => route.path);

function refresh() {
  if (route.name === 'dashboard') {
    notesStore.fetchDailyTimeline();
  } else if (route.name === 'tags') {
    notesStore.fetchTags();
  } else if (route.name === 'editor') {
    notesStore.fetchCurrentNote();
  } else {
    router.replace('/');
  }
}
</script>

<style scoped lang="scss">
.app-shell {
  min-height: 100vh;
  background: #f3f4f6;

  &__sidebar {
    background: #101828;
    color: #f8fafc;
    display: flex;
    flex-direction: column;
    gap: 1.5rem;
    padding: 1.5rem 1rem;
  }

  &__header {
    background: #ffffff;
    display: flex;
    justify-content: space-between;
    align-items: center;
    padding: 1rem 1.5rem;
    border-bottom: 1px solid #e2e8f0;
  }
}

.logo {
  font-weight: 700;
  font-size: 1.25rem;
  text-align: center;
  letter-spacing: 0.08em;
}

.navigation {
  border-right: none;
}

.status-card {
  margin-top: auto;
  background: rgba(255, 255, 255, 0.08);
  padding: 1rem;
  border-radius: 12px;

  &__title {
    font-size: 0.875rem;
    color: #cbd5f5;
  }

  &__value {
    margin-top: 0.5rem;
    font-size: 1.5rem;
    font-weight: bold;
  }
}

.header-title {
  font-size: 1.5rem;
  font-weight: 600;
  color: #1f2937;
}

.header-actions {
  display: flex;
  gap: 1rem;
}

@media (max-width: 768px) {
  .app-shell {
    flex-direction: column;

    &__sidebar {
      width: 100% !important;
      flex-direction: row;
      align-items: center;
      gap: 1rem;
    }

    &__header {
      flex-direction: column;
      align-items: flex-start;
      gap: 0.75rem;
    }
  }

  .status-card {
    margin-top: 0;
  }
}
</style>
