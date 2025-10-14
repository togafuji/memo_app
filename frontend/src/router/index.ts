import { createRouter, createWebHistory } from 'vue-router';
import DashboardView from '../views/DashboardView.vue';
import NoteEditorView from '../views/NoteEditorView.vue';
import TagBrowserView from '../views/TagBrowserView.vue';

const router = createRouter({
  history: createWebHistory(),
  routes: [
    {
      path: '/',
      name: 'dashboard',
      component: DashboardView
    },
    {
      path: '/editor',
      name: 'editor',
      component: NoteEditorView
    },
    {
      path: '/tags',
      name: 'tags',
      component: TagBrowserView
    }
  ]
});

export default router;
