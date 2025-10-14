<template>
  <section class="bullet-editor">
    <header class="bullet-editor__header">
      <h2>箇条書きメモ</h2>
      <p class="bullet-editor__hint">Enter で追加、Ctrl + ↑/↓ で並び替えが可能です</p>
    </header>
    <ul class="bullet-editor__list">
      <li v-for="(bullet, index) in bullets" :key="index" class="bullet-editor__item">
        <span class="bullet-editor__handle" role="button" tabindex="0" @keydown.prevent="handleKeydown($event, index)">
          ⋮⋮
        </span>
        <el-input
          v-model="bullet.content"
          type="textarea"
          :autosize="{ minRows: 1, maxRows: 3 }"
          placeholder="メモ内容を入力"
          @keyup.enter.prevent="addAfter(index)"
        />
        <div class="bullet-editor__actions">
          <el-button
            circle
            size="small"
            :disabled="index === 0"
            :icon="ArrowUp"
            @click="() => reorder(index, index - 1)"
            aria-label="上へ移動"
          />
          <el-button
            circle
            size="small"
            :disabled="index === bullets.length - 1"
            :icon="ArrowDown"
            @click="() => reorder(index, index + 1)"
            aria-label="下へ移動"
          />
          <el-button
            circle
            size="small"
            type="danger"
            :icon="Delete"
            @click="() => remove(index)"
            aria-label="削除"
          />
        </div>
      </li>
    </ul>
    <el-button type="primary" plain @click="add">項目を追加</el-button>
  </section>
</template>

<script setup lang="ts">
import { computed } from 'vue';
import { ArrowUp, ArrowDown, Delete } from '@element-plus/icons-vue';
import { useNotesStore } from '../stores/notes';

const notesStore = useNotesStore();
const bullets = computed(() => notesStore.editor.bulletPoints);

function add() {
  notesStore.addBulletPoint();
}

function addAfter(index: number) {
  notesStore.editor.bulletPoints.splice(index + 1, 0, {
    position: index + 1,
    content: ''
  });
  notesStore.reorderBulletPoints(index + 1, index + 1);
}

function remove(index: number) {
  notesStore.removeBulletPoint(index);
}

function reorder(oldIndex: number, newIndex: number) {
  notesStore.reorderBulletPoints(oldIndex, newIndex);
}

function handleKeydown(event: KeyboardEvent, index: number) {
  if (event.ctrlKey && event.key === 'ArrowUp' && index > 0) {
    reorder(index, index - 1);
  } else if (event.ctrlKey && event.key === 'ArrowDown' && index < bullets.value.length - 1) {
    reorder(index, index + 1);
  }
}
</script>

<style scoped lang="scss">
.bullet-editor {
  display: flex;
  flex-direction: column;
  gap: 1rem;

  &__header h2 {
    font-size: 1.25rem;
    font-weight: 600;
  }

  &__hint {
    color: #6b7280;
    font-size: 0.875rem;
  }

  &__list {
    display: flex;
    flex-direction: column;
    gap: 0.75rem;
  }

  &__item {
    background: #f9fafb;
    border-radius: 12px;
    padding: 0.75rem;
    display: grid;
    grid-template-columns: 32px 1fr auto;
    gap: 0.75rem;
    align-items: center;
  }

  &__handle {
    cursor: grab;
    font-size: 1.25rem;
    text-align: center;
    color: #9ca3af;
  }

  &__actions {
    display: flex;
    gap: 0.25rem;
  }
}
</style>
