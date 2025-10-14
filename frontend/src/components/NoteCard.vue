<template>
  <article class="note-card" :aria-busy="isPending">
    <header class="note-card__header">
      <h3>{{ note.title }}</h3>
      <el-tag v-if="note.summaryStatus === 'COMPLETED'" type="success">要約済み</el-tag>
      <el-tag v-else type="warning">処理中</el-tag>
    </header>
    <section class="note-card__body">
      <p v-if="note.summary" class="note-card__summary">{{ note.summary }}</p>
      <p v-else class="note-card__placeholder">要約はまだ生成されていません。</p>
      <ul class="note-card__bullets">
        <li v-for="bp in note.bulletPoints" :key="bp.id">{{ bp.content }}</li>
      </ul>
    </section>
    <footer class="note-card__footer">
      <div class="note-card__tags">
        <el-tag v-for="tag in note.tags" :key="tag.id" effect="plain">#{{ tag.name }}</el-tag>
      </div>
      <el-button
        size="small"
        type="primary"
        :loading="isPending"
        @click="() => $emit('request-summary', note.id)"
      >
        再要約をリクエスト
      </el-button>
    </footer>
  </article>
</template>

<script setup lang="ts">
import { computed } from 'vue';
import type { GraphQLNote } from '../types';

const props = defineProps<{ note: GraphQLNote }>();

const isPending = computed(() => props.note.summaryStatus !== 'COMPLETED');
</script>

<style scoped lang="scss">
.note-card {
  background: #ffffff;
  border-radius: 14px;
  padding: 1.25rem;
  display: flex;
  flex-direction: column;
  gap: 1rem;
  box-shadow: 0 10px 25px rgba(15, 23, 42, 0.08);

  &__header {
    display: flex;
    align-items: center;
    justify-content: space-between;
    gap: 0.5rem;
  }

  &__summary {
    color: #1f2937;
    line-height: 1.5;
  }

  &__placeholder {
    color: #9ca3af;
    font-style: italic;
  }

  &__bullets {
    list-style: disc;
    padding-left: 1.5rem;
    color: #4b5563;
  }

  &__footer {
    display: flex;
    justify-content: space-between;
    align-items: center;
    flex-wrap: wrap;
    gap: 0.75rem;
  }

  &__tags {
    display: flex;
    flex-wrap: wrap;
    gap: 0.5rem;
  }
}
</style>
