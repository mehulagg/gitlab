<script>
import { GlIcon } from '@gitlab/ui';
import TopNavMenuItem from './top_nav_menu_item.vue';

export default {
  components: {
    GlIcon,
    TopNavMenuItem,
  },
  props: {
    navData: {
      type: Object,
      required: true,
    },
  },
  computed: {
    primary() {
      return this.navData.primary || [];
    },
    secondary() {
      return this.navData.secondary || [];
    },
  },
};
</script>

<template>
  <div>
    <header class="gl-display-flex gl-align-items-center gl-p-4">
      <h1 class="gl-m-0 gl-font-lg">{{ __('Menu') }}</h1>
      <gl-icon class="gl-ml-auto" name="search" />
    </header>
    <div class="gl-h-full gl-display-flex gl-align-items-stretch gl-flex-direction-column">
      <div class="gl-py-3">
        <top-nav-menu-item v-for="menu in primary" :key="menu.id" :menu-item="menu" />
      </div>
      <div v-if="secondary.length" class="gl-py-3 gl-border-1 gl-border-t-solid gl-border-gray-100">
        <top-nav-menu-item v-for="menu in secondary" :key="menu.id" :menu-item="menu" />
      </div>
    </div>
  </div>
</template>
