<script>
import { GlIcon, GlTooltipDirective } from '@gitlab/ui';
import TopNavMenuItem from './top_nav_menu_item.vue';

export default {
  components: {
    GlIcon,
    TopNavMenuItem,
  },
  directives: {
    GlTooltip: GlTooltipDirective,
  },
  computed: {
    menuItem() {
      return {
        id: 'home',
        view: 'home',
      };
    },
  },
};
</script>

<template>
  <header class="gl-py-4">
    <top-nav-menu-item
      v-gl-tooltip="{ title: s__('TopNav|Go back') }"
      class="gl-font-size-h2! gl-font-weight-bold"
      :menu-item="menuItem"
    >
      <span class="gl-display-flex gl-align-items-center">
        <gl-icon class="gl-mr-3" name="angle-left" />
        <slot>{{ __('Menu') }}</slot>
      </span>
    </top-nav-menu-item>
  </header>
</template>
