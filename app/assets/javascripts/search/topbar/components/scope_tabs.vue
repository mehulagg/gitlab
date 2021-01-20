<script>
import { GlTabs, GlTab } from '@gitlab/ui';

export default {
  name: 'ScopeTabs',
  components: {
    GlTabs,
    GlTab,
  },
  props: {
    scopeTabs: {
      type: Array,
      required: false,
      default: () => [],
    },
    scope: {
      type: String,
      required: false,
      default: null,
    },
    term: {
        type: String,
        required: false,
        default: null,
      },
    },
    mounted() {
      // const url = `${scopeTabs[0].url}`
      //
      // return api
      //   .get(url)
      //   .then(({ data }) => showCount(el, data.count))
      //   .catch((e) => {
      //     // eslint-disable-next-line no-console
      //     console.error(`Failed to fetch search count from '${url}'.`, e);
      //   });
    },
    methods: {
      isTabActive(tabScope) {
        return tabScope === this.scope;
      }
    }
  }
</script>

<template>
  <div v-if="term">
    <gl-tabs class="nav-links search-filter scrolling-tabs nav nav-tabs">
      <gl-tab
        v-for="tab in scopeTabs"
        :key="tab.scope"
        :active="isTabActive(tab.scope)"
        :title="__(tab.title)"/>
    </gl-tabs>
    test
  </div>
</template>
