<script>
import { GlDrawer } from '@gitlab/ui';
import { MountingPortal } from 'portal-vue';
import { mapState, mapActions, mapGetters } from 'vuex';
import BoardSidebarLabelsSelect from '~/boards/components/sidebar/board_sidebar_labels_select.vue';
import BoardSidebarTitle from '~/boards/components/sidebar/board_sidebar_title.vue';
import { ISSUABLE } from '~/boards/constants';
import SidebarConfidentialityWidget from '~/sidebar/components/confidential/sidebar_confidentiality_widget.vue';
import SidebarDateWidget from '~/sidebar/components/date/sidebar_date_widget.vue';
import SidebarParticipantsWidget from '~/sidebar/components/participants/sidebar_participants_widget.vue';
import SidebarSubscriptionsWidget from '~/sidebar/components/subscriptions/sidebar_subscriptions_widget.vue';

export default {
  components: {
    GlDrawer,
    MountingPortal,
    BoardSidebarLabelsSelect,
    BoardSidebarTitle,
    SidebarConfidentialityWidget,
    SidebarDateWidget,
    SidebarParticipantsWidget,
    SidebarSubscriptionsWidget,
  },
  computed: {
    ...mapGetters(['isSidebarOpen', 'activeBoardItem']),
    ...mapState(['sidebarType', 'fullPath', 'issuableType']),
    isIssuableSidebar() {
      return this.sidebarType === ISSUABLE;
    },
    showSidebar() {
      return this.isIssuableSidebar && this.isSidebarOpen;
    },
  },
  methods: {
    ...mapActions(['toggleBoardItem', 'setActiveItemConfidential', 'setActiveItemSubscribed']),
    handleClose() {
      this.toggleBoardItem({ boardItem: this.activeBoardItem, sidebarType: this.sidebarType });
    },
  },
};
</script>

<template>
  <mounting-portal mount-to="#js-right-sidebar-portal" name="right-sidebar" append>
    <gl-drawer
      v-if="showSidebar"
      class="gl-absolute"
      :open="isSidebarOpen"
      :header-height="heightFromTop"
      @close="handleClose"
    >
      <template #header>{{ __('Epic details') }}</template>
      <template #default>
        <board-sidebar-title data-testid="sidebar-title" />
        <sidebar-date-widget
          :iid="activeBoardItem.iid"
          :full-path="fullPath"
          date-type="startDate"
          :issuable-type="issuableType"
          :can-inherit="true"
        />
        <sidebar-date-widget
          :iid="activeBoardItem.iid"
          :full-path="fullPath"
          date-type="dueDate"
          :issuable-type="issuableType"
          :can-inherit="true"
        />
        <board-sidebar-labels-select class="labels" />
        <sidebar-participants-widget
          :iid="activeBoardItem.iid"
          :full-path="fullPath"
          issuable-type="epic"
        />
        <sidebar-confidentiality-widget
          :iid="activeBoardItem.iid"
          :full-path="fullPath"
          :issuable-type="issuableType"
          @confidentialityUpdated="setActiveItemConfidential($event)"
        />
        <sidebar-subscriptions-widget
          :iid="activeBoardItem.iid"
          :full-path="fullPath"
          :issuable-type="issuableType"
        />
      </template>
    </gl-drawer>
  </mounting-portal>
</template>
