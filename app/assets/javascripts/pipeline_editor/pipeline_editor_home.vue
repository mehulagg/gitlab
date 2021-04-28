<script>
import CommitSection from './components/commit/commit_section.vue';
import PipelineEditorDrawer from './components/drawer/pipeline_editor_drawer.vue';
import PipelineEditorDrawerUi from './components/drawer/pipeline_editor_drawer_ui.vue';
import PipelineEditorFileNav from './components/file_nav/pipeline_editor_file_nav.vue';
import PipelineEditorHeader from './components/header/pipeline_editor_header.vue';
import PipelineEditorTabs from './components/pipeline_editor_tabs.vue';
import { TABS_WITH_COMMIT_FORM, CREATE_TAB } from './constants';

export default {
  containerRef: 'CONTAINER_REF',
  drawerExpandedWidth: 484,
  components: {
    CommitSection,
    PipelineEditorDrawer,
    PipelineEditorDrawerUi,
    PipelineEditorFileNav,
    PipelineEditorHeader,
    PipelineEditorTabs,
  },
  props: {
    ciConfigData: {
      type: Object,
      required: true,
    },
    ciFileContent: {
      type: String,
      required: true,
    },
    isNewCiConfigFile: {
      type: Boolean,
      required: true,
    },
  },
  data() {
    return {
      currentTab: CREATE_TAB,
      isDrawerExpanded: false,
      containerWidth: '100%',
    };
  },
  computed: {
    adjustedContainerWidth() {
      // return this.isDrawerExpanded
      //   ? this.containerWidth - this.$options.drawerExpandedWidth
      //   : this.containerWidth;
      return this.containerWidth;
    },
    containerClass() {
      // return this.isDrawerExpanded ? '' : 'gl-w-full';
      return 'gl-w-full';
    },
    showCommitForm() {
      return TABS_WITH_COMMIT_FORM.includes(this.currentTab);
    },
  },
  mounted() {
    this.containerWidth = this.getCurrentWidth();
  },
  methods: {
    getCurrentWidth() {
      const ref = this.$refs[this.$options.containerRef];
      if (ref) {
        return ref.getBoundingClientRect()?.width;
      }

      return 0;
    },
    setCurrentTab(tabName) {
      this.currentTab = tabName;
    },
    toggleDrawer() {
      this.isDrawerExpanded = !this.isDrawerExpanded;
    },
  },
};
</script>

<template>
  <div
    :ref="$options.containerRef"
    class="gl-pr-9 gl-transition-medium"
    :class="containerClass"
    :style="{ width: `${adjustedContainerWidth}px` }"
  >
    <pipeline-editor-file-nav v-on="$listeners" />
    <pipeline-editor-header
      :ci-config-data="ciConfigData"
      :is-new-ci-config-file="isNewCiConfigFile"
    />
    <pipeline-editor-tabs
      :ci-config-data="ciConfigData"
      :ci-file-content="ciFileContent"
      v-on="$listeners"
      @set-current-tab="setCurrentTab"
    />
    <commit-section v-if="showCommitForm" :ci-file-content="ciFileContent" v-on="$listeners" />
    <pipeline-editor-drawer-ui
      :is-expanded="isDrawerExpanded"
      :expanded-width="$options.drawerExpandedWidth"
      @toggleDrawer="toggleDrawer"
    />
  </div>
</template>
