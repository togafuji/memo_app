<template>
  <section class="timeline" aria-label="日付タイムライン">
    <header class="timeline__header">
      <div class="timeline__titles">
        <h2>日付ページ</h2>
        <p class="timeline__subtitle">範囲を指定して最近のメモを確認できます</p>
      </div>
      <div class="timeline__filters">
        <el-date-picker
          v-model="dateRange"
          type="daterange"
          unlink-panels
          range-separator="~"
          start-placeholder="開始日"
          end-placeholder="終了日"
          format="YYYY-MM-DD"
          @change="onRangeChange"
        />
      </div>
    </header>

    <el-timeline>
      <el-timeline-item
        v-for="page in pages"
        :key="page.id"
        :timestamp="formatDate(page.entryDate)"
        placement="top"
        color="#6366f1"
      >
        <div class="timeline__cards">
          <NoteCard
            v-for="note in page.notes"
            :key="note.id"
            :note="note"
            @request-summary="requestSummary"
          />
        </div>
      </el-timeline-item>
    </el-timeline>
  </section>
</template>

<script setup lang="ts">
import { computed, ref, watchEffect } from 'vue';
import { format, parseISO } from 'date-fns';
import { useNotesStore } from '../stores/notes';
import NoteCard from './NoteCard.vue';

const notesStore = useNotesStore();
const pages = computed(() => notesStore.dailyPages);
const dateRange = ref<[Date, Date] | null>(null);

watchEffect(() => {
  if (!notesStore.dailyPages.length) {
    notesStore.fetchDailyTimeline();
  }
});

function formatDate(value: string) {
  return format(parseISO(value), 'yyyy年MM月dd日');
}

async function onRangeChange(value: [Date, Date] | null) {
  if (!value) {
    await notesStore.fetchDailyTimeline();
    return;
  }
  const [start, end] = value;
  await notesStore.fetchDailyTimeline({
    start: format(start, 'yyyy-MM-dd'),
    end: format(end, 'yyyy-MM-dd')
  });
}

function requestSummary(noteId: string) {
  notesStore.requestSummary(noteId);
}
</script>

<style scoped lang="scss">
.timeline {
  display: flex;
  flex-direction: column;
  gap: 1.5rem;

  &__header {
    display: flex;
    flex-wrap: wrap;
    justify-content: space-between;
    gap: 1rem;
  }

  &__titles h2 {
    font-size: 1.5rem;
    font-weight: 600;
  }

  &__subtitle {
    color: #6b7280;
    margin-top: 0.25rem;
  }

  &__cards {
    display: grid;
    grid-template-columns: repeat(auto-fill, minmax(280px, 1fr));
    gap: 1rem;
  }
}

@media (max-width: 768px) {
  .timeline__cards {
    grid-template-columns: 1fr;
  }
}
</style>
