<script>
import { FREQUENT_ITEMS_PROJECTS, FREQUENT_ITEMS_GROUPS } from '~/frequent_items/constants';
import KeepAliveSlots from '~/vue_shared/components/keep_alive_slots.vue';
import eventHub, { EVENT_RESPONSIVE_TOGGLE } from '../event_hub';
import ResponsiveHeader from './responsive_header.vue';
import ResponsiveHome from './responsive_home.vue';
import TopNavContainerView from './top_nav_container_view.vue';

export default {
  components: {
    ResponsiveHeader,
    ResponsiveHome,
    TopNavContainerView,
    KeepAliveSlots,
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
  created() {
    eventHub.$on(EVENT_RESPONSIVE_TOGGLE, this.onToggle);
  },
  beforeDestroy() {
    eventHub.$off(EVENT_RESPONSIVE_TOGGLE, this.onToggle);
  },
  methods: {
    onToggle() {
      document.body.classList.toggle('top-nav-responsive-open');
    },
    onMenuItemClick({ view }) {
      if (view) {
        this.activeView = view;
      }
    },
  },
  FREQUENT_ITEMS_PROJECTS,
  FREQUENT_ITEMS_GROUPS,
};
</script>

<template>
  <keep-alive-slots :slot-key="activeView">
    <template #home>
      <responsive-home :nav-data="navData" @menu-item-click="onMenuItemClick" />
    </template>
    <template #projects>
      <responsive-header @menu-item-click="onMenuItemClick">{{ __('Projects') }}</responsive-header>
      <top-nav-container-view
        :frequent-items-dropdown-type="$options.FREQUENT_ITEMS_PROJECTS.namespace"
        :frequent-items-vuex-module="$options.FREQUENT_ITEMS_PROJECTS.vuexModule"
        container-class="gl-px-3"
        v-bind="navData.views.projects"
      />
    </template>
    <template #groups>
      <responsive-header @menu-item-click="onMenuItemClick">{{ __('Groups') }}</responsive-header>
      <top-nav-container-view
        :frequent-items-dropdown-type="$options.FREQUENT_ITEMS_GROUPS.namespace"
        :frequent-items-vuex-module="$options.FREQUENT_ITEMS_GROUPS.vuexModule"
        container-class="gl-px-3"
        v-bind="navData.views.groups"
      />
    </template>
  </keep-alive-slots>
</template>
