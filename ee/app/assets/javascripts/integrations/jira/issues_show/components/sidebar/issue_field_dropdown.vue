<script>
import { GlDropdown, GlDropdownItem, GlDropdownText, GlLoadingIcon } from '@gitlab/ui';

export default {
  components: {
    GlDropdown,
    GlDropdownItem,
    GlDropdownText,
    GlLoadingIcon,
  },
  props: {
    text: {
      type: String,
      required: false,
      default: null,
    },
    title: {
      type: String,
      required: false,
      default: null,
    },
  },
  data() {
    return {
      isLoading: true,
      items: [],
    };
  },
  computed: {
    noItems() {
      return this.items.length === 0;
    },
  },
  mounted() {
    // We are using mock data here which should come from the backend
    setTimeout(() => {
      // eslint-disable-next-line @gitlab/require-i18n-strings
      this.items = [{ title: 'In Progress' }, { title: 'Done' }];
      this.isLoading = false;
    }, 1000);
  },
  methods: {
    showDropdown() {
      this.$refs.dropdown.show();
    },
  },
};
</script>

<template>
  <gl-dropdown ref="dropdown" :text="text" :header-text="title" block lazy>
    <div v-if="isLoading" class="gl-h-13">
      <gl-loading-icon size="md" />
    </div>
    <div v-else>
      <gl-dropdown-text v-if="noItems">{{ __('No items') }}</gl-dropdown-text>
      <gl-dropdown-item v-for="item in items" :key="item.title">{{ item.title }}</gl-dropdown-item>
    </div>
  </gl-dropdown>
</template>
