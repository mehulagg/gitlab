<script>
import dismissUserCallout from '~/graphql_shared/mutations/dismiss_user_callout.mutation.graphql';
import getUserCallouts from '~/pipelines/graphql/queries/get_user_callouts.query.graphql';

export default {
  props: {
    featureName: {
      type: String,
      required: true,
    },
  },
  data() {
    return {
      callouts: [],
      localIsDismissed: false,
      mutationIsLoading: false,
    };
  },
  apollo: {
    callouts: {
      query: getUserCallouts,
      update(data) {
        return data?.currentUser?.callouts?.nodes.map(({ featureName }) => featureName);
      },
      error(err) {
        console.error(err);
      },
    },
  },
  computed: {
    loading() {
      return this.$apollo.queries.callouts.loading || this.mutationIsLoading;
    },
    slotProps() {
      return {
        loading: this.loading,
        dismiss: this.dismiss,
      };
    },
    showCallout() {
      return !this.localIsDismissed && !this.callouts.includes(this.featureName);
    },
  },
  methods: {
    async dismiss() {
      this.mutationIsLoading = true;
      this.localIsDismissed = true;

      try {
        await this.$apollo.mutate({
          mutation: dismissUserCallout,
          variables: {
            input: {
              featureName: this.featureName,
            },
          },
        });
      } catch (err) {
        console.error(err);
      } finally {
        this.mutationIsLoading = false;
      }
    },
  },
  render() {
    return this.showCallout ? this.$scopedSlots.default(this.slotProps) : null;
  },
};
</script>
