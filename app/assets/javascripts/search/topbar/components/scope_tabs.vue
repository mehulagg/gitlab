<script>
import { GlTabs, GlTab } from '@gitlab/ui';
import { mapState } from 'vuex';
import { ALL_SCOPE_TABS } from '../constants';

export default {
  name: 'ScopeTabs',
  components: {
    GlTabs,
    GlTab,
  },
  props: {
    scopeTabs: {
      type: Array,
      required: true,
    },
    count: {
      type: String,
      required: true,
    }
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
  computed: {
    ...mapState(['query']),
  },
  methods: {
    isTabActive(tab) {
      return tab === this.query.scope;
    },
    shouldShowTabs() {
      return this.query.search && this.query.search !== 0;
    },
  },
  ALL_SCOPE_TABS
};
</script>

<template>
  <div v-if="shouldShowTabs">
<!--    SCOPE TABS = {{scopeTabs}}<br>-->
<!--    ALL TABS = {{$options.ALL_SCOPE_TABS}}<br>-->
<!--    SELECTED TABS = {{$options.ALL_SCOPE_TABS[scopeTabs[0]]}}<br>-->
    <gl-tabs class="nav-links search-filter scrolling-tabs nav nav-tabs">
      <gl-tab
        v-for="tab in scopeTabs"
        :key="$options.ALL_SCOPE_TABS[tab].scope"
        :active="isTabActive($options.ALL_SCOPE_TABS[tab].scope)"
        :title="$options.ALL_SCOPE_TABS[tab].title"/>
    </gl-tabs>
  </div>
</template>
