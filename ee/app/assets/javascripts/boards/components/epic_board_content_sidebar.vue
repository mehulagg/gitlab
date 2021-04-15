<script>
import { GlDrawer } from '@gitlab/ui';
import { mapState, mapActions, mapGetters } from 'vuex';
import BoardSidebarLabelsSelect from '~/boards/components/sidebar/board_sidebar_labels_select.vue';
import BoardSidebarSubscription from '~/boards/components/sidebar/board_sidebar_subscription.vue';
import BoardSidebarTitle from '~/boards/components/sidebar/board_sidebar_title.vue';
import { ISSUABLE } from '~/boards/constants';
import { contentTop } from '~/lib/utils/common_utils';
import SidebarConfidentialityWidget from '~/sidebar/components/confidential/sidebar_confidentiality_widget.vue';

export default {
  headerHeight: `${contentTop()}px`,
  components: {
    GlDrawer,
    BoardSidebarLabelsSelect,
    BoardSidebarSubscription,
    BoardSidebarTitle,
    SidebarConfidentialityWidget,
  },
  computed: {
    ...mapGetters(['isSidebarOpen', 'activeBoardItem']),
    ...mapState(['sidebarType', 'fullPath']),
    isIssuableSidebar() {
      return this.sidebarType === ISSUABLE;
    },
    showSidebar() {
      return this.isIssuableSidebar && this.isSidebarOpen;
    },
  },
  methods: {
    ...mapActions(['toggleBoardItem', 'setActiveEpicConfidential']),
    handleClose() {
      this.toggleBoardItem({ boardItem: this.activeBoardItem, sidebarType: this.sidebarType });
    },
  },
};
</script>

<template>
  <gl-drawer
    v-if="showSidebar"
    :open="isSidebarOpen"
    :header-height="$options.headerHeight"
    @close="handleClose"
  >
    <template #header>{{ __('Epic details') }}</template>
    <template #default>
      <board-sidebar-title data-testid="sidebar-title" />
      <board-sidebar-labels-select class="labels" />
      <sidebar-confidentiality-widget
        :iid="activeBoardItem.iid"
        :full-path="fullPath"
        issuable-type="epic"
        @confidentialityUpdated="setActiveEpicConfidential($event)"
      />
      <board-sidebar-subscription class="subscriptions" />
    </template>
  </gl-drawer>
</template>
