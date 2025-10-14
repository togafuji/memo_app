import { defineStore } from 'pinia';
import { format, parseISO } from 'date-fns';
import { apolloClient } from '../services/graphqlClient';
import {
  CREATE_NOTE_MUTATION,
  DAILY_TIMELINE_QUERY,
  NOTE_QUERY,
  NOTES_BY_FILTER_QUERY,
  REQUEST_SUMMARY_MUTATION,
  TAGS_QUERY
} from '../services/queries';
import type {
  BulletPointInput,
  CreateNoteInput,
  DailyPage,
  GraphQLNote,
  NoteFilter,
  Tag
} from '../types';

interface EditorState {
  title: string;
  entryDate: string;
  bulletPoints: BulletPointInput[];
  selectedTags: string[];
}

interface DailyPageWithNotes extends DailyPage {
  notes: GraphQLNote[];
}

export const useNotesStore = defineStore('notes', {
  state: () => ({
    dailyPages: [] as DailyPageWithNotes[],
    tags: [] as Tag[],
    editor: {
      title: '',
      entryDate: format(new Date(), 'yyyy-MM-dd'),
      bulletPoints: [{ position: 0, content: '' }],
      selectedTags: []
    } as EditorState,
    activeNote: null as GraphQLNote | null,
    loading: false
  }),
  getters: {
    pendingSummaries(state) {
      return state.dailyPages.flatMap((page) => page.notes).filter((note) => note.summaryStatus !== 'COMPLETED').length;
    }
  },
  actions: {
    async fetchDailyTimeline(range?: { start: string; end: string }) {
      this.loading = true;
      try {
        const { data } = await apolloClient.query({
          query: DAILY_TIMELINE_QUERY,
          variables: {
            rangeStart: range?.start,
            rangeEnd: range?.end
          },
          fetchPolicy: 'network-only'
        });
        this.dailyPages = data.dailyPages.map((page: DailyPageWithNotes) => ({
          ...page,
          entryDate: page.entryDate,
          notes: page.notes.sort((a, b) => new Date(b.createdAt).getTime() - new Date(a.createdAt).getTime())
        }));
      } finally {
        this.loading = false;
      }
    },
    async fetchTags() {
      const { data } = await apolloClient.query({
        query: TAGS_QUERY,
        fetchPolicy: 'network-only'
      });
      this.tags = data.tags;
    },
    async filterNotes(filter: NoteFilter) {
      this.loading = true;
      try {
        const { data } = await apolloClient.query({
          query: NOTES_BY_FILTER_QUERY,
          variables: filter,
          fetchPolicy: 'network-only'
        });
        return data.notes as GraphQLNote[];
      } finally {
        this.loading = false;
      }
    },
    async fetchCurrentNote(noteId?: string) {
      if (!noteId && !this.activeNote) return;
      const id = noteId ?? this.activeNote?.id;
      if (!id) return;
      const { data } = await apolloClient.query({
        query: NOTE_QUERY,
        variables: { id },
        fetchPolicy: 'network-only'
      });
      this.activeNote = data.note;
      this.editor = {
        title: data.note.title,
        entryDate: format(parseISO(data.note.createdAt), 'yyyy-MM-dd'),
        bulletPoints: data.note.bulletPoints.map((bp: any, index: number) => ({
          position: index,
          content: bp.content
        })),
        selectedTags: data.note.tags.map((tag: Tag) => tag.name)
      };
    },
    addBulletPoint() {
      this.editor.bulletPoints.push({ position: this.editor.bulletPoints.length, content: '' });
    },
    removeBulletPoint(index: number) {
      this.editor.bulletPoints.splice(index, 1);
      this.editor.bulletPoints = this.editor.bulletPoints.map((bp, idx) => ({ ...bp, position: idx }));
    },
    reorderBulletPoints(oldIndex: number, newIndex: number) {
      const updated = [...this.editor.bulletPoints];
      const [moved] = updated.splice(oldIndex, 1);
      updated.splice(newIndex, 0, moved);
      this.editor.bulletPoints = updated.map((bp, index) => ({ ...bp, position: index }));
    },
    updateBulletPoint(index: number, content: string) {
      this.editor.bulletPoints[index].content = content;
    },
    setEntryDate(value: string) {
      this.editor.entryDate = value;
    },
    setTitle(value: string) {
      this.editor.title = value;
    },
    toggleTag(tag: string) {
      if (this.editor.selectedTags.includes(tag)) {
        this.editor.selectedTags = this.editor.selectedTags.filter((t) => t !== tag);
      } else {
        this.editor.selectedTags = [...this.editor.selectedTags, tag];
      }
    },
    async createNote() {
      const input: CreateNoteInput = {
        title: this.editor.title,
        entryDate: this.editor.entryDate,
        bulletPoints: this.editor.bulletPoints.filter((bp) => bp.content.trim().length > 0),
        tagNames: this.editor.selectedTags
      };
      const { data } = await apolloClient.mutate({
        query: CREATE_NOTE_MUTATION,
        variables: { input }
      });
      this.activeNote = data.createNote.note;
      await this.fetchDailyTimeline();
      return data.createNote.note as GraphQLNote;
    },
    async requestSummary(noteId: string) {
      const { data } = await apolloClient.mutate({
        query: REQUEST_SUMMARY_MUTATION,
        variables: { noteId }
      });
      await this.fetchDailyTimeline();
      return data.requestSummary.note as GraphQLNote;
    }
  }
});
