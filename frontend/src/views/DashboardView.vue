<template>
  <div class="dashboard">
    <DailyTimeline />
  </div>
</template>

<script setup lang="ts">
import DailyTimeline from '../components/DailyTimeline.vue';
</script>

<style scoped>
.dashboard {
  display: flex;
  flex-direction: column;
  gap: 1.5rem;
}
</style>
