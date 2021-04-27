<script>
import { FREQUENT_ITEMS_PROJECTS, FREQUENT_ITEMS_GROUPS } from '~/frequent_items/constants';
import KeepAliveSlots from '~/vue_shared/components/keep_alive_slots.vue';
import eventHub from '../event_hub';
import TopNavResponsiveContainerView from './top_nav_responsive_container_view.vue';
import TopNavResponsiveHome from './top_nav_responsive_home.vue';
import TopNavResponsiveNewView from './top_nav_responsive_new_view.vue';

const MENU_ITEM_EVENT = 'responsive:menu-item-click';

export default {
  components: {
    KeepAliveSlots,
    TopNavResponsiveContainerView,
    TopNavResponsiveNewView,
    TopNavResponsiveHome,
  },
  provide: {
    menuItemEvent: MENU_ITEM_EVENT,
  },
  props: {
    navData: {
      type: Object,
      required: true,
    },
  },
  data() {
    return {
      activeView: 'home',
    };
  },
  mounted() {
    eventHub.$on(MENU_ITEM_EVENT, this.onMenuItem);
  },
  beforeDestroy() {
    eventHub.$off(MENU_ITEM_EVENT, this.onMenuItem);
  },
  methods: {
    onMenuItem({ view }) {
      if (!view) {
        return;
      }

      this.activeView = view;
    },
  },
  FREQUENT_ITEMS_PROJECTS,
  FREQUENT_ITEMS_GROUPS,
};
</script>

<template>
  <keep-alive-slots :slot-key="activeView">
    <template #home>
      <top-nav-responsive-home :nav-data="navData" />
    </template>
    <template v-if="navData.views['new']" #new>
      <top-nav-responsive-new-view :new-view-model="navData.views['new']" />
    </template>
    <template #projects>
      <top-nav-responsive-container-view
        :header-title="__('Projects')"
        :frequent-items-dropdown-type="$options.FREQUENT_ITEMS_PROJECTS.namespace"
        :frequent-items-vuex-module="$options.FREQUENT_ITEMS_PROJECTS.vuexModule"
        v-bind="navData.views.projects"
      />
    </template>
    <template #groups>
      <top-nav-responsive-container-view
        :header-title="__('Groups')"
        :frequent-items-dropdown-type="$options.FREQUENT_ITEMS_GROUPS.namespace"
        :frequent-items-vuex-module="$options.FREQUENT_ITEMS_GROUPS.vuexModule"
        v-bind="navData.views.groups"
      />
    </template>
  </keep-alive-slots>
</template>
