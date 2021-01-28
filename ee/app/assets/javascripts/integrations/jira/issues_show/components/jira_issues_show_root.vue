<script>
import { fetchIssue } from 'ee/integrations/jira/issues_show/api';

export default {
  name: 'JiraIssuesShow',
  inject: {
    issuesShowPath: {
      default: '',
    },
  },
  data() {
    return {
      issue: {},
    };
  },
  async mounted() {
    this.issue = await fetchIssue(this.issuesShowPath);
  },
};
</script>

<template>
  <div></div>
</template>
