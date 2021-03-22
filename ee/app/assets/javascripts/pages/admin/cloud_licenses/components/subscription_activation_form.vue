<script>
import { GlButton, GlForm, GlFormGroup, GlFormInput } from '@gitlab/ui';
import activateSubscriptionMutation from 'ee/pages/admin/cloud_licenses/graphql/mutations/activate_subscription.mutation.graphql';

export const SUBSCRIPTION_ACTIVATION_EVENT = 'subscription-activation';

export default {
  name: 'CloudLicenseSubscriptionActivationForm',
  components: {
    GlButton,
    GlForm,
    GlFormGroup,
    GlFormInput,
  },
  data() {
    return {
      activationCode: null,
      isLoading: false,
    };
  },
  methods: {
    submit() {
      this.isLoading = true;
      this.$apollo
        .mutate({
          mutation: activateSubscriptionMutation,
          variables: {
            gitlabSubscriptionActivateInput: {
              activationCode: this.activationCode,
            },
          },
        })
        .then(
          ({
            data: {
              gitlabSubscriptionActivate: { errors },
            },
          }) => {
            if (errors.length) {
              throw new Error();
            }
            this.$emit(SUBSCRIPTION_ACTIVATION_EVENT, this.activationCode);
          },
        )
        .catch(() => {
          this.$emit(SUBSCRIPTION_ACTIVATION_EVENT, null);
        })
        .finally(() => {
          this.isLoading = false;
        });
    },
  },
};
</script>
<template>
  <gl-form @submit.stop.prevent="submit">
    <gl-form-group>
      <div class="gl-display-flex gl-flex-wrap gl-justify-content-center">
        <label class="gl-text-center gl-w-full" for="activation-code-group">
          {{ s__('CloudLicense|Paste your activation code below') }}
        </label>
        <gl-form-input
          id="activation-code-group"
          v-model="activationCode"
          :disabled="isLoading"
          :placeholder="s__('CloudLicense|Paste your activation code')"
          class="gl-mr-3"
          required
          size="xl"
        />
        <gl-button
          :disabled="isLoading"
          category="primary"
          class="gl-align-self-end"
          data-testid="activate-button"
          type="submit"
          variant="confirm"
        >
          {{ s__('CloudLicense|Activate') }}
        </gl-button>
      </div>
    </gl-form-group>
  </gl-form>
</template>
