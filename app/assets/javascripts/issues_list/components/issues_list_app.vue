<script>
import { toNumber } from 'lodash';
import createFlash from '~/flash';
import IssuableList from '~/issuable_list/components/issuable_list_root.vue';
import { PAGE_SIZE } from '~/issues_list/constants';
import axios from '~/lib/utils/axios_utils';
import { convertObjectPropsToCamelCase, getParameterByName } from '~/lib/utils/common_utils';
import { __ } from '~/locale';

export default {
  PAGE_SIZE,
  components: {
    IssuableList,
  },
  props: {
    endpoint: {
      type: String,
      required: true,
    },
    fullPath: {
      type: String,
      required: true,
    },
  },
  data() {
    return {
      currentPage: toNumber(getParameterByName('page')) || 1,
      isLoading: false,
      issues: [],
      totalIssues: 0,
    };
  },
  computed: {
    urlParams() {
      return {
        page: this.currentPage,
        state: 'opened',
      };
    },
  },
  mounted() {
    this.fetchIssues();
  },
  methods: {
    fetchIssues(pageToFetch) {
      this.isLoading = true;

      return axios
        .get(this.endpoint, {
          params: {
            page: pageToFetch || this.currentPage,
            per_page: this.$options.PAGE_SIZE,
            state: 'opened',
            with_labels_details: true,
          },
        })
        .then(({ data, headers }) => {
          this.currentPage = Number(headers['x-page']);
          this.totalIssues = Number(headers['x-total']);
          this.issues = data.map((issue) => convertObjectPropsToCamelCase(issue, { deep: true }));
        })
        .catch(() => {
          createFlash({ message: __('An error occurred while loading issues') });
        })
        .finally(() => {
          this.isLoading = false;
        });
    },
    handlePageChange(page) {
      this.fetchIssues(page);
    },
  },
};
</script>

<template>
  <div>
    <issuable-list
      :namespace="fullPath"
      recent-searches-storage-key="issues"
      :search-input-placeholder="__('Search or filter results…')"
      :search-tokens="[]"
      :sort-options="[]"
      :issuables="issues"
      :tabs="[]"
      current-tab=""
      :issuables-loading="isLoading"
      :show-pagination-controls="true"
      :total-items="totalIssues"
      :current-page="currentPage"
      :previous-page="currentPage - 1"
      :next-page="currentPage + 1"
      :url-params="urlParams"
      @page-change="handlePageChange"
    />
  </div>
</template>
