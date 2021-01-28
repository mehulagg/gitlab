<script>
import { fetchIssue } from 'ee/integrations/jira/issues_show/api';
import IssuableShow from '~/issuable_show/components/issuable_show_root.vue';

import { convertObjectPropsToCamelCase } from '~/lib/utils/common_utils';

export default {
  name: 'JiraIssuesShow',
  components: {
    IssuableShow,
  },
  inject: {
    issuesShowPath: {
      default: '',
    },
  },
  data() {
    return {
      isLoading: true,
      issue: {},
    };
  },
  async mounted() {
    this.issue = convertObjectPropsToCamelCase(await fetchIssue(this.issuesShowPath), {
      deep: true,
    });
    this.isLoading = false;
  },
};
</script>

<template>
  <div>
    <issuable-show v-if="!isLoading" :issuable="issue" :enable-edit="false"></issuable-show>
  </div>
</template>
