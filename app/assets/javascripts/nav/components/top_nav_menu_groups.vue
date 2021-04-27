<script>
import TopNavMenuItem from './top_nav_menu_item.vue';

export default {
  components: {
    TopNavMenuItem,
  },
  props: {
    groups: {
      type: Array,
      required: true,
    },
    withTopBorder: {
      type: Boolean,
      required: false,
      default: false,
    },
  },
  computed: {
    showTitles() {
      return this.groups.length > 1;
    },
  },
  methods: {
    showBorder(groupIndex) {
      return this.withTopBorder || groupIndex > 0;
    },
    getGroupClasses(groupIndex) {
      const showBorder = this.withTopBorder || groupIndex > 0;

      const classes = showBorder ? 'gl-pt-3 gl-border-1 gl-border-t-solid gl-border-gray-100' : '';

      return groupIndex > 0 ? `${classes} gl-mt-3` : classes;
    },
  },
};
</script>

<template>
  <div class="gl-display-flex gl-align-items-stretch gl-flex-direction-column">
    <div
      v-for="({ id, menuItems, title }, groupIndex) in groups"
      :key="id"
      :class="getGroupClasses(groupIndex)"
      data-testid="menu-item-group"
    >
      <div v-if="title && showTitles" class="gl-font-weight-bold gl-px-4 gl-text-body">
        {{ title }}
      </div>
      <top-nav-menu-item
        v-for="(menuItem, menuItemIndex) in menuItems"
        :key="menuItem.title"
        :menu-item="menuItem"
        :class="{ 'gl-mt-1': menuItemIndex !== 0 }"
      />
    </div>
  </div>
</template>
