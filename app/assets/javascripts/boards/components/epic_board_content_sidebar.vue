<script>
import { GlDrawer } from '@gitlab/ui';
import { mapState, mapActions, mapGetters } from 'vuex';
import BoardSidebarLabelsSelect from '~/boards/components/sidebar/board_sidebar_labels_select.vue';
import { ISSUABLE } from '~/boards/constants';
import { contentTop } from '~/lib/utils/common_utils';
import glFeatureFlagsMixin from '~/vue_shared/mixins/gl_feature_flags_mixin';

export default {
  headerHeight: `${contentTop()}px`,
  components: {
    GlDrawer,
    BoardSidebarLabelsSelect,
  },
  mixins: [glFeatureFlagsMixin()],
  computed: {
    ...mapGetters(['isSidebarOpen', 'activeIssue']),
    ...mapState(['sidebarType']),
    isIssuableSidebar() {
      return this.sidebarType === ISSUABLE;
    },
    showSidebar() {
      return this.isIssuableSidebar && this.isSidebarOpen;
    },
    fullPath() {
      return this.activeIssue?.referencePath?.split('#')[0] || '';
    },
  },
  methods: {
    ...mapActions(['toggleBoardItem']),
    handleClose() {
      this.toggleBoardItem({ boardItem: this.activeIssue, sidebarType: this.sidebarType });
    },
  },
};
</script>

<template>
  <gl-drawer
    v-if="showSidebar"
    data-testid="sidebar-drawer"
    :open="isSidebarOpen"
    :header-height="$options.headerHeight"
    @close="handleClose"
  >
    <template #header>{{ __('Epic details') }}</template>
    <template #default>
      <board-sidebar-labels-select class="labels" />
    </template>
  </gl-drawer>
</template>
