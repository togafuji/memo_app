<template>
  <div class="editor-page">
    <div class="editor-page__form">
      <el-form label-position="top">
        <el-form-item label="タイトル">
          <el-input v-model="notesStore.editor.title" placeholder="今日の出来事" />
        </el-form-item>
        <el-form-item label="日付">
          <el-date-picker v-model="dateValue" type="date" format="YYYY-MM-DD" />
        </el-form-item>
      </el-form>
      <BulletEditor />
      <TagSuggestions />
      <el-button type="primary" size="large" :disabled="!canSubmit" @click="submit">保存して要約</el-button>
    </div>
    <SummaryPanel />
  </div>
</template>

<script setup lang="ts">
import { computed, ref, watch } from 'vue';
import { format } from 'date-fns';
import { useNotesStore } from '../stores/notes';
import BulletEditor from '../components/BulletEditor.vue';
import SummaryPanel from '../components/SummaryPanel.vue';
import TagSuggestions from '../components/TagSuggestions.vue';

const notesStore = useNotesStore();
const dateValue = ref(new Date(notesStore.editor.entryDate));

watch(dateValue, (value) => {
  notesStore.setEntryDate(format(value, 'yyyy-MM-dd'));
});

const canSubmit = computed(() =>
  notesStore.editor.title.trim().length > 0 &&
  notesStore.editor.bulletPoints.some((bp) => bp.content.trim().length > 0)
);

async function submit() {
  const note = await notesStore.createNote();
  await notesStore.requestSummary(note.id);
}
</script>

<style scoped lang="scss">
.editor-page {
  display: grid;
  grid-template-columns: minmax(0, 2fr) minmax(280px, 1fr);
  gap: 2rem;

  &__form {
    display: flex;
    flex-direction: column;
    gap: 1.5rem;
  }
}

@media (max-width: 1024px) {
  .editor-page {
    grid-template-columns: 1fr;
  }
}
</style>
