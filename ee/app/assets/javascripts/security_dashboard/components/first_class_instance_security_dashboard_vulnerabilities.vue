<script>
import produce from 'immer';
import { GlAlert, GlIntersectionObserver, GlLoadingIcon } from '@gitlab/ui';
import { fetchPolicies } from '~/lib/graphql';
import VulnerabilityList from './vulnerability_list.vue';
import vulnerabilitiesQuery from '../graphql/queries/instance_vulnerabilities.query.graphql';
import { VULNERABILITIES_PER_PAGE } from '../store/constants';
import { preparePageInfo } from '../helpers';

export default {
  components: {
    GlAlert,
    GlIntersectionObserver,
    GlLoadingIcon,
    VulnerabilityList,
  },
  props: {
    filters: {
      type: Object,
      required: false,
      default: () => ({}),
    },
  },
  data() {
    return {
      pageInfo: {},
      isFirstResultLoading: true,
      vulnerabilities: [],
      errorLoadingVulnerabilities: false,
      sortBy: 'severity',
      sortDirection: 'desc',
    };
  },
  computed: {
    isLoadingQuery() {
      return this.$apollo.queries.vulnerabilities.loading;
    },
    sort() {
      return `${this.sortBy}_${this.sortDirection}`;
    },
  },
  apollo: {
    vulnerabilities: {
      query: vulnerabilitiesQuery,
      fetchPolicy: fetchPolicies.NETWORK_ONLY,
      variables() {
        return {
          first: VULNERABILITIES_PER_PAGE,
          sort: this.sort,
          ...this.filters,
        };
      },
      update: ({ vulnerabilities }) => vulnerabilities.nodes,
      result({ data, loading }) {
        this.isFirstResultLoading = loading;
        this.pageInfo = preparePageInfo(data?.vulnerabilities?.pageInfo);
      },
      error() {
        this.errorLoadingVulnerabilities = true;
      },
    },
  },
  methods: {
    onErrorDismiss() {
      this.errorLoadingVulnerabilities = false;
    },
    fetchNextPage() {
      if (this.pageInfo.hasNextPage) {
        this.$apollo.queries.vulnerabilities.fetchMore({
          variables: { after: this.pageInfo.endCursor },
          updateQuery: (previousResult, { fetchMoreResult }) => {
            const results = produce(fetchMoreResult, (draftData) => {
              // eslint-disable-next-line no-param-reassign
              draftData.vulnerabilities.nodes = [
                ...previousResult.vulnerabilities.nodes,
                ...draftData.vulnerabilities.nodes,
              ];
            });
            return results;
          },
        });
      }
    },
    handleSortChange({ sortBy, sortDesc }) {
      this.sortDirection = sortDesc ? 'desc' : 'asc';
      this.sortBy = sortBy;
    },
  },
};
</script>

<template>
  <div>
    <gl-alert
      v-if="errorLoadingVulnerabilities"
      class="mb-4"
      variant="danger"
      @dismiss="onErrorDismiss"
    >
      {{
        s__(
          'SecurityReports|Error fetching the vulnerability list. Please check your network connection and try again.',
        )
      }}
    </gl-alert>
    <vulnerability-list
      v-else
      :filters="filters"
      :is-loading="isFirstResultLoading"
      :vulnerabilities="vulnerabilities"
      should-show-project-namespace
      @sort-changed="handleSortChange"
    />
    <gl-intersection-observer
      v-if="pageInfo.hasNextPage"
      class="text-center"
      @appear="fetchNextPage"
    >
      <gl-loading-icon v-if="isLoadingQuery" size="md" />
    </gl-intersection-observer>
  </div>
</template>
