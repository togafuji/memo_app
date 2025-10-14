import { onBeforeUnmount, watch, type Ref } from 'vue';
import type { GraphQLNote } from '../types';
import { useNotesStore } from '../stores/notes';

export function useRealtimeSummary(noteId: Ref<string | undefined>) {
  const notesStore = useNotesStore();
  let eventSource: EventSource | null = null;
  let reconnectTimer: ReturnType<typeof setTimeout> | null = null;

  function disconnect() {
    if (eventSource) {
      eventSource.close();
      eventSource = null;
    }
    if (reconnectTimer) {
      clearTimeout(reconnectTimer);
      reconnectTimer = null;
    }
  }

  function connect(noteIdValue: string) {
    disconnect();
    eventSource = new EventSource(`/graphql/subscriptions?noteId=${noteIdValue}`);
    eventSource.onmessage = (event) => {
      try {
        const payload = JSON.parse(event.data) as { note: GraphQLNote };
        notesStore.activeNote = payload.note;
        notesStore.fetchDailyTimeline();
      } catch (error) {
        console.error('Failed to parse subscription payload', error);
      }
    };
    eventSource.onerror = () => {
      disconnect();
      reconnectTimer = setTimeout(() => connect(noteIdValue), 3000);
    };
  }

  watch(
    noteId,
    (value) => {
      if (!value) {
        disconnect();
        return;
      }
      connect(value);
    },
    { immediate: true }
  );

  onBeforeUnmount(() => {
    disconnect();
  });
}
