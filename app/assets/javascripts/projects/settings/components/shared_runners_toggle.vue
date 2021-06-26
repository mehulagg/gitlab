<script>
import { GlAlert, GlToggle, GlTooltip } from '@gitlab/ui';
import axios from '~/lib/utils/axios_utils';
import { __ } from '~/locale';

const DEFAULT_ERROR_MESSAGE = __('An error occurred while updating the configuration.');

export default {
  components: {
    GlAlert,
    GlToggle,
    GlTooltip,
    CcValidationRequiredAlert: () =>
      import('ee_component/billings/components/cc_validation_required_alert.vue'),
  },
  props: {
    isDisabledAndUnoverridable: {
      type: Boolean,
      required: true,
    },
    isEnabled: {
      type: Boolean,
      required: true,
    },
    isCreditCardValidationRequired: {
      type: Boolean,
      required: false,
    },
    updatePath: {
      type: String,
      required: true,
    },
  },
  data() {
    return {
      isLoading: false,
      isSharedRunnerEnabled: false,
      errorMessage: null,
      isCcValidationRequired: false,
    };
  },
  created() {
    this.isSharedRunnerEnabled = this.isEnabled;
    this.isCcValidationRequired = this.isCreditCardValidationRequired;
  },
  methods: {
    creditCardValidated() {
      this.isCcValidationRequired = false;
    },
    toggleSharedRunners() {
      this.isLoading = true;
      this.errorMessage = null;

      axios
        .post(this.updatePath)
        .then(() => {
          this.isLoading = false;
          this.isSharedRunnerEnabled = !this.isSharedRunnerEnabled;
          this.isCcValidationRequired = this.isCreditCardValidationRequired;
        })
        .catch((error) => {
          this.isLoading = false;
          this.errorMessage = error.response?.data?.error || DEFAULT_ERROR_MESSAGE;
        });
    },
  },
};
</script>

<template>
  <div>
    <section class="gl-mt-5">
      <gl-alert v-if="errorMessage" class="gl-mb-3" variant="danger" :dismissible="false">
        {{ errorMessage }}
      </gl-alert>

      <div v-if="isCcValidationRequired && !isSharedRunnerEnabled">
        <cc-validation-required-alert class="gl-pb-5" @verifiedCreditCard="creditCardValidated" />
      </div>
      <div v-else ref="sharedRunnersToggle">
        <gl-toggle
          :disabled="isDisabledAndUnoverridable"
          :is-loading="isLoading"
          :label="__('Enable shared runners for this project')"
          :value="isSharedRunnerEnabled"
          data-testid="toggle-shared-runners"
          @change="toggleSharedRunners"
        />
      </div>

      <gl-tooltip v-if="isDisabledAndUnoverridable" :target="() => $refs.sharedRunnersToggle">
        {{ __('Shared runners are disabled on group level') }}
      </gl-tooltip>
    </section>
  </div>
</template>
