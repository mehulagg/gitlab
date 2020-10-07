import { n__, __ } from '~/locale';
import issuesCollapsedQuery from '../queries/issues_collapsed.query.graphql';
import issuesQuery from '../queries/issues.query.graphql';

export default {
  name: 'WidgetIssues',
  props: ['targetProjectFullPath'],
  computed: {
    summary(count) {
      return n__('%d open issue', '%d open issues', count);
    },
    statusIcon(count) {
      return count > 0 ? 'warning' : 'success';
    },
  },
  methods: {
    fetchCollapsedData({ targetProjectFullPath }) {
      return this.$apollo
        .query({ query: issuesCollapsedQuery, variables: { projectPath: targetProjectFullPath } })
        .then(({ data }) => data.project.issues.count);
    },
    fetchFullData({ targetProjectFullPath }) {
      return this.$apollo
        .query({ query: issuesQuery, variables: { projectPath: targetProjectFullPath } })
        .then(({ data }) =>
          data.project.issues.nodes.map(issue => ({
            id: issue.id,
            text: issue.title,
            icon: {
              name:
                issue.state === 'closed' ? 'status_failed_borderless' : 'status_success_borderless',
              class: issue.state === 'closed' ? 'text-danger' : 'text-success',
            },
            badge: issue.state === 'closed' && {
              text: __('Closed'),
            },
          })),
        );
    },
  },
};
