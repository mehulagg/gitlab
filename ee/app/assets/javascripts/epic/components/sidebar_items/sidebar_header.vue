<script>
import { mapActions } from 'vuex';

import ToggleSidebar from '~/vue_shared/components/sidebar/toggle_sidebar.vue';

import SidebarTodo from './sidebar_todo.vue';

export default {
  components: {
    ToggleSidebar,
    SidebarTodo,
  },
  props: {
    sidebarCollapsed: {
      type: Boolean,
      required: true,
    },
  },
  methods: {
    ...mapActions(['toggleSidebar']),
  },

  emits: [],
};
</script>

<template>
  <div class="block issuable-sidebar-header">
    <span class="issuable-header-text hide-collapsed float-left">{{ __('To Do') }}</span>
    <toggle-sidebar
      :collapsed="sidebarCollapsed"
      css-classes="float-right"
      @toggle="toggleSidebar({ sidebarCollapsed })"
    />
    <sidebar-todo v-show="!sidebarCollapsed" :sidebar-collapsed="sidebarCollapsed" />
  </div>
</template>
