<template>
  <section class="summary-panel" aria-live="polite">
    <header class="summary-panel__header">
      <h2>要約プレビュー</h2>
      <el-tag :type="statusTag.type">{{ statusTag.text }}</el-tag>
    </header>
    <p v-if="note?.summary" class="summary-panel__body">{{ note.summary }}</p>
    <p v-else class="summary-panel__placeholder">要約ジョブの結果がここに表示されます。</p>
    <footer class="summary-panel__footer">
      <el-button type="primary" :loading="isProcessing" @click="requestSummary">要約をリクエスト</el-button>
    </footer>
  </section>
</template>

<script setup lang="ts">
import { computed } from 'vue';
import { useNotesStore } from '../stores/notes';
import { useRealtimeSummary } from '../composables/useRealtimeSummary';

const notesStore = useNotesStore();
const note = computed(() => notesStore.activeNote);

const noteId = computed(() => note.value?.id);

useRealtimeSummary(noteId);

const isProcessing = computed(() => note.value?.summaryStatus !== 'COMPLETED');
const statusTag = computed(() => {
  if (!note.value) {
    return { type: 'info', text: '未送信' };
  }
  switch (note.value.summaryStatus) {
    case 'COMPLETED':
      return { type: 'success', text: '完了' };
    case 'PROCESSING':
      return { type: 'warning', text: '処理中' };
    case 'PENDING':
    default:
      return { type: 'info', text: '待機中' };
  }
});

function requestSummary() {
  if (note.value) {
    notesStore.requestSummary(note.value.id);
  }
}
</script>

<style scoped lang="scss">
.summary-panel {
  background: #ffffff;
  border-radius: 16px;
  padding: 1.5rem;
  box-shadow: 0 20px 40px rgba(15, 23, 42, 0.12);
  display: flex;
  flex-direction: column;
  gap: 1rem;

  &__header {
    display: flex;
    justify-content: space-between;
    align-items: center;
  }

  &__body {
    font-size: 1rem;
    line-height: 1.6;
    color: #1f2937;
  }

  &__placeholder {
    color: #9ca3af;
    font-style: italic;
  }

  &__footer {
    margin-top: auto;
    display: flex;
    justify-content: flex-end;
  }
}
</style>
