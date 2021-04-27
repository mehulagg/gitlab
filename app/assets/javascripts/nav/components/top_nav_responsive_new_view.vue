<script>
import TopNavMenuGroups from './top_nav_menu_groups.vue';
import TopNavSubviewHeader from './top_nav_subview_header.vue';

export default {
  components: {
    TopNavMenuGroups,
    TopNavSubviewHeader,
  },
  props: {
    newViewModel: {
      type: Object,
      required: true,
    },
  },
  computed: {
    menuGroups() {
      return this.newViewModel.menu_sections.map((x) => ({
        id: x.title,
        title: x.title,
        menuItems: x.menu_items,
      }));
    },
  },
};
</script>

<template>
  <div>
    <top-nav-subview-header />
    <top-nav-menu-groups :groups="menuGroups" />
  </div>
</template>
