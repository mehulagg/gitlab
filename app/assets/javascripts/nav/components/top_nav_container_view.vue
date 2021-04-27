<script>
import FrequentItemsApp from '~/frequent_items/components/app.vue';
import eventHub from '~/frequent_items/event_hub';
import VuexModuleProvider from '~/vue_shared/components/vuex_module_provider.vue';
import TopNavMenuGroups from './top_nav_menu_groups.vue';

export default {
  components: {
    FrequentItemsApp,
    TopNavMenuGroups,
    VuexModuleProvider,
  },
  inheritAttrs: false,
  props: {
    frequentItemsVuexModule: {
      type: String,
      required: true,
    },
    frequentItemsDropdownType: {
      type: String,
      required: true,
    },
    frequentItemsContainerClass: {
      type: String,
      required: false,
      default: '',
    },
    linksPrimary: {
      type: Array,
      required: false,
      default: () => [],
    },
    linksSecondary: {
      type: Array,
      required: false,
      default: () => [],
    },
  },
  computed: {
    menuGroups() {
      return [
        { key: 'primary', menuItems: this.linksPrimary },
        { key: 'secondary', menuItems: this.linksSecondary },
      ].filter((x) => x.menuItems?.length);
    },
  },
  mounted() {
    // For historic reasons, the frequent-items-app component requires this too start up.
    this.$nextTick(() => {
      eventHub.$emit(`${this.frequentItemsDropdownType}-dropdownOpen`);
    });
  },
};
</script>

<template>
  <div class="top-nav-container-view gl-display-flex gl-flex-direction-column">
    <div class="frequent-items-dropdown-container gl-w-auto" :class="frequentItemsContainerClass">
      <div class="frequent-items-dropdown-content gl-w-full! gl-pt-0!">
        <vuex-module-provider :vuex-module="frequentItemsVuexModule">
          <frequent-items-app v-bind="$attrs" />
        </vuex-module-provider>
      </div>
    </div>
    <top-nav-menu-groups class="gl-mt-auto" :groups="menuGroups" with-top-border />
  </div>
</template>
