<script>
import TopNavMenuItem from './top_nav_menu_item.vue';

const BORDER_CLASSES = 'gl-pt-3 gl-border-1 gl-border-t-solid gl-border-gray-100';

export default {
  components: {
    TopNavMenuItem,
  },
  props: {
    sections: {
      type: Array,
      required: true,
    },
    withTopBorder: {
      type: Boolean,
      required: false,
      default: false,
    },
  },
  methods: {
    onClick(menuItem) {
      // If we're a link, let's just do the default behavior so the view won't change
      if (menuItem.href) {
        return;
      }

      this.$emit('menu-item-click', menuItem);
    },
  },
  BORDER_CLASSES,
};
</script>

<template>
  <div class="gl-display-flex gl-align-items-stretch gl-flex-direction-column">
    <div
      v-for="({ id, menuItems }, sectionIndex) in sections"
      :key="id"
      :class="{
        [$options.BORDER_CLASSES]: withTopBorder || sectionIndex > 0,
        'gl-mt-3': sectionIndex > 0,
      }"
      data-testid="menu-section"
    >
      <top-nav-menu-item
        v-for="(menuItem, menuItemIndex) in menuItems"
        :key="menuItem.id"
        :menu-item="menuItem"
        data-testid="menu-item"
        :class="{ 'gl-mt-1': menuItemIndex > 0 }"
        @click="onClick(menuItem)"
      />
    </div>
  </div>
</template>
