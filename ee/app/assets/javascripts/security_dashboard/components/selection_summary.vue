<script>
import { GlButton, GlFormSelect } from '@gitlab/ui';
import { s__, n__ } from '~/locale';
import toast from '~/vue_shared/plugins/global_toast';
import { deprecatedCreateFlash as createFlash } from '~/flash';
import vulnerabilityDismiss from '../graphql/vulnerability_dismiss.mutation.graphql';
import { REFETCH_QUERIES } from '../store/constants';

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
      const promises = this.selectedVulnerabilities.map(vulnerability =>
        this.$apollo
          .mutate({
            mutation: vulnerabilityDismiss,
            variables: { id: vulnerability.id, comment: this.dismissalReason },
            refetchQueries: REFETCH_QUERIES,
          })
          .then(() => 'fulfilled')
          .catch(() => 'rejected'),
      );

      return Promise.all(promises).then(statuses => {
        let fulfilled = 0;
        let rejected = 0;

        statuses.forEach(promise => {
          if (promise === 'fulfilled') {
            fulfilled += 1;
          } else {
            rejected += 1;
          }
        });

        if (fulfilled > 0) {
          toast(n__('%d vulnerability dismissed', '%d vulnerabilities dismissed', fulfilled));
        }

        if (rejected > 0) {
          createFlash(
            n__(
              'SecurityReports|There was an error dismissing %d vulnerability. Please try again later.',
              'SecurityReports|There was an error dismissing %d vulnerabilities. Please try again later.',
              rejected,
            ),
            'alert',
          );
        }
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
      <span ref="dismiss-message">{{ message }}</span>
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
