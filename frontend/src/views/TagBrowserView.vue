<template>
  <div class="tag-browser">
    <aside class="tag-browser__sidebar">
      <h2>タグ一覧</h2>
      <el-input v-model="keyword" placeholder="タグを検索" :prefix-icon="Search" />
      <ul class="tag-browser__list">
        <li
          v-for="tag in filteredTags"
          :key="tag.id"
          :class="['tag-browser__item', { 'tag-browser__item--active': selectedTag?.id === tag.id }]"
          @click="() => selectTag(tag)"
        >
          <span>#{{ tag.name }}</span>
          <small>関連度 {{ tag.weight?.toFixed(2) ?? '---' }}</small>
        </li>
      </ul>
    </aside>
    <section class="tag-browser__content">
      <header>
        <h3 v-if="selectedTag">{{ selectedTag.name }} のノート</h3>
        <p v-else>タグを選択すると関連ノートが表示されます。</p>
      </header>
      <div v-if="relatedNotes.length" class="tag-browser__notes">
        <NoteCard v-for="note in relatedNotes" :key="note.id" :note="note" @request-summary="requestSummary" />
      </div>
      <el-empty v-else description="関連ノートがありません" />
    </section>
  </div>
</template>

<script setup lang="ts">
import { computed, ref, watchEffect } from 'vue';
import { Search } from '@element-plus/icons-vue';
import { useNotesStore } from '../stores/notes';
import NoteCard from '../components/NoteCard.vue';
import type { GraphQLNote, Tag } from '../types';

const notesStore = useNotesStore();
const keyword = ref('');
const selectedTag = ref<Tag | null>(null);
const relatedNotes = ref<GraphQLNote[]>([]);

watchEffect(async () => {
  if (!notesStore.tags.length) {
    await notesStore.fetchTags();
  }
});

const filteredTags = computed(() =>
  notesStore.tags.filter((tag) => tag.name.toLowerCase().includes(keyword.value.toLowerCase()))
);

async function selectTag(tag: Tag) {
  selectedTag.value = tag;
  relatedNotes.value = await notesStore.filterNotes({ tagId: tag.id });
}

function requestSummary(noteId: string) {
  notesStore.requestSummary(noteId);
}
</script>

<style scoped lang="scss">
.tag-browser {
  display: grid;
  grid-template-columns: 300px 1fr;
  gap: 2rem;

  &__sidebar {
    background: #ffffff;
    border-radius: 14px;
    padding: 1.5rem;
    display: flex;
    flex-direction: column;
    gap: 1rem;
  }

  &__list {
    list-style: none;
    padding: 0;
    margin: 0;
    display: flex;
    flex-direction: column;
    gap: 0.5rem;
  }

  &__item {
    padding: 0.75rem 1rem;
    border-radius: 12px;
    background: #f3f4f6;
    display: flex;
    justify-content: space-between;
    cursor: pointer;
    transition: background 0.2s ease;

    &--active {
      background: #dbeafe;
    }
  }

  &__content {
    background: #ffffff;
    border-radius: 14px;
    padding: 1.5rem;
    display: flex;
    flex-direction: column;
    gap: 1.5rem;
  }

  &__notes {
    display: grid;
    grid-template-columns: repeat(auto-fill, minmax(260px, 1fr));
    gap: 1rem;
  }
}

@media (max-width: 1024px) {
  .tag-browser {
    grid-template-columns: 1fr;
  }
}
</style>
