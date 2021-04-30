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
import { helpPagePath } from '~/helpers/help_page_helper';
import validation from '~/vue_shared/directives/validation';
import {
  fieldRequiredMessage,
  subscriptionActivationForm,
  subscriptionQueries,
} from '../constants';

export const SUBSCRIPTION_ACTIVATION_EVENT = 'subscription-activation';
export const adminLicenseUrl = helpPagePath('/user/admin_area/license');

export default {
  i18n: {
    title: subscriptionActivationForm.title,
    howToActivateSubscription: subscriptionActivationForm.howToActivateSubscription,
    activationCode: subscriptionActivationForm.activationCode,
    pasteActivationCode: subscriptionActivationForm.pasteActivationCode,
    acceptTerms: subscriptionActivationForm.acceptTerms,
    activateLabel: subscriptionActivationForm.activateLabel,
    fieldRequiredMessage,
  },
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
  links: {
    adminLicenseUrl,
  },
  directives: {
    validation: validation(),
  },
  data() {
    const form = {
      state: false,
      showValidation: false,
      fields: {
        activationCode: {
          required: true,
          state: null,
          value: '',
        },
        terms: {
          required: true,
          state: null,
        },
      },
    };
    return {
      form,
      isLoading: false,
    };
  },
  computed: {
    isCheckboxValid() {
      if (this.form.showValidation) {
        return this.form.fields.terms.state ? null : false;
      }
      return null;
    },
    isRequestingActivation() {
      return this.isLoading;
    },
  },
  methods: {
    submit() {
      if (!this.form.state) {
        this.form.showValidation = true;
        return;
      }
      this.form.showValidation = false;
      this.isLoading = true;
      this.$apollo
        .mutate({
          mutation: subscriptionQueries.mutation,
          variables: {
            gitlabSubscriptionActivateInput: {
              activationCode: this.form.fields.activationCode.value,
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
  <gl-card>
    <template #header>
      <h5 class="gl-my-0 gl-font-weight-bold">{{ $options.i18n.title }}</h5>
    </template>
    <p>
      <gl-sprintf :message="$options.i18n.howToActivateSubscription">
        <template #link="{ content }">
          <gl-link :href="$options.links.adminLicenseUrl" target="_blank">{{ content }}</gl-link>
        </template>
      </gl-sprintf>
    </p>
    <gl-form novalidate @submit.prevent="submit">
      <div class="gl-display-flex gl-flex-wrap">
        <gl-form-group
          class="gl-flex-grow-1"
          :invalid-feedback="form.fields.activationCode.feedback"
          data-testid="form-group-activation-code"
        >
          <label class="gl-w-full" for="activation-code-group">
            {{ $options.i18n.activationCode }}
          </label>
          <gl-form-input
            id="activation-code-group"
            v-model="form.fields.activationCode.value"
            v-validation:[form.showValidation]
            :disabled="isLoading"
            :placeholder="$options.i18n.pasteActivationCode"
            :state="form.fields.activationCode.state"
            name="activationCode"
            class="gl-mb-4"
            required
          />
        </gl-form-group>

        <gl-form-group
          class="gl-mb-0"
          :state="isCheckboxValid"
          :invalid-feedback="$options.i18n.fieldRequiredMessage"
          data-testid="form-group-terms"
        >
          <gl-form-checkbox v-model="form.fields.terms.state" :state="isCheckboxValid">
            <gl-sprintf :message="$options.i18n.acceptTerms">
              <template #link="{ content }">
                <gl-link href="https://about.gitlab.com/terms/" target="_blank"
                  >{{ content }}
                </gl-link>
              </template>
            </gl-sprintf>
          </gl-form-checkbox>
        </gl-form-group>

        <gl-button
          :loading="isRequestingActivation"
          category="primary"
          class="gl-mt-6 js-no-auto-disable"
          data-testid="activate-button"
          type="submit"
          variant="confirm"
        >
          {{ $options.i18n.activateLabel }}
        </gl-button>
      </div>
    </gl-form>
  </gl-card>
</template>
