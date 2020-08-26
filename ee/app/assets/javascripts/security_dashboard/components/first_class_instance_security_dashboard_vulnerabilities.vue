<script>
import { GlAlert, GlButton, GlIntersectionObserver, GlLoadingIcon } from '@gitlab/ui';
import { fetchPolicies } from '~/lib/graphql';
import VulnerabilityList from './vulnerability_list.vue';
import vulnerabilitiesQuery from '../graphql/instance_vulnerabilities.graphql';
import { VULNERABILITIES_PER_PAGE } from '../store/constants';
import { preparePageInfo } from '../helpers';

export default {
  components: {
    GlAlert,
    GlButton,
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
    };
  },
  computed: {
    isQueryLoading() {
      return this.$apollo.queries.vulnerabilities.loading;
    },
  },
  apollo: {
    vulnerabilities: {
      query: vulnerabilitiesQuery,
      fetchPolicy: fetchPolicies.NETWORK_ONLY,
      variables() {
        return {
          first: VULNERABILITIES_PER_PAGE,
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
            fetchMoreResult.vulnerabilities.nodes.unshift(...previousResult.vulnerabilities.nodes);
            return fetchMoreResult;
          },
        });
      }
    },
  },

  emits: [],
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
    />
    <gl-intersection-observer
      v-if="pageInfo.hasNextPage"
      class="text-center"
      @appear="fetchNextPage"
    >
      <gl-button :disabled="isFirstResultLoading" @click="fetchNextPage">
        <gl-loading-icon v-if="isQueryLoading" size="md" />
        <template v-else>{{ s__('SecurityReports|Load more vulnerabilities') }}</template>
      </gl-button>
    </gl-intersection-observer>
  </div>
</template>
