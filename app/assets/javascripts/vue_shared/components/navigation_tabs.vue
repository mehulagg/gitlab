<script>
import $ from 'jquery';
import { GlBadge, GlTabs, GlTab } from '@gitlab/ui';

/**
 * Given an array of tabs, renders non linked bootstrap tabs.
 * When a tab is clicked it will trigger an event and provide the clicked scope.
 *
 * This component is used in apps that handle the API call.
 * If you only need to change the URL this component should not be used.
 *
 * @example
 * <navigation-tabs
 *   :tabs="[
 *   {
 *      name: String,
 *      scope: String,
 *      count: Number || Undefined || Null,
 *      isActive: Boolean,
 *    },
 *   ]"
 *   @onChangeTab="onChangeTab"
 *   />
 */
export default {
  name: 'NavigationTabs',
  props: {
    tabs: {
      type: Array,
      required: true,
    },
    scope: {
      type: String,
      required: false,
      default: '',
    },
  },
  mounted() {
    $(document).trigger('init.scrolling-tabs');
  },
  methods: {
    shouldRenderBadge(count) {
      // 0 is valid in a badge, but evaluates to false, we need to check for undefined or null
      return !(count === undefined || count === null);
    },

    onTabClick(tab) {
      this.$emit('onChangeTab', tab.scope);
    },
  },
  components: {
    GlBadge,
    GlTabs,
    GlTab,
  },
};
</script>
<template>
  <gl-tabs class="gl-align-items-center gl-w-full">
    <gl-tab
      v-for="(tab, i) in tabs"
      :key="i"
      :active="tab.isActive"
      @click="onTabClick(tab)"
    >
      <template #title>
        <span data-testid="`${scope}-tab-${tab.scope}`" class="`js-${scope}-tab-${tab.scope}`">{{ tab.name }}</span>
        <gl-badge v-if="shouldRenderBadge(tab.count)" size="sm" class="gl-tab-counter-badge">{{ tab.count }}</gl-badge>
      </template>
    </gl-tab>
  </gl-tabs>
</template>
