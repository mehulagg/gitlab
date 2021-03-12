<script>
import { GlNav, GlNavItemDropdown, GlDropdownForm } from '@gitlab/ui';
import TopNavContent from './top_nav_content.vue';

export default {
  components: {
    GlNav,
    GlNavItemDropdown,
    GlDropdownForm,
    TopNavContent,
  },
  props: {
    navData: {
      type: Object,
      required: true,
    },
  },
};
</script>

<template>
  <div>
    <gl-nav>
      <gl-nav-item-dropdown text="Menu" icon="ellipsis_v">
        <gl-dropdown-form>
          <top-nav-content :primary="navData.topPrimary" :secondary="navData.topSecondary" />
        </gl-dropdown-form>
      </gl-nav-item-dropdown>
    </gl-nav>
  </div>
</template>
