<template>
  <section class="tag-suggestions">
    <header class="tag-suggestions__header">
      <h2>タグ候補</h2>
      <el-button text size="small" @click="refresh">候補を更新</el-button>
    </header>
    <div class="tag-suggestions__chips">
      <el-check-tag
        v-for="tag in suggestions"
        :key="tag"
        :checked="selected.has(tag)"
        @change="() => toggle(tag)"
      >
        {{ tag }}
      </el-check-tag>
    </div>
  </section>
</template>

<script setup lang="ts">
import { computed } from 'vue';
import { useNotesStore } from '../stores/notes';

const notesStore = useNotesStore();
const suggestions = computed(() => notesStore.tags.slice(0, 10).map((tag) => tag.name));
const selected = computed(() => new Set(notesStore.editor.selectedTags));

function toggle(tag: string) {
  notesStore.toggleTag(tag);
}

function refresh() {
  notesStore.fetchTags();
}
</script>

<style scoped lang="scss">
.tag-suggestions {
  background: #fff7ed;
  border-radius: 14px;
  padding: 1.25rem;
  display: flex;
  flex-direction: column;
  gap: 0.75rem;

  &__header {
    display: flex;
    justify-content: space-between;
    align-items: center;
  }

  &__chips {
    display: flex;
    flex-wrap: wrap;
    gap: 0.5rem;
  }
}
</style>
