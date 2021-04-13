<script>
import {
  GlButton,
  GlCard,
  GlForm,
  GlFormCheckbox,
  GlFormGroup,
  GlFormInput,
  GlLink,
  GlSprintf,
} from '@gitlab/ui';
import activateSubscriptionMutation from 'ee/pages/admin/cloud_licenses/graphql/mutations/activate_subscription.mutation.graphql';

export const SUBSCRIPTION_ACTIVATION_EVENT = 'subscription-activation';

export default {
  name: 'CloudLicenseSubscriptionActivationForm',
  components: {
    GlButton,
    GlCard,
    GlForm,
    GlFormGroup,
    GlFormInput,
    GlFormCheckbox,
    GlSprintf,
    GlLink,
  },
  inject: ['freeTrialPath', 'buySubscriptionPath'],
  data() {
    return {
      activationCode: null,
      isLoading: false,
      termsAccepted: false,
    };
  },
  computed: {
    activateButtonDisabled() {
      return this.isLoading || !this.termsAccepted;
    },
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
  <div>
    <gl-card>
      <template #header>
        <h5 class="gl-my-0 gl-font-weight-bold">{{ s__('CloudLicense|Activate subscription') }}</h5>
      </template>

      <p>
        <gl-sprintf
          :message="
            s__('CloudLicense|Learn how to %{linkStart}activate your subscription%{linkEnd}.')
          "
        >
          <template #link="{ content }">
            <gl-link href="" target="_blank">{{ content }}</gl-link>
          </template>
        </gl-sprintf>
      </p>
      <gl-form @submit.stop.prevent="submit">
        <gl-form-group class="gl-mb-0">
          <div class="gl-display-flex gl-flex-wrap">
            <label class="gl-w-full" for="activation-code-group">
              {{ s__('CloudLicense|Activation code') }}
            </label>
            <gl-form-input
              id="activation-code-group"
              v-model="activationCode"
              :disabled="isLoading"
              :placeholder="s__('CloudLicense|Paste your activation code')"
              class="gl-w-full gl-mb-4"
              required
            />

            <gl-form-checkbox v-model="termsAccepted">
              <gl-sprintf
                :message="
                  s__(
                    'CloudLicense|I agree that my use of the GitLab Software is subject to the Subscription Agreement located at the %{linkStart}Terms of Service%{linkEnd}, unless otherwise agreed to in writing with GitLab.',
                  )
                "
              >
                <template #link="{ content }">
                  <gl-link href="https://about.gitlab.com/terms/" target="_blank">{{
                    content
                  }}</gl-link>
                </template>
              </gl-sprintf>
            </gl-form-checkbox>

            <gl-button
              :disabled="activateButtonDisabled"
              category="primary"
              class="gl-mt-6"
              data-testid="activate-button"
              type="submit"
              variant="confirm"
            >
              {{ s__('CloudLicense|Activate') }}
            </gl-button>
          </div>
        </gl-form-group>
      </gl-form>
    </gl-card>

    <div class="row gl-mt-7">
      <div class="col-lg-6">
        <gl-card>
          <template #header>
            <h5 class="gl-my-0 gl-font-weight-bold">{{ s__('CloudLicense|Free trial') }}</h5>
          </template>
          <p>
            {{
              s__(
                'CloudLicense|You can start a free trial of GitLab Ultimate without any obligation or payment details.',
              )
            }}
          </p>
          <gl-button
            category="secondary"
            class="gl-mt-6"
            data-testid="free-trial-button"
            variant="confirm"
            :href="freeTrialPath"
          >
            {{ s__('CloudLicense|Start free trial') }}
          </gl-button>
        </gl-card>
      </div>
      <div class="col-lg-6">
        <gl-card>
          <template #header>
            <h5 class="gl-my-0 gl-font-weight-bold">{{ s__('CloudLicense|Subscription') }}</h5>
          </template>
          <p>
            {{
              s__(
                'CloudLicense|Ready to get started? A GitLab plan is ideal for scaling organizations and for multi team usage.',
              )
            }}
          </p>
          <gl-button
            category="secondary"
            class="gl-mt-6"
            data-testid="buy-subscription-button"
            variant="confirm"
            :href="buySubscriptionPath"
          >
            {{ s__('CloudLicense|Buy subscription') }}
          </gl-button>
        </gl-card>
      </div>
    </div>
  </div>
</template>
