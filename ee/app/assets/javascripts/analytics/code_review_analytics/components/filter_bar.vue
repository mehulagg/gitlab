<script>
import { mapState, mapActions } from 'vuex';
import FilteredSearchBar from '~/vue_shared/components/filtered_search_bar/filtered_search_bar_root.vue';
import { __ } from '~/locale';
import MilestoneToken from '../../shared/components/tokens/milestone_token.vue';
import LabelToken from '../../shared/components/tokens/label_token.vue';

export default {
  components: {
    FilteredSearchBar,
  },
  props: {
    projectPath: {
      type: String,
      required: true,
    },
  },
  data() {
    return {
      initialFilterValue: [],
    };
  },
  computed: {
    ...mapState('filters', {
      milestonePath: 'milestonePath',
      labelsPath: 'labelsPath',
      milestones: state => state.milestones.data,
      milestonesLoading: state => state.milestones.isLoading,
      labels: state => state.labels.data,
      labelsLoading: state => state.labels.isLoading,
    }),
    tokens() {
      return [
        {
          icon: 'clock',
          title: __('Milestone'),
          type: 'milestone',
          token: MilestoneToken,
          milestones: this.milestones,
          unique: true,
          symbol: '%',
          isLoading: this.milestonesLoading,
          fetchData: this.fetchMilestones,
        },
        {
          icon: 'labels',
          title: __('Label'),
          type: 'label',
          token: LabelToken,
          labels: this.labels,
          unique: false,
          symbol: '~',
          isLoading: this.labelsLoading,
          fetchData: this.fetchLabels,
        },
      ];
    },
  },
  created() {
    this.fetchMilestones();
    this.fetchLabels();
  },
  methods: {
    ...mapActions('filters', ['fetchMilestones', 'fetchLabels', 'setFilters']),
    processFilters(filters) {
      return filters.reduce((acc, token) => {
        const { type, value } = token;
        const { operator } = value;
        let tokenValue = value.data;

        // remove wrapping double quotes which were added for token values that include spaces
        if (
          (tokenValue[0] === "'" && tokenValue[tokenValue.length - 1] === "'") ||
          (tokenValue[0] === '"' && tokenValue[tokenValue.length - 1] === '"')
        ) {
          tokenValue = tokenValue.slice(1, -1);
        }

        if (!acc[type]) {
          acc[type] = [];
        }

        acc[type].push({ value: tokenValue, operator });
        return acc;
      }, {});
    },
    handleFilter(filters) {
      const { label: labelNames, milestone } = this.processFilters(filters);
      const milestoneTitle = milestone ? milestone[0] : null;
      this.setFilters({ labelNames, milestoneTitle });
    },
  },

  emits: [],
};
</script>

<template>
  <filtered-search-bar
    :namespace="projectPath"
    recent-searches-storage-key="code-review-analytics"
    :search-input-placeholder="__('Filter results')"
    :tokens="tokens"
    :initial-filter-value="initialFilterValue"
    class="row-content-block"
    @onFilter="handleFilter"
  />
</template>
