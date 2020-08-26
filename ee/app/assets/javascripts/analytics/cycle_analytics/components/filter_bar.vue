<script>
import { mapState, mapActions } from 'vuex';
import { __ } from '~/locale';
import FilteredSearchBar from '~/vue_shared/components/filtered_search_bar/filtered_search_bar_root.vue';
import MilestoneToken from '~/vue_shared/components/filtered_search_bar/tokens/milestone_token.vue';
import LabelToken from '~/vue_shared/components/filtered_search_bar/tokens/label_token.vue';
import AuthorToken from '~/vue_shared/components/filtered_search_bar/tokens/author_token.vue';

export const prepareTokens = ({
  milestone = null,
  author = null,
  assignees = [],
  labels = [],
} = {}) => {
  const authorToken = author ? [{ type: 'author', value: { data: author } }] : [];
  const milestoneToken = milestone ? [{ type: 'milestone', value: { data: milestone } }] : [];
  const assigneeTokens = assignees?.length
    ? assignees.map(data => ({ type: 'assignees', value: { data } }))
    : [];
  const labelTokens = labels?.length
    ? labels.map(data => ({ type: 'labels', value: { data } }))
    : [];

  return [...authorToken, ...milestoneToken, ...assigneeTokens, ...labelTokens];
};

export default {
  name: 'FilterBar',
  components: {
    FilteredSearchBar,
  },
  props: {
    groupPath: {
      type: String,
      required: true,
    },
  },
  computed: {
    ...mapState('filters', {
      milestones: state => state.milestones.data,
      labels: state => state.labels.data,
      authors: state => state.authors.data,
      assignees: state => state.assignees.data,
      initialTokens: state => state.initialTokens,
    }),
    tokens() {
      return [
        {
          icon: 'clock',
          title: __('Milestone'),
          type: 'milestone',
          token: MilestoneToken,
          initialMilestones: this.milestones,
          unique: true,
          symbol: '%',
          operators: [{ value: '=', description: 'is', default: 'true' }],
          fetchMilestones: this.fetchMilestones,
        },
        {
          icon: 'labels',
          title: __('Label'),
          type: 'labels',
          token: LabelToken,
          initialLabels: this.labels,
          unique: false,
          symbol: '~',
          operators: [{ value: '=', description: 'is', default: 'true' }],
          fetchLabels: this.fetchLabels,
        },
        {
          icon: 'pencil',
          title: __('Author'),
          type: 'author',
          token: AuthorToken,
          initialAuthors: this.authors,
          unique: true,
          operators: [{ value: '=', description: 'is', default: 'true' }],
          fetchAuthors: this.fetchAuthors,
        },
        {
          icon: 'user',
          title: __('Assignees'),
          type: 'assignees',
          token: AuthorToken,
          initialAuthors: this.assignees,
          unique: false,
          operators: [{ value: '=', description: 'is', default: 'true' }],
          fetchAuthors: this.fetchAssignees,
        },
      ];
    },
  },
  methods: {
    ...mapActions('filters', [
      'setFilters',
      'fetchMilestones',
      'fetchLabels',
      'fetchAuthors',
      'fetchAssignees',
    ]),
    initialFilterValue() {
      const {
        selectedMilestone: milestone = null,
        selectedAuthor: author = null,
        selectedAssignees: assignees = [],
        selectedLabels: labels = [],
      } = this.initialTokens;

      return prepareTokens({ milestone, author, assignees, labels });
    },
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
      const { labels, milestone, author, assignees } = this.processFilters(filters);

      this.setFilters({
        selectedAuthor: author ? author[0].value : null,
        selectedMilestone: milestone ? milestone[0].value : null,
        selectedAssignees: assignees ? assignees.map(a => a.value) : [],
        selectedLabels: labels ? labels.map(l => l.value) : [],
      });
    },
  },

  emits: [],
};
</script>

<template>
  <filtered-search-bar
    :namespace="groupPath"
    recent-searches-storage-key="value-stream-analytics"
    :search-input-placeholder="__('Filter results')"
    :tokens="tokens"
    :initial-filter-value="initialFilterValue()"
    @onFilter="handleFilter"
  />
</template>
