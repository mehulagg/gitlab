<script>
import { GlButton, GlFormSelect } from '@gitlab/ui';
import { s__, n__ } from '~/locale';
import toast from '~/vue_shared/plugins/global_toast';
import createFlash from '~/flash';
import vulnerabilityDismiss from '../graphql/mutations/vulnerability_dismiss.mutation.graphql';

const REASON_NONE = s__('SecurityReports|[No reason]');
const REASON_WONT_FIX = s__("SecurityReports|Won't fix / Accept risk");
const REASON_FALSE_POSITIVE = s__('SecurityReports|False positive');

export default {
  name: 'SelectionSummary',
  components: {
    GlButton,
    GlFormSelect,
  },
  props: {
    selectedVulnerabilities: {
      type: Array,
      required: true,
    },
  },
  data() {
    return {
      dismissalReason: null,
    };
  },
  computed: {
    selectedVulnerabilitiesCount() {
      return this.selectedVulnerabilities.length;
    },
    canDismissVulnerability() {
      return Boolean(this.dismissalReason && this.selectedVulnerabilitiesCount > 0);
    },
    message() {
      return n__(
        'Dismiss %d selected vulnerability as',
        'Dismiss %d selected vulnerabilities as',
        this.selectedVulnerabilitiesCount,
      );
    },
  },
  methods: {
    handleDismiss() {
      if (!this.canDismissVulnerability) return;

      this.dismissSelectedVulnerabilities();
    },
    dismissSelectedVulnerabilities() {
      let fulfilledCount = 0;
      let rejectedCount = 0;

      const promises = this.selectedVulnerabilities.map((vulnerability) =>
        this.$apollo
          .mutate({
            mutation: vulnerabilityDismiss,
            variables: { id: vulnerability.id, comment: this.dismissalReason },
          })
          .then(() => {
            fulfilledCount += 1;
            this.$emit('vulnerability-updated', vulnerability.id);
          })
          .catch(() => {
            rejectedCount += 1;
          }),
      );

      Promise.all(promises)
        .then(() => {
          if (fulfilledCount > 0) {
            toast(
              n__('%d vulnerability dismissed', '%d vulnerabilities dismissed', fulfilledCount),
            );
          }

          if (rejectedCount > 0) {
            createFlash({
              message: n__(
                'SecurityReports|There was an error dismissing %d vulnerability. Please try again later.',
                'SecurityReports|There was an error dismissing %d vulnerabilities. Please try again later.',
                rejectedCount,
              ),
            });
          }
        })
        .catch(() => {
          createFlash({
            message: s__('SecurityReports|There was an error dismissing the vulnerabilities.'),
          });
        });
    },
  },
  dismissalReasons: [
    { value: null, text: s__('SecurityReports|Select a reason') },
    REASON_FALSE_POSITIVE,
    REASON_WONT_FIX,
    REASON_NONE,
  ],
};
</script>

<template>
  <div class="card">
    <form class="card-body d-flex align-items-center" @submit.prevent="handleDismiss">
      <span data-testid="dismiss-message">{{ message }}</span>
      <gl-form-select
        v-model="dismissalReason"
        class="mx-3 w-auto"
        :options="$options.dismissalReasons"
      />
      <gl-button
        type="submit"
        class="js-no-auto-disable"
        category="secondary"
        variant="warning"
        :disabled="!canDismissVulnerability"
      >
        {{ s__('SecurityReports|Dismiss Selected') }}
      </gl-button>
    </form>
  </div>
</template>
