<script>
import { GlTabs } from '@gitlab/ui';
import RepoTab from './repo_tab.vue';

export default {
  components: {
    RepoTab,
    GlTabs,
  },
  props: {
    activeFile: {
      type: Object,
      required: true,
    },
    files: {
      type: Array,
      required: true,
    },
  },
  data() {
    return {
      activeIndex: 0,
    };
  },
  computed: {
    localActiveFile() {
      return this.files[this.activeIndex];
    },
  },
  watch: {
    activeFile: {
      immediate: true,
      handler(file) {
        console.log(
          `[repo_tabs.1] localActiveFile=${this.localActiveFile?.path} file=${file.path}`,
        );
        // If we locally got it right, don't do anything
        if (this.localActiveFile?.path === file.path) {
          return;
        }

        // We need to update the current active tab
        const index = this.files.findIndex((x) => x.path === file.path);
        this.activeIndex = index;
        console.log(`[repo_tabs.2] activeIndex=${this.activeIndex}`);
      },
    },
  },
};
</script>

<template>
  <div class="multi-file-tabs">
    <gl-tabs v-model="activeIndex">
      <repo-tab v-for="tab in files" :key="tab.key" :tab="tab" />
    </gl-tabs>
  </div>
</template>
