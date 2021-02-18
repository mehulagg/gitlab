<script>
import { convertToGraphQLId, getIdFromGraphQLId } from '~/graphql_shared/utils';
import query from '~/issuable_sidebar/subscriptions/assignees.subscription.graphql';
import { capitalizeFirstCharacter, convertToCamelCase } from '~/lib/utils/text_utility';

export default {
  name: 'AssigneesRealtime',
  props: {
    mediator: {
      type: Object,
      required: true,
    },
    issuableType: {
      type: String,
      required: true,
    },
    issuableId: {
      type: Number,
      required: true,
    },
  },
  computed: {
    issuableClass() {
      return capitalizeFirstCharacter(convertToCamelCase(this.issuableType));
    },
  },
  apollo: {
    $subscribe: {
      assignees: {
        query,
        variables() {
          return {
            issuableId: convertToGraphQLId(this.issuableClass, this.issuableId),
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
      if (data.issuableAssigneesUpdated !== null) {
        const assignees = data.issuableAssigneesUpdated.map((n) => ({
          ...n,
          avatar_url: n.avatarUrl,
          id: getIdFromGraphQLId(n.id),
        }));

        this.mediator.store.setAssigneesFromRealtime(assignees);
      }
    },
  },
  render() {
    return this.$slots.default;
  },
};
</script>
