<script>
import { GlAlert, GlButton, GlIntersectionObserver } from '@gitlab/ui';
import VulnerabilityList from './vulnerability_list.vue';
import vulnerabilitiesQuery from '../graphql/group_vulnerabilities.graphql';
import { VULNERABILITIES_PER_PAGE } from '../store/constants';
import { preparePageInfo } from '../helpers';

export default {
  components: {
    GlAlert,
    GlButton,
    GlIntersectionObserver,
    VulnerabilityList,
  },
  props: {
    groupFullPath: {
      type: String,
      required: true,
    },
    filters: {
      type: Object,
      required: false,
      default: () => ({}),
    },
  },
  data() {
    return {
      pageInfo: {},
      vulnerabilities: [],
      errorLoadingVulnerabilities: false,
    };
  },
  apollo: {
    vulnerabilities: {
      query: vulnerabilitiesQuery,
      variables() {
        return {
          fullPath: this.groupFullPath,
          first: VULNERABILITIES_PER_PAGE,
          ...this.filters,
        };
      },
      update: ({ group }) => group.vulnerabilities.nodes,
      result({ data }) {
        this.pageInfo = preparePageInfo(data?.group?.vulnerabilities?.pageInfo);
      },
      error() {
        this.errorLoadingVulnerabilities = true;
      },
    },
  },
  computed: {
    isLoadingQuery() {
      return this.$apollo.queries.vulnerabilities.loading;
    },
    isLoadingFirstResult() {
      return this.isLoadingQuery && this.vulnerabilities.length === 0;
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
            fetchMoreResult.group.vulnerabilities.nodes.unshift(
              ...previousResult.group.vulnerabilities.nodes,
            );
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
      :is-loading="isLoadingFirstResult"
      :vulnerabilities="vulnerabilities"
      should-show-project-namespace
    />
    <gl-intersection-observer
      v-if="pageInfo.hasNextPage"
      class="text-center"
      @appear="fetchNextPage"
    >
      <gl-button :loading="isLoadingQuery" :disabled="isLoadingQuery" @click="fetchNextPage">{{
        s__('SecurityReports|Load more vulnerabilities')
      }}</gl-button>
    </gl-intersection-observer>
  </div>
</template>
