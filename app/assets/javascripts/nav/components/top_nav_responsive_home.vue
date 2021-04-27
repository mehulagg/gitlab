<script>
import { GlIcon, GlTooltipDirective } from '@gitlab/ui';
import TopNavMenuGroups from './top_nav_menu_groups.vue';
import TopNavMenuItem from './top_nav_menu_item.vue';

export default {
  components: {
    GlIcon,
    TopNavMenuGroups,
    TopNavMenuItem,
  },
  directives: {
    GlTooltip: GlTooltipDirective,
  },
  props: {
    navData: {
      type: Object,
      required: true,
    },
  },
  computed: {
    menuGroups() {
      return [
        { id: 'primary', menuItems: this.navData.primary },
        { id: 'secondary', menuItems: this.navData.secondary },
      ].filter((x) => x.menuItems?.length);
    },
  },
};
</script>

<template>
  <div>
    <header class="gl-display-flex gl-align-items-center gl-p-4">
      <h1 class="gl-m-0 gl-font-size-h2 gl-reset-color">{{ __('Menu') }}</h1>
      <top-nav-menu-item
        v-for="(menuItem, index) in navData.header_menu_items"
        :key="menuItem.id"
        v-gl-tooltip="{ title: menuItem.title }"
        :class="index === 0 ? 'gl-ml-auto' : 'gl-ml-3'"
        :menu-item="menuItem"
      >
        <gl-icon :name="menuItem.icon" :aria-label="menuItem.title" />
      </top-nav-menu-item>
    </header>
    <top-nav-menu-groups class="gl-h-full" :groups="menuGroups" />
  </div>
</template>
