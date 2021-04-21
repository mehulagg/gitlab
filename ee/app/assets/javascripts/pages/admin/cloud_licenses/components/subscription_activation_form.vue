<script>
import {
  GlAlert,
  GlButton,
  GlCard,
  GlForm,
  GlFormCheckbox,
  GlFormGroup,
  GlFormInput,
  GlLink,
  GlSprintf,
} from '@gitlab/ui';
import { subscriptionQueries } from '../constants';

export const SUBSCRIPTION_ACTIVATION_EVENT = 'subscription-activation';

export default {
  name: 'CloudLicenseSubscriptionActivationForm',
  components: {
    GlAlert,
    GlButton,
    GlCard,
    GlForm,
    GlFormGroup,
    GlFormInput,
    GlFormCheckbox,
    GlSprintf,
    GlLink,
  },
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
          mutation: subscriptionQueries.mutation,
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
            this.$emit(SUBSCRIPTION_ACTIVATION_EVENT, true);
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
  <gl-card body-class="gl-p-0">
    <template #header>
      <h5 class="gl-my-0 gl-font-weight-bold">{{ s__('CloudLicense|Activate subscription') }}</h5>
    </template>

    <div class="gl-p-5 gl-border-b-1 gl-border-gray-100 gl-border-b-solid">
      <gl-alert variant="danger" :title="s__('There is a connectivity issue')" :dismissible="false">
        <gl-sprintf
          :message="
            s__(
              'CloudLicense|To activate your subscription, connect to GitLab servers throught the %{linkStart}Cloud Sync service%{linkEnd}, a hassle-free way to manage your subuscription.',
            )
          "
        >
          <template #link="{ content }">
            <gl-link href="TODO" target="_blank" class="gl-text-decoration-none!">{{
              content
            }}</gl-link>
          </template>
        </gl-sprintf>
        <gl-sprintf
          :message="
            s__(
              'CloudLicense|Get help for the most common connectivity issues by %{linkStart}troublshooting the activation code%{linkEnd}.',
            )
          "
        >
          <template #link="{ content }">
            <gl-link href="TODO" target="_blank" class="gl-text-decoration-none!">
              {{ content }}
            </gl-link>
          </template>
        </gl-sprintf>
      </gl-alert>
    </div>
    <div class="gl-p-5">
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
                  <gl-link href="https://about.gitlab.com/terms/" target="_blank"
                    >{{ content }}
                  </gl-link>
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
    </div>
  </gl-card>
</template>
