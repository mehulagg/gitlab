<script>
import { GlAlert, GlFormGroup, GlFormInput } from '@gitlab/ui';
import { mapState, mapGetters, mapActions } from 'vuex';
import { sprintf, s__ } from '~/locale';
import Step from './step.vue';

export default {
  name: 'AddonPurchase',
  components: {
    GlAlert,
    GlFormGroup,
    GlFormInput,
    Step,
  },
  computed: {
    ...mapState(['numberOfPacks']),
    alertText() {
      return this.selectedPlan === '';
    },
    isValid() {
      return true;
    },
  },
  i18n: {
    stepTitle: s__('Checkout|Purchase details'),
    nextStepButtonText: s__('Checkout|Continue to billing'),
    ciMinutesAlertText: s__(
      "Checkout|CI Minute packs are only used after you've used your subscription's montly quota. The additional minutes will roll over month to month and are valid for one year.",
    ),
    numberOfUsersLabel: s__('Checkout|CI Minute Packs'),
    ciMinutePackName: s__('Checkout|CI Minute Packs'),
  },
};
</script>

<template>
  <step
    step="purchaseDetails"
    :title="$options.i18n.stepTitle"
    :is-valid="isValid"
    :next-step-button-text="$options.i18n.nextStepButtonText"
  >
    <template #body>
      <gl-alert :dismissible="false" variant="info" class="gl-mb-5">
        {{ $options.i18n.ciMinutesAlertText }}
      </gl-alert>
      <gl-form-group :label="$options.i18n.numberOfUsersLabel" label-size="sm" class="number">
        <gl-form-input
          ref="number-of-packs"
          v-model.number="numberOfPacks"
          type="number"
          :min="1"
        />
      </gl-form-group>
    </template>
    <template #summary>
      <strong ref="summary-line-1">
        {{ selectedPlanTextLine }}
      </strong>
      <div v-if="isSetupForCompany" ref="summary-line-2">
        {{ $options.i18n.group }}: {{ organizationName || selectedGroupName }}
      </div>
      <div ref="summary-line-3" class="gl-font-weight-bold">{{ numberOfAddons }} {{ $options.i18n.ciMinutePackName }}</div>
    </template>
  </step>
</template>
