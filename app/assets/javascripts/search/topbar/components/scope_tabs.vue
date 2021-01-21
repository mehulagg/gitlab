<script>
import { GlTabs, GlTab, GlBadge } from '@gitlab/ui';
import { mapState } from 'vuex';
import { visitUrl, setUrlParams } from '~/lib/utils/url_utility';
import axios from '~/lib/utils/axios_utils';
import { ALL_SCOPE_TABS } from '../constants';

export default {
  name: 'ScopeTabs',
  components: {
    GlTabs,
    GlTab,
    GlBadge,
  },
  props: {
    scopeTabs: {
      type: Array,
      required: true,
    },
    count: {
      type: String,
      required: true,
    },
    countPath: {
      type: String,
      required: true,
    }
  },
  mounted() {
    this.$nextTick(() => {
      const elements = Array.from(this.$el.querySelectorAll('.js-search-counts'));

      return Promise.all(elements.map(this.refreshCount));
    })
  },
  computed: {
    ...mapState(['query']),
  },
  methods: {
    handleTabChange(scope) {
      visitUrl(setUrlParams({ scope, page: null, state: null, confidential: null }));
    },
    isTabActive(tab) {
      return tab === this.query.scope;
    },
    showCount(el, count) {
      el.textContent = count;
      el.classList.remove('hidden');
    },
    refreshCount(el) {
      const url = this.countPath;
      const {scope} = el.dataset;

      return axios
        .get(url, { params: { scope, search: this.query.search, project_id: this.query.project_id, group_id: this.query.group_id } })
        .then(({ data }) => this.showCount(el, data.count))
        .catch((e) => {
          // eslint-disable-next-line no-console
          console.error(`Failed to fetch search count from '${url}'.`, e);
        });
    },
    shouldShowTabs() {
      return this.query.search && this.query.search !== 0;
    },
  },
  ALL_SCOPE_TABS
};
</script>

<template>
  <div v-if="shouldShowTabs" class="scrolling-tabs-container inner-page-scroll-tabs is-smaller">
    <gl-tabs class="nav-links search-filter scrolling-tabs nav nav-tabs">
      <gl-tab
        v-for="tab in scopeTabs"
        :key="$options.ALL_SCOPE_TABS[tab].scope"
        :active="isTabActive($options.ALL_SCOPE_TABS[tab].scope)"
        @click="handleTabChange($options.ALL_SCOPE_TABS[tab].scope)"
        >
        <template #title>
          <span> {{ $options.ALL_SCOPE_TABS[tab].title }} </span>
          <gl-badge
            :data-scope="$options.ALL_SCOPE_TABS[tab].scope"
            :variant="isTabActive($options.ALL_SCOPE_TABS[tab].scope) ? 'neutral' : 'muted'"
            size="md"
            :class="{'js-search-counts': !isTabActive($options.ALL_SCOPE_TABS[tab].scope), 'hidden': !isTabActive($options.ALL_SCOPE_TABS[tab].scope)}"
          >
            {{ count }}
          </gl-badge>
        </template>
      </gl-tab>
    </gl-tabs>
  </div>
</template>
