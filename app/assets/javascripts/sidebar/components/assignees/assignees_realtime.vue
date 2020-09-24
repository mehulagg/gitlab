<script>
import { getIdFromGraphQLId } from '~/graphql_shared/utils';
import query from '~/issuable_sidebar/subscriptions/issue_sidebar.subscription.graphql';

export default {
  name: 'AssigneesRealtime',
  props: {
    mediator: {
      type: Object,
      required: true,
    },
    issuableIid: {
      type: String,
      required: true,
    },
    projectPath: {
      type: String,
      required: true,
    },
  },
  apollo: {
    $subscribe: {
      issue: {
        query,
        variables() {
          return {
            projectPath: this.projectPath,
            iid: this.issuableIid,
          };
        },
        result(data) {
          this.handleFetchResult(data);
        },
      },
    },
  },
  methods: {
    handleFetchResult({ data }) {
      const { nodes } = data.issueUpdated.assignees;

      const assignees = nodes.map((n) => ({
        ...n,
        avatar_url: n.avatarUrl,
        id: getIdFromGraphQLId(n.id),
      }));

      this.mediator.store.setAssigneesFromRealtime(assignees);
    },
  },
  render() {
    return this.$slots.default;
  },
};
</script>
